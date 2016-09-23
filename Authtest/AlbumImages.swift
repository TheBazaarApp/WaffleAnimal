//
//  AlbumImages.swift
//  buy&sell
//
//  Created by cssummer16 on 6/22/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.
//

import UIKit
import Firebase

class AlbumImages: ItemTableViewController {
    
    var albumName: String?
    var albumID: String?
    
    //MARK: SETUP FUNCTIONS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = FIRAuth.auth()?.currentUser
        uid = user!.uid
        navigationItem.title = "Items in \(albumName!)"
        let path = "\(college)/user/\(uid!)/albums/\(albumID!)/unsoldItems"
        childAddedListener(path)
        childChangedListener(path)
        childRemovedListener(path)
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("redRidingHood", sender: nil)
    }
    
    
    
    
    
    override func formatCell(cell: ViewItemsCell, item: Item) {
        if item.tag == "In Search Of" {
            if item.hasPic {
                cell.albumImagesISOPicImage.image = item.picture
                cell.albumImagesISOPicLabel.numberOfLines = 80
                cell.albumImagesISOPicLabel.text = item.itemName + "\n \n" + item.itemDescription
            } else {
                cell.albumImagesISOLabel.numberOfLines = 80
                cell.albumImagesISOLabel.text = item.itemName + "\n \n" + item.itemDescription
            }
        } else {
            cell.albumItemLabel.text = item.itemName
            cell.albumItemImage.image = item.picture
        }
    }
    
    
    
    
    override func childAddedDetails(newItem: Item, snapshot: FIRDataSnapshot) {
        newItem.imageKey = snapshot.key
        let itemInfoDict = snapshot.value as? [String : AnyObject]
        newItem.tag = itemInfoDict!["tag"] as! String
        newItem.itemName = itemInfoDict!["name"] as! String
        newItem.itemDescription = itemInfoDict!["description"] as! String
        newItem.sellerCollege = mainClass.domainBranch
        newItem.uid = mainClass.uid
        if newItem.tag == "In Search Of" {
            if (itemInfoDict!["hasPic"] as? Bool) != nil {
                newItem.hasPic = false
            }
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
    
    
    
    
    
    
    
    //NAVIGATION FUNCTIONS
    
    
    //Go to other view controllers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "redRidingHood" { //Called when you click on one item
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! ViewItemsCell
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                let itemKey = items.keys.sort()[indexPath.row]
                var item = items[itemKey]!
                if searchBarActive && searchBar!.text != "" {
                    item = filteredItems[indexPath.row]
                }
                
                if item.tag == "In Search Of" {
                    if item.hasPic {
                        cell.albumImagesISOPicBackground.backgroundColor = mainClass.ourBlue
                    } else {
                        cell.albumImagesISOBackground.backgroundColor = mainClass.ourBlue
                    }
                } else {
                    cell.albumItemLabel.backgroundColor = mainClass.ourBlue
                }
                
                //Pass info to next ViewController
                let controller = segue.destinationViewController  as! CloseUp
                controller.name = item.itemName
                controller.pic = item.picture
                controller.imageID = item.imageKey
                controller.sellerUID = uid
                controller.sellerCollege = college
                controller.albumID = albumID
                controller.location = "default location"
            }
        }
    }
    
}
