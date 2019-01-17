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

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var scoreField: UITextField!
    @IBOutlet weak var outOfField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        if (name == "" || score == "" || outOf == "") {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            let numScore = Double(score!)
            let numOutOf = Double(outOf!)
            
            if (numScore ?? -1 < 0 || numOutOf ?? -1 < 0) {
                navigationItem.rightBarButtonItem?.isEnabled = false
                return
            }
            
            if (numScore ?? 0 <= numOutOf ?? 0) {
                navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
        
    }
    
    
    @IBAction func hideKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let name = nameField.text
        let score = Double(scoreField.text!)
        let outOf = Double(outOfField.text!)
        let type = assignmentWeights[categoryPicker.selectedRow(inComponent: 0)]
        
        let toAdd = Assignment(name: name!, type: type, score: score!, max: outOf!)
        
        if (segue.identifier == "unwindToCoursePage") {
            if let dest = segue.destination as? CoursePageViewController {
                dest.course?.assignments.append(toAdd)
            }
        }
    }
 

    
}
