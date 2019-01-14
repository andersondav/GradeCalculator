//
//  AddCourseViewController.swift
//  GradeCalculator
//
//  Created by Anderson David on 1/13/19.
//  Copyright © 2019 Anderson David. All rights reserved.
//

import UIKit

class AddCourseViewController: UIViewController {

    @IBOutlet weak var courseNameField: UITextField!
    @IBOutlet weak var creditHourField: UITextField!
    @IBOutlet weak var gradeSystemControl: UISegmentedControl!
    @IBOutlet weak var setWeightsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setWeightsButton.isEnabled = false
        
        creditHourField.adjustsFontSizeToFitWidth = false
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        let courseName = courseNameField.text
        let toAdd = Course(name: courseName!, weights: ["All": 1.0], assignments: [Assignment()] )
        
        if let dest = segue.destination as? HomeScreenViewController {
            dest.courses.append(toAdd)
        }
        
        
        
    }
 
    @IBAction func exitKeyboard(_ sender: Any) {
        view.endEditing(true)
    }

    @IBAction func checkInfo(_ sender: Any) {
        
        if let courseName = courseNameField.text, let credits = Int(creditHourField.text!) {
            if gradeSystemControl.selectedSegmentIndex == 0 {
                navigationItem.rightBarButtonItem!.isEnabled = true
            } else {
                navigationItem.rightBarButtonItem!.isEnabled = false
            }
        } else {
            navigationItem.rightBarButtonItem!.isEnabled = false
        }
        
        
    }
    
    @IBAction func checkWeighting(_ sender: Any) {
        if gradeSystemControl.selectedSegmentIndex == 0 {
            setWeightsButton.isEnabled = false
        } else {
            setWeightsButton.isEnabled = true
        }
    }
}
