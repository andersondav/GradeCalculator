//
//  AddAssignmentViewController.swift
//  GradeCalculator
//
//  Created by Anderson David on 1/15/19.
//  Copyright © 2019 Anderson David. All rights reserved.
//

import UIKit

class AddAssignmentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var weights = [String:Double]()
    var assignmentWeights:[String] = [String]()
    var courseIndex:Int = 0
    var myCourses:[Course] = []

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var scoreField: UITextField!
    @IBOutlet weak var outOfField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loadCourseArray()
        
        // determine weights to display
        weights = myCourses[courseIndex].weights
        
        // text field setup
        scoreField.adjustsFontSizeToFitWidth = false
        outOfField.adjustsFontSizeToFitWidth = false
        
        // picker view setup
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
    }
    
    // loads in course array from user defaults
    func loadCourseArray() {
        if let data = UserDefaults.standard.value(forKey: "myCourses") as? Data {
            myCourses = try! PropertyListDecoder().decode(Array<Course>.self, from: data)
        } else {
            myCourses = []
        }
    }
    
    // MARK - START NAVIGATION METHODS:
    // called when saving the new course
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get info that user wants to add
        let name = nameField.text
        let score = Double(scoreField.text!)
        let outOf = Double(outOfField.text!)
        let type = Array(weights.keys)[categoryPicker.selectedRow(inComponent: 0)]
        
        // create an assignment with this info and add to the assignments array for designated course
        let toAdd = Assignment(name: name!, type: type, score: score!, max: outOf!)
        myCourses[courseIndex].assignments.append(toAdd)
        
        // save array to user defaults
        saveCourseArray()
        
        
        if let dest = segue.destination as? CoursePageViewController {
            // pass most recent course array to coursePage VC
            dest.myCourses = myCourses
            
            // reload coursePage TableView
            dest.assignmentsTableView.reloadData()
            
            // recalculate the total grade for the course and pass to coursePage VC
            dest.percentGrade = calculateGrade(course: myCourses[courseIndex])
        }
        
    }
    
    func calculateGrade(course: Course) -> String {
        
        // get the course, its assignments, and its weights
        let currentCourse = course
        let assignments:[Assignment] = currentCourse.assignments
        let weights = currentCourse.weights
        
        if (weights.count == 1) { // if the grade system is raw points
            if assignments.count != 0 {  // if there are assignments
                var total = 0.0
                var max = 0.0
                for assignment in assignments {
                    total += assignment.score
                    max += assignment.max
                }
                
                let percent = total / max * 100.0
                return String(format: "%.1f", percent) + "%"
            } else {  // no assignments
                return "--%"
            }
        } else {
            // if no assignments
            if (assignments.count == 0) {
                return "--%"
            } else {
                
                //accumulate the number of points and max points for each weight category
                var pointTotals:[String:[Double]] = [:]
                for entry in weights {
                    pointTotals[entry.key] = [0.0, 0.0]
                }
                for assignment in assignments {
                    pointTotals[assignment.type]![0] += assignment.score
                    pointTotals[assignment.type]![1] += assignment.max
                }
                
                // sum up the percentage in each category the student has achieved
                var sum = 0.0
                for entry in pointTotals {
                    if (entry.value[1] != 0.0) {
                        sum += entry.value[0] / entry.value[1] * 100.0 * weights[entry.key]!
                    } else {
                        sum += 100 * weights[entry.key]!
                    }
                    
                }
                
                // set the perecentage to a string and return
                let sumString = String.init(format: "%.1f", sum)
                return "\(sumString)%"
            }
        }
    }
    
    // used to save course array to user defaults
    func saveCourseArray() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(myCourses), forKey: "myCourses")
    }
    // MARK - END NAVIGATION METHODS:
    
    // only one component: the types of assignments
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // the picker view will display the weights, so displays weights.count things
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return weights.count
    }
    
    // each row will display that index's entry in weights dictionary
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(weights.keys)[row]
    }
    
    // called when user edits any of the text fields
    @IBAction func validateForm(_ sender: Any) {
        
        // make sure that none of the text fields are empty/nil, and make sure the assignment name is not a repeat of other assignments in that course
        if let name = nameField.text, let score = scoreField.text, let outOf = outOfField.text {
            if (!name.isEmpty || !score.isEmpty || !outOf.isEmpty) {
                if !foundCourseWithName(name: name) {
                    navigationItem.rightBarButtonItem?.isEnabled = true
                }
            }
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
    }
    
    // used to find if an assignment with a given name exists in the assignments array
    func foundCourseWithName(name: String) -> Bool {
        for entry in myCourses[courseIndex].assignments {
            if (entry.name == name) {
                return true
            }
        }
        return false
        
    }
    
    // used to hide the keyboard when user taps off a text field
    @IBAction func hideKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
}
