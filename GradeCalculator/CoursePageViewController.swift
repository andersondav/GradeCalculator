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

    @IBOutlet weak var assignmentsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view loaded")
        // Do any additional setup after loading the view.
        self.title = courseName
        
        assignmentsTableView.dataSource = self
        assignmentsTableView.delegate = self
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print("outside if statement")
        if segue.identifier == "toAddAssignment" {
            print("here")
            if let dest = segue.destination as? AddAssignmentViewController {
                dest.weights = course?.weights ?? ["All": 1.0]
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
        
        if (course?.assignments.count == 0) {
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
