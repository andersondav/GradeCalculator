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

        // Do any additional setup after loading the view.
        if (courseIndex > -1) {
            let course = myCourses[courseIndex]
            
            gradeLabel.text = percentGrade
            
            creditHourField.text = String(course.credits)
            
            var weightsString:String = ""
            
            for weight in course.weights {
                
                weightsString.append(contentsOf: "\(weight.key): ")
                
                let percentString = String(format: "%.1f", weight.value * 100.0)
                
                weightsString.append(contentsOf: "\(percentString)%\n")
                
            }
            
            weightsLabel.text = weightsString
            
        }
        
        navigationItem.rightBarButtonItem!.isEnabled = false
        
    }
    
    @IBAction func exitKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let dest = segue.destination as? CoursePageViewController {
            myCourses[courseIndex].credits = Int(creditHourField.text!)!
            
            let data = try? PropertyListEncoder().encode(myCourses)
            
            UserDefaults.standard.set(data, forKey: "myCourses")
            
            dest.myCourses = try! PropertyListDecoder().decode([Course].self, from: UserDefaults.standard.value(forKey: "myCourses") as! Data)
//            dest.course = dest.myCourses[courseIndex]
        }
        
        
    }
 
    @IBAction func validateChange(_ sender: Any) {
        
        if let newCredits = Int((creditHourField.text)!) {
            
            navigationItem.rightBarButtonItem!.isEnabled = true
            
        } else {
            navigationItem.rightBarButtonItem!.isEnabled = false
        }
        
    }
    
}
