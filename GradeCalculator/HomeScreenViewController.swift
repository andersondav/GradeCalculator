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
    
    // used for the VC's title
    var username = ""
    
    var myCourses = [Course]()
    var filteredCourses = [Course]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Retrieve the stored username and set as title
        username = UserDefaults.standard.object(forKey: "username") as! String
        self.title = "\(username)'s Courses"
        
        // Load course array
        loadCourseArray()
        
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
    
    // Load up user's saved courses
    func loadCourseArray() {
        if let data = UserDefaults.standard.value(forKey:"myCourses") as? Data {
            myCourses = try! PropertyListDecoder().decode(Array<Course>.self, from: data)
        } else {
            myCourses = []
        }
    }
        
    // MARK - START NAVIGATION METHODS:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCoursePage" {
            if let dest = segue.destination as? CoursePageViewController {
                
                // send the course name, percent grade, and index in courses tableView to dest
                let sendingCell = sender as? HomeScreenCourseCell
                dest.courseName = (sendingCell?.courseNameLabel.text)!
                dest.percentGrade = (sendingCell?.percentageLabel.text)!

                let row = findCourseInArray(courseName: (sendingCell?.courseNameLabel.text)!)
                if (row >= 0) {
                    dest.index = row
                } else {
                    dest.index = 0
                }
                
                // deselect the selected cell
                let index:IndexPath = coursesTableView.indexPath(for: sendingCell!)!
                coursesTableView.deselectRow(at: index, animated: true)
                
                // send most recent courses array to dest
                dest.myCourses = myCourses
            }
        }
        
        // exit the keyboard
        view.endEditing(true)
        
    }
    
    func findCourseInArray(courseName: String) -> Int {
        
        // used to find a course with a given name (each courseName is unique)
        var counter = 0
        for entry in myCourses {
            if courseName == entry.name {
                return counter
            }
            counter += 1
        }
        
        // return -1 if course with that name not found
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
    // MARK - END NAVIGATION METHODS
    
    //MARK - START TABLEVIEW METHODS:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (myCourses.count == 0) {  // no courses have been added, so show "tap to add" cell
            return 1
        } else if (filteredCourses.count != 0) {  // filter has results, so return filtered count
            return filteredCourses.count
        } else if (filteredCourses.count == 0 && !(searchBar.text!.isEmpty)) {  // no filtered results, so return "no
             return 1                                                              // matches found cell"
        }
        //no filtering and courses have been added
        return myCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenCourseCell") as! HomeScreenCourseCell
        
        coursesTableView.allowsSelection = true
        
        if (myCourses.count == 0) {  // no courses have been added
            cell.courseNameLabel.text = "Tap \"+\" to add courses"
            cell.courseNameLabel.font = UIFont.boldSystemFont(ofSize: cell.courseNameLabel.font.pointSize)
            cell.percentageLabel.text = ""
            
            //disable selection of "tap to add" cell
            coursesTableView.allowsSelection = false
            return cell
        }
        
        if (searchBar.text!.isEmpty && filteredCourses.count == 0) {  // normal course array
            
            //get the course name
            let courseName = myCourses[indexPath.row].name
            cell.courseNameLabel?.text = courseName
            cell.courseNameLabel.font = UIFont.boldSystemFont(ofSize: 25.0)
            
            //calculate grade
            cell.percentageLabel.text = calculateGrade(course: myCourses[indexPath.row])
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
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {  // if clicked the delete button
            if (myCourses.count == 1) {  // no more courses now, need to show "tap to add" cell
                myCourses = []
                coursesTableView.reloadData()
            } else {  // still other courses left, so just remove that row, no need to reload
                // in case user is deleting while filtering, find the index of the course by its name, then remove that index
                let sendingCell = coursesTableView.cellForRow(at: indexPath) as! HomeScreenCourseCell
                let name = sendingCell.courseNameLabel.text!
                let indexInArray = findCourseInArray(courseName: name)
                myCourses.remove(at: indexInArray)
                if (searchBar.text!.isEmpty) {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    filter(self)
                }
                
            }
            
            // save courses array
            let data = try? PropertyListEncoder().encode(myCourses)
            UserDefaults.standard.set(data, forKey: "myCourses")
        }
        
    }
    // MARK - END TABLEVIEW METHODS:
    
    func calculateGrade(course: Course) -> String {
        
        // get the course, its assignments, and its weights
        let currentCourse = course
        let assignments:[Assignment] = currentCourse.assignments
        let weights = currentCourse.weights

        if (weights.count == 1) { // if the grade system is raw points
            if assignments.count != 0 {  // if there are assignments
                var total = 0.0
                var max = 0.0
                for assignment in assignments {
                    total += assignment.score
                    max += assignment.max
                }
                
                let percent = total / max * 100.0
                return String(format: "%.1f", percent) + "%"
            } else {  // no assignments
                return "--%"
            }
        } else {
            // if no assignments
            if (assignments.count == 0) {
                return "--%"
            } else {
                
                //accumulate the number of points and max points for each weight category
                var pointTotals:[String:[Double]] = [:]
                for entry in weights {
                    pointTotals[entry.key] = [0.0, 0.0]
                }
                for assignment in assignments {
                    pointTotals[assignment.type]![0] += assignment.score
                    pointTotals[assignment.type]![1] += assignment.max
                }
                
                // sum up the percentage in each category the student has achieved
                var sum = 0.0
                for entry in pointTotals {
                    if (entry.value[1] != 0.0) {
                        sum += entry.value[0] / entry.value[1] * 100.0 * weights[entry.key]!
                    } else {
                        sum += 100 * weights[entry.key]!
                    }
                    
                }
                
                // set the perecentage to a string and return
                let sumString = String.init(format: "%.1f", sum)
                return "\(sumString)%"
            }
        }
    }
    
    @IBAction func unwindToHome(_ sender: UIStoryboardSegue) {
        // called when user has added a new course or new assignments have been created
          // if new courses have been added, need to display on tableView,
          // and if new assignments, need to recalculate grades
//        print("reloading")
//        print(myCourses)
        coursesTableView.reloadData()
    }
    
    @IBAction func exitKeyboard(_ sender: Any) {
        //called when user taps off the search bar
        view.endEditing(true)
    }
    
    @IBAction func endEdit(_ sender: Any) {
        // called when user taps the clear button next to search bar
        searchBar.text = ""
        view.endEditing(true)
        
        // recall filter which will reload data with empty filteredCourse array
        filter(self)
    }
    
    @IBAction func filter(_ sender: Any) {
        // called when the user changes what is in the search bar
        let searchTerm = searchBar.text!.lowercased()
        
        // reset the filtered courses
        filteredCourses = []
        
        if (searchTerm.isEmpty) {  // no search
            coursesTableView.reloadData()  // reload with an empty filteredCourse array
            return
        }
        
        // if there is a search term, add relevant results to filteredCourses
        for entry in myCourses {
            let lowercaseName = entry.name.lowercased()
            if (lowercaseName.contains(searchTerm)) {
                filteredCourses.append(entry)
            }
        }
        
        // reload the tableView with a populated filteredCourse array
        coursesTableView.reloadData()
    }
}
