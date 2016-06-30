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

class CreateAccountViewController: UIViewController {

    @IBOutlet var nameField: UITextField!

    @IBOutlet var emailField: UITextField!
    
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var reEnterPasswordField: UITextField!
    
    @IBOutlet weak var collegeField: UITextField!
    
    var ref = FIRDatabase.database().reference()

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func didPressCreateAccount(sender: AnyObject) {
        FIRAuth.auth()?.createUserWithEmail(emailField.text!, password: passwordField.text!, completion: {
            user, error in
            if let error = error{
                let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)

            }
            else {
                if self.nameField.text == "" {
                    let ac = UIAlertController(title: "Error", message: "Please enter a name", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                }
                if self.collegeField.text == "" {
                    let ac = UIAlertController(title: "Error", message: "Please enter a college", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)

                }
                
                if self.passwordField.text != self.reEnterPasswordField.text {
                    let ac = UIAlertController(title: "Error", message: "passwords do not match", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                    

                }
                if ((self.emailField.text?.hasSuffix(".edu")) == true){
                    FIRAuth.auth()?.currentUser?.sendEmailVerificationWithCompletion({ error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        else {
                            print("im here")
                            self.getProfileInfo()

                            let ac = UIAlertController(title: "Please Verify Email", message: "We need you to verify your email before you can start using BubbleU!", preferredStyle: .Alert)
                            let callActionHandler = { (action: UIAlertAction) -> Void in
                                let mailURL = NSURL(string: "message://")
                                if UIApplication.sharedApplication().canOpenURL(mailURL!){
                                    UIApplication.sharedApplication().openURL(mailURL!)
                                }
                            }
                            ac.addAction(UIAlertAction(title: "Verify", style: .Default, handler: callActionHandler))
                            self.presentViewController(ac, animated: true, completion: nil)
                        }

                    })
                }
                else{
                    let ac = UIAlertController(title: "Please Enter a Valid Email", message: "Make sure to enter the email your college provided you", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                }
            }
        })
    }
    
    
    func getProfileInfo(){
        if let user = FIRAuth.auth()?.currentUser {
            print("am i here yet")
            print(FIRAuth.auth()?.currentUser)
            print(user.uid)
            print(user.email)
            
            //nameField.text = user.displayName
            let changeRequest = user.profileChangeRequest()
            changeRequest.displayName = self.nameField.text
            self.ref.child("hmc/user/\(user.uid)/profile/college").setValue(collegeField.text)
            self.ref.child("hmc/user/\(user.uid)/profile/name").setValue(nameField.text)

            
        }
    }
 
}
