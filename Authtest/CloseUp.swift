//
//  CloseUp.swift
//  buy&sell
//
//  Created by cssummer16 on 6/21/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.
//

import UIKit
import Firebase

class CloseUp: UIViewController {
    
    //MARK: VARIABLES AND OUTLETS
    
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buy: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    var imageName: String?
    var imageID: String?
    var pic: UIImage?
    var unsold = true
    var seller: String?
    
    var ref = FIRDatabase.database().reference() //create database reference
    var uid: String?
    var itemDetailsListener: FIRDatabaseHandle?
    let college = "hmc"
    let user = FIRAuth.auth()!.currentUser!.displayName
    var name: String?
    var descript: String?
    var 🔥: String?
    
    var location: String? //Later put info from here into a map
    var lat = 123.45 //default lat and long
    var long = 67.89
    var segueLoc = "CloseUp"
    var latDefault: Double?
    var longDefault: Double?
    var locationLabel: String?
    
    
    
    //MARK: SETUP
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("location is \(location!)")
        locationButton.setTitle(location!, forState: .Normal)
        scrollView.contentSize = CGSizeMake(320,600) //At some future date if the constraints aren't still trying to destroy our lives, take this out.
        
        if let cost = 🔥 {
            print("me == fun")
            price!.text = cost
            itemDescription.text = descript!
        }
        
        itemName.text = name!
        image.image = pic!
        
        getDefault()
        getItemInfo()
    }
    
    
    
    //MARK: FIREBASE FUNCTIONS
    
    
    //Access Firebase, get and display item price, description, and location
    func getItemInfo() {
        var imageRef: FIRDatabaseReference
        if imageID != nil {
            if unsold {
                imageRef = ref.child("\(self.college)/user/\(uid!)/unsoldItems/\(imageID!)")
            } else {
                imageRef = ref.child("\(self.college)/user/\(uid!)/soldItems/\(imageID!)")
            }
            itemDetailsListener = imageRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
                
                if let allItems = snapshot.value as? [String : AnyObject] {
                    self.price.text = allItems["price"] as? String
                    self.location = allItems["location"] as? String
                    self.long = allItems["locationLong"] as! Double
                    self.lat = allItems["locationLat"] as! Double
                    self.itemDescription.lineBreakMode = .ByWordWrapping
                    self.itemDescription.numberOfLines = 0
                    self.itemDescription.text = allItems["description"] as? String
                } else {
                    print("problem!!!")
                }
            })
            
        }
        
    }
    
    
    
    
    func getDefault() {
        if let user = FIRAuth.auth()?.currentUser {
            let dataRef = ref.child("\(self.college)/user/\(user.uid)/profile")
            _ = dataRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                let data = snapshot.value as? [String : AnyObject]
                if let labelText = data?["defaultLocation"] as? String {
                    self.locationLabel = labelText
                }
                if let latText = data?["defaultLatitude"] as? Double {
                    self.latDefault = latText
                }
                if let longText = data?["defaultLongitude"] as? Double {
                    self.longDefault = longText
                }
                else {
                    self.latDefault = 0.0
                    self.longDefault = 0.0
                }
            })
        }
        
    }
    
    
    
    
    
    
    //MARK: ACTIONS AND NAVIGATION
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "nemo" {
            segue.destinationViewController.hidesBottomBarWhenPushed = true
            let chitChat: ChatViewController = segue.destinationViewController as! ChatViewController
            if let receiver = self.seller {
                chitChat.receiver = receiver
                chitChat.receiveruid = self.uid!
            }
        }
        else {
            if segue.identifier == "simba" {
                if let nextController = segue.destinationViewController as? MapViewController {
                    nextController.segueLoc = segueLoc
                    nextController.lat = lat
                    nextController.long = long
                    nextController.latDefault = latDefault
                    nextController.longDefault = longDefault
                }
            }
        }
    }
    
    
    
    
    //When you click "...", an alert comes up from the bottom
    @IBAction func viewMore(sender: AnyObject) {
        let optionsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let message = UIAlertAction(title: "Message", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Message worked!")
        })
        
        let report = UIAlertAction(title: "Report", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Report worked!")
        })
        let wishlist = UIAlertAction(title: "Wishlist", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Wishlist worked!")
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancel worked!")
        })
        optionsMenu.addAction(message)
        optionsMenu.addAction(report)
        optionsMenu.addAction(wishlist)
        optionsMenu.addAction(cancel)
        
        self.presentViewController(optionsMenu, animated: true, completion: nil)
    }
    
    
    
    //Called when the view is disappearing
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if itemDetailsListener != nil {
            ref.removeObserverWithHandle(itemDetailsListener!)
        }
    }
    
    
    
    
    
}

