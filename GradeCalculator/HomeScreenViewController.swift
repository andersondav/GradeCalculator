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
        
        username = UserDefaults.standard.object(forKey: "username") as! String
        
        let data = UserDefaults.standard.value(forKey: "myCourses") as? Data ?? nil
        
        if (data != nil) {
            courses = try! PropertyListDecoder().decode(Array<Course>.self, from: data!)
        } else {
            courses = []
        }
        
        // Do any additional setup after loading the view.
        self.title = "\(username)'s Courses"
        navigationItem.hidesBackButton = true
        
        //add an example course
//        courses.append(Course())
//        courses.append(Course())
        
        coursesTableView.dataSource = self
        coursesTableView.delegate = self
        
        coursesTableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        username = UserDefaults.standard.object(forKey: "username") as! String
        self.title = "\(username)'s Courses"
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
                
//                let index:IndexPath = coursesTableView.indexPath(for: sendingCell!)!
//                coursesTableView.deselectRow(at: index, animated: true)
//                //dest.course = courses[index.row]
//                dest.index = index.row
                var row = -1
                var counter = 0
                for entry in courses {
                    if sendingCell?.courseNameLabel.text == entry.name {
                        row = counter
                    }
                    counter += 1
                }
                
                if (row >= 0) {
                    dest.index = row
                } else {
                    dest.index = 0
                }
                
                if let data = UserDefaults.standard.value(forKey: "myCourses") {
                    dest.myCourses = try! PropertyListDecoder().decode(Array<Course>.self, from: data as! Data)
                }
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
        
        coursesTableView.allowsSelection = true
        
        if (courses.count == 0) {
            cell.courseNameLabel.text = "Tap \"+\" to add courses"
            cell.courseNameLabel.font = UIFont.boldSystemFont(ofSize: cell.courseNameLabel.font.pointSize)
            cell.percentageLabel.text = ""
            coursesTableView.allowsSelection = false
            return cell
        }
        
        //get the course name
        let courseName = courses[indexPath.row].name
        cell.courseNameLabel?.text = courseName
        cell.courseNameLabel.font = UIFont.boldSystemFont(ofSize: 25.0)
        
        //calculate grade
        let currentCourse = courses[indexPath.row]
        let assignments:[Assignment] = currentCourse.assignments
        let weights = currentCourse.weights
        
        print(currentCourse)
        
        if (weights.count == 1) {
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
        } else {
            if (assignments.count == 0) {
                cell.percentageLabel.text = "--%"
            } else {
                //cell.percentageLabel.text = "--%"
                var pointTotals:[String:[Double]] = [:]
                for entry in weights {
                    pointTotals[entry.key] = [0.0, 0.0]
                }
                
                for assignment in assignments {
                    pointTotals[assignment.type]![0] += assignment.score
                    pointTotals[assignment.type]![1] += assignment.max
                }
                
                var pointsToGrade:[String:Double] = [:]
                
                for entry in pointTotals {
                    if (pointTotals[entry.key]![1] != 0.0) {
                        pointsToGrade[entry.key] = pointTotals[entry.key]![0] / pointTotals[entry.key]![1] * 100
                    } else {
                        pointsToGrade[entry.key] = 100.0
                    }
                }
                
                for entry in pointsToGrade {
                    pointsToGrade[entry.key] = entry.value * weights[entry.key]!
                }
                
                var sum = 0.0
                
                for entry in pointsToGrade {
                    sum += entry.value
                }
                
                let sumString = String.init(format: "%.1f", sum)
                
                cell.percentageLabel.text = "\(sumString)%"
            }
        }
        
        
        
        return cell
    }
    
    @IBAction func unwindToHome(_ sender: UIStoryboardSegue) {
        coursesTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            print("Deleted")
            
            if (courses.count == 1) {
                courses = []
                coursesTableView.reloadData()
            } else {
                courses.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            
            let data = try? PropertyListEncoder().encode(courses)
            
            UserDefaults.standard.set(data, forKey: "myCourses")
        }
        
    }
    
    @IBAction func exitKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}
