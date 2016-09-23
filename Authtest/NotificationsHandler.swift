//
//  NotificationsHandler.swift
//  Authtest
//
//  Created by CSSummer16 on 7/21/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import Foundation
import Firebase

class NotificationsHandler: NSObject {
    
    var message: String?
    var type: NotificationCell.NotificationType?
    var key: String?

    
    init(message: String, type: NotificationCell.NotificationType, key: String) {
        self.message = message
        self.type = type
        self.key = key
    }
    
    
}

class HandlerData {
    
}


class MessagesHandler: HandlerData {
    var receiveruid: String
    var reciever: String
    init(receiveruid: String, reciever: String){
        self.receiveruid = receiveruid
        self.reciever = reciever
    }
}



class CloseUpHandler: HandlerData {
    var picUid: String
    var name: String
    var uid: String
    var albumID: String
    var seller: String
    var sellerCollege: String?
    init(picUid: String, name: String, uid: String, albumID: String, seller: String) {
        self.picUid = picUid
        self.name = name
        self.uid = uid
        self.albumID = albumID
        self.seller = seller
    }
}



class RatingHandler: HandlerData {
    var sellerName: String
    var buyerName: String
    var itemName: String
    var date: String
    var status: String
    var rateeName: String
    var rateeUID: String
    var rateeCollege: String
    var notificationID: String
    init (sellerName: String, buyerName: String, itemName: String, date: String, status: String, rateeName: String, rateeUID: String, rateeCollege: String, notificationID: String) {
        self.sellerName = sellerName
        self.buyerName = buyerName
        self.itemName = itemName
        self.date = date
        self.status = status
        self.rateeName = rateeName
        self.rateeUID = rateeUID
        self.rateeCollege = rateeCollege
        self.notificationID = notificationID
    }
}