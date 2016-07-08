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
    var index = 0
    var albumName = ""
    var albumID = ""
    var location = ""
    var locationLat: Double?
    var locationLong: Double?
    
    
    func addItem(item: Item){
        unsoldItems.append(item)
    }
    
    
    func createIndex(index: Int){
        self.index = index
    }
    
    
}