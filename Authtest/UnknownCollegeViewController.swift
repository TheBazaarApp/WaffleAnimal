//
//  UnknownCollegeViewController.swift
//  Authtest
//
//  Created by cssummer16 on 8/6/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import Firebase

class UnknownCollegeViewController: UIViewController {
    
    
    var college: String!
    var myCollege: String!
    var segueLoc: String!
    let uid = FIRAuth.auth()?.currentUser!.uid
    let ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var collegeLabel: UILabel!
    @IBOutlet weak var emailDomain: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var website: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collegeLabel.text = college!
        self.hideKeyboardWhenTappedAround()
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
        tabBarController?.tabBar.hidden = true
    }
    
    
    @IBAction func didPressOkay(sender: AnyObject) {
        let pathToNotification = ref.child("adminNotifications/").childByAutoId()
        
        let notificationDetails = ["notificationType" : "newCollege",
                                   "collegeName" : college!,
                                   "emailDomain": emailDomain.text!,
                                   "location": location.text!,
                                   "collegeWebsite": website.text!,
                                   "posterUID": uid,
                                   "posterCollege": myCollege]
        pathToNotification.setValue(notificationDetails)
        if segueLoc == "domainNotRecognized" {
            //Add to newColleges branch of database
            let pathToNewCollege = ref.child("otherColleges/\(mainClass.domainBranch!)/")
            
            let newCollegeDetails = [ "collegeName" : college!,
                                      "verified": false] //Could also add "add To Domain": STUFF
            
            pathToNewCollege.setValue(newCollegeDetails)
            mainClass.collegeName = college!
            
            //Segue to CollegeChooser
            performSegueWithIdentifier("kristoff", sender: nil)
        }
        if segueLoc == "verifyCollege" {
            //Popup telling them they can't trade with this college yet.
            let ac = UIAlertController(title: "Change Email", message: "We have a different college associated with your email domain.  Once we have verified that your email domain is correct, we will add you to \(college!). Until then, your college will be listed as \(myCollege).", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler:  { (alert: UIAlertAction!) -> Void in
                //Segue to CollegeChooser
                self.performSegueWithIdentifier("kristoff", sender: nil)
            }))
            presentViewController(ac, animated: true, completion: nil)
            
        } else {
            //Pop back to the CollegeChooser scene
            if let stack = self.navigationController?.viewControllers {
                if let previousViewController = stack[stack.count - 3] as? CollegeChooser {
                    previousViewController.addCollege(college)
                    self.navigationController?.popToViewController(previousViewController, animated: true)
                }
            }
        }
    }
    
    
    
    @IBAction func didPressCancel(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "kristoff" { //Called if you selected your college as a new college
            if let destination = segue.destinationViewController as? CollegeChooser {
                print("segueing, segueloc is first time")
                destination.segueLoc = "firstTime"
            }
        }
    }
    
}
