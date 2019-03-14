//
//  AssignmentScreenViewController.swift
//  GradeCalculator
//
//  Created by Anderson David on 2/5/19.
//  Copyright © 2019 Anderson David. All rights reserved.
//

import UIKit

class AssignmentScreenViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var myCourses:[Course] = []
    var courseIndex:Int = -1
    var assignmentIndex:Int = -1
    
    @IBOutlet weak var outOfTextField: UITextField!
    @IBOutlet weak var scoreTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var nameTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // set assignment's name and score/out of fields
        let assignment = myCourses[courseIndex].assignments[assignmentIndex]
        self.title = "Assignment Info"
        scoreTextField.text = String(format: "%.1f", assignment.score)
        outOfTextField.text = String(format: "%.1f", assignment.max)
        nameTextField.text = assignment.name
        
        // picker view setup
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        // set the selected picker index to be what type the assignment is of
        setInitialPickerIndex()
        
        // disable saving changes because no changes made yet
        navigationItem.rightBarButtonItem!.isEnabled = false
        
    }
    
    // used to set the initial picker view selection
    func setInitialPickerIndex() {
        let course = myCourses[courseIndex]
        
        var currentIndex = -1
        var counter = 0
        
        // find the entry of the assignment types array that has the same name as the type of the assignment user is viewing, and set category picker to select that index
        for entry in course.weights.keys {
            if entry == course.assignments[assignmentIndex].type {
                categoryPicker.selectRow(counter, inComponent: 0, animated: true)
                return
            }
            counter += 1
        }
        
        
    }
    

    
    // MARK - START NAVIGATION METHODS
    // called when the user presses the save button
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // create a new assignment with the specified changes, and set it to the original assignment in the array
        let course = myCourses[courseIndex]
        let newAssignment = Assignment(name: nameTextField.text!, type: Array(course.weights.keys)[categoryPicker.selectedRow(inComponent: 0)], score: Double(scoreTextField.text!)!, max: Double(outOfTextField.text!)!)
        myCourses[courseIndex].assignments[assignmentIndex] = newAssignment
        
        // save most recent course array to user defaults
        saveCourseArray()
        if let dest = segue.destination as? CoursePageViewController {
            // give the course page the most recent course array, and reload the table view
            dest.myCourses = myCourses
            dest.assignmentsTableView.reloadData()
            
        }
    }
    
    // used to save the course array into user defaults
    func saveCourseArray() {
        if let data = try? PropertyListEncoder().encode(myCourses) {
            UserDefaults.standard.set(data, forKey: "myCourses")
        }
    }
    // MARK - END NAVIGATION METHODS:

    // MARK - START PICKER VIEW METHODS:
    // just one component: the assignment weights
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // display all the assignment types that course has
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myCourses[courseIndex].weights.count
    }
    
    // return the nth entry of the weights array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(myCourses[courseIndex].weights.keys)[row]
    }
    
    // called when the user edits either of the text fields
    @IBAction func changeVals(_ sender: Any) {
        // make sure the score and out of fields are legal values >= 0, or else user cannot save changes
        if let score = Double(scoreTextField.text!), let outOf = Double(outOfTextField.text!), let name = nameTextField.text {
            if score >= 0 && outOf >= 0 && !(name.isEmpty) {
                navigationItem.rightBarButtonItem!.isEnabled = true
                return
            }
        }
        
        navigationItem.rightBarButtonItem!.isEnabled = false
    }
    
    // used to exit the keyboard when user taps off a text field
    @IBAction func exitKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    // called when user changes selection of the picker view
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // make sure the text fields are correctly set up, then user can save
        changeVals(self)
    }
    
}
