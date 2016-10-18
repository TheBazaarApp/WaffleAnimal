//
//  ReportViewController.swift
//  Authtest
//
//  Created by CS Laptop on 9/21/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import OneSignal

class ReportViewController: UIViewController {

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var reasonField: UITextView!
   
    var itemName = ""
    var sellerName = ""
    var itemDescription = ""
    var sellerID = ""
    var sellerCollege = ""
    var imageID = ""
    var albumID = ""
    let senderName = mainClass.displayName!
    let senderID = mainClass.uid!
    let senderCollege = mainClass.domainBranch!
    let ref = mainClass.ref
    let sellerHolder = IDHolder()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reasonField.layer.cornerRadius = 8.0
        reasonField.layer.masksToBounds = true
        reasonField.layer.borderColor = mainClass.ourBlue.CGColor
        reasonField.layer.borderWidth = 4.0
        itemLabel.text = itemName
        sellerLabel.text = sellerName
        mainClass.getNotificationID(sellerID, holder: sellerHolder)

        
    }
    
    
    
    //When you click "...", an alert comes up from the bottom
    func sendReportNotification() {
        let key = ref.child("/\(sellerCollege)/user/\(sellerID)/notifications").childByAutoId().key
        let reportedPath = "/\(self.sellerCollege)/user/\(sellerID)/notifications/\(key)"
        let adminKey = ref.child("adminReportNotifications").childByAutoId().key
        let adminReportedPath = "adminReportNotifications/\(adminKey)"
        
        let notificationInfo = [
            "message" : "Your \(itemName) got reported.",
            "type"  : "ReportedItem",
            "picUid": imageID,
            "name": itemName,
            "uid": sellerID,
            "albumID": albumID,
            "seller": sellerName]
        
        
        let adminNotificationInfo = [
            "imageID": imageID,
            "itemName": itemName,
            "itemDescription": itemDescription,
            "reason": reasonField.text!,
            "sellerID": sellerID,
            "sellerName": sellerName,
            "sellerCollege": sellerCollege,
            "senderID": senderID,
            "senderName": senderName,
            "senderCollege": senderCollege,
            "albumID": albumID
        ]
        
        OneSignal.postNotification(["contents": ["en": "Please review the item. Note that our team will also review the item."], "headings": ["en": "Your \(itemName) got reported :("], "include_player_ids": [sellerHolder.id]])
        
        let childUpdates = [reportedPath: notificationInfo,
                            adminReportedPath: adminNotificationInfo]
        self.ref.updateChildValues(childUpdates)
    }
    



    


    @IBAction func didPressSubmit(sender: AnyObject) {
        if let text = reasonField.text {
            if text != "" {
                sendReportNotification()
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                mainClass.simpleAlert("Blank Field", message: "Please Add Reason For Reporting", viewController: self)
            }
        }
    }
    
    

}
