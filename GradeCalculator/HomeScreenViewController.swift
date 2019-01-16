//
//  HomeScreenViewController.swift
//  GradeCalculator
//
//  Created by Anderson David on 1/11/19.
//  Copyright © 2019 Anderson David. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var coursesTableView: UITableView!
    
    var username = ""
    
    var courses = [Course]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "\(username)'s Courses"
        navigationItem.hidesBackButton = true
        
        //add an example course
//        courses.append(Course())
//        courses.append(Course())
        
        coursesTableView.dataSource = self
        coursesTableView.delegate = self
        
        coursesTableView.reloadData()
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toCoursePage" {
            if let dest = segue.destination as? CoursePageViewController {
                let sendingCell = sender as? HomeScreenCourseCell
                dest.courseName = (sendingCell?.courseNameLabel.text)!
                dest.percentGrade = (sendingCell?.percentageLabel.text)!
                
                let index:IndexPath? = coursesTableView.indexPath(for: sendingCell!)
                dest.course = courses[index!.row]
            }
        }
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "toCoursePage") {
            let sendingCell = sender as? HomeScreenCourseCell
            if (sendingCell?.percentageLabel.text == "") {
                return false
            }
        }
        return true
    }
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (courses.count == 0) {
            return 1
        }
        
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenCourseCell") as! HomeScreenCourseCell
        
        if (courses.count == 0) {
            cell.courseNameLabel.text = "Tap \"+\" to add courses"
            cell.courseNameLabel.font = UIFont.systemFont(ofSize: cell.courseNameLabel.font.pointSize)
            cell.percentageLabel.text = ""
            return cell
        }
        
        //get the course name
        let courseName = courses[indexPath.row].name
        cell.courseNameLabel?.text = courseName
        cell.courseNameLabel.font = UIFont.boldSystemFont(ofSize: 25.0)
        
        //calculate grade
        let assignments:[Assignment] = courses[indexPath.row].assignments
        if assignments.count != 0 {
            var total = 0.0, max = 0.0
            for assignment in assignments {
                total += assignment.score
                max += assignment.max
            }
            
            let percent = total / max * 100.0
            cell.percentageLabel.text = String(format: "%.1f", percent) + "%"
        } else {
            cell.percentageLabel.text = "--%"
        }
        
        
        return cell
    }
    
    @IBAction func unwindToHome(_ sender: UIStoryboardSegue) {
        coursesTableView.reloadData()
    }
    
}
