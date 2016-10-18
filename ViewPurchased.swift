//
//  ViewPurchased.swift
//  Authtest
//
//  Created by cssummer16 on 8/2/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import Firebase

class ViewPurchased: ItemTableViewController {
    
    
    //MARK: SETUP FUNCTIONS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Navigation button
        navigationItem.title = "Purchased Items"
        let path = "\(self.college)/user/\(uid!)/purchasedItems"
        childAddedListener(path)
        childChangedListener(path)
        childRemovedListener(path)
    }
    
    
    
    
    override func formatCell(cell: ViewItemsCell, item: Item) {
        if item.tag == "In Search Of" {
            if item.hasPic {
                cell.purchasedItemsISOPicImage.image = item.picture
                cell.purchasedItemsISOPicLabel.numberOfLines = 80
                cell.purchasedItemsISOPicLabel.text = item.itemName + "\n \n" + item.itemDescription
            } else {
                cell.purchasedItemsISOLabel.numberOfLines = 80
                cell.purchasedItemsISOLabel.text = item.itemName + "\n \n" + item.itemDescription
            }
        } else {
            cell.purchasedLabel.text = item.itemName
            cell.purchasedImage.image = item.picture
        }
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("zira", sender: nil)
    }
    
    
    
    
    
    //MARK: Firebase Functions
    
    
    override func childAddedDetails(newItem: Item, snapshot: FIRDataSnapshot) {
        newItem.imageKey = snapshot.key
        let itemInfoDict = snapshot.value as? [String : AnyObject]
        newItem.albumKey = itemInfoDict!["albumKey"] as? String
        newItem.itemName = itemInfoDict!["name"] as! String
        newItem.itemDescription = itemInfoDict!["description"] as! String
        newItem.tag = itemInfoDict!["tag"] as! String
        newItem.sellerCollege = itemInfoDict!["sellerCollege"] as? String
        newItem.uid = itemInfoDict!["sellerId"] as? String
        if newItem.tag == "In Search Of" {
            if (itemInfoDict!["hasPic"] as? Bool) != nil {
                newItem.hasPic = false
            }
        }
    }
    
    
    override func childChangedDetails(snapshot: FIRDataSnapshot) {
        let imageKey = snapshot.key
        let itemInfoDict = snapshot.value as? [String : AnyObject]
        
        let name = itemInfoDict!["name"] as! String //TODO: Do something with this!
        let tag = itemInfoDict!["tag"] as! String
        for item in self.items.values {
            if item.imageKey == imageKey { //We found a matching item!
                item.itemName = tag
                item.itemDescription = itemInfoDict!["description"] as! String

            }
        }
    }
    
    
    
    
    
    
    
    //MARK: Navigation Functions
    
    
    
    //Go to other view controllers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "zira" { //Called when you click one one of the items
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! ViewItemsCell
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                //currentCell.purchasedLabel.backgroundColor = mainClass.ourBlue
                let itemKey = items.keys.sort()[indexPath.row]
                var item = items[itemKey]
                
                //If we're in the middle of filtering, choose indexes differently
                if searchBarActive && searchBar!.text != "" {
                    item = filteredItems[indexPath.row]
                }
                
                if item!.tag == "In Search Of" {
                    if item!.hasPic {
                        cell.purchasedItemsISOPicBackground.backgroundColor = mainClass.ourBlue
                    } else {
                        cell.purchasedItemsISOBackground.backgroundColor = mainClass.ourBlue
                    }
                } else {
                    cell.purchasedLabel.backgroundColor = mainClass.ourBlue
                }
                
                
                //Send image name, image, ID, and sold status to the next view controller
                let controller = segue.destinationViewController  as! CloseUp
                controller.name = item?.itemName
                controller.pic = item?.picture
                controller.category = "purchased"
                controller.imageID = item?.imageKey
                controller.sellerUID = item!.uid
                controller.sellerCollege = item?.sellerCollege
                controller.albumID = item!.albumKey!
                controller.location = "default location"
            }
        }
    }
    
}
