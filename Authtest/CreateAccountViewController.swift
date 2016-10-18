//
//  CreateAccountViewController.swift
//  Authtest
//
//  Created by CSSummer16 on 6/14/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    
    //MARK: OUTLETS/VARIABLES
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var reEnterPasswordField: UITextField!
    @IBOutlet weak var segement: UISegmentedControl!
    @IBOutlet weak var createAccount: UIButton!
    var collegeName: String?
    var currentlySaving = false
    var ref = FIRDatabase.database().reference()
    var notificationsID = ""

    
    //MARK: SETUP FUNCTIONS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainClass.loginTime = true
        nameField.delegate = self
        lastNameField.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        segement.selectedSegmentIndex = 1
        // Do any additional setup after loading the view.
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.accessibilityIdentifier == "firstName" {
            let maxLength = 15
            let currentString: NSString = nameField.text!
            let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: string)
            return newString.length <= maxLength
        }
        if textField.accessibilityIdentifier == "lastName" {
            let maxLength = 20
            let currentString: NSString = nameField.text!
            let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: string)
            return newString.length <= maxLength
        }
        return true
    }
    
    
    
    // MARK: - NAVIGATION/FIREBASE FUNCTIONS
    
    
    
    @IBAction func segmentAction(sender: AnyObject) {
        if(segement.selectedSegmentIndex == 1) {
            CreateAccountViewController.load()
        }
        else if(segement.selectedSegmentIndex == 0) {
            self.performSegueWithIdentifier("drizella", sender: nil)
        }
    }
    
    
    
    @IBAction func didPressCreateAccount(sender: AnyObject) {
        if !currentlySaving {
            currentlySaving = true
            if let email = self.emailField.text {
                if email.hasSuffix(".edu") { 
                    if self.nameField.text == "" {
                        mainClass.simpleAlert("Error", message: "Please enter a  first name.", viewController: self)
                        return
                    }
                    if self.lastNameField.text == "" {
                        mainClass.simpleAlert("Error", message: "Please enter a last name.", viewController: self)
                        currentlySaving = false
                        return
                    }
                    
                    if self.passwordField.text != self.reEnterPasswordField.text {
                        mainClass.simpleAlert("Error", message: "Passwords do not match.", viewController: self)
                        currentlySaving = false
                        return
                    }
                    if let alert = nameField.text!.removeBadWords() {
                        self.presentViewController(alert, animated: true, completion: nil)
                        currentlySaving = false
                        return
                    }
                    
                    if let alert = lastNameField.text!.removeBadWords() {
                        self.presentViewController(alert, animated: true, completion: nil)
                        currentlySaving = false
                        return
                    }
                    
                    FIRAuth.auth()?.createUserWithEmail(emailField.text!, password: passwordField.text!, completion: {
                        user, error in
                        if let error = error {
                            mainClass.simpleAlert("Error Creating User", message: error.localizedDescription, viewController: self)
                            self.currentlySaving = false
                        } else {
                        FIRAuth.auth()?.currentUser?.sendEmailVerificationWithCompletion({ error in
                            if let error = error {
                                mainClass.simpleAlert("Error Sending Verification Email", message: error.localizedDescription, viewController: self)
                            }
                            else { //Everything worked!!!
                                self.setProfileInfo()
                                self.getCollegeName(0)
                            }
                            
                        })
                    }
                    })
                }
                else{
                    mainClass.simpleAlert("Please Enter a Valid Email", message: "Make sure to enter the email your college provided you", viewController: self)
                }
            }
            else {
                mainClass.simpleAlert("Please Enter an Email", message: "You need an email to create an account silly", viewController: self)
            }
        }
    }
    
    
    
    
    
    func setProfileInfo() {
        if let user = FIRAuth.auth()?.currentUser {
            
            let changeRequest = user.profileChangeRequest()
            let firstName = nameField.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
            let lastName = lastNameField.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
            changeRequest.displayName = firstName + " " + lastName
            changeRequest.commitChangesWithCompletion { error in
                if error != nil {
                    mainClass.simpleAlert("Error Saving Display Name", message: "\(error!.localizedDescription) \n You can re-save your name later by editing your profile. ", viewController: self)
                }
            }
            
            self.ref.child("\(mainClass.domainBranch!)/user/\(user.uid)/profile/name").setValue(nameField.text! + " " + lastNameField.text!)
            
            let userInfo = ["collegeDomain": mainClass.domainBranch!,
                            "notificationsID": notificationsID]
            
            self.ref.child("users/\(user.uid)").setValue(userInfo)
            
        }
    }
    
    
    
    func getCollegeName(repetitions: Int) {
        if let collegeName = mainClass.collegeName { //name is recognized
            self.collegeName = collegeName
            self.performSegueWithIdentifier("mushu", sender: nil) //Go to verify college
        } else {
            if !mainClass.initialized && repetitions > 3 {
                let triggerTime = (Int64(NSEC_PER_SEC) * 1) //Wait a second
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                    self.getCollegeName(repetitions + 1)
                })
            }
            else {
                let ac = UIAlertController(title: "Email Domain Not Recognized", message: "On the next screen, please type in your college.", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (UIAlertAction) -> Void in
                    self.performSegueWithIdentifier("mufasa", sender: nil)
                }))
                self.presentViewController(ac, animated: true, completion: nil)
            }
        }
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mufasa" { //Go to Verify College
            let navigationController = segue.destinationViewController as! UINavigationController
            let nextVC = navigationController.viewControllers.first as! CollegeChooserTableView
            nextVC.segueLoc = "domainNotRecognized"
            nextVC.myCollege = "no college"
        }
    }
    
}
