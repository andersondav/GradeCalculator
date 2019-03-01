//
//  CoursePageViewController.swift
//  GradeCalculator
//
//  Created by Anderson David on 1/15/19.
//  Copyright © 2019 Anderson David. All rights reserved.
//

import UIKit

class CoursePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // passed in from home screen
    var courseName:String = ""
    var percentGrade:String = ""
    var index:Int = 0
    
    var myCourses:[Course] = []
    var filteredAssignments = [Assignment]()

    @IBOutlet weak var searchBar: UITextField!
    
    @IBOutlet weak var assignmentsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load course array
        loadCourseArray()
        
        // set title to course name
        self.title = myCourses[index].name
        
        // table view setup
        assignmentsTableView.dataSource = self
        assignmentsTableView.delegate = self
        assignmentsTableView.keyboardDismissMode = .onDrag
        
        // set padding of search bar
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 20))
        searchBar.leftView = paddingView
        searchBar.leftViewMode = .always
    }
    
    // called when the back button is pressed
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            
            // passes most recent course array to home screen, and reloads home screen table view
            let viewControllers = navigationController?.viewControllers
            self.prepare(for: UIStoryboardSegue(identifier: "coursePageToHome", source: self, destination: viewControllers![0]), sender: self)
        }
    }
    
    // loads courses array from User defaults
    func loadCourseArray() {
        if let data = UserDefaults.standard.value(forKey: "myCourses") as? Data {
            myCourses = try! PropertyListDecoder().decode(Array<Course>.self, from: data)
        }
    }
    
    // saves course array into user defaults
    func saveCourseArray() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(myCourses), forKey: "myCourses")
    }
    
    // MARK - START NAVIGATION METHODS:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddAssignment" {
            if let dest = segue.destination as? AddAssignmentViewController {
                // pass most recent course array to addAssignment VC
                dest.myCourses = myCourses
                
                // pass the index of the course to the addAssignment VC so it knows where to add assignments
                dest.courseIndex = self.index
            }
        }
        
        if segue.identifier == "coursePageToHome" {
            if let dest = segue.destination as? HomeScreenViewController {
                // save course array to user defaults
                saveCourseArray()
                
                // give home screen most recent course array
                dest.myCourses = myCourses
                
                // reload home screen table view
                dest.coursesTableView.reloadData()
            }
        }
        
        if segue.identifier == "toViewAssignment" {
            if let dest = segue.destination as? AssignmentScreenViewController {
                // pass most recent course array to addAssignment VC
                dest.myCourses = myCourses
                
                // pass the index of the course to the addAssignment VC
                dest.courseIndex = self.index
                
                let sendingCell = sender as! HomeScreenCourseCell
                
                // deselect selected cell
                let index = assignmentsTableView.indexPath(for: sendingCell)
                assignmentsTableView.deselectRow(at: index!, animated: true)
                
                // find the assignment in the assignments array, and pass its index to the viewAssignment VC
                let counter = findAssignmentIndex(name: sendingCell.courseNameLabel.text!)
                dest.assignmentIndex = counter
                
            }
        }
        
        if segue.identifier == "showCourseInfo" {
            if let dest = segue.destination as? CourseInfoViewController {
                // pass the course array, course's index, and the percentage grade to courseInfo VC
                dest.myCourses = myCourses
                dest.courseIndex = self.index
                dest.percentGrade = self.percentGrade
            }
        }
        view.endEditing(true)
    }
    
    // used to find which index an assignment with a specified name occupies in the array
    func findAssignmentIndex(name: String) -> Int {
        var counter = 0
        
        for entry in myCourses[self.index].assignments {
            if (entry.name == name) {
                return counter
            }
            counter += 1
        }
        return -1
    }
    
    // called when unwinding to course page from the viewAssignment, addAssignment, or viewInfo VCs
    @IBAction func unwindToCoursePage(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        assignmentsTableView.reloadData()
    }
    // MARK - END NAVIGATION METHODS:
    
    // MARK - START TABLEVIEW METHODS:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (myCourses[index].assignments.count == 0) {  // no assignments
            return 1
        } else if (filteredAssignments.count != 0) {  // there are search results
            return filteredAssignments.count
        } else if (filteredAssignments.count == 0 && !(searchBar.text!.isEmpty)) {  // there are no search results
            return 1
        } else {  // no search was done and there are assignments
            return myCourses[index].assignments.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentCell") as! HomeScreenCourseCell
        assignmentsTableView.allowsSelection = true
        
        if (myCourses[index].assignments.count == 0) {  // no assignments
            assignmentsTableView.allowsSelection = false
            cell.courseNameLabel.text = "Tap \"+\" to add assignments"
            cell.courseNameLabel.font = UIFont.boldSystemFont(ofSize: cell.courseNameLabel.font.pointSize)
            cell.percentageLabel.text = ""
            return cell
        } else if (filteredAssignments.count != 0) {  // there are search results
            cell.courseNameLabel.text = filteredAssignments[indexPath.row].name
            let score = filteredAssignments[indexPath.row].score
            let max = filteredAssignments[indexPath.row].max
            
            cell.percentageLabel.text = "\(score)/\(max)"
            return cell
        } else if (!searchBar.text!.isEmpty && filteredAssignments.count == 0) {  // there are no search results
            cell.courseNameLabel.text = "No matching results."
            cell.percentageLabel.text = ""
            return cell
        } else {  // no search was done and there are assignments
            cell.courseNameLabel.text = myCourses[index].assignments[indexPath.row].name
            
            let score = myCourses[index].assignments[indexPath.row].score
            let max = myCourses[index].assignments[indexPath.row].max
            
            cell.percentageLabel.text = "\(score)/\(max)"
            
            return cell
        }
    }
    
    // called when an assignment cell is deleted
    func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if (myCourses[index].assignments.count == 1) {  // only one assignment, just remove it and reload
                myCourses[index].assignments = []
                assignmentsTableView.reloadData()
            } else {  // need to remove the assignment with that name
                let sendingCell = tableView.cellForRow(at: indexPath) as! HomeScreenCourseCell
                let name = sendingCell.courseNameLabel.text!
                let indexInArray = findAssignmentIndex(name: name)
                myCourses[index].assignments.remove(at: indexInArray)
                if (searchBar.text!.isEmpty) {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    filter(self)
                }
                
            }
            
            // save the most recent course array to user defaults
            let data = try? PropertyListEncoder().encode(myCourses)
            UserDefaults.standard.set(data, forKey: "myCourses")
        }
        
    }

    // used to exit the keyboard when user taps off search bar
    @IBAction func exitKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    // called when user edits what is in the search bar
    @IBAction func filter(_ sender: Any) {
        filteredAssignments = []
        
        if var searchTerm = searchBar.text {
            if !searchTerm.isEmpty {
                searchTerm = searchTerm.lowercased()
                for entry in (myCourses[index].assignments) {
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
    
    // called when user clears what is in the search bar
    @IBAction func clearSearchBar(_ sender: Any) {
        searchBar.text = ""
        filter(self)
    }
}
