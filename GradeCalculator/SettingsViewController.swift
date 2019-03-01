//
//  SettingsViewController.swift
//  GradeCalculator
//
//  Created by Anderson David on 1/30/19.
//  Copyright © 2019 Anderson David. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var newUsernameField: UITextField!
    @IBOutlet weak var setNewNameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // the set new name button is enabled by default
        setNewNameButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            let viewControllers = navigationController!.viewControllers
            self.prepare(for: UIStoryboardSegue(identifier: "unWindToHome", source: self, destination: viewControllers[0]), sender: self)
        }
    }
    
    // MARK - START NAVIGATION METHODS:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // when user returns to the home page, reload the page with the most recent username
        if let dest = segue.destination as? HomeScreenViewController {
            let username = UserDefaults.standard.value(forKey: "username") as! String
            dest.title = "\(username)'s Courses"
        }
    }
    // MARK - END NAVIGATION METHODS:

    // called when the user edits the new username field
    @IBAction func validateName(_ sender: Any) {
        // makes sure the new username is not an empty string and it is not nil
        if (!(newUsernameField.text!.isEmpty) && newUsernameField.text != nil) {
            setNewNameButton.isEnabled = true
        }
    }
    
    // used to exit keyboard when user taps off the text field
    @IBAction func exitKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    // called when the user presses the 'set new username' button
    @IBAction func setNewName(_ sender: Any) {
        // save new username into user defaults
        UserDefaults.standard.set(newUsernameField.text, forKey: "username")
        newUsernameField.text = ""
    }
    
    // called when the user presses the 'clear data' button
    @IBAction func clearData(_ sender: Any) {
        // an alert with the following message will pop up asking user if they are sure they want to clear infos
        let clearMessage = "Are you sure you want to clear all app data? All entered information will be lost and you will be returned to the login screen. This action cannot be undone."
        let clearAlert = UIAlertController(title: "Clear Data", message: clearMessage, preferredStyle: UIAlertController.Style.alert)
        
        // if the user confirms clearing data, will call confirmedClear() method
        clearAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction)
            in self.confirmedClear()
        }))
        
        // if the user says they don't want to clear data, print they cancelled to console
        clearAlert.addAction(UIAlertAction(title: "No", style: .default, handler: {
            (action: UIAlertAction) in
            print("user cancelled the clear data")
        }))
        
        // present the alert
        present(clearAlert, animated: true, completion: nil)
    }
    
    func confirmedClear() {
        // set a blank username
        UserDefaults.standard.set("", forKey: "username")
        
        // set the courses array to a blank array
        let blankArray:[Course] = []
        UserDefaults.standard.set(try? PropertyListEncoder().encode(blankArray), forKey: "myCourses")
        
        // take user back to login screen
        self.performSegue(withIdentifier: "clearedData", sender: self)
    }
    
}
