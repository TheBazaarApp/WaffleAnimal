//
//  Item.swift
//  buy&sell
//
//  Created by cssummer16 on 6/13/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.
//

import UIKit

class Item: NSObject {
    
    var tags: String
    var itemName: String
    var itemDescription: String
    var price: String
//  var url: NSURL
    var location: String?
    var sold: Bool?
    var picture: UIImage
    var seller: String
    
    init(itemDescription: String, tags: String, itemName: String, price: String, picture: UIImage, seller: String) {
        self.itemDescription = itemDescription
        self.tags = tags
        self.itemName = itemName
        self.price = price
        self.picture = picture
        self.seller = seller
    }
    
    func getPicture() -> UIImage {
        return picture
    }
    func getSeller() -> String {
        return seller
    }
    
    func getTags() -> String {
        return tags
    }
    
    func getItemName() -> String {
        return itemName
    }
    
    func getItemDescription() -> String {
        return itemDescription
    }
    
    func getPrice() -> String {
        return price
    }
    
//    func getUrl() -> NSURL {
//        return url
//    }
    
    func getLocation() -> String {
        return location!
    }
    
    func getSold() -> Bool {
        return sold!
    }

}

