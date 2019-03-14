//
//  SetWeightsViewController.swift
//  GradeCalculator
//
//  Created by Anderson David on 1/27/19.
//  Copyright © 2019 Anderson David. All rights reserved.
//

import UIKit

class SetWeightsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var categoryLabel: UITextField!
    @IBOutlet weak var weightLabel: UITextField!
    @IBOutlet weak var addWeightButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var weightsTable: UITableView!
    
    // contains the weights that the user has chosen to have for the course
    var weights = [String:Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView setup
        weightsTable.delegate = self
        weightsTable.dataSource = self
        weightsTable.allowsSelection = false
        
        // disable adding a weight since the fields are blank
        addWeightButton.isEnabled = false
        
        // disable saving since no weights have been added
        saveButton.isEnabled = false
    }
    
    // MARK - START NAVIGATION METHODS:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // when going back to add page, set the chosen weights as the weights of the course to-add
        if segue.identifier == "unwindToAddPage" {
            if let dest = segue.destination as? AddCourseViewController {
                dest.weights = self.weights
            }
            
        }
    }
    // MARK - END NAVIGATION METHODS
    
    // MARK - START TABLEVIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weights.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weightCell") as! HomeScreenCourseCell
        // (I'm reusing the HomeScreenCourseCell since it has the same labels needed for these cells) //
        
        // "courseName" is the assignmentType, corresponds to key of the weights array
        let keyArray = Array(weights.keys)
        cell.courseNameLabel?.text! = keyArray[indexPath.row]
        
        // "percentage" is the percent of the total grade that assignment type makes up
        let percentage = weights[keyArray[indexPath.row]]! * 100.0
        let percentageString = String(format: "%.1f%%", percentage)
        cell.percentageLabel?.text! = percentageString
        
        return cell
    }
    
    // called if user deletes a cell from tableView
    func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let sendingCell = weightsTable.cellForRow(at: indexPath) as! HomeScreenCourseCell
            
            // remove that weight from the weights array, and delete that cell from the table view
            self.weights.removeValue(forKey: sendingCell.courseNameLabel.text!)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // sum of the total weights, and if they don't add to 1, disable the save button
            var sum = checkWeightsSum()
            if sum != 1.0 {
                saveButton.isEnabled = false
            } else {
                saveButton.isEnabled = true
            }
        }
        
    }
    // MARK - END TABLEVIEW METHODS:
    
    // exit keyboard when user taps off a text field
    @IBAction func exitKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    // called when user edits either text field
    @IBAction func validateData(_ sender: Any) {
        if let _ = categoryLabel.text, let percentage = Double(weightLabel.text!) {
            
            // make sure that, if the user adds this entry, the sum of the weights doesn't go over 1.0.
              // if it does go over, don't allow the user to enter this value into the table
            var sumOfWeights = checkWeightsSum()
            sumOfWeights += percentage / 100.0
            if (sumOfWeights > 1.0) {
                addWeightButton.isEnabled = false
            } else {
                addWeightButton.isEnabled = true
            }
        }
    }
    
    // called when a user adds a weight to the table view
    @IBAction func validateAndAdd(_ sender: Any) {
        
        // add this assignment type and weighted value to the array
        let category = categoryLabel.text
        let weight = Double(weightLabel.text!)! / 100.0
        weights[category!] = weight
        
        // clear the labels
        categoryLabel.text = ""
        weightLabel.text = ""
        
        // reload the tableView
        weightsTable.reloadData()
        
        // check the sum of weights that have been added. If the weights don't add to 1.0,
          // disable the save button
        let sum = checkWeightsSum()
        if sum != 1.0 {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
        
    }
    
    // used to check if the weights have all added to 1.0
    func checkWeightsSum() -> Double {
        var sum = 0.0
        for entry in weights {
            sum += entry.value
        }
        return sum
    }
    
}
