//
//  AddCourseViewController.swift
//  GradeCalculator
//
//  Created by Anderson David on 1/13/19.
//  Copyright © 2019 Anderson David. All rights reserved.
//

import UIKit
import TextFieldEffects

class AddCourseViewController: UIViewController {

    @IBOutlet weak var courseNameField: UITextField!
    @IBOutlet weak var creditHourField: UITextField!
    @IBOutlet weak var gradeSystemControl: UISegmentedControl!
    @IBOutlet weak var setWeightsButton: UIButton!
    @IBOutlet weak var chosenWeightsLabel: UILabel!
    
    var myCourses:[Course] = []
    var weights:[String:Double] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the Course array
        loadCourseArray()
        
        // starts with raw points selected, so no need to set weights
        setWeightsButton.isEnabled = false
        
        creditHourField.adjustsFontSizeToFitWidth = false
        
        // No Weights set, so don't show them
        chosenWeightsLabel.isHidden = true
        
    }
    
    // Used to load course array from user defaults at load
    func loadCourseArray() {
        if let data = UserDefaults.standard.value(forKey:"myCourses") as? Data {
            myCourses = try! PropertyListDecoder().decode(Array<Course>.self, from: data)
        } else {
            myCourses = []
        }
    }
    
    // used to save course array into user defaults
    func saveCourseArray(courseArray: [Course]) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(courseArray), forKey: "myCourses")
    }
    
    // MARK - START NAVIGATION METHODS:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Have added a course and want to return to home screen
        if (segue.identifier == "coursePageToHome") {
            
            // courseName and credits will have non-nil values due to validation methods
            let courseName = courseNameField.text
            let credits = Int(creditHourField.text!)!
            
            // create the course to add
            var toAdd = Course(name: courseName!, weights: ["All": 1.0], assignments: [], credits: credits)
            
            // if the user has set custom weights, use those instead of raw point system
            if (weights.count > 0) {
                toAdd.weights = weights
            }
            
            if let dest = segue.destination as? HomeScreenViewController {
                
                // append this course to the course array in the home screen
                dest.myCourses.append(toAdd)
                
                // save to user defaults the most recent course array
                saveCourseArray(courseArray: dest.myCourses)
                
                // coursesTableView will be reloaded at end of unwind segue
            }
        
        }
        
    }
    // MARK - END NAVIGATION METHODS
 
    // called when a user taps off a text field
    @IBAction func exitKeyboard(_ sender: Any) {
        view.endEditing(true)
    }

    // called when the user changes what is entered in the text fields
    @IBAction func checkInfo(_ sender: Any) {
        
        if let courseName = courseNameField.text, let _ = Int(creditHourField.text!) {  // make sure courseName is non-nil and creditField has a number
            
            // make sure courseName is not empty
            if (courseName.isEmpty) {  // if courseName is empty, don't allow saving
                navigationItem.rightBarButtonItem!.isEnabled = false
                return
            }
            
            // since each course name is unique, make sure name is unique
            let found = findCourse(courseName: courseName)
            if (found) {  // if there is already a course with that name, don't allow saving
                navigationItem.rightBarButtonItem!.isEnabled = false
                return
            }
            
            if gradeSystemControl.selectedSegmentIndex == 0 {  // if the user has raw points selected, ok to save
                navigationItem.rightBarButtonItem!.isEnabled = true
                return
            } else if gradeSystemControl.selectedSegmentIndex == 1 {  // if user has selected weighted, they have to have selected weights in order to save
                if chosenWeightsLabel.text != "Choose 'Set Weights' to set weights" {
                    navigationItem.rightBarButtonItem!.isEnabled = true
                    return
                } else {
                    navigationItem.rightBarButtonItem!.isEnabled = false
                    return
                }
            }
        
        }
    }
    
    // this function is used to ensure there are no two courses with the same name
    func findCourse(courseName: String) -> Bool {
        for entry in myCourses {
            if (entry.name == courseName) {
                return true
            }
        }
        return false
    }
    
    // called when the segmented control changes selected index
    @IBAction func checkWeighting(_ sender: Any) {
        if gradeSystemControl.selectedSegmentIndex == 0 {  // if the user changes to raw points
            
            // disable setting weights
            setWeightsButton.isEnabled = false
            
            // don't show weights
            chosenWeightsLabel.isHidden = true
            
            // set raw point system
            weights = ["All": 1.0]
            
            // see if save button can be enabled (make sure all fields are correctly filled)
            checkInfo(self)
        } else { // if the user changes to weighted
            
            // allow user to go set weights
            setWeightsButton.isEnabled = true
            
            // reset weights to empty array
            weights = [:]
            
            // since weights is empty, prompt user to set weights
            chosenWeightsLabel.text = "Choose 'Set Weights' to set weights"
            chosenWeightsLabel.isHidden = false
            
            // don't allow saving because no weights
            navigationItem.rightBarButtonItem!.isEnabled = false
        }
    }
    
    // called when the user has successfully added weights and is now returning to the add course page
    @IBAction func unwindToAddPage(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        
        //display the chosen weights
        displayWeights()
        chosenWeightsLabel.isHidden = false
        
        // check that all other fields are correctly filled and check if user is ready to save the course
        checkInfo(self)
    }
    
    // used to display the weights that the user has chosen
    func displayWeights() {
        if (weights.count == 0) {
            chosenWeightsLabel.text = "Choose 'Set Weights' to set weights"
        } else {
            var weightsString = ""
            
            for key in weights.keys {
                let percentage = String(format: "%.1f", weights[key]! * 100.0)
                weightsString += "\(key) - \(percentage)%   "
            }
            
            chosenWeightsLabel.text = weightsString
        }
    }
}
