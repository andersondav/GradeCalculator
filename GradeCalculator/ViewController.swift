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
        
        // text field setup
        nameTextField.adjustsFontSizeToFitWidth = false
        var placeHolder = NSMutableAttributedString()
        let Name  = "e.g. John"
        placeHolder = NSMutableAttributedString(string:Name, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20.0, weight: .light)])
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range:NSRange(location:0,length:Name.count))
        nameTextField.attributedPlaceholder = placeHolder
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //see if user has logged in with name before, and send them to main screen if done
        if let username = UserDefaults.standard.object(forKey: "username") as? String {
            if (username == "") {
                print("empty string")
            } else {
                performSegue(withIdentifier: "setUpSegue", sender: self)
            }
            
        }
        
    }

    @IBAction func exitKeyboard(_ sender: Any) {
        // exits keyboard when user taps off a text field
        view.endEditing(true)
    }
    
    // check that name is valid
    @IBAction func checkValidName(_ sender: Any) {
        
        if let name = nameTextField.text {
            if (name.contains(" ")) {
                errorLabel.text = "Name must not include spaces."
                errorLabel.textColor = UIColor.red
                startButton.isEnabled = false
            } else if (name.isEmpty) {
                errorLabel.text = "Please input a valid name."
                errorLabel.textColor = UIColor.red
                startButton.isEnabled = false
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
    
    @IBAction func login(_ sender: Any) {
        
        // when pressing start button, save the username and an empty course array
        UserDefaults.standard.set(self.username, forKey: "username")
        let courses:[Course] = []
        UserDefaults.standard.set(courses, forKey: "myCourses")
        self.performSegue(withIdentifier: "setUpSegue", sender: self)
        
    }
}

