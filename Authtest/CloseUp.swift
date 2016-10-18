//
//  CloseUp.swift
//  buy&sell
//
//  Created by cssummer16 on 6/21/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.
//

import UIKit
import Firebase
import MessageUI
import OneSignal

class CloseUp: UIViewController, MFMailComposeViewControllerDelegate {
    
    
    
    //MARK: VARIABLES AND OUTLETS
    
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buy: UIButton!
    @IBOutlet weak var purpleText: UILabel!
    @IBOutlet weak var cancel: UIImageView!
    @IBOutlet weak var pin: UIImageView!
    @IBOutlet weak var message: UIImageView!
    @IBOutlet weak var sellerName: UILabel!
    @IBOutlet weak var blueBox: UILabel!
    @IBOutlet weak var viewInsideScrollview: UIView!
    @IBOutlet weak var viewMore: UIImageView!
    @IBOutlet weak var buyBottomConstraint: NSLayoutConstraint!

    
    
    
    
    
    var imageName: String?
    var imageID: String?
    var albumID: String?
    var pic: UIImage?
    var seller: String?
    var ref = FIRDatabase.database().reference()
    var sellerUID: String?
    var itemDetailsListener: FIRDatabaseHandle?
    var myCollege = mainClass.domainBranch
    var sellerCollege: String?
    var currentUsername: String?
    var name: String?
    var descript: String?
    var 🔥: String?
    var lat: Double?
    var long: Double?
    var segueLoc = "CloseUp"
    var latDefault: Double?
    var longDefault: Double?
    var location: String?
    var locationLabel: String?
    var storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com")
    var category = "unsold"
    var buyerName: String?
    var buyerCollege: String?
    var buyerUID: String?
    var notificationID: String?
    var transactionCanceled = false
    var cancelTransactionButton = UIButton()
    var totallyDeleted = false
    var tag = ""
    var myFault = false //Used to make sure that the "Item has been bought" popup doesn't show up if its location has been changed b/c of something you did
    var hasPic = true
    var imageRef: FIRDatabaseReference!
    var aaa: FIRDatabaseHandle?
    var sellerHolder = IDHolder()
    var buyerHolder = IDHolder()

    
    //MARK: SETUP
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        if category == "sold" {
            if !transactionCanceled {
                buy.setTitle("Confirm Finished Transaction", forState: .Normal)
            } else {
                buy.setTitle("Add This Item Back to the Feed", forState: .Normal)
                cancelTransactionButton.setTitle("Delete This Item Forever", forState: .Normal)
            }
            
            buy.titleLabel!.font = UIFont.boldSystemFontOfSize(CGFloat(20.0))
            buy.setTitleColor(UIColor.blackColor(), forState: .Normal)
            addSecondButton()
        }
        if category == "purchased" {
            buy.setTitle("Cancel Transaction", forState: .Normal)
            buy.titleLabel!.font = UIFont.boldSystemFontOfSize(CGFloat(20.0))
            buy.backgroundColor = .blackColor()
            buy.setTitleColor(.whiteColor(), forState: .Normal)
        }
        self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = true
        buy.layer.cornerRadius = 5
        purpleText.layer.cornerRadius = 50
        let cancelButton = UITapGestureRecognizer(target:self, action: #selector(cancelTapped))
        let pinButton = UITapGestureRecognizer(target:self, action: #selector(pinTapped))
        let messageButton = UITapGestureRecognizer(target:self, action: #selector(messageTapped))
        let edgePan = UIScreenEdgePanGestureRecognizer(target:self, action: #selector(cancelTapped))
        let viewMoreButton = UITapGestureRecognizer(target:self, action: #selector(viewMoreImageTapped))
        edgePan.edges = .Left
        self.view.addGestureRecognizer(edgePan)
        cancel.addGestureRecognizer(cancelButton)
        pin.addGestureRecognizer(pinButton)
        message.addGestureRecognizer(messageButton)
        viewMore.addGestureRecognizer(viewMoreButton)
        buy.translatesAutoresizingMaskIntoConstraints = true //TODO: Problematic!?
        let width = self.view.frame.size.width
        buy.frame = CGRectMake(5, width + 60, width - 10, 40)
        
        if let currUser = FIRAuth.auth()?.currentUser {
            currentUsername = currUser.displayName
            if currUser.uid == sellerUID {
                //You're looking at your own item, so don't let you message yourself
                if category != "sold" {
                    hideViewMore()
                }
            }
        }
        
        if let cost = 🔥 {
            price.text = cost
            itemDescription.text = descript!
        }
        if let name = name {
            itemName.text = name
        }
        
        sellerName.text = seller
        if let pic = pic {
            image.image = pic
        }
        
        getDefault()
        getItemInfo()
        if let sellerID = sellerUID {
            mainClass.getNotificationID(sellerID, holder: sellerHolder)

        }
        if let buyerId = buyerUID {
            mainClass.getNotificationID(buyerId, holder: buyerHolder)
        }
    }
    
    
    
    func hideViewMore() {
        viewMore.hidden = true
        message.hidden = true
        pin.translatesAutoresizingMaskIntoConstraints = true //TOD: Is this problematic?
        pin.frame.origin.x = view.frame.width - 35
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if totallyDeleted {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    
    func addSecondButton() {
        let width = self.view.frame.size.width
        cancelTransactionButton.frame = CGRectMake(5, width + 110, width - 10, 40) //TOD: Is this problematic?
        if transactionCanceled {
            cancelTransactionButton.setTitle("Delete Item Forever", forState: .Normal)
        } else {
            cancelTransactionButton.setTitle("Cancel Transaction", forState: .Normal)
        }
        cancelTransactionButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cancelTransactionButton.titleLabel!.font = UIFont.boldSystemFontOfSize(CGFloat(20.0))
        cancelTransactionButton.backgroundColor = UIColor.blackColor()
        cancelTransactionButton.layer.cornerRadius = 5
        cancelTransactionButton.addTarget(self, action: #selector(pushedSecondButton), forControlEvents: UIControlEvents.TouchUpInside)
        viewInsideScrollview.insertSubview(cancelTransactionButton, aboveSubview: blueBox)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = true
    }
    
    func cancelTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func pinTapped() {
        self.performSegueWithIdentifier("simba", sender: self)
    }
    
    func messageTapped() {
        self.performSegueWithIdentifier("nemo", sender: self)
        
    }
    
    func viewMoreImageTapped() {
        let optionsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        
        let report = UIAlertAction(title: "Report", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
                //self.sendReportNotification()
                self.performSegueWithIdentifier("merida", sender: nil)
        })
        
        var title = "View Seller's Profile"
        if category == "sold" {
            title = "View Buyer's Profile"
        }
        let profile = UIAlertAction(title: title, style: .Default, handler: { (alert: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("elsa", sender: nil)
        })
        
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        
        
        
        
        if mainClass.uid != sellerUID {
            optionsMenu.addAction(report)
        }
        optionsMenu.addAction(profile)
        optionsMenu.addAction(cancel)
        self.presentViewController(optionsMenu, animated: true, completion: nil)
        
    }
    
    func removeSecondButton() {
        blueBox.frame.origin.y -= 50 //TODO: Maybe remove this line
        let width = self.view.frame.size.width
        buy.frame = CGRectMake(5, width + 60, width - 10, 40)
        buy.setTitle("Buy", forState: .Normal)
        buy.titleLabel!.font = UIFont.boldSystemFontOfSize(CGFloat(28.0))
        buy.setTitleColor(mainClass.ourBlue, forState: .Normal)
        blueBox.frame = CGRectMake(5, width + 120, width - 10, blueBox.frame.size.height)
        cancelTransactionButton.removeFromSuperview() //TOD: Is this problematic?
        category = "unsold"
    }
    
    //MARK: FIREBASE FUNCTIONS
    
    
    //Access Firebase, get and display item price, description, and location
    func getItemInfo() {
        //var imageRef = ref
        if imageID != nil {
            if category == "unsold" || category == "sold" {
                imageRef = ref.child("\(self.sellerCollege!)/user/\(sellerUID!)/\(category)Items/\(imageID!)")
            } else {
                imageRef = ref.child("\(mainClass.domainBranch!)/user/\(mainClass.uid!)/\(category)Items/\(imageID!)")
            }
            
            itemDetailsListener = imageRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
                if let itemData = snapshot.value as? [String : AnyObject] {
                    self.tag = itemData["tag"] as! String
                    var price = String(itemData["price"] as! Double)
                    if price == "-0.1134" {
                        price = "0"
                    }
                    self.price.text = price
                    self.itemDescription.lineBreakMode = .ByWordWrapping
                    self.itemDescription.numberOfLines = 10
                    self.blueBox.numberOfLines = 30
                    self.blueBox.lineBreakMode = .ByWordWrapping
                    if let description = itemData["description"] as? String {
                        self.itemDescription.text = description
                    } else {
                        self.itemDescription.text = ""
                    }
                    
                    
                    
                    
                    self.name = itemData["name"] as? String
                    if self.tag == "In Search Of" {
                        self.itemName.text = "In Search Of: " + self.name!
                    } else {
                        self.itemName.text = self.name!
                    }
                    
                    
                    
                    if let location = itemData["location"] {
                        self.location = location as? String
                    }
                    if let lat = itemData["locationLat"] {
                        
                        self.lat = lat as? Double
                        self.long = itemData["locationLong"] as? Double
                    } else {
                        self.pin.hidden = true
                    }
                    
                    
                    self.formatBlueBox()
                    
                    
                    
                    if self.category == "sold" {
                        
                        if (itemData["cancelled"] as? Bool) != nil {
                            self.transactionCanceled = true
                            self.buy.setTitle("Restore Item to the Feed", forState: .Normal)
                            self.cancelTransactionButton.setTitle("Delete Item Forever", forState: .Normal)
                        }
                        self.buyerName = itemData["buyerName"] as? String
                        self.buyerUID = itemData["buyerID"] as? String
                        self.buyerCollege = itemData["buyerCollege"] as? String
                        self.sellerName.text = "Bought by: \(self.buyerName!)"
                        self.blueBox.center.y += 50
                    } else {
                        self.seller = itemData["sellerName"] as? String
                        self.sellerName.text = self.seller! //TODO: Crashed here!  Why???
                    }
                } else { //The snapshot is blank (b/c the item has been deleted (presumably)
                    if self.itemDescription.text == "Description" {
                        self.itemDescription.text = ""
                        self.formatBlueBox()
                    }
                    if !self.myFault { //Only show the popup if the item has disappeared for some reason that's not your fault
                        var message = "Looks like you're too late."
                        if self.category == "unsold" {
                            message += "Buy faster next time!"
                        }
                        
                        let alert = UIAlertController(title: "Item Has Been Bought, Moved, or Deleted", message: message, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
                            self.navigationController?.popViewControllerAnimated(true)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                if self.segueLoc == "Notifications" {
                    let imageLocation = self.storageRef.child("\(self.sellerCollege!)/user/\(self.sellerUID!)/images/\(self.imageID!)")
                    imageLocation.downloadURLWithCompletion{ (URL, error) -> Void in
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                            if error != nil {
                                self.image.image = mainClass.defaultPic(self.tag)
                            }
                            else {
                                if let picData = NSData(contentsOfURL: URL!) {
                                    let picture = UIImage(data: picData)
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.image.image = picture
                                    }
                                }
                                else {
                                    self.image.image = mainClass.defaultPic(self.tag)
                                }
                            }
                        }
                    }
                }
                self.myFault = false
            })
        }
    }
    
    
    
    
    func formatBlueBox() {
        //buyBottomConstraint.active = false
        blueBox.translatesAutoresizingMaskIntoConstraints = true
        let width = self.view.frame.width
        let textHeight = mainClass.heightForView(self.itemDescription.text!, font: UIFont.systemFontOfSize(17), width: width - 10)
        if category == "sold" {
            self.blueBox.frame = CGRectMake(5, width + 130, width - 10, textHeight + 190)
        } else {
            self.blueBox.frame = CGRectMake(5, width + 130, width - 10, textHeight + 140)
        }
    }
    
    
    
    
    
    func getDefault() {
        if let user = FIRAuth.auth()?.currentUser {
            let dataRef = ref.child("\(self.myCollege!)/user/\(user.uid)/profile")
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
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "nemo" { //Go to messaging
            segue.destinationViewController.hidesBottomBarWhenPushed = true
            let chitChat = segue.destinationViewController as! ChatViewController
            if category == "sold" {
                chitChat.receiver = buyerName!
                chitChat.receiveruid = buyerUID!
                chitChat.otherPersonsCollege = buyerCollege!
            } else {
                if let receiver = self.seller {
                    chitChat.receiver = receiver
                    chitChat.receiveruid = sellerUID!
                    chitChat.otherPersonsCollege = sellerCollege!
                }
            }
            chitChat.segueLoc = "CloseUp"
        }
        if segue.identifier == "simba" { //Go to map
            if let nextController = segue.destinationViewController as? MapViewController {
                nextController.segueLoc = "CloseUp"
                nextController.lat = lat!
                nextController.long = long!
                nextController.latDefault = latDefault
                nextController.longDefault = longDefault
                if location != nil {
                    nextController.locationDescription = location!
                }
            }
        }
        if segue.identifier == "elsa" {
            if let nextController = segue.destinationViewController as? ProfileViewController {
                if category == "sold" {
                    nextController.uid = buyerUID!
                    nextController.college = buyerCollege!
                } else {
                    nextController.uid = sellerUID!
                    nextController.college = sellerCollege!
                }
                nextController.segueLoc = "closeup"
            }
        }
        if segue.identifier == "merlin" {
            //Called when the seller says the transaction is complete
            if let nextController = segue.destinationViewController as? RatingViewController {
                nextController.sellerName = FIRAuth.auth()!.currentUser!.displayName
                nextController.buyerName = buyerName!
                nextController.itemName = itemName.text!
                nextController.date = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
                nextController.status = "Transaction Complete"
                nextController.rateeName = buyerName!
                nextController.raterUID = sellerUID!
                nextController.rateeUID = buyerUID!
                nextController.segueLoc = "closeup"
                nextController.notificationID = notificationID!
                nextController.rateeCollege = buyerCollege!
            }
        }
        if segue.identifier == "merida" {
            if let nextController = segue.destinationViewController as? ReportViewController {
                nextController.sellerName = seller!
                nextController.sellerCollege = sellerCollege!
                nextController.sellerID = sellerUID!
                nextController.itemName = name!
                nextController.itemDescription = itemDescription.text!
                nextController.albumID = albumID!
                nextController.imageID = imageID!
            }
        }
    }
    
       
    func tooBadLogIn(activity: String) {
        let reportAnonymous = UIAlertController(title: "Please Sign Up/Log In", message: "To \(activity), please sign up or log in and then try again.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
        reportAnonymous.addAction(cancelAction)
        self.presentViewController(reportAnonymous, animated: true, completion: nil)
    }
    
    
    
    
    
    
    @IBAction func pressedBuy(sender: AnyObject) {
        if !transactionCanceled {
            if category == "unsold" {
                boughtItem()
            }
            if category == "sold" {
                clickedConfirmTransaction()
            }
            if category == "purchased" {
                clickedBuyerCancelledTransaction()
            }
        } else {
            if category == "sold" {
                clickedBackToFeed()
            }
        }
    }
    
    
    
    
    
    func clickedBackToFeed() {
        let areYouSure = UIAlertController(title: "Are You Sure You Want to Return This To The Feed?", message: nil, preferredStyle: .Alert)
        
        areYouSure.addAction(UIAlertAction(title: "Yes", style: .Default) { (alertAction) -> Void in
            self.myFault = true
            self.restoreToFeed()
            self.transactionCanceled = false
            self.removeSecondButton()
            self.transactionCanceled = true
            })
        areYouSure.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        presentViewController(areYouSure, animated: true, completion: nil)
    }
    
    
    
    func restoreToFeed() {
        transactionCanceled = false
        
        let pathToUserUnsoldItems = "/\(sellerCollege!)/user/\(sellerUID!)/unsoldItems/\(imageID!)"
        let pathToUserAlbumItem = "/\(sellerCollege!)/user/\(sellerUID!)/albums/\(albumID!)/unsoldItems/\(imageID!)"
        let pathToUserAlbumDetails = "/\(sellerCollege!)/user/\(sellerUID!)/albums/\(albumID!)/albumDetails"
        let pathToCollegeAlbumItem = "/\(sellerCollege!)/albums/\(albumID!)/unsoldItems/\(imageID!)"
        let pathToCollegeAlbumDetails = "/\(sellerCollege!)/albums/\(albumID!)/albumDetails"
        let pathToUserSoldItems = "/\(sellerCollege!)/user/\(sellerUID!)/soldItems/\(imageID!)"
        
        let itemInfo = ref.child("/\(sellerCollege!)/user/\(sellerUID!)/soldItems/\(imageID!)")
        itemInfo.observeSingleEventOfType(.Value, withBlock:  { snapshot in
            if let itemData = snapshot.value as? [String: AnyObject] {
                //Reformat this to work with the way things are structured in different places
                
                var userUnsoldItemsData = itemData
                userUnsoldItemsData["buyerCollege"] = nil
                userUnsoldItemsData["buyerID"] = nil
                userUnsoldItemsData["buyerName"] = nil
                userUnsoldItemsData["sellerId"] = self.sellerUID!
                userUnsoldItemsData["sellerName"] = mainClass.displayName!
                userUnsoldItemsData["cancelled"] = nil
                var albumItemDetails = ["description": self.itemDescription.text!,
                    "name": self.name!,
                    "price": self.price.text!,
                    "tag" : itemData["tag"]!,
                ]
                
                if !self.hasPic {
                    albumItemDetails["hasPic"] = false
                }
                
                var userAlbumDetails = ["albumName" : itemData["albumName"]!,
                    "timestamp" : NSDate().timeIntervalSince1970 * -1]
                if let location = itemData["location"] {
                    userAlbumDetails["location"] = location
                }
                if let locationLat = itemData["locationLat"] {
                    userAlbumDetails["locationLat"] = locationLat
                }
                if let locationLong = itemData["locationLong"] {
                    userAlbumDetails["locationLong"] = locationLong
                }
                
                var collegeAlbumDetails = userAlbumDetails
                collegeAlbumDetails["sellerID"] = mainClass.uid!
                collegeAlbumDetails["sellerName"] = mainClass.displayName!
                
                let childUpdates = [pathToUserUnsoldItems : userUnsoldItemsData,
                    pathToUserAlbumItem : albumItemDetails,
                    pathToUserAlbumDetails : userAlbumDetails,
                    pathToCollegeAlbumItem : albumItemDetails,
                    pathToCollegeAlbumDetails : collegeAlbumDetails,
                    pathToUserSoldItems : NSNull()]
                
                self.ref.updateChildValues(childUpdates)
                
            }
        })
    }
    
    
    
    
    func clickedBuyerCancelledTransaction() {
        let areYouSure = UIAlertController(title: "Are You Sure?", message: "If you cancel this transaction, you and the seller will still be able to rate each other.", preferredStyle: .Alert)
        
        areYouSure.addAction(UIAlertAction(title: "Cancel Transaction", style: .Default) { (alertAction) -> Void in
            self.myFault = true
            self.deletePurchasedItem(mainClass.domainBranch!, buyerUID: mainClass.uid!)
            self.sendRatingNoficication(self.sellerName.text!, sellerUID: self.sellerUID!, sellerCollege: self.sellerCollege!, buyerName: mainClass.displayName!, buyerUID: mainClass.uid!, buyerCollege: mainClass.domainBranch!, status: "Buyer Cancelled Transaction")
            self.sendBuyerRejectedNotification()
            self.markTransactionAsCancelled()
            self.transactionCanceled = true
            self.explainWhereRatingIs()
            })
        areYouSure.addAction(UIAlertAction(title: "Never Mind", style: .Cancel, handler: nil))
        presentViewController(areYouSure, animated: true, completion: nil)
    }
    
    
    func explainWhereRatingIs() {
        let areYouSure = UIAlertController(title: "Rating Available", message: "You can rate the seller by visiting your notifications.", preferredStyle: .Alert)
        areYouSure.addAction(UIAlertAction(title: "Okay", style: .Default) { (alertAction) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
            })
        presentViewController(areYouSure, animated: true, completion: nil)
    }
    
    
    
    func sendBuyerRejectedNotification() {
        let messageDetails = ["message" : "\(mainClass.displayName!) cancelled the sale of your \(name!)!",
                              "type" : "BuyerRejected",
                              "picUid": imageID!, //
            "name": name!, //presumably item name
            "uid": sellerUID!,
            "albumID": albumID!,
            "seller": self.sellerName.text!]
        
        ref.child("/\(sellerCollege!)/user/\(sellerUID!)/notifications").childByAutoId().updateChildValues(messageDetails)
        
    }
    
    
    
    
    func clickedConfirmTransaction() {
        let ac = UIAlertController(title: "Are you sure?", message: "Marking the transaction as complete will completely remove it from our database.  Only do this after the buyer has received the item and you have received your payment.", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "Complete Transaction", style: .Default) { (alertAction) -> Void in
            self.myFault = true
            self.sendRatingNoficication(mainClass.displayName!, sellerUID: mainClass.uid!, sellerCollege: mainClass.domainBranch!, buyerName: self.buyerName!, buyerUID: self.buyerUID!, buyerCollege: self.buyerCollege!, status: "Transaction Complete")
            self.deleteSoldItem()
            self.deletePurchasedItem(self.buyerCollege!, buyerUID: self.buyerUID!)
            self.totallyDeleted = true
            self.ratingTime()
            })
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    
    
    
    func ratingTime() {
        performSegueWithIdentifier("merlin", sender: nil)
    }
    
    
    
    
    
    
    func boughtItem() {
        if currentUsername != nil {
            if sellerUID != FIRAuth.auth()?.currentUser?.uid {
                let areYouSure = UIAlertController(title: "Are you sure?", message: "Buying this item takes it off the feed", preferredStyle: .Alert)
                let buyItAction = UIAlertAction(title: "Buy!", style: .Default) { (alertAction) -> Void in
                    self.myFault = true
                    self.changeInDatabase()
                    self.exchangeColleges()
                    self.category = "purchased"
                    self.buy.setTitle("Cancel Transaction", forState: .Normal)
                    self.buy.backgroundColor = .blackColor()
                    self.buy.setTitleColor(.whiteColor(), forState: .Normal)
                    self.buy.titleLabel!.font = UIFont.boldSystemFontOfSize(CGFloat(20.0))
                    let messageSeller = UIAlertController(title: "Do you want to message the seller?", message: "You can message the seller to arrange a pickup time and place.", preferredStyle: .Alert)
                    let okayAction = UIAlertAction(title: "Message Seller", style: .Default) { (alertAction) -> Void in
                        self.performSegueWithIdentifier("nemo", sender: nil)
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                    messageSeller.addAction(okayAction)
                    messageSeller.addAction(cancelAction)
                    
                    
                    self.presentViewController(messageSeller, animated: true, completion: nil)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                areYouSure.addAction(buyItAction)
                areYouSure.addAction(cancelAction)
                self.presentViewController(areYouSure, animated: true, completion: nil)
                
            }
            else {
                let ac = UIAlertController(title: "LOL", message: "You can't buy your own item noob", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
            }
        } else {
            tooBadLogIn("buy this item")
        }
    }
    
    
    
    
    func pushedSecondButton() {
        //If the transaction hasn't been cancelled yet, the user is pushing the "Cancel Transaction" button
        if !transactionCanceled {
            let areYouSure = UIAlertController(title: "Are You Sure?", message: "If you cancel this transaction, you and the buyer will still be able to rate each other.", preferredStyle: .Alert)
            
            areYouSure.addAction(UIAlertAction(title: "Cancel Transaction", style: .Default) { (alertAction) -> Void in
                self.sendRatingNoficication(mainClass.displayName!, sellerUID: mainClass.uid!, sellerCollege: mainClass.domainBranch!, buyerName: self.buyerName!, buyerUID: self.buyerUID!, buyerCollege: self.buyerCollege!, status: "Seller Cancelled Transaction")
                self.deletePurchasedItem(self.buyerCollege!, buyerUID: self.buyerUID!)
                self.markTransactionAsCancelled()
                self.buy.setTitle("Restore Item to the Feed", forState: .Normal)
                self.cancelTransactionButton.setTitle("Delete This Item Forever", forState: .Normal)
                self.transactionCanceled = true
                })
            areYouSure.addAction(UIAlertAction(title: "Never Mind", style: .Cancel, handler: nil))
            presentViewController(areYouSure, animated: true, completion: nil)
        } else { //If the transaction is already cancelled, the user is pushing the "Delete Forever" button
            let areYouSure = UIAlertController(title: "Are You Sure?", message: "This item will be permanently deleted from our database.", preferredStyle: .Alert)
            areYouSure.addAction(UIAlertAction(title: "Delete", style: .Default) { (alertAction) -> Void in
                self.myFault = true
                self.deleteSoldItem()
                self.navigationController?.popViewControllerAnimated(true)
                })
            areYouSure.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            presentViewController(areYouSure, animated: true, completion: nil)
        }
    }
    
    
    
    func markTransactionAsCancelled() {
        ref.updateChildValues(["\(sellerCollege!)/user/\(sellerUID!)/soldItems/\(imageID!)/cancelled" : true])
    }
    
    
    func sendRatingNoficication(sellerName: String, sellerUID: String, sellerCollege: String, buyerName: String, buyerUID: String, buyerCollege: String, status:String) {
        
        
        
        var buyerNotificationDetails = ["sellerName" : sellerName,
                                        "buyerName" : buyerName,
                                        "itemName" : itemName.text!,
                                        "date" : NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle),
                                        "status" : status,
                                        "rateeName" : sellerName,
                                        "rateeUID" : sellerUID,
                                        "rateeCollege" : sellerCollege]
        
        var sellerNotificationDetails = ["sellerName" : sellerName,
                                         "buyerName" : buyerName,
                                         "itemName" : itemName.text!,
                                         "date" : NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle),
                                         "status" : status,
                                         "rateeName" : buyerName,
                                         "rateeUID" : buyerUID,
                                         "rateeCollege" : buyerCollege]
        
        if status == "Seller Cancelled Transaction" {
            buyerNotificationDetails["message"] = "\(sellerName) cancelled the sale of the \(itemName.text!)"
            buyerNotificationDetails["type"] = "SellerRejected"
            OneSignal.postNotification(["contents": ["en": "Please rate \(sellerName) after your cancelled transaction"], "headings": ["en": "\(sellerName) cancelled the sale of the \(itemName.text!)"], "include_player_ids": [self.buyerHolder.id]])
            
            sellerNotificationDetails["message"] = "Please rate \(buyerName) after your cancelled transaction."
            sellerNotificationDetails["type"] = "Rating"
            
        }
        if status == "Transaction Complete" {
            buyerNotificationDetails["message"] = "Please rate \(sellerName) after your transaction."
            buyerNotificationDetails["type"] = "Rating"
            OneSignal.postNotification(["contents": ["en": "Please rate \(sellerName) after your  transaction"], "headings": ["en": "\(sellerName) confirmed the sale of the \(itemName.text!)"], "include_player_ids": [self.buyerHolder.id]])
            
            sellerNotificationDetails["message"] = "Please rate \(buyerName) after your transaction."
            sellerNotificationDetails["type"] = "Rating"
        }
        if status == "Buyer Cancelled Transaction" {
            buyerNotificationDetails["message"] = "Please rate \(sellerName) after your cancelled transaction."
            buyerNotificationDetails["type"] = "Rating"
            
            sellerNotificationDetails["message"] = "\(buyerName) cancelled the sale of the \(itemName.text!)"
            sellerNotificationDetails["type"] = "Rating"
            OneSignal.postNotification(["contents": ["en": "Please rate \(buyerName) after your cancelled transaction"], "headings": ["en": "\(buyerName) cancelled the sale of the \(itemName.text!)"], "include_player_ids": [self.sellerHolder.id]])
            
        }
        
        let pathToBuyerNotification = "/\(buyerCollege)/user/\(buyerUID)/notifications/"
        let buyerKey = ref.child(pathToBuyerNotification).childByAutoId().key
        
        let pathToSellerNotification = "/\(sellerCollege)/user/\(sellerUID)/notifications/"
        let sellerKey = ref.child(pathToSellerNotification).childByAutoId().key
        self.notificationID = sellerKey
        
        let childUpdates = [pathToBuyerNotification + "/\(buyerKey)" : buyerNotificationDetails,
                            pathToSellerNotification + "/\(sellerKey)" : sellerNotificationDetails]
        
        ref.updateChildValues(childUpdates)
        
    }
    
    
    
    
    //After the user marks a transaction as complete OR the seller or buyer rejects the transaction, call this function
    func deletePurchasedItem(buyerCollege: String, buyerUID: String) {
        ref.child("\(buyerCollege)/user/\(buyerUID)/purchasedItems/\(imageID!)").setValue(NSNull())
    }
    
    
    
    
    //After the user marks a transaction as complete OR the seller completely deletes an item, call this function
    func deleteSoldItem() {
        //Delete the item from the seller's sold items
        ref.child("\(self.sellerCollege!)/user/\(sellerUID!)/soldItems/\(imageID!)").setValue(NSNull())
        let soldLocation = storageRef.child("\(self.sellerCollege!)/user/\(sellerUID!)/images/\(self.imageID!)")
        soldLocation.deleteWithCompletion { (error) -> Void in
        }
    }
    
    
    
    
    
    func exchangeColleges() {
        let myID = FIRAuth.auth()!.currentUser!.uid
        ref.child("\(myCollege!)/user/\(myID)/messages/all/\(sellerUID!)/college").setValue(sellerCollege!)
        ref.child("\(sellerCollege!)/user/\(sellerUID!)/messages/all/\(myID)/college").setValue(myCollege!)
    }
    
    
    
    
    //When an item is bought, take it out of unsold items and add it to sold/purchased items in the database
    func changeInDatabase() {
        let pathToUserUnsoldItems = "/\(sellerCollege!)/user/\(sellerUID!)/unsoldItems/\(imageID!)"
        let pathToUserAlbums = "/\(sellerCollege!)/user/\(sellerUID!)/albums/\(albumID!)/unsoldItems/\(imageID!)"
        let pathToCollegeAlbums = "/\(sellerCollege!)/albums/\(albumID!)/unsoldItems/\(imageID!)"
        
        let pathToUserSoldItems = "/\(sellerCollege!)/user/\(sellerUID!)/soldItems/\(imageID!)"
        let pathToUserBoughtItems = "/\(myCollege!)/user/\(FIRAuth.auth()!.currentUser!.uid)/purchasedItems/\(imageID!)"
        let key = ref.child("/\(sellerCollege!)/user/\(sellerUID!)/notifications").childByAutoId().key
        let pathToNotification = "/\(sellerCollege!)/user/\(sellerUID!)/notifications/\(key)"
        
        let messageDetails = ["message" : "\(currentUsername!) has bought your \(name!)!",
                              "type" : "BoughtItem",
                              "picUid": imageID!,
                              "name": name!,
                              "uid": sellerUID!,
                              "albumID": albumID!,
                              "seller": seller!]
        
        OneSignal.postNotification(["contents": ["en": "Please arrange a meeting time/place to complete the transaction!"], "headings": ["en": "\(currentUsername!) has bought your \(name!)!"], "include_player_ids": [self.sellerHolder.id]])
        
        let itemInfo = ref.child("/\(sellerCollege!)/user/\(sellerUID!)/unsoldItems/\(imageID!)")
        itemInfo.observeSingleEventOfType(.Value, withBlock:  { snapshot in
            if let itemData = snapshot.value as? [String: AnyObject] {
                
                let timestamp = NSDate().timeIntervalSince1970 * -1
                let currUser = FIRAuth.auth()!.currentUser!
                
                var soldData = itemData
                soldData["sellerId"] = NSNull()
                soldData["sellerName"] = NSNull()
                soldData["buyerID"] = currUser.uid
                soldData["buyerName"] = currUser.displayName
                soldData["buyerCollege"] = self.myCollege!
                
                var boughtData = itemData
                boughtData["timestamp"] = timestamp
                boughtData["sellerCollege"] = self.sellerCollege!
                
                
                
                let childUpdates = [pathToUserUnsoldItems : NSNull(),
                    pathToUserAlbums : NSNull(),
                    pathToCollegeAlbums : NSNull(),
                    pathToUserSoldItems : soldData,
                    pathToUserBoughtItems : boughtData,
                    pathToNotification : messageDetails]
                
                self.ref.updateChildValues(childUpdates)
            }
        })
    }
    
    
    
    
    //Called when the view is disappearing
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
        self.tabBarController?.tabBar.hidden = false
        if itemDetailsListener != nil {
            imageRef.removeObserverWithHandle(itemDetailsListener!)
        }
    }
    
}



