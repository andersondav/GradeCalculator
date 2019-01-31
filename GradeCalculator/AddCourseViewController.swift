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
    
    //var weights = [String:Double]()
    var myCourses:[Course] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = UserDefaults.standard.value(forKey:"myCourses") as? Data {
            myCourses = try! PropertyListDecoder().decode(Array<Course>.self, from: data)
        }
        
        setWeightsButton.isEnabled = false
        
        creditHourField.adjustsFontSizeToFitWidth = false
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "coursePageToHome") {
            
            let courseName = courseNameField.text
            let credits = Int(creditHourField.text!)!
            var toAdd = Course(name: courseName!, weights: ["All": 1.0], assignments: [], credits: credits)
            
            
            if let dest = segue.destination as? HomeScreenViewController {
                myCourses.append(toAdd)
                
                UserDefaults.standard.set(try? PropertyListEncoder().encode(myCourses), forKey: "myCourses")
                print("saved courses")
                
                let data = UserDefaults.standard.value(forKey: "myCourses") as? Data ?? nil
                
                if (data == nil) {
                    print("stored nil")
                }
                
                if (data != nil) {
                    dest.courses = try! PropertyListDecoder().decode(Array<Course>.self, from: data!)
                } else {
                    dest.courses = []
                }
                
                print(dest.courses)
                
                dest.coursesTableView.reloadData()
            }
        
        }
        
//        if (segue.identifier == "toSetWeights") {
//            if let dest = segue.destination as? SetWeightsViewController {
//                dest.weights = self.weights
//            }
//        }
        
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
