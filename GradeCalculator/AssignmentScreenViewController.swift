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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(myCourses)
        print(courseIndex)
        print(assignmentIndex)
        
        let assignment = myCourses[courseIndex].assignments[assignmentIndex]
        
        self.title = assignment.name
        scoreTextField.text = String(format: "%.1f", assignment.score)
        outOfTextField.text = String(format: "%.1f", assignment.max)
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        let course = myCourses[courseIndex]
        var assignmentStrings:[String] = []
        
        for entry in course.weights {
            assignmentStrings.append(entry.key)
        }
        
        var currentIndex = -1
        var counter = 0
        
        for entry in assignmentStrings {
            if entry == assignment.type {
                currentIndex = counter
                break
            }
            counter += 1
        }
        
        if (currentIndex != -1) {
            categoryPicker.selectRow(currentIndex, inComponent: 0, animated: true)
        }
        
        navigationItem.rightBarButtonItem!.isEnabled = false
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let course = myCourses[courseIndex]
        var assignmentStrings:[String] = []
        
        for entry in course.weights {
            assignmentStrings.append(entry.key)
        }
        
        let newAssignment = Assignment(name: self.title!, type: assignmentStrings[categoryPicker.selectedRow(inComponent: 0)], score: Double(scoreTextField.text!)!, max: Double(outOfTextField.text!)!)
        
        myCourses[courseIndex].assignments[assignmentIndex] = newAssignment
        
        if let data = try? PropertyListEncoder().encode(myCourses) {
            UserDefaults.standard.set(data, forKey: "myCourses")
        }
        
        if let dest = segue.destination as? CoursePageViewController {
            let data = UserDefaults.standard.value(forKey: "myCourses") as! Data
            dest.myCourses = try! PropertyListDecoder().decode([Course].self, from: data)
            dest.assignmentsTableView.reloadData()
//            dest.course = dest.myCourses[courseIndex]
        }
    }
 

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let course = myCourses[courseIndex]
        
        return course.weights.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let course = myCourses[courseIndex]
        var assignmentStrings:[String] = []
        
        for entry in course.weights {
            assignmentStrings.append(entry.key)
        }
        
        return assignmentStrings[row]
    }
    
    @IBAction func changeVals(_ sender: Any) {
        if let score = Double(scoreTextField.text!) {
            if let outOf = Double(outOfTextField.text!) {
                if score >= 0 && outOf >= 0 {
                    navigationItem.rightBarButtonItem!.isEnabled = true
                    return
                }
            }
        }
        
        navigationItem.rightBarButtonItem!.isEnabled = false
    }
    
    @IBAction func exitKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        changeVals(self)
    }
    
}
