//
//  CollegeChooser.swift
//  Authtest
//
//  Created by cssummer16 on 8/3/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

//GOOD PLACES TO GET A GOOD COLLEGE LIST:
//https://raw.githubusercontent.com/Hipo/university-domains-list/master/world_universities_and_domains.json
//http://pastebin.com/LND21t5F
//http://stackoverflow.com/questions/9673214/where-can-i-get-a-list-of-all-college-university-e-mail-domains
//http://doors.stanford.edu/~sr/universities.html

import UIKit
//import RAMReel
import Firebase


class CollegeChooser: UIViewController {
    
    //var dataSource: SimplePrefixQueryDataSource!
    //var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
    
    
    @IBOutlet weak var selectedCollegesHolder: UIView!
    @IBOutlet weak var myCollegeBox: UILabel!
    var myCollege = mainClass.domainBranch
    var myCollegeName = mainClass.collegeName
    var collText = ""
    var numColleges = 0
    let font = UIFont.boldSystemFontOfSize(CGFloat(15.0))
    let textColor = UIColor.cyanColor()
    let listBackgroundColor = UIColor.greenColor()
    var collList = [String]()
    var previousColleges = [String]()
    let ref = FIRDatabase.database().reference() //Root of the realtime database
    //let uid = FIRAuth.auth()!.currentUser!.uid
    var segueLoc = ""
    var previousVC: ViewController?
    
    @IBOutlet weak var addAnotherCollege: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedCollegesHolder.layer.cornerRadius = 5
        addAnotherCollege.layer.cornerRadius = 5
        if myCollegeName != nil {
            myCollegeBox.text = " " + myCollegeName!
        } else {
            myCollegeBox.text = " no college selected"
        }
        
        for col in previousColleges {
            addCollege(col)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.navigationBarHidden = true
    }
    
    
    
    @IBAction func cancelPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func savePressed(sender: AnyObject) {
        if segueLoc == "skipAndBrowse" || segueLoc == "feed" {
            saveCollegesToLocalStorage()
        } else {
            saveColleges()
            if segueLoc == "firstTime" {
                performSegueWithIdentifier("maleficent", sender: nil)
            } else {
                navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    
    
    
    func saveColleges() {
        var colDomains = [String]()
        var colsWithoutDomains = [String]()
        for college in collList {
            if let colDomain = mainClass.emailGetter.getDomainFromName(college) {
                colDomains.append(colDomain)
            } else {
                colsWithoutDomains.append(college)
            }
        }
        var collegeDetails = [String: NSObject]()
        
        if colDomains.count > 0 {
            collegeDetails["colleges"] = NSArray(array: colDomains)
        } else {
            collegeDetails["colleges"] = NSNull()
        }
        
        if colsWithoutDomains.count > 0 {
            collegeDetails["collegesWithoutDomains"] = NSArray(array: colsWithoutDomains)
        } else {
            collegeDetails["collegesWithoutDomains"] = NSNull()
        }
        ref.child("\(myCollege!)/user/\(mainClass.uid!)/settings").setValue(collegeDetails)
    }
    
    
    
    func saveCollegesToLocalStorage() {
        
        var colDomains = [String]()
        for college in collList {
            if let colDomain = mainClass.emailGetter.getDomainFromName(college) {
                colDomains.append(colDomain)
            }
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(colDomains, forKey: "skipAndBrowseColleges")
        if segueLoc == "skipAndBrowse" {
            previousVC!.goToFeed()
        }
        if segueLoc == "feed" {
            if let stack = self.navigationController?.viewControllers {
                if let previousViewController = stack[stack.count-2] as? FeedController {
                    previousViewController.resetCollegeListeners()
                }
                navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    
    
    
    
    func addCollege(college: String) {
        collList.append(college)
        let collegeLabel = UILabel()
        collegeLabel.text = college
        collegeLabel.numberOfLines = 1
        selectedCollegesHolder.addSubview(collegeLabel)
        collegeLabel.translatesAutoresizingMaskIntoConstraints = false
        collegeLabel.tag = numColleges
        
        let xButton = UIButton()
        xButton.setTitle("x", forState: .Normal)
        xButton.backgroundColor = UIColor.blackColor()
        xButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        xButton.layer.cornerRadius = 10
        selectedCollegesHolder.addSubview(xButton)
        xButton.translatesAutoresizingMaskIntoConstraints = false
        xButton.addTarget(self, action: #selector(xPressed), forControlEvents: UIControlEvents.TouchUpInside)
        xButton.tag = numColleges
        
        
        
        
        let viewsDict = ["collegeLabel": collegeLabel,
                         "xButton": xButton]
        
        selectedCollegesHolder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[collegeLabel]-5-[xButton(20)]-|", options: [], metrics: nil, views: viewsDict))
        selectedCollegesHolder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(25 * numColleges)-[collegeLabel(25)]", options: [], metrics: nil, views: viewsDict))
        selectedCollegesHolder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(25 * numColleges + 2)-[xButton(20)]", options: [], metrics: nil, views: viewsDict))
        
        numColleges += 1
    }
    
    
    func xPressed(sender:UIButton!) { 
        let tagID = sender.tag
        collList.removeAtIndex(tagID)
        
        let subviewList = selectedCollegesHolder.subviews
        let lastX = subviewList[subviewList.count - 1]
        let lastLabel = subviewList[subviewList.count - 2]
        lastX.removeFromSuperview()
        lastLabel.removeFromSuperview()
        
        for view in selectedCollegesHolder.subviews {
            let tag = view.tag
            if tag >= tagID {
                if view.dynamicType === UILabel.self && tag >= tagID {
                    let label = view as! UILabel
                    label.text = collList[tag]
                }
            }
            
        }
        numColleges -= 1
    }
    
    
    
    
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "eric" { //Called when the user clicks on the "Add College" button
            if let destination = segue.destinationViewController as? CollegeChooserTableView {
                destination.myCollege = myCollegeName ?? "no college selected"
                destination.colleges = collList
            }
        }
        if segue.identifier == "maleficent" {
            if let destination = segue.destinationViewController as? ViewController {
                destination.segueLoc = "collegeChooser"
            }
        }
    }
    
    
}

