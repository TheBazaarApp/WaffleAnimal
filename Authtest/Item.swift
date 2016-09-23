//
//  Item.swift
//  buy&sell
//
//  Created by cssummer16 on 6/13/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.
//

import UIKit

class Item: NSObject {
    
    var tag: String
    var itemName: String
    var itemDescription: String
    var price: Double
    var sold: Bool?
    var picture = UIImage(named: "white")
    var seller: String?
    var timestamp: Double
    var uid: String?
    var imageKey = ""
    weak var album: Album?
    var albumKey: String?
    var albumName: String?
    var lat: Double?
    var long: Double?
    var location: String?
    var sellerCollege:String?
    var hasPic = true
    
    init(itemDescription: String, tag: String, itemName: String, price: Double, timestamp: Double) {
        self.itemDescription = itemDescription
        self.tag = tag
        self.itemName = itemName
        self.price = price
        self.timestamp = timestamp
    }
    
    
    init(itemDescription: String, tags: String, itemName: String, price: Double, picture: UIImage, seller: String, timestamp: Double, uid: String) {
        self.itemDescription = itemDescription
        self.tag = tags
        self.itemName = itemName
        self.price = price
        self.picture = picture
        self.seller = seller
        self.timestamp = timestamp
        self.uid = uid
    }
    
    override init() {
        self.tag = ""
        self.itemName = ""
        self.itemDescription = ""
        self.price = -0.1134
        self.timestamp = 0
        
    }
    
    
    
}

