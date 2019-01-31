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
        
        var placeHolder = NSMutableAttributedString()
        let Name  = "e.g. John"
        
        // Set the Font
        placeHolder = NSMutableAttributedString(string:Name, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35.0)])
        
        // Set the color
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range:NSRange(location:0,length:Name.count))
        
        // Add attribute
        nameTextField.attributedPlaceholder = placeHolder
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let username = UserDefaults.standard.object(forKey: "username") as? String {
            if (username == "") {
                print("empty string")
            } else {
                performSegue(withIdentifier: "setUpSegue", sender: self)
            }
            
        }
    }

    @IBAction func exitKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func checkValidName(_ sender: Any) {
        
        if let name = nameTextField.text {
            if (name.contains(" ")) {
                errorLabel.text = "Name must not include spaces."
                errorLabel.textColor = UIColor.red
                startButton.isEnabled = false
            } else if (name == "") {
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "setUpSegue" {
//            if let dest = segue.destination as? HomeScreenViewController {
//                //dest.username = username
//                UserDefaults.standard.set(self.username , forKey: "username")
//            }
//        }
//    }
    
    @IBAction func login(_ sender: Any) {
        
        UserDefaults.standard.set(self.username, forKey: "username")
        
        var courses:[Course] = []
        
        UserDefaults.standard.set(courses, forKey: "myCourses")
        
        self.performSegue(withIdentifier: "setUpSegue", sender: self)
        
    }
}

