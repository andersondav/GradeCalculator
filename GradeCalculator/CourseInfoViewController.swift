//
//  CourseInfoViewController.swift
//  GradeCalculator
//
//  Created by Anderson David on 2/6/19.
//  Copyright © 2019 Anderson David. All rights reserved.
//

import UIKit

class CourseInfoViewController: UIViewController {

    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var creditHourField: UITextField!
    @IBOutlet weak var weightsLabel: UILabel!
    
    var myCourses = [Course]()
    var courseIndex:Int = -1
    var percentGrade:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // if the courseIndex is in bounds
        if (courseIndex > -1) {
            let course = myCourses[courseIndex]

            // set grade label and credit hour field
            gradeLabel.text = percentGrade
            creditHourField.text = String(course.credits)
            
            // display the weights the course has
            displayWeights()
            
        }
        
        // save button is disabled by default
        navigationItem.rightBarButtonItem!.isEnabled = false
        
    }
    
    // used to display the weights for the course user is viewing
    func displayWeights() {
        let course = myCourses[courseIndex]
        var weightsString:String = ""
        
        for weight in course.weights {
            weightsString.append(contentsOf: "\(weight.key): ")
            let percentString = String(format: "%.1f", weight.value * 100.0)
            weightsString.append(contentsOf: "\(percentString)%\n")
        }
        
        weightsLabel.text = weightsString
    }
    

    // MARK - START NAVIGATION METHODS:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? CoursePageViewController {
            // edit the credit field of the course user is viewing
            myCourses[courseIndex].credits = Int(creditHourField.text!)!
            
            // save the course array to user defaults
            saveCourseArray()
            
            // give course page most recent course array
            dest.myCourses = myCourses
        }
    }
    
    // used to save the course array to user defaults
    func saveCourseArray() {
        if let data = try? PropertyListEncoder().encode(myCourses) {
             UserDefaults.standard.set(data, forKey: "myCourses")
        }
    }
 
    // called when the user edits a text field
    @IBAction func validateChange(_ sender: Any) {
        
        // if the new credits number is a valid integer, allow saving
        if let newCredits = Int((creditHourField.text)!) {
            if (newCredits >= 0) {
                navigationItem.rightBarButtonItem!.isEnabled = true
            }
        } else {
            navigationItem.rightBarButtonItem!.isEnabled = false
        }
        
    }
    
    // used to exit keyboard when user taps off a text field
    @IBAction func exitKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
}
