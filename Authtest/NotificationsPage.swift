//
//  NotificationsPage.swift
//  Authtest
//
//  Created by CSSummer16 on 7/19/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import Firebase

class NotificationsPage: UITableViewController {
    
    let ref = FIRDatabase.database().reference()
    let college = mainClass.domainBranch
    let user = FIRAuth.auth()?.currentUser
    var notificationsListener: FIRDatabaseHandle?
    var notifications = [NotificationsHandler]()
    var notificationsDict = [NotificationsHandler: HandlerData]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listenForNotifications()
        listenForRemovedNotifications()
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Key Terms", style: .Plain, target: self, action: #selector(goToKeyTerms)) //TODO: add this back in once we have notifications
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.rowHeight = 70.0
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Notifications"
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBarHidden = false
    }
    
    func listenForNotifications() {
        let notificationsRef = ref.child("\(self.college!)/user/\(user!.uid)/notifications")
        notificationsListener = notificationsRef.observeEventType(FIRDataEventType.ChildAdded, withBlock: { (snapshot) in
            let notificationData = snapshot.value as! [String : AnyObject]
            let message = notificationData["message"] as! String
            let notification = notificationData["type"] as! String
            let key = snapshot.key
            let type = self.convertStringToNotificationType(notification)
            let newNotification = NotificationsHandler(message: message, type: type, key: key)
            if type == .BoughtItem || type == .ReportedItem || type == .BuyerRejected || type == .NewItem {
                let picUid = notificationData["picUid"] as! String
                let name = notificationData["name"] as! String
                let uid = notificationData["uid"] as! String
                let albumId = notificationData["albumID"] as! String
                let seller = notificationData["seller"] as! String
                let newCloseUpHandler = CloseUpHandler(picUid: picUid, name: name, uid: uid, albumID: albumId, seller: seller)
                self.notificationsDict[newNotification] = newCloseUpHandler
                self.notifications.insert(newNotification, atIndex: 0)
                self.tableView.reloadData()
            }
            if type == .MessageReceived {
                let receiveruid = notificationData["receiveruid"] as! String
                let receiver = notificationData["receiver"] as! String
                let newMessageHandle = MessagesHandler(receiveruid: receiveruid, reciever: receiver)
                self.notificationsDict[newNotification] = newMessageHandle
                self.notifications.insert(newNotification, atIndex: 0)
                self.tableView.reloadData()
            }
            if type == .Rating || type == .SellerRejected {
                let sellerName = notificationData["sellerName"] as! String
                let buyerName = notificationData["buyerName"] as! String
                let itemName = notificationData["itemName"] as! String
                let date = notificationData["date"] as! String
                let status = notificationData["status"] as! String
                let rateeName = notificationData["rateeName"] as! String
                let rateeUID = notificationData["rateeUID"] as! String
                let rateeCollege = notificationData["rateeCollege"] as! String
                let newRatingHandler = RatingHandler(sellerName: sellerName, buyerName: buyerName, itemName: itemName, date: date, status: status, rateeName: rateeName, rateeUID: rateeUID, rateeCollege: rateeCollege, notificationID: snapshot.key)
                self.notificationsDict[newNotification] = newRatingHandler
                self.notifications.insert(newNotification, atIndex: 0)
                self.tableView.reloadData()
            }
        })
    }
    
    
    
    func listenForRemovedNotifications() {
        let notificationsRef = ref.child("\(self.college!)/user/\(user!.uid)/notifications")
        notificationsListener = notificationsRef.observeEventType(FIRDataEventType.ChildRemoved, withBlock: { (snapshot) in
            let key = snapshot.key
            for (index, notification) in self.notifications.enumerate().reverse() {
                if notification.key == key {
                    self.notifications.removeAtIndex(index)
                }
            }
            self.tableView.reloadData()
        })
    }
    
    
    
    
    
    func convertStringToNotificationType(type: String) -> NotificationCell.NotificationType {
        switch type {
        case "Generic":
            return .Generic
        case "BoughtItem":
            return .BoughtItem //Got it
        case "MessageReceived":
            return .MessageReceived //Got it
        case "NewItem":
            return .NewItem //Later
        case "Rating":
            return .Rating
        case "BugFix":
            return .BugFix
        case "BuyerRejected":
            return .BuyerRejected
        case "SellerRejected":
            return .SellerRejected
        case "ReportedItem":
            return .ReportedItem //Got it
        case "RemovingOld":
            return .RemovingOld
        default:
            return .Generic
        }
        
    }
    
    // MARK: - Table view data source
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notifications.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Notifications", forIndexPath: indexPath) as! NotificationCell
        let currNotification = notifications[indexPath.row]
        cell.handler = currNotification
        let message = currNotification.message
        let type = currNotification.type
        cell.setMessageText(message!)
        cell.notificationType = type!
        cell.icon.image = cell.getIcon()
        cell.setGoSomewhereText(cell.goSomewhereText())
        return cell
    }
    
    
    
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let key = notifications[indexPath.row].key {
                let pathToUserNotifications = ref.child("\(college!)/user/\(user!.uid)/notifications/\(key)")
                pathToUserNotifications.removeValue()
                notifications.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!) as! NotificationCell
        let notification = currentCell.notificationType!
        switch notification {
        case .BoughtItem:
            performSegueWithIdentifier("notifyBought", sender: currentCell)
        case .MessageReceived:
            performSegueWithIdentifier("notifyMessages", sender: currentCell)
        case .ReportedItem:
            performSegueWithIdentifier("notifyReported", sender: currentCell)
        case .Rating:
            performSegueWithIdentifier("notifyRating", sender: currentCell)
        case .BuyerRejected:
            performSegueWithIdentifier("notifyBought", sender: currentCell)
        case .SellerRejected:
            performSegueWithIdentifier("notifyRating", sender: currentCell)
        case .NewItem:
            performSegueWithIdentifier("notifyBought", sender: currentCell) //TODO: check this works
        default: break
        }
    }
    
    
    func goToKeyTerms() {
        performSegueWithIdentifier("timon", sender: nil)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let identifier = segue.identifier!
        if let cell = sender as? NotificationCell {
            let handler = cell.handler!
            if identifier == "notifyBought" { //TODO: no need to save some of the other stuff (uid, displayname of seller)
                let detailView = segue.destinationViewController as! CloseUp
                let data = notificationsDict[handler]! as! CloseUpHandler
                detailView.sellerUID = mainClass.uid!
                detailView.sellerCollege = mainClass.domainBranch!
                detailView.seller = mainClass.displayName!
                detailView.albumID = data.albumID
                detailView.imageID = data.picUid
                detailView.segueLoc = "Notifications"
                detailView.category = "sold"
                if cell.notificationType == .BuyerRejected {
                    detailView.transactionCanceled = true
                }
            }
            if identifier == "notifyReported" {
                let detailView = segue.destinationViewController as! CloseUp
                let data = notificationsDict[handler]! as! CloseUpHandler
                detailView.sellerUID = data.uid
                detailView.sellerCollege = data.sellerCollege ?? mainClass.domainBranch
                detailView.seller = data.seller
                detailView.imageID = data.picUid
                detailView.segueLoc = "Notifications"
                detailView.category = "unsold"
            }
            if identifier == "notifyMessages" {
                let messages = segue.destinationViewController as! ChatViewController
                let data = notificationsDict[handler]! as! MessagesHandler
                messages.receiveruid = data.receiveruid
                messages.receiver = data.reciever
            }
            if identifier == "notifyRating" {
                let ratingView = segue.destinationViewController as! RatingViewController
                let data = notificationsDict[handler]! as! RatingHandler
                ratingView.sellerName = data.sellerName
                ratingView.buyerName = data.buyerName
                ratingView.itemName = data.itemName
                ratingView.date = data.date
                ratingView.status = data.status
                ratingView.rateeName = data.rateeName
                ratingView.raterUID = mainClass.uid!
                ratingView.rateeUID = data.rateeUID
                ratingView.notificationID = data.notificationID
                ratingView.rateeCollege = data.rateeCollege
                ratingView.segueLoc = "notifications"
            }
        }
    }
}

