//
//  CreateAccountViewController.swift
//  Authtest
//
//  Created by CSSummer16 on 6/14/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateAccountViewController: UIViewController {

    @IBOutlet var nameField: UITextField!

    @IBOutlet var emailField: UITextField!
    
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var reEnterPasswordField: UITextField!
    
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
                if ((self.emailField.text?.hasSuffix(".edu")) == true){
                    FIRAuth.auth()?.currentUser?.sendEmailVerificationWithCompletion({ error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        else {
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
    
//    func Login(sender: AnyObject){
//        FIRAuth.auth()?.signInWithEmail(emailField.text!, password: passwordField.text!, completion: {user, error in
//            if error != nil{
//                print("Incorrect")
//            }
//            else{
//                if ((FIRAuth.auth()?.currentUser?.emailVerified) != nil) && ((FIRAuth.auth()?.currentUser?.emailVerified) != false){
//                    print("Login Successful")
//                }
//                else{
//                    print("Please verify your email")
//                }
//            }
//        })
//
//    }

 
}
