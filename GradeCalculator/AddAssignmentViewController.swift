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
        
        let data = UserDefaults.standard.value(forKey: "myCourses") as? Data ?? nil
        
        if (data != nil) {
            myCourses = try! PropertyListDecoder().decode(Array<Course>.self, from: data!)
        } else {
            myCourses = []
        }
        
        let currentCourse = myCourses[courseIndex]
        weights = currentCourse.weights
        
        scoreField.adjustsFontSizeToFitWidth = false
        outOfField.adjustsFontSizeToFitWidth = false
        
        for key in weights.keys {
            assignmentWeights.append(key)
        }
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return assignmentWeights.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return assignmentWeights[row]
    }
    
    @IBAction func validateForm(_ sender: Any) {
        
        let name = nameField.text
        let score = scoreField.text
        let outOf = outOfField.text
        
        if ((name?.isEmpty)! || (score?.isEmpty)! || (outOf?.isEmpty)!) {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            
            var found = false
            for entry in myCourses[courseIndex].assignments {
                if (entry.name == name) {
                    found = true
                }
            }
            
            if (found) {
                navigationItem.rightBarButtonItem?.isEnabled = false
                return
            }
            
            if let numScore = Double(score!) {
                if let numOutOf = Double(outOf!) {
                    if (numScore >= 0 && numOutOf >= 0) {
                        navigationItem.rightBarButtonItem?.isEnabled = true
                        return
                    }
                }
            }
            
            navigationItem.rightBarButtonItem?.isEnabled = false
            
        }
        
    }
    
    
    @IBAction func hideKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let name = nameField.text
        let score = Double(scoreField.text!)
        let outOf = Double(outOfField.text!)
        let type = assignmentWeights[categoryPicker.selectedRow(inComponent: 0)]

        let toAdd = Assignment(name: name!, type: type, score: score!, max: outOf!)
        
        myCourses[courseIndex].assignments.append(toAdd)
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(myCourses), forKey: "myCourses")
        
        if let dest = segue.destination as? CoursePageViewController {
            let data = UserDefaults.standard.value(forKey: "myCourses") as? Data ?? nil
            
            if (data != nil) {
                dest.myCourses = try! PropertyListDecoder().decode(Array<Course>.self, from: data!)
            } else {
                dest.myCourses = []
            }
            
//            dest.course = dest.myCourses[index]
            dest.assignmentsTableView.reloadData()
        }
        
    }
 

    
}
