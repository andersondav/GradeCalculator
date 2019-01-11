//
//  ViewController.swift
//  GradeCalculator
//
//  Created by Anderson David on 1/11/19.
//  Copyright © 2019 Anderson David. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        nameTextField.adjustsFontSizeToFitWidth = false
    }

    @IBAction func exitKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func checkValidName(_ sender: Any) {
        
        if let name = nameTextField.text {
            if (name.contains(" ")) {
                errorLabel.text = "Name must not include spaces."
                errorLabel.textColor = UIColor.red
            } else if (name == "") {
                errorLabel.text = "Please input a valid name."
                errorLabel.textColor = UIColor.red
            } else {
                username = name
                startButton.isEnabled = true
                errorLabel.textColor = UIColor.clear
            }
        } else {
            errorLabel.text = "Please input a valid name."
            errorLabel.textColor = UIColor.red
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setUpSegue" {
            if let dest = segue.destination as? HomeScreenViewController {
                dest.username = username
            }
        }
    }
    
}

