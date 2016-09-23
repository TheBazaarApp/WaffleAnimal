//
//  ViewItems.swift
//  buy&sell
//
//  Created by cssummer16 on 6/20/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.
//

import UIKit
import Firebase

class ViewItems: ItemTableViewController {
    
    
    //MARK: SETUP FUNCTIONS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Navigation button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "All Albums", style: .Plain, target: self, action: #selector(theBeast))
        navigationItem.title = "Unsold Items"
        let path = "\(college)/user/\(uid!)/unsoldItems"
        childAddedListener(path)
        childChangedListener(path)
        childRemovedListener(path)
    }
    
    
    
    
    
    
    override func formatCell(cell: ViewItemsCell, item: Item) {
        if item.tag == "In Search Of" {
            if item.hasPic {
                cell.viewItemsISOPicImage.image = item.picture
                cell.viewItemsISOPicLabel.numberOfLines = 80
                cell.viewItemsISOPicLabel.text = item.itemName + "\n \n" + item.itemDescription
            } else {
                cell.viewItemsISOLabel.numberOfLines = 80
                cell.viewItemsISOLabel.text = item.itemName + "\n \n" + item.itemDescription
            }
        } else {
            cell.itemLabel.text = item.itemName
            cell.itemImage.image = item.picture
        }
    }
    
    
    
    
    
    
    //MARK: Firebase Functions
    
    
    override func childAddedDetails (newItem: Item, snapshot: FIRDataSnapshot) {
        newItem.imageKey = snapshot.key
        let itemInfoDict = snapshot.value as? [String : AnyObject]
        newItem.albumKey = itemInfoDict!["albumKey"] as? String
        newItem.albumName = itemInfoDict!["albumName"] as? String
        newItem.itemName = itemInfoDict!["name"] as! String
        print("item name is \(newItem.itemName)")
        newItem.tag = itemInfoDict!["tag"] as! String
        newItem.itemDescription = itemInfoDict!["description"] as! String
        newItem.sellerCollege = college
        newItem.uid = uid!
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
        let albumName = itemInfoDict!["albumName"] as! String
        let tag = itemInfoDict!["tag"] as! String
        for item in self.items.values {
            if item.imageKey == imageKey { //We found a matching item!
                item.itemName = name
                item.albumName = albumName
                item.tag = tag
                item.itemDescription = itemInfoDict!["description"] as! String

            }
        }
    }
    
    
    
    
    
    
    
    
    //MARK: Navigation Functions
    
    
    //Go to the "All Albums" view
    func theBeast() {
        performSegueWithIdentifier("theBeast", sender: self)
    }
    
    
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("cruella", sender: nil)
    }
    
    

    //Go to other view controllers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "cruella" { //Called when you click one one of the items
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! ViewItemsCell
                
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                let itemKey = items.keys.sort()[indexPath.row]
                var item = items[itemKey]!
                
                //If we're in the middle of filtering, choose indexes differently
                if searchBarActive && searchBar!.text != "" {
                    item = filteredItems[indexPath.row]
                }
                
                if item.tag == "In Search Of" {
                    if item.hasPic {
                        cell.viewItemsISOPicBackground.backgroundColor = mainClass.ourBlue
                    } else {
                        cell.viewItemsISOBackground.backgroundColor = mainClass.ourBlue
                    }
                } else {
                    cell.itemLabel.backgroundColor = mainClass.ourBlue
                }
                
                
                
                //Send image name, image, ID, and sold status to the next view controller
                let controller = segue.destinationViewController  as! CloseUp
                controller.name = item.itemName
                controller.pic = item.picture
                controller.imageID = item.imageKey
                controller.sellerUID = uid
                controller.sellerCollege = college
                controller.albumID = item.albumKey
            }
        }
        if segue.identifier == "theBeast" {
            if let controller = segue.destinationViewController as? ViewAlbum {
                controller.uid = uid!
                controller.college = college
            }
        }
    }
    
}

