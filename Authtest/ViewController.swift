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

    @IBOutlet var Username: UITextField!
    
    
    @IBOutlet var Password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 0.0, green: 0.1, blue: 0.6, alpha: 0.9)
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func didPressLogin(sender: AnyObject) {
        FIRAuth.auth()?.signInWithEmail(Username.text!, password: Password.text!, completion: {user, error in
            if error != nil{
                
                let erroralert = UIAlertController(title: "Unable to Login", message: error?.localizedDescription, preferredStyle: .Alert)
                erroralert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                self.presentViewController(erroralert, animated: true, completion: nil)
            }
            else{
                if ((FIRAuth.auth()?.currentUser?.emailVerified) != nil) && ((FIRAuth.auth()?.currentUser?.emailVerified) != false){
                    
                    let success = UIAlertController(title: "Login Successful", message: nil, preferredStyle: .Alert)
                    let submitAction = UIAlertAction(title: "Ok", style: .Default) { [unowned self] (action: UIAlertAction!) in
                        self.performSegueWithIdentifier("SWRevealViewController", sender: sender)
                    }
                    success.addAction(submitAction)
                    self.presentViewController(success, animated: true, completion: nil)
                }
                else{
                    let verify = UIAlertController(title: "Please Verify Email", message: "We need you to verify your email before you can start using BubbleU!", preferredStyle: .Alert)
                    verify.addAction(UIAlertAction(title: "Verify", style: .Default, handler: nil))
                    self.presentViewController(verify, animated: true, completion: nil)
                }
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
        presentViewController(ac, animated: true, completion: nil)
    }
    
    @IBAction func didPressSkipAndBrowse(sender: AnyObject) {
//        let ac = UIAlertController(title: "Warning", message: "If you skip and browse, you cannot use the app in it's full scope", preferredStyle: .Alert)
//        let submitAction = UIAlertAction(title: "Ok", style: .Default) { [unowned self] (action: UIAlertAction!) in
//            self.performSegueWithIdentifier("SWRevealViewController", sender: nil)
//        }
//        let submitCancel = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
//        ac.addAction(submitAction)
//        ac.addAction(submitCancel)
//        self.presentViewController(ac, animated: true, completion: nil)
        self.performSegueWithIdentifier("SWRevealViewController", sender: nil)
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

