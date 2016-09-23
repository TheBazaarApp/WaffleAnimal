//
//  CollegeChooserTableView.swift
//  Authtest
//
//  Created by HMCloaner on 8/25/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit

class CollegeChooserTableView: SearchBarTableViewController {

    // MARK: - Table view data source


    var selectedCollege: String?
    var myCollege = "no college selected"
    var colleges: [String]!
    var font = UIFont.boldSystemFontOfSize(CGFloat(18.0))
    var textColor = UIColor.whiteColor()
    var listBackgroundColor = UIColor(red: 37/255, green: 137/255, blue: 189/255, alpha: 1.0)
    var segueLoc = ""
    var filteredColleges = [String]()
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
        tabBarController?.tabBar.hidden = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredColleges = allColleges
        self.title = "College Chooser"
    }

    
//    
    //Specifies how many items there will be in the table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBarActive && searchBar!.text != "" {
            return filteredColleges.count
        }
        return allColleges.count
    }
    
    
    
    //MARK: Tableview functions
    
    
    //Specify what is in each cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel!.text = filteredColleges[indexPath.row]
        
        return cell
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
           newCollegeAlert()
        } else {
            choseCollege(tableView.cellForRowAtIndexPath(indexPath)!.textLabel!.text!)
        }
    }
    
        
        
        func choseCollege(name: String) {
            selectedCollege = name
            if selectedCollege == self.myCollege {
                self.simpleAlert("\(self.selectedCollege!) is your college.  You automatically trade with it.")
            } else {
                var foundMatch = false
                if colleges != nil {
                    for college in self.colleges {
                        if self.selectedCollege == college {
                            foundMatch = true 
                            self.simpleAlert("You are already trading with \(self.selectedCollege!).")
                        }
                    }
                }
                
                if !foundMatch {
                    self.choosePressed()
                }
            }
        }
        
    
    
    //When you're searching, filter results in tableview
    override func filterContentForSearchText(searchText: String) {
        filteredColleges = allColleges.filter { college in
            return college == "College Not Listed" || college.lowercaseString.containsString(searchText.lowercaseString)
        }
    }
    
    
    override func cancelSearching(){
        super.cancelSearching()
        filterContentForSearchText("")
    }
    
    
    
    func newCollegeAlert() {
        let ac = UIAlertController(title: "College Not Listed", message: "Type the college name below.", preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "College Name"
        }
        ac.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (UIAlertAction) -> Void in
            let collName = ac.textFields![0].text
            if collName != nil && collName != "" {
                self.choseCollege(collName!)
            } else {
                mainClass.simpleAlert("Invalid College Name", message: "", viewController: self)
            }
            
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    




    
    let allColleges: [String] = {
        do {
            guard let dataPath = NSBundle.mainBundle().pathForResource("collegesPlain", ofType: "txt") else {
                return []
            }
            
            let data = try WordReader(filepath: dataPath)
            let dataWords = ["College Not Listed"] + data.words
            return dataWords
            
        }
        catch let error {
            return []
        }
    }()
    
    
        func choosePressed () {
        
        if let formattedCollege = formatCollege(selectedCollege!) {
            if segueLoc == "verifyCollege" || segueLoc == "domainNotRecognized" {
                //Send us a notification, then take the user to the Choose Colleges scene
                let pathToNotification = mainClass.ref.child("adminNotifications/").childByAutoId()
                
                let notificationDetails = ["notificationType" : "incorrectCollegeDomain",
                                           "collegeSelected" : formattedCollege,
                                           "collegeFromEmailDomain" : myCollege,
                                           "posterUID": mainClass.uid ?? "no uid",
                                           "posterEmail": mainClass.email ?? "no email"]
                
                pathToNotification.setValue(notificationDetails)
                
                var message = "We have a different email domain listed for this college.  Once we have verified that your email domain is correct, we will allow you to trade with this college."
                if segueLoc == "verifyCollege" {
                    message += " Until then, your college will be listed as \(myCollege)."
                }
                let ac = UIAlertController(title: "Email Domain Not Recognized", message: message, preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (UIAlertAction) -> Void in
                    self.performSegueWithIdentifier("lilo", sender: nil)
                }))
                self.presentViewController(ac, animated: true, completion: nil)
            } else {
                if colleges.count >= 12 {
                    simpleAlert("You can only trade with up to 12 colleges.  To add this college, first delete another college you are trading with.")
                } else {
                    selectedCollege! = formattedCollege
                    backToCollegeChooser()
                }
            }
        } else {
            //Take to the details VC
            performSegueWithIdentifier("megara", sender: nil)
        }
    }
    
    
    
    
    
    func backToCollegeChooser() {
        if let stack = self.navigationController?.viewControllers {
            if let previousViewController = stack[stack.count-2] as? CollegeChooser {
                previousViewController.addCollege(selectedCollege!)
                
            }
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    func simpleAlert( message: String) {
        let alert = UIAlertController(title: "Can't Save College", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

    
    
    

    
    
    func formatCollege(chosenCollege: String) -> String? {
        for college in allColleges {
            if college.lowercaseString == chosenCollege.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceCharacterSet()).lowercaseString && college != "" {
                return college
            }
        }
        return nil
    }
    
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "megara" { //Called when you've put in a college we've never heard about
            if let destination = segue.destinationViewController as? UnknownCollegeViewController {
                destination.college = selectedCollege!
                destination.segueLoc = segueLoc
                if myCollege != "no college selected" {
                    destination.myCollege = myCollege
                } else {
                    destination.myCollege = selectedCollege!
                }
            }
        }
        if segue.identifier == "lilo" {
            if let destination = segue.destinationViewController as? CollegeChooser {
                destination.segueLoc = "firstTime"
            }
        }
    }
    
    
}

