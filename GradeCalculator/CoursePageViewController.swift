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
    var filteredAssignments = [Assignment]()

    @IBOutlet weak var searchBar: UITextField!
    
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
        assignmentsTableView.keyboardDismissMode = .onDrag
        
        navigationItem.hidesBackButton = true
        
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 20))
        searchBar.leftView = paddingView
        searchBar.leftViewMode = .always
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
                    dest.myCourses = try! PropertyListDecoder().decode(Array<Course>.self, from: data)
                }
                
                dest.coursesTableView.reloadData()
            }
        }
        
        if segue.identifier == "toViewAssignment" {
            if let dest = segue.destination as? AssignmentScreenViewController {
                if let data = UserDefaults.standard.value(forKey:"myCourses") as? Data {
                    dest.myCourses = try! PropertyListDecoder().decode(Array<Course>.self, from: data)
                }
                dest.courseIndex = self.index
                
                let sendingCell = sender as! HomeScreenCourseCell
                
                let index = assignmentsTableView.indexPath(for: sendingCell)
                
                var counter = 0
                
                for entry in myCourses[self.index].assignments {
                    if (entry.name == sendingCell.courseNameLabel.text) {
                        break
                    }
                    counter += 1
                }
                
                dest.assignmentIndex = counter
                
                assignmentsTableView.deselectRow(at: index!, animated: true)
                
            }
        }
        
        if segue.identifier == "showCourseInfo" {
            if let dest = segue.destination as? CourseInfoViewController {
                if let data = UserDefaults.standard.value(forKey:"myCourses") as? Data {
                    dest.myCourses = try! PropertyListDecoder().decode(Array<Course>.self, from: data)
                }
                dest.courseIndex = self.index
                dest.percentGrade = self.percentGrade
            }
        }
        view.endEditing(true)
    }
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (course?.assignments.count == 0) {
            return 1
        } else if (filteredAssignments.count != 0) {
            return filteredAssignments.count
        } else if (filteredAssignments.count == 0 && !(searchBar.text!.isEmpty)) {
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
            cell.courseNameLabel.font = UIFont.boldSystemFont(ofSize: cell.courseNameLabel.font.pointSize)
            cell.percentageLabel.text = ""
            return cell
        } else if (filteredAssignments.count != 0) {
            cell.courseNameLabel.text = filteredAssignments[indexPath.row].name
            let score = filteredAssignments[indexPath.row].score
            let max = filteredAssignments[indexPath.row].max
            
            cell.percentageLabel.text = "\(score)/\(max)"
            return cell
        } else if (!searchBar.text!.isEmpty && filteredAssignments.count == 0) {
            cell.courseNameLabel.text = "No matching results."
            cell.percentageLabel.text = ""
            return cell
        } else {
            cell.courseNameLabel.text = course?.assignments[indexPath.row].name
            
            let score = course!.assignments[indexPath.row].score
            let max = course!.assignments[indexPath.row].max
            
            cell.percentageLabel.text = "\(score)/\(max)"
            
            return cell
        }
    }
    
    @IBAction func unwindToCoursePage(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        assignmentsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            print("Deleted")
            
            if (myCourses[index].assignments.count == 1) {
                myCourses[index].assignments = []
                course = myCourses[index]
                assignmentsTableView.reloadData()
            } else {
                myCourses[index].assignments.remove(at: indexPath.row)
                course = myCourses[index]
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            
            let data = try? PropertyListEncoder().encode(myCourses)
            
            UserDefaults.standard.set(data, forKey: "myCourses")
        }
        
    }

    @IBAction func exitKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func filter(_ sender: Any) {
        filteredAssignments = []
        
        if var searchTerm = searchBar.text {
            if !searchTerm.isEmpty {
                searchTerm = searchTerm.lowercased()
                for entry in (course?.assignments)! {
                    if entry.name.lowercased().contains(searchTerm) {
                        filteredAssignments.append(entry)
                    }
                }
                assignmentsTableView.reloadData()
            } else {
                assignmentsTableView.reloadData()
            }
        }
    }
    
    @IBAction func clearSearchBar(_ sender: Any) {
        searchBar.text = ""
        filter(self)
    }
}
