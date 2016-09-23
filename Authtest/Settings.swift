//
//  Settings.swift
//  Authtest
//
//  Created by cssummer16 on 8/2/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class Settings: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var emailField: UILabel!
    @IBOutlet weak var emailsOn: UISwitch!
    @IBOutlet weak var collegesField: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    let ref = FIRDatabase.database().reference()
    let uid = mainClass.uid
    let username = mainClass.displayName
    var email = mainClass.email
    let user = mainClass.user
    let college = mainClass.domainBranch
    var myCollegeName = mainClass.collegeName
    var collList = [String]()
    var colInfoHere = false
    var repetitions = 0
    
    
    
    override func viewDidLoad() { 
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        collegesField.textColor = .purpleColor()
        getSettingsInfo()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBarHidden = false
        navigationItem.title = "Settings"
        scrollView.flashScrollIndicators()
    }
    
    
    
    
    func getSettingsInfo() {
        let dataRef = ref.child("\(self.college!)/user/\(uid!)/settings")
        emailField.text = mainClass.user!.email
        
        dataRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            var collString = ""
            
            if let settingsData = snapshot.value as? [String : AnyObject] {
                if let emailsVal = settingsData["emails"] as? Bool {
                    self.emailsOn.setOn(emailsVal, animated: false)
                }
                
                self.collList = [String]()
                if let colleges = settingsData["colleges"] as? NSArray {
                    
                    let colDomains = colleges as! [String]
                    for col in colDomains {
                        if let colName = mainClass.emailGetter.getNameFromDomain(col) {
                            collString += colName + "\n"
                            self.collList.append(colName)
                        }
                    }
                }
                if let collegesWithoutDomains = settingsData["collegesWithoutDomains"] as? NSArray {
                    for col in collegesWithoutDomains as! [String] {
                        collString += col + "\n"
                        self.collList.append(col)
                    }
                }
            }
            self.colInfoHere = true
            if self.myCollegeName == nil {
                collString = "my college (no name available)\n" + collString
            } else {
                collString = self.myCollegeName! + "\n" + collString
            }
            self.collegesField.text = collString
        })
    }
   
    
    
    @IBAction func didPressLogout(sender: AnyObject) {
        let ac = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .Alert)
        let sign = { (action: UIAlertAction) -> Void in
            try! FIRAuth.auth()!.signOut()
            mainClass.loginTime = true
            self.performSegueWithIdentifier("naveen", sender: sender)
        }
        ac.addAction(UIAlertAction(title: "Okay", style: .Default, handler: sign))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func didPressAddCollege(sender: AnyObject) {
        if !colInfoHere {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * 1), dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                if (self.repetitions <= 2) {
                    self.repetitions += 1
                    self.didPressAddCollege(sender)
                }
            })
        } else {
            performSegueWithIdentifier("lumiere", sender: sender)
        }
    }
    
    
    
    
    @IBAction func didPressChangeEmail(sender: AnyObject) {
        
        let ac = UIAlertController(title: "Change Email", message: "You will need to verify your email address.", preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "New Email"
        }
        ac.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Current Password"
            textField.secureTextEntry = true
        }
        ac.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
            
            
            let newEmail = (ac.textFields![0] as UITextField).text! as String
            if !newEmail.hasSuffix(".edu") {
                mainClass.simpleAlert("Error", message: "Please enter a valid .edu college email.", viewController: self)
            } else {
                if newEmail == self.user!.email {
                    mainClass.simpleAlert("Error", message: "Nice try.  You're already using this email.", viewController: self)
                } else {
                    let password = (ac.textFields![1] as UITextField).text! as String
                    let credential = FIREmailPasswordAuthProvider.credentialWithEmail(self.email!, password: password)
                    self.user?.reauthenticateWithCredential(credential) { error in
                        if error != nil {
                            mainClass.simpleAlert("Couldn't Verify User", message: "Double check that your password is correct.", viewController: self)
                        } else {
                            // User re-authenticated.
                            self.user?.updateEmail(newEmail) { error in
                                if let error = error {
                                    mainClass.simpleAlert("Error Changing Email", message: error.localizedDescription, viewController: self)
                                } else {
                                    //Send a verification email.  Show users a popup, which takes them to it when they close it
                                    FIRAuth.auth()?.currentUser?.sendEmailVerificationWithCompletion({ error in
                                        if let error = error {
                                            mainClass.simpleAlert("Error Sending Verification Email", message: "\(error.localizedDescription) \n Please sign up with a different email or contact us at thebazaarappteam@gmail for help.", viewController: self)
                                        }
                                        else {
                                            self.email = FIRAuth.auth()?.currentUser!.email
                                            self.emailField.text = self.email
                                            mainClass.simpleAlert("Please Verify Email", message: "You will have to verify this new email before you can sign in with it.", viewController: self)
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    @IBAction func didPressChangePassword(sender: AnyObject) {
        let ac = UIAlertController(title: "Change Password", message: nil, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Current Password"
            textField.secureTextEntry = true
        }
        ac.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "New Password"
            textField.secureTextEntry = true
        }
        ac.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Confirm New Password"
            textField.secureTextEntry = true
        }
        ac.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
            let currentPassword = (ac.textFields![0] as UITextField).text! as String
            let newPassword = (ac.textFields![1] as UITextField).text! as String
            let confirmNewPassword = (ac.textFields![2] as UITextField).text! as String
            if newPassword != confirmNewPassword {
                mainClass.simpleAlert("Error", message: "New passwords don't match.", viewController: self)
            } else {
                let credential = FIREmailPasswordAuthProvider.credentialWithEmail(self.email!, password: currentPassword)
                self.user?.reauthenticateWithCredential(credential) { error in
                    if error != nil {
                        mainClass.simpleAlert("Password Incorrect", message: "Double check that your current password was correct.", viewController: self)
                    } else {
                        //Everything's fine!  Change the password
                        self.user?.updatePassword(newPassword) { error in
                            if let error = error {
                                mainClass.simpleAlert("Couldn't change password", message: error.localizedDescription, viewController: self)
                            } else {
                                mainClass.simpleAlert("Password Changed", message: "", viewController: self)
                            }
                        }
                    }
                }
            }
            
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func didPressContact(sender: AnyObject) {
        
        let ac = UIAlertController(title: "Contact Bazaar", message: "Thank you for  contacting Bazaar!  You can email us now or reach us any time at theBazaarAppTeam@gmail.com.", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "Open Email", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
            let mailComposeViewController = self.configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["theBazaarAppTeam@gmail.com"])
        mailComposerVC.setSubject("Message from Bazaar User \(username!)")
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .Alert)
        self.presentViewController(sendMailErrorAlert, animated: true, completion: nil)
        
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    @IBAction func changedEmails(sender: UISwitch) {
        let emailsRef = ref.child("/\(self.college!)/user/\(self.uid!)/settings/emails")
        emailsRef.setValue(sender.on)
    }
    
    
    
    
    
    @IBAction func didPressDeleteAccount(sender: AnyObject) {
        
        let ac = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete account?  All of your user's information will be permanently deleted.", preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }
        ac.addAction(UIAlertAction(title: "Continue", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
            let currentPassword = (ac.textFields![0] as UITextField).text! as String
            let credential = FIREmailPasswordAuthProvider.credentialWithEmail(self.email!, password: currentPassword)
            self.user?.reauthenticateWithCredential(credential) { error in
                if error != nil {
                    mainClass.simpleAlert("Password Incorrect", message: "Double check that your current password was correct.", viewController: self)
                } else {
                    self.lastChance("We'll miss you if you leave!  If you are 100% sure you want to delete your account, type 'goodbye'.")
                    self.presentViewController(ac, animated: true, completion: nil)
                }
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    
    func lastChance(message: String) {
        let ac = UIAlertController(title: "Last Chance", message: message, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "goodbye"
        }
        ac.addAction(UIAlertAction(title: "Delete Forever", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
            let goodbye = (ac.textFields![0] as UITextField).text! as String
            if goodbye == "goodbye" {
                // Account deleted.  Segue back to login screen
                self.deleteUserData()
            } else {
                self.lastChance("You didn't type 'goodbye' correctly.  If you are 100% sure you want to delete your account, type 'goodbye'.")
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    
    func deleteUserData() {
        let college = self.college!
        let uid = self.uid!
        var numFirebaseResponses = 0
        
        //Delete all of the user's albums OK!
        ref.child("\(college)/user/\(uid)/albums").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            numFirebaseResponses += 1
            if let allAlbums = snapshot.value as? [String : AnyObject] {
                for albumKey in allAlbums.keys {
                    self.deleteData("\(self.college!)/albums/\(albumKey)")
                }
            }
        })
        
        //Delete all of the user's unsold items OK!
        ref.child("\(college)/user/\(uid)/unsoldItems").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            numFirebaseResponses += 1
            if let allItems = snapshot.value as? [String : AnyObject] {
                for imageKey in allItems.keys {
                    self.deletePic("\(self.college!)/user/\(self.uid!)/images/\(imageKey)")
                }
            }
        })
        
        
        //Delete all of the user's sold items
        //Also send the buyer a notification OK!
        ref.child("\(college)/user/\(uid)/soldItems").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            numFirebaseResponses += 1
            if let allItems = snapshot.value as? [String : AnyObject] {
                for (imageKey, itemData) in allItems {
                    let itemName = itemData["name"] as! String
                    let buyerID = itemData["buyerID"] as! String
                    let buyerCollege = itemData["buyerCollege"] as! String
                    self.deletePic("\(self.college!)/user/\(self.uid!)/images/\(imageKey)") //Delete sold items from storage
                    
                    //Send buyer a notification
                    self.sendGenericNotification(buyerCollege, id: buyerID, message: "\(self.username!) has deleted their account, so the sale of the \(itemName) is cancelled.")
                    
                    self.deleteData("\(buyerCollege)/user/\(buyerID)/purchasedItems/\(imageKey)") //Delete from purchased items in database
                }
            }
        })
        
        
        //Delete all of the user's purchased items
        ref.child("\(college)/user/\(uid)/purchasedItems").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            numFirebaseResponses += 1
            if let allItems = snapshot.value as? [String : AnyObject] {
                for (imageKey, itemData) in allItems {
                    let itemName = itemData["name"] as! String
                    let albumKey = itemData["albumKey"] as! String
                    let sellerID = itemData["sellerId"] as! String
                    let sellerName = itemData["sellerName"] as! String
                    let sellerCollege = itemData["sellerCollege"] as! String
                    
                    //Send seller a notification
                    self.sendBuyerRejectedNotification(itemName, imageID: imageKey, sellerUID: sellerID, albumID: albumKey, sellerName: sellerName, sellerCollege: sellerCollege)
                }
            }
        })
        
        
        //Delete the user from the list of users
        
        self.deleteData("users/\(uid)")
        
        
        //Delete the user's branch
        self.deleteData("\(college)/user/\(uid)")
        
        //Delete account
        user?.deleteWithCompletion { error in
            if error != nil {
                mainClass.simpleAlert("Error Deleting User", message: "", viewController: self)
            } else {
                let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
                appDelegate.backToLogin()
            }
        }
    }
    
    
    
    func sendGenericNotification(college: String, id: String, message: String) {
        let messageDetails = ["message" : message,
                              "type" : "Generic"]
        
        ref.child("/\(college)/user/\(id)/notifications").childByAutoId().setValue(messageDetails)
    }
    
    
    func deletePic(path: String) {
        mainClass.storageRef.child(path).deleteWithCompletion { (error) -> Void in
        }
    }
    
    
    func deleteData(path: String) {
        self.ref.child(path).setValue(NSNull())
    }
    
    
    func sendBuyerRejectedNotification(itemName: String, imageID: String, sellerUID: String, albumID: String, sellerName: String, sellerCollege: String) {
        let messageDetails = ["message" : "\(mainClass.displayName!) cancelled the sale of your \(itemName)!",
                              "type" : "BuyerRejected",
                              "picUid": imageID, //
            "name": itemName, //presumably item name
            "uid": sellerUID,
            "albumID": albumID,
            "seller": sellerName]
        
        ref.child("/\(sellerCollege)/user/\(sellerUID)/notifications").childByAutoId().updateChildValues(messageDetails)
        
    }
    
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "lumiere" { //Called when the user clicks on the "Unsold Items" button
            if let destination = segue.destinationViewController as? CollegeChooser {
                destination.previousColleges = collList
            }
        }
    }
    
}
