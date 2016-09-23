//
//  ViewAlbum.swift
//  buy&sell
//
//  Created by cssummer16 on 6/21/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.
//

import UIKit
import Firebase


class ViewAlbum: ItemTableViewController {
    
    
    //MARK: OUTLETS AND VARIABLES
    
    //var imageKey = [String]()
    var didEdit:Bool = false
    var didDelete:Bool = false
    var editButton: UIBarButtonItem?
    var deleteButton: UIBarButtonItem?
    var segueLoc: String?
    let darkRed = UIColor(red: 166/255, green: 56/255, blue: 40/255, alpha: 1.0)
    
    
    //MARK: SETUP FUNCTIONS
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.isAlbumView = true
        
        //Add navigation bar
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Baskerville", size: 40)!], forState:  .Normal)
        
        if segueLoc == "profile" {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Options", style: .Plain, target: self, action: #selector(viewMore))
            
            navigationItem.title = ""
        } else {
            
            navigationItem.title = "All Albums"
        }
        let path = "\(college)/user/\(uid!)/albums"
        childAddedListener(path)
        childChangedListener(path)
        childRemovedListener(path)
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        colorChange()
    }
    
    
    
    
    
    func colorChange() {
        for cell in tableView.visibleCells  {
            let realCell = cell as! ViewItemsCell
            if realCell.albumLabel != nil { //happens if we have a normal cell
                if didEdit {
                    realCell.albumLabel.backgroundColor = mainClass.ourGold
                }
                else {
                    if didDelete {
                        realCell.albumLabel.backgroundColor = darkRed
                    } else {
                        realCell.albumLabel.backgroundColor = mainClass.ourBlue
                    }
                }
            } else {
                if realCell.viewAlbumsISOBackground != nil { //happens if we have an iso w/o pic cell
                    if didEdit {
                        realCell.viewAlbumsISOBackground.backgroundColor = mainClass.ourGold
                    }
                    else {
                        if didDelete {
                            realCell.viewAlbumsISOBackground.backgroundColor = darkRed
                        } else {
                            realCell.viewAlbumsISOBackground.backgroundColor = mainClass.ourBlue
                        }
                    }
                } else { //happens if we have an iso with pic cel
                    if didEdit {
                        realCell.viewAlbumsISOPicBackground.backgroundColor = mainClass.ourGold
                    }
                    else {
                        if didDelete {
                            realCell.viewAlbumsISOPicBackground.backgroundColor = darkRed
                        } else {
                            realCell.viewAlbumsISOPicBackground.backgroundColor = mainClass.ourBlue
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    //MARK: TABLEVIEW FUNCTIONS
    
    
    override func formatCell(cell: ViewItemsCell, item: Item) {
        if item.tag == "In Search Of" {
            if item.hasPic {
                cell.viewAlbumsISOPicLabel.numberOfLines = 1
                cell.viewAlbumsISOPicLabel.text = item.itemName
                if didEdit == true {
                    cell.viewAlbumsISOPicBackground.backgroundColor = mainClass.ourGold
                    return
                }
                if didDelete == true {
                    cell.viewAlbumsISOPicBackground.backgroundColor = darkRed
                    return
                }
                cell.viewAlbumsISOPicBackground.backgroundColor = mainClass.ourBlue
                cell.viewAlbumsISOPicImage.image = item.picture
            } else {
                cell.viewAlbumsISOLabel.numberOfLines = 1
                cell.viewAlbumsISOLabel.text = item.itemName
                if didEdit == true {
                    cell.viewAlbumsISOBackground.backgroundColor = mainClass.ourGold
                    return
                }
                if didDelete == true {
                    cell.viewAlbumsISOBackground.backgroundColor = darkRed
                    return
                }
                cell.viewAlbumsISOBackground.backgroundColor = mainClass.ourBlue
            }
        } else {
            cell.albumLabel.text = item.itemName
            cell.albumImage.image = item.picture
            if didEdit == true {
                cell.albumLabel.backgroundColor = mainClass.ourGold
                return
            }
            if didDelete == true {
                cell.albumLabel.backgroundColor = darkRed
                return
            }
            cell.albumLabel.backgroundColor = mainClass.ourBlue
            cell.albumImage.image = item.picture
        }
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!) as! ViewItemsCell
        //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if segueLoc == "profile" {
            if didEdit {
                performSegueWithIdentifier("goldilocks", sender: currentCell)
            }
            else {
                if didDelete {
                    showDeletePopup(indexPath!.row)
                } else {
                    mainClass.simpleAlert("No Option Selected", message: "To edit or delete albums, press the 'Options' button", viewController: self)
                }
                tableView.deselectRowAtIndexPath(indexPath!, animated: false)
            }
        } else {
            performSegueWithIdentifier("snowwhite", sender: currentCell)
        }
    }
    
    
    
    
    
    
    
    
    
    //MARK: EDITING/DELETING ALBUMS FUNCTIONS
    
    
    
    
    
    func pressedDelete() {
        didDelete = !didDelete
        didEdit = false
        if didDelete {
            navigationItem.title = "Deleting Albums"
        } else {
            navigationItem.title = ""
        }
        colorChange()
    }
    
    
    
    
    func pressedEdit() {
        didEdit = !didEdit
        didDelete = false
        if didEdit {
            navigationItem.title = "Editing Albums"
        } else {
            navigationItem.title = ""
        }
        colorChange()
    }
    
    
    
//    func cancel() {
//        didEdit = false
//        didDelete = false
//        navigationItem.title = ""
//        colorChange()
//    }
//    
    
    
    
    
    
    func showDeletePopup(index: Int) {
        let deleteAlert = UIAlertController(title: "Delete", message: "Are you sure you want to delete your item?", preferredStyle: .Alert)
        
        let yesAction = UIAlertAction(title: "Delete", style: .Default) { (alertAction) -> Void in
            self.deleteAlbum(index)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        deleteAlert.addAction(yesAction)
        deleteAlert.addAction(cancelAction)
        
        presentViewController(deleteAlert, animated: true, completion: nil)
    }
    
    
    
    func deleteAlbum(index: Int) {
        let albumIndices = items.keys.sort()
        let albumIndex = albumIndices[index]
        //Loop through items
        let dataRef = ref.child("\(self.college)/user/\(uid!)/unsoldItems")
        dataRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            dispatch_barrier_async(self.queue) {
                let allItems = snapshot.value as? [String : AnyObject]
                for (imageKey, item) in allItems! {
                    let currentAlbumID = item["albumKey"] as! String
                    if currentAlbumID == self.items[albumIndex]!.albumKey {
                        let path = self.ref.child("\(self.college)/user/\(self.uid!)/unsoldItems/\(imageKey)")
                        path.removeValue()
                    }
                    let imagePath = self.storageRef.child("\(self.college)/user/\(self.uid!)/images/\(imageKey)")
                    imagePath.deleteWithCompletion { (error) -> Void in
                    }
                }
                //Delete album from database (both under user's albums and under the college's albums)
                let path = self.ref.child("\(self.college)/user/\(self.uid!)/albums/\(self.items[albumIndex]!.albumKey!)")
                path.removeValue()
                let path2 = self.ref.child("\(self.college)/albums/\(self.items[albumIndex]!.albumKey!)")
                path2.removeValue()
            }
        })
    }
    
    
    
    
    
    override func childAddedDetails (newAlbum: Item, snapshot: FIRDataSnapshot) {
        let albumInfo = snapshot.value as! [String: AnyObject]
        if let unsoldItemsDict = albumInfo["unsoldItems"] as? [String: AnyObject] {
            let listOfImageIDs = Array(unsoldItemsDict.keys)
            let firstItemImageKey = listOfImageIDs[0] as String
            let tag = unsoldItemsDict[firstItemImageKey]!["tag"] as! String
            if tag == "In Search Of" {
                if (unsoldItemsDict[firstItemImageKey]!["hasPic"] as? Bool) != nil {
                    newAlbum.hasPic = false
                }
            }
            newAlbum.sellerCollege = mainClass.domainBranch
            newAlbum.uid = mainClass.uid
            newAlbum.imageKey = firstItemImageKey
            newAlbum.tag = tag
            //Get tag
            newAlbum.albumKey = snapshot.key
            newAlbum.itemName = albumInfo["albumDetails"]!["albumName"] as! String
        }
    }
    
    
    
    
    
    override func childChangedDetails(snapshot: FIRDataSnapshot) {
        let albumID = snapshot.key
        let albumInfo = snapshot.value as! [String: AnyObject]
        if let unsoldItemsDict = albumInfo["unsoldItems"] as? [String: AnyObject] {
            let listOfImageIDs = Array(unsoldItemsDict.keys)
            let idOfFirstImage = listOfImageIDs[0] as String
            let albumName = albumInfo["albumDetails"]!["albumName"] as! String
            dispatch_barrier_async(self.queue) { [weak self] in 
                if self != nil {
                    for (index, album) in self!.items {
                        if album.albumKey == albumID { //We found a matching album!
                            album.itemName = albumName
                            album.imageKey = idOfFirstImage
                            self?.getActualImages(index)
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    //MARK: NAVIGATION FUNCTIONS
    
    
    //Go to the seller's profile
    func viewMore() {
        let optionsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        var editTitle = "Edit Album"
        if didEdit {
            editTitle = "Done Editing"
        }
        let edit = UIAlertAction(title: editTitle, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.pressedEdit()
        })
        var deleteTitle = "Delete Album"
        if didDelete {
            deleteTitle = "Done Deleting"
        }
        
        let delete = UIAlertAction(title: deleteTitle, style: .Default, handler: { (alert: UIAlertAction!) -> Void in
            self.pressedDelete()
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        optionsMenu.addAction(edit)
        optionsMenu.addAction(delete)
        
        optionsMenu.addAction(cancel)
        self.presentViewController(optionsMenu, animated: true, completion: nil)
        
    }
    
    
    
    //Go to other view controllers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            //let cell = tableView.cellForRowAtIndexPath(indexPath) as! ViewItemsCell
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            let albumIndex = items.keys.sort()[indexPath.row]
            var album = items[albumIndex]!
            if searchBarActive && searchBar!.text != "" {
                album = filteredItems[indexPath.row]
            }

            if segue.identifier == "goldilocks" { //Edit an album
                
                //Pass data to the next view controller
                let controller = segue.destinationViewController  as! AddNewItem
                controller.album = album.itemName
                controller.albumID = album.albumKey
                controller.segueLoc = "EditAlbums"
            }
            
            if segue.identifier == "snowwhite" { //Go to Album Images when you click on an album
                
                //Pass data to the next view controller
                let controller = segue.destinationViewController  as! AlbumImages
                controller.albumName = album.itemName
                controller.albumID = album.albumKey
                controller.college = college
            }
        }
    }
    
}




