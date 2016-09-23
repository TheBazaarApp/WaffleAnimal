//
//  viewSold.swift
//  Authtest
//
//  Created by cssummer16 on 8/2/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import Firebase

class viewSold: ItemTableViewController {
    
    
    //MARK: SETUP FUNCTIONS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Navigation button
        navigationItem.title = "Sold Items"
        let path = "\(college)/user/\(uid!)/soldItems"
        childAddedListener(path)
        childChangedListener(path)
        childRemovedListener(path)
    }
    
    
    
    
    
    //MARK: TableView Functions
    
    
    override func formatCell(cell: ViewItemsCell, item: Item) {
        if item.tag == "In Search Of" {
            if item.hasPic {
                cell.soldItemsISOPicImage.image = item.picture
                cell.soldItemsISOPicLabel.numberOfLines = 80
                cell.soldItemsISOPicLabel.text = item.itemName + "\n \n" + item.itemDescription
            } else {
                cell.soldItemsISOLabel.numberOfLines = 80
                cell.soldItemsISOLabel.text = item.itemName + "\n \n" + item.itemDescription
            }
        } else {
            cell.soldLabel.text = item.itemName
            cell.soldImage.image = item.picture
        }
    }
    
    
    
    
    
    
    
    
    //MARK: Firebase Functions
    
    override func childAddedDetails (newItem: Item, snapshot: FIRDataSnapshot) {
        newItem.imageKey = snapshot.key
        let itemInfoDict = snapshot.value as? [String : AnyObject]
        newItem.albumKey = itemInfoDict!["albumKey"] as? String
        newItem.itemName = itemInfoDict!["name"] as! String
        newItem.tag = itemInfoDict!["tag"] as! String
        newItem.sellerCollege = mainClass.domainBranch
        newItem.uid = mainClass.uid
        if newItem.tag == "In Search Of" {
            if (itemInfoDict!["hasPic"] as? Bool) != nil {
                newItem.hasPic = false
            }
         newItem.itemDescription = itemInfoDict!["description"] as! String
        }
    }
    
    
    override func childChangedDetails(snapshot: FIRDataSnapshot) {
        let imageKey = snapshot.key
        let itemInfoDict = snapshot.value as? [String : AnyObject]
        
        let name = itemInfoDict!["name"] as! String
        let tag = itemInfoDict!["tag"] as! String

        for item in self.items.values {
            if item.imageKey == imageKey { //We found a matching item!
                item.itemName = name
                item.tag = tag
                item.itemDescription = itemInfoDict!["description"] as! String
            }
        }
    }
    
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("sebastien", sender: nil)
    }
    
    
    
    
    
    
    
    
    //Go to other view controllers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "sebastien" { //Called when you click one one of the items
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! ViewItemsCell
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                //currentCell.soldLabel.backgroundColor = mainClass.ourBlue
                let itemKey = items.keys.sort()[indexPath.row]
                var item = items[itemKey]!
                
                
                //If we're in the middle of filtering, choose indexes differently
                if searchBarActive && searchBar!.text != "" {
                    item = filteredItems[indexPath.row]
                }
                
                if item.tag == "In Search Of" {
                    if item.hasPic {
                        cell.soldItemsISOPicBackground.backgroundColor = mainClass.ourBlue
                    } else {
                        cell.soldItemsISOBackground.backgroundColor = mainClass.ourBlue
                    }
                } else {
                    cell.soldLabel.backgroundColor = mainClass.ourBlue
                }
                
                //Send image name, image, ID, and sold status to the next view controller
                let controller = segue.destinationViewController  as! CloseUp
                controller.name = item.itemName
                controller.pic = item.picture
                controller.imageID = item.imageKey
                controller.sellerUID = uid
                controller.hasPic = item.hasPic
                controller.category = "sold"
                controller.sellerCollege = college
                controller.albumID = item.albumKey
                controller.segueLoc = "viewSold"
            }
        }
    }
    
}
