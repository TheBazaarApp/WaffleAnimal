//
//  NotificationCell.swift
//  Authtest
//
//  Created by CSSummer16 on 7/19/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    var icon = UIImageView()
    var message = UILabel()
    var goSomewhere = UILabel()
    var notificationType: NotificationType?
    //    var messageText: String?
    var handler: NotificationsHandler?
    
    var genericMessage: String?
    var genericGoSomewhere: String?
    var personName: String?
    var junk: String?
    var imageID: String?
    var name: String?
    var uid: String?
    var albumID: String?
    var seller: String?
    var recieiverUid: String?
    var reciever: String?
    var boughtItem: UIImage?
    
    
    enum NotificationType {
        case Generic
        case BoughtItem
        case MessageReceived
        case NewItem
        case Rating
        case BugFix
        case BuyerRejected
        case SellerRejected
        case ReportedItem
        case RemovingOld
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        message.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        goSomewhere.translatesAutoresizingMaskIntoConstraints = false
        
        message.numberOfLines = 2
        
        self.contentView.addSubview(icon)
        self.contentView.addSubview(message)
        self.contentView.addSubview(goSomewhere)
        
        let viewsDict = ["message" : message,
                         "goSomewhere" : goSomewhere,
                         "icon" : icon]
        
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[message(30)]-[goSomewhere]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-15-[icon(40)]-15-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[icon(40)]-10-[message]|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[icon]-10-[goSomewhere]|", options: [], metrics: nil, views: viewsDict))
    }
    
    
    func goSomewhereText() -> String {
        switch notificationType! {
        case .Generic:
            return genericGoSomewhere!
        case .BoughtItem:
            return "Click to mark transaction as complete!"
        case .MessageReceived:
            return "Click to respond!"
        case .NewItem:
            return "Click to see item!"
        case .Rating:
            return "Click to rate!"
        case .BugFix:
            return "Click to download latest version!"
        case .BuyerRejected:
            return "Click to choose what to do with this item."
        case .SellerRejected:
            return "Click to rate this scumbag :( "
        case .ReportedItem:
            return "Click to see item."
        case .RemovingOld:
            return "Click to see \(junk!)"
            
        }
        
    }
    
    func setMessageText(messageText: String) {
        let messageAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(12)]
        let messageString = NSMutableAttributedString(string: messageText, attributes: messageAttributes)
        messageString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, messageString.length))
        message.attributedText = messageString
    }
    
    func setGoSomewhereText(goSomewhereText: String) {
        let goSomewhereAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(10)]
        let goSomewherString = NSMutableAttributedString(string: goSomewhereText, attributes: goSomewhereAttributes)
        goSomewherString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, goSomewherString.length))
        goSomewhere.attributedText = goSomewherString
    }
    
    
    
    
    func getIcon() -> UIImage {
        switch notificationType! {
        case .Generic:
            return UIImage(named: "ic_info_outline")!
        case .BoughtItem:
            return UIImage(named: "ic_attach_money")!
        case .MessageReceived:
            return UIImage(named: "ic_chat_bubble_outline")!
        case .NewItem:
            return UIImage(named: "newItem")!
        case .Rating:
            return UIImage(named: "ic_star_border")!
        case .BugFix:
            return UIImage(named: "bugFix")!
        case .BuyerRejected:
            return UIImage(named: "SaleRejected")!
        case .SellerRejected:
            return UIImage(named: "SaleRejected")!
        case .ReportedItem:
            return UIImage(named: "ic_report")!
        case .RemovingOld:
            return UIImage(named: "removingOld")!
            
        }
    }
    
    

    
    
    
    
    
    
}
