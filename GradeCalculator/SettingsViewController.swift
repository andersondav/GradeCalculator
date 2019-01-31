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

        // Do any additional setup after loading the view.
        setNewNameButton.isEnabled = false
        
        //navigationItem.hidesBackButton = true
    }
    
    func back(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "settingsToHome", sender: self)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let dest = segue.destination as? HomeScreenViewController {
            let username = UserDefaults.standard.value(forKey: "username") as! String
            dest.title = "\(username)'s Courses"
        }
    }
 

    @IBAction func validateName(_ sender: Any) {
        if (newUsernameField.text != "") {
            setNewNameButton.isEnabled = true
        }
    }
    
    @IBAction func exitKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func setNewName(_ sender: Any) {
        UserDefaults.standard.set(newUsernameField.text, forKey: "username")
        newUsernameField.text = ""
    }
    
    @IBAction func clearData(_ sender: Any) {
        let clearMessage = "Are you sure you want to clear all app data? All entered information will be lost and you will be returned to the login screen. This action cannot be undone."
        var clearAlert = UIAlertController(title: "Clear Data", message: clearMessage, preferredStyle: UIAlertController.Style.alert)
        
        clearAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction)
            in self.confirmedClear()
        }))
        
        clearAlert.addAction(UIAlertAction(title: "No", style: .default, handler: {
            (action: UIAlertAction) in
            print("user cancelled the clear data")
        }))
        
        present(clearAlert, animated: true, completion: nil)
    }
    
    func confirmedClear() {
        let blankArray:[Course] = []
        
        UserDefaults.standard.set("", forKey: "username")
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(blankArray), forKey: "myCourses")
        self.performSegue(withIdentifier: "clearedData", sender: self)
    }
    
}
