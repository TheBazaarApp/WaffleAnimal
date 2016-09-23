//
//  Album.swift
//  Authtest
//
//  Created by CSSummer16 on 6/29/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import Foundation
import UIKit

class Album: NSObject {
    
    var unsoldItems = [Item]()
    var albumName = ""
    var albumID = ""
    var location = ""
    var locationLat: Double?
    var locationLong: Double?
    var hasReadyItem = false
    var seller = ""
    var sellerID = ""
    var sellerCollege = ""
    var isISO = false
    var imageIndex = 0 //Which item are we on?
    var visibleItemIndex = 0
    
    
    func addItem(item: Item){
        item.album = self
        unsoldItems.append(item)
    }
    
    
    
}