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
    
    @IBOutlet weak var weightsTable: UITableView!
    
    var weights = [String:Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        weightsTable.delegate = self
        weightsTable.dataSource = self
        
        addWeightButton.isEnabled = false
        weightsTable.allowsSelection = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToAddPage" {
            if let dest = segue.destination as? AddCourseViewController {
                dest.weights = self.weights
            }
            
        }
    }
 
    @IBAction func exitKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func validateAndAdd(_ sender: Any) {
        let category = categoryLabel.text
        let weight = Double(weightLabel.text!)! / 100.0
        
        weights[category!] = weight
        
        print(weights)
        print("about to reload data")
        
        weightsTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weights.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weightCell") as! HomeScreenCourseCell

        //let cell = HomeScreenCourseCell()
        
        let keyArray = Array(weights.keys)
        print(keyArray)
        print(indexPath.row)
        print(keyArray[indexPath.row])
        
        cell.courseNameLabel?.text! = keyArray[indexPath.row]
        
        let percentage = weights[keyArray[indexPath.row]]! * 100.0
        let percentageString = String(format: "%.1f%%", percentage)
        cell.percentageLabel?.text! = percentageString
        
        return cell
    }
    
    @IBAction func validateData(_ sender: Any) {
        if let _ = categoryLabel.text {
            if let percentage = Double(weightLabel.text!) {
                var sum = 0.0
                for key in weights.keys {
                    sum += self.weights[key]!
                }
                
                sum += percentage / 100.0
                
                if (sum > 1.0) {
                    addWeightButton.isEnabled = false
                } else {
                    addWeightButton.isEnabled = true
                }
            }
        }
    }
}
