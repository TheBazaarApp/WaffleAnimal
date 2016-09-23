//
//  VerifyCollegeViewController.swift
//  Authtest
//
//  Created by cssummer16 on 8/6/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import Firebase

class VerifyCollegeViewController: UIViewController {
    
    @IBOutlet weak var collegeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let collegeName = mainClass.collegeName!
        collegeLabel.text = collegeName
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "abu" { //College is correct; go to CollegeChooser scene
            if let destination = segue.destinationViewController as? CollegeChooser {
                destination.previousColleges = [String]()
                destination.segueLoc = "firstTime"
            }
        }
        if segue.identifier == "rafiki" { //College is incorrect; go to CollegeChooserTableView scene
            if let destination = segue.destinationViewController as? CollegeChooserTableView {
                destination.segueLoc = "verifyCollege"
            }
        }
    }
}
