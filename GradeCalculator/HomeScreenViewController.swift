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
    
    var courses = [String:Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "\(username)'s Courses"
        navigationItem.hidesBackButton = true
        
        courses =
            ["Calc 3": 97, "Spanish": 95]
        
        coursesTableView.dataSource = self
        coursesTableView.delegate = self
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = addButton
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenCourseCell") as! HomeScreenCourseCell
        
        let courseName = Array(courses.keys)[indexPath.row]
        cell.courseNameLabel?.text = courseName
        
        if let percentage = courses[courseName] {
            cell.percentageLabel?.text = "\(percentage)%"
        } else {
            cell.percentageLabel?.text = "0%"
        }
    
        return cell
    }
    
    
}
