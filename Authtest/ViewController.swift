//
//  ViewController.swift
//  Authtest
//
//  Created by CSSummer16 on 6/13/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var Username: UITextField!
    @IBOutlet var Password: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var loginButton: UIButton!
    
    var segueLoc = ""
    var notificationsID = ""
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func goToFeed() {
        let feedScene = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SWRevealViewController") as UIViewController
        let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        appDelegate.window?.rootViewController = feedScene
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainClass.loginTime = true
        loginButton.layer.cornerRadius = 5
        self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = true
        self.hideKeyboardWhenTappedAround()
        if segueLoc == "collegeChooser" { 
            showVerifyPopup()
        }
    }
    
    
    @IBAction func segmentedControlAction(sender: AnyObject) {
        if(segmentedControl.selectedSegmentIndex == 1) {
            self.performSegueWithIdentifier("iago", sender: nil)
            
        }
        
    }
    
    
    
    
    
    
    
    func showVerifyPopup() {
        let ac = UIAlertController(title: "Please Verify Email", message: "Almost done!  We need you to verify your email before you can start using Bazaar!", preferredStyle: .Alert)
        let callActionHandler = { (action: UIAlertAction) -> Void in
            let mailURL = NSURL(string: "message://")
            if UIApplication.sharedApplication().canOpenURL(mailURL!){
                UIApplication.sharedApplication().openURL(mailURL!)
            }
        }
        ac.addAction(UIAlertAction(title: "Open Email", style: .Default, handler: callActionHandler))
        ac.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
        self.presentViewController(ac, animated: true, completion: nil)
        
    }
    
    
    
    
    @IBAction func didPressLogin(sender: AnyObject) {
        FIRAuth.auth()?.signInWithEmail(Username.text!, password: Password.text!, completion: {user, error in
            if error != nil{
                mainClass.simpleAlert("Unable to Login", message: error!.localizedDescription, viewController: self)
            }
        })
    }
    
    @IBAction func didPressForgotPassword(sender: AnyObject) {
        let ac = UIAlertController(title: "Enter email", message: nil, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler(nil)
        let submitAction = UIAlertAction(title: "Submit", style: .Default) { [ac] (action: UIAlertAction!) in
            let answer = ac.textFields![0]
            FIRAuth.auth()?.sendPasswordResetWithEmail(answer.text!, completion: nil)
        }
        
        ac.addAction(submitAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    @IBAction func didPressSkipAndBrowse(sender: AnyObject) {
        //Check local storage
        let defaults = NSUserDefaults.standardUserDefaults()
        let collegeList = defaults.objectForKey("skipAndBrowseColleges")
        if (collegeList as? [String]) != nil {
            goToFeed()
        } else {
            //Go to college chooser
            performSegueWithIdentifier("cogsworth", sender: nil)
        }
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "cogsworth" { //Called when the user clicks on the "Add College" button
            let navigationController = segue.destinationViewController as! UINavigationController
            if let destination = navigationController.viewControllers.first as? CollegeChooser {
                destination.segueLoc = "skipAndBrowse"
                destination.previousVC = self
            }
        }
        if segue.identifier == "iago" { //Called when user goes to create account
            let createAccount = segue.destinationViewController as! CreateAccountViewController
            createAccount.notificationsID = self.notificationsID
        }
    }
    
    
    func notVerifiedAlert() {
        mainClass.simpleAlert("Not Verified", message: "Please verify your email address in order to log in.", viewController: self)
    }
    
    
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

