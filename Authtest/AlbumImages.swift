//
//  AlbumImages.swift
//  buy&sell
//
//  Created by cssummer16 on 6/22/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.
//

import UIKit
import Firebase

class AlbumImages: UITableViewController {
    
    @IBOutlet var myTableView: UITableView!
    
    var ref = FIRDatabase.database().reference() //create database reference
    let storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com") //create storage reference
    var uid: String?
    
    var namesOfPics = [String]()
    var displayedID = [String]()
    var actualImages = [UIImage]()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredNames = [String]()
    var albumName: String?
    var albumID: String?
    var itemsListener: FIRDatabaseHandle?
    var thisIsAnnoying = false
    var count = 0

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = FIRAuth.auth()?.currentUser
        uid = user!.uid
        
        //Set up search bar in the header
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        getItemsForSale()
        
    }
    
    
    
    
    //////////////////////////////////// TableView Functions ///////////////////////////////////
    
    
    //Specifies how many items there will be in the table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredNames.count
        }
        //return namesOfPics.count
        if thisIsAnnoying {
            count += 1
            
        }
        return count

    }
    
    
    //Specify what is in each cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ViewItemsCell = self.tableView.dequeueReusableCellWithIdentifier("genie") as! ViewItemsCell
        
        let itemName: String
        if searchController.active && searchController.searchBar.text != "" { //Filter is active; display only filtered stuff
            itemName = filteredNames[indexPath.row]
            let indexOfFilter = namesOfPics.indexOf(itemName)
            let filterImage = actualImages[indexOfFilter!]
            cell.itemImage.image = filterImage
            
        } else {  //Filter is inacctive, display pic. as usual
            itemName = namesOfPics[indexPath.row]
            var item: UIImage?
            item = actualImages[indexPath.row]
            cell.albumItem.image = item
            
        }
        
        cell.albumItemLabel.text = itemName
        return cell
    }
    
    
    
    
    //Access the storage and the database to get personal info, the profile pic, and the sold and unsold items
    func getItemsForSale(){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in

        if let user = FIRAuth.auth()?.currentUser {
            //Get items from the database and storage
            var imageRef: FIRDatabaseReference
            imageRef = self.ref.child("/user/\(user.uid)/albums/\(self.albumID!)")
            self.itemsListener = imageRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
                
                if let allItemsDict = snapshot.value as? [String : AnyObject] {
                    let unsoldItemsDict = allItemsDict["unsoldItems"] as! [String: AnyObject]
                    let unsoldImageIDs = Array(unsoldItemsDict.keys)
                    for id in unsoldImageIDs {
                        let imageInfo = unsoldItemsDict[id]
                        let imageName = imageInfo!["name"] as! String
                        self.displayedID.append(id)
                        self.namesOfPics.append(imageName)
                    }
                    self.getActualImages()
                }
            })
            
        }
        }
    }
    
    
    
    
    // Access storage to get images
    func getActualImages(){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in

//        //Put the default image in the array enough times that the array has enough spots to accomodate the images we're going to add
//        let dummyImage = UIImage(named: "PrettySunset.jpg")
//        for _ in 0...(self.displayedID.count - 1) {
//            self.actualImages.append(dummyImage!)
//        }
        
        
        //Loop through image IDs, get them from storage, add them in
        for i in 0...(self.displayedID.count - 1) {
            let imageRef: FIRStorageReference
            imageRef = self.storageRef.child("users/\(self.uid!)/unsoldItems/\(self.displayedID[i])") //Path to the image in stoage
            imageRef.downloadURLWithCompletion{ (URL, error) -> Void in  //Download the image
                if (error != nil) {
                    print("error!!!")
                } else {
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in

                    if let picData = NSData(contentsOfURL: URL!) { //The pic!!!
                        let image = UIImage(data: picData)!
                        self.actualImages.append(image)
                        //self.myTableView.reloadData()
                        self.thisIsAnnoying = true
                        let num = self.actualImages.count
                        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                            self.myTableView.beginUpdates()
                            let newNSIndexPath = NSIndexPath(forItem: num-1, inSection: 0)
                            self.myTableView.insertRowsAtIndexPaths([newNSIndexPath], withRowAnimation: .None)
                            self.myTableView.endUpdates()
                        }

                    }
                }
                }
            }
        }
        }
    }
    
    //////////////////////////////////// Navigation Function ///////////////////////////////////
    
    
    //Go to other view controllers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "redRidingHood" { //Called when you click on one item
            if let indexPath = self.tableView.indexPathForSelectedRow {
                var pic: UIImage
                var picName: String
                var picID: String
                picID = displayedID[indexPath.row]
                picName = namesOfPics[indexPath.row]
                pic = actualImages[indexPath.row]
                if searchController.active && searchController.searchBar.text != "" {
                    picName = filteredNames[indexPath.row]
                    let indexOfFilter = namesOfPics.indexOf(picName)
                    pic = actualImages[indexOfFilter!]
                    picID = displayedID[indexOfFilter!]
                }
                
                //Pass info to next ViewController
                let controller = segue.destinationViewController  as! CloseUp
                controller.imageName = picName
                controller.pic = pic
                controller.imageID = picID
            }
        }
        
        
    }
    
    
    
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeObserverWithHandle(itemsListener!)
    }
    
    
    
    
    
    
    
    
    //////////////////////////////////// Filtering Functions ///////////////////////////////////
    
    
    //When you're searching, filter results in tableview
    func filterContentForSearchText(searchText: String, scope: String = "AllImages") {
        filteredNames = namesOfPics.filter { filter in
            return filter.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }
    
    
}



extension AlbumImages: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
}
