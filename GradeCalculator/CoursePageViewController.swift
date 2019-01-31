//
//  CoursePageViewController.swift
//  GradeCalculator
//
//  Created by Anderson David on 1/15/19.
//  Copyright © 2019 Anderson David. All rights reserved.
//

import UIKit

class CoursePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var courseName:String = ""
    var percentGrade:String = ""
    var course:Course? = Course()
    var index:Int = 0
    var myCourses:[Course] = []

    @IBOutlet weak var assignmentsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data = UserDefaults.standard.value(forKey: "myCourses") as? Data ?? nil
        
        if (data != nil) {
            myCourses = try! PropertyListDecoder().decode(Array<Course>.self, from: data!)
        } else {
            myCourses = []
        }
        
        self.course = myCourses[index]
        self.title = myCourses[index].name
        
        assignmentsTableView.dataSource = self
        assignmentsTableView.delegate = self
        
        navigationItem.hidesBackButton = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddAssignment" {
            //print("here")
            if let dest = segue.destination as? AddAssignmentViewController {
                dest.index = self.index
            }
        }
        
        if segue.identifier == "coursePageToHome" {
            //print("in the second if")
            if let dest = segue.destination as? HomeScreenViewController {
                UserDefaults.standard.set(try? PropertyListEncoder().encode(myCourses), forKey: "myCourses")
                
                if let data = UserDefaults.standard.value(forKey:"myCourses") as? Data {
                    dest.courses = try! PropertyListDecoder().decode(Array<Course>.self, from: data)
                }
                
                dest.coursesTableView.reloadData()
            }
        }
    }
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (course?.assignments.count == 0) {
            return 1
        } else {
            return course?.assignments.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentCell") as! HomeScreenCourseCell
        assignmentsTableView.allowsSelection = true
        
        if (course?.assignments.count == 0) {
            assignmentsTableView.allowsSelection = false
            cell.courseNameLabel.text = "Tap \"+\" to add assignments"
            cell.courseNameLabel.font = UIFont.systemFont(ofSize: cell.courseNameLabel.font.pointSize)
            cell.percentageLabel.text = ""
            return cell
        }
        
        cell.courseNameLabel.text = course?.assignments[indexPath.row].name
        
        let score = course!.assignments[indexPath.row].score
        let max = course!.assignments[indexPath.row].max
        
        cell.percentageLabel.text = "\(score)/\(max)"
        
        return cell
    }
    
    @IBAction func unwindToCoursePage(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        assignmentsTableView.reloadData()
    }

}
