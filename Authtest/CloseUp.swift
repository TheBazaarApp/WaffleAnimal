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
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buy: UIButton!
    
    var imageName: String?
    var imageID: String?
    var pic: UIImage?
    var unsold = true
    var location: String? //Later put info from here into a map
    var ref = FIRDatabase.database().reference() //create database reference
    var uid: String?
    var itemDetailsListener: FIRDatabaseHandle?
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSizeMake(320,600) //At some future date if the constraints aren't still trying to destroy our lives, take this out.
        let user = FIRAuth.auth()?.currentUser
        uid = user!.uid
        image.image = pic!
        itemName.text = imageName
        getItemInfo()
    }
    
    
    
    
    //Access Firebase, get and display item pricce, description, and location
    func getItemInfo() {
        var imageRef: FIRDatabaseReference
        if unsold {
            imageRef = ref.child("/user/\(uid!)/unsoldItems/\(imageID!)")
        } else {
            imageRef = ref.child("/user/\(uid!)/soldItems/\(imageID!)")
        }
        itemDetailsListener = imageRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            
            if let allItems = snapshot.value as? [String : AnyObject] {
                self.price.text = allItems["price"] as? String
                self.location = allItems["location"] as? String
                self.itemDescription.lineBreakMode = .ByWordWrapping
                self.itemDescription.numberOfLines = 0
                self.itemDescription.text = allItems["description"] as? String
            } else {
                print("problem!!!")
            }
        })
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
    
    
    
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeObserverWithHandle(itemDetailsListener!)
    }
    
    
    

    
}
