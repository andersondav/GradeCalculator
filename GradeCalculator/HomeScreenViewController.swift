//
//  HomeScreenViewController.swift
//  GradeCalculator
//
//  Created by Anderson David on 1/11/19.
//  Copyright © 2019 Anderson David. All rights reserved.
//

import UIKit
import TextFieldEffects

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var coursesTableView: UITableView!
    @IBOutlet weak var searchBar: UITextField!
    
    //used for the VC's title
    var username = ""
    
    var courses = [Course]()
    var filteredCourses = [Course]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // retrieve the stored username and set as title
        username = UserDefaults.standard.object(forKey: "username") as! String
        self.title = "\(username)'s Courses"
        
        // retrieve the stored course array
        let data = UserDefaults.standard.value(forKey: "myCourses") as? Data ?? nil
        if (data != nil) {
            courses = try! PropertyListDecoder().decode(Array<Course>.self, from: data!)
        } else {
            courses = []
        }
        
        // Hide back button
        navigationItem.hidesBackButton = true
        
        // TableView setup
        coursesTableView.dataSource = self
        coursesTableView.delegate = self
        coursesTableView.keyboardDismissMode = .onDrag
        
        // set search bar padding
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 20))
        searchBar.leftView = paddingView
        searchBar.leftViewMode = .always
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // reset the username and title in case user changed their name
        username = UserDefaults.standard.object(forKey: "username") as! String
        self.title = "\(username)'s Courses"
    }
    
    // MARK: - NAVIGATION METHODS
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCoursePage" {
            if let dest = segue.destination as? CoursePageViewController {
                
                // send the course name, percent grade, and index in courses tableView to dest
                let sendingCell = sender as? HomeScreenCourseCell
                dest.courseName = (sendingCell?.courseNameLabel.text)!
                dest.percentGrade = (sendingCell?.percentageLabel.text)!

                var row = findCourseInArray(courseName: (sendingCell?.courseNameLabel.text)!)
                if (row >= 0) {
                    dest.index = row
                } else {
                    dest.index = 0
                }
                
                // deselect the selected cell
                let index:IndexPath = coursesTableView.indexPath(for: sendingCell!)!
                coursesTableView.deselectRow(at: index, animated: true)
                
                // send most recent courses array to dest
                if let data = UserDefaults.standard.value(forKey: "myCourses") {
                    dest.myCourses = try! PropertyListDecoder().decode(Array<Course>.self, from: data as! Data)
                }
            }
        }
        
        // exit the keyboard
        view.endEditing(true)
        
    }
    
    func findCourseInArray(courseName: String) -> Int {
        var counter = 0
        for entry in courses {
            if courseName == entry.name {
                return counter
            }
            counter += 1
        }
        return -1
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        // ensures that if there are no courses, user cannot select a cell
        if (identifier == "toCoursePage") {
            let sendingCell = sender as? HomeScreenCourseCell
            if (sendingCell?.percentageLabel.text == "") {
                return false
            }
        }
        return true
    }
    // MARK: - END NAVIGATION METHODS
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (courses.count == 0) {  // no courses have been added, so show "tap to add" cell
            return 1
        } else if (filteredCourses.count != 0) {  // filter has results, so return filtered count
            return filteredCourses.count
        } else if (filteredCourses.count == 0 && !(searchBar.text!.isEmpty)) {  // no filtered results, so return "no
             return 1                                                              // matches found cell"
        }
        //no filtering and courses have been added
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenCourseCell") as! HomeScreenCourseCell
        
        coursesTableView.allowsSelection = true
        
        if (courses.count == 0) {  // no courses have been added
            cell.courseNameLabel.text = "Tap \"+\" to add courses"
            cell.courseNameLabel.font = UIFont.boldSystemFont(ofSize: cell.courseNameLabel.font.pointSize)
            cell.percentageLabel.text = ""
            
            //disable selection of "tap to add" cell
            coursesTableView.allowsSelection = false
            return cell
        }
        
        if (searchBar.text!.isEmpty && filteredCourses.count == 0) {  // normal course array
            
            //get the course name
            let courseName = courses[indexPath.row].name
            cell.courseNameLabel?.text = courseName
            cell.courseNameLabel.font = UIFont.boldSystemFont(ofSize: 25.0)
            
            //calculate grade
            cell.percentageLabel.text = calculateGrade(course: courses[indexPath.row])
            return cell
            
        } else if (filteredCourses.count == 0) {  // no filtered results, show "No results" cell
            cell.courseNameLabel.text = "No matching results."
            cell.percentageLabel.text = ""
            return cell
        } else {  // have filtered results, return filtered results
            
            //get the course name
            let courseName = filteredCourses[indexPath.row].name
            cell.courseNameLabel?.text = courseName
            cell.courseNameLabel.font = UIFont.boldSystemFont(ofSize: 25.0)
            
            //calculate grade
            cell.percentageLabel.text = calculateGrade(course: filteredCourses[indexPath.row])
            return cell
        }
        
        return cell
        
    }
    
    func calculateGrade(course: Course) -> String {
        let currentCourse = course
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
                return String(format: "%.1f", percent) + "%"
            } else {
                return "--%"
            }
        } else {
            if (assignments.count == 0) {
                return "--%"
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
                
                return "\(sumString)%"
            }
        }
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
    
    @IBAction func endEdit(_ sender: Any) {
        searchBar.text = ""
        view.endEditing(true)
        filter(self)
    }
    
    @IBAction func filter(_ sender: Any) {
        let searchTerm = searchBar.text!.lowercased()
        
        filteredCourses = []
        
        if (searchTerm.isEmpty) {
            coursesTableView.reloadData()
            return
        }
        
        for entry in courses {
            let lowercaseName = entry.name.lowercased()
            if (lowercaseName.contains(searchTerm)) {
                filteredCourses.append(entry)
            }
        }
        
        coursesTableView.reloadData()
    }
}
