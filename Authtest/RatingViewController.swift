//
//  RatingViewController.swift
//  Authtest
//
//  Created by cssummer16 on 8/10/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import Firebase

class RatingViewController: UIViewController {
    
    
    
    var sellerName: String?
    var buyerName: String?
    var itemName: String?
    var date: String?
    var status: String?
    var rating: Int?
    var rateeName: String?
    var raterUID: String?
    var rateeUID: String?
    var starArray: [UIButton]!
    var segueLoc: String?
    var notificationID: String?
    var raterCollege = mainClass.domainBranch!
    var rateeCollege: String?
    let ref = FIRDatabase.database().reference()
    
    
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var buyerLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var rateTitleLabel: UILabel!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = true
        sellerLabel.text = sellerName!
        buyerLabel.text = buyerName!
        itemLabel.text = itemName!
        dateLabel.text = date!
        statusLabel.text = status!
        rateTitleLabel.text = "Please Rate \(rateeName!)"
        starArray = [star1, star2, star3, star4, star5]
    }
    
    
    @IBAction func clickedStar1(sender: AnyObject) {
        changeStarColors(1)
    }
    
    @IBAction func clickedStar2(sender: AnyObject) {
        changeStarColors(2)
    }
    
    @IBAction func clickedStar3(sender: AnyObject) {
        changeStarColors(3)
    }
    
    @IBAction func clickedStar4(sender: AnyObject) {
        changeStarColors(4)
    }
    
    @IBAction func clickedStar5(sender: AnyObject) {
        changeStarColors(5)
    }
    
    
    
    func changeStarColors(rating: Int) {
        self.rating = rating
        for (index, star) in starArray.enumerate() {
            if index < rating {
                star.setImage(UIImage(named: "Filled Star"), forState: .Normal)
            } else {
                star.setImage(UIImage(named: "rating"), forState: .Normal)
            }
        }
    }
    
    
    
    
    
    @IBAction func submitRating(sender: AnyObject) { //Complain if no stars selected
        if rating != nil {
            updateDatabaseAfterRating()
        } else {
            let ac = UIAlertController(title: "You Must Select A Rating Before Saving", message: nil, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    
    
    
    func updateDatabaseAfterRating() {
        let pathToRating = mainClass.ref.child("\(rateeCollege!)/user/\(rateeUID!)/profile/rating")
        var currentRating: Double?
        var ratingCount = 0
        pathToRating.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if snapshot.value != nil {
                currentRating = snapshot.value as? Double
            }
            let pathToRatingCount = mainClass.ref.child("\(self.rateeCollege!)/user/\(self.rateeUID!)/profile/ratingCount")
            pathToRatingCount.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let count = snapshot.value as? Int {
                    ratingCount = count
                }
                var newRating = Double(self.rating!)
                if currentRating != nil {
                    newRating = (Double(ratingCount) * currentRating! + Double(self.rating!)) / (Double(ratingCount) + 1)
                }
                
                //Remove notification
                //Update the person's rating
                let childUpdates = ["\(self.raterCollege)/user/\(self.raterUID!)/notifications/\(self.notificationID!)" : NSNull(),
                    "\(self.rateeCollege!)/user/\(self.rateeUID!)/profile/rating" : newRating,
                    "\(self.rateeCollege!)/user/\(self.rateeUID!)/profile/ratingCount" : ratingCount + 1
                ]
                
                mainClass.ref.updateChildValues(childUpdates)
                self.pop()
            })
        })
    }
    
    
    
    @IBAction func rateLater(sender: AnyObject) {
        if segueLoc != "notifications" {
            let ac = UIAlertController(title: "This transactions will be available in your notifications.", message: nil, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (UIAlertAction) -> Void in
                self.pop()
            }))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            pop()
        }
    }
    
    func pop () {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    
}
