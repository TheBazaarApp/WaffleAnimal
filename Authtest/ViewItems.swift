//
//  ViewItems.swift
//  buy&sell
//
//  Created by cssummer16 on 6/20/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.
//

import UIKit
import Firebase

class ViewItems: UITableViewController {
    
    
    @IBOutlet var myTableView: UITableView!
    
    
    var ref = FIRDatabase.database().reference() //create database reference
    let storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com") //create storage reference
    var namesOfPics = [String]()
    var displayedID = [String]()
    var uid: String?
    var unsold = true
    var actualImages = [UIImage]()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredNames = [String]()
    var albumName: String?
    var thisIsAnnoying = false
    var count = 0
    var itemsListener: FIRDatabaseHandle?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = FIRAuth.auth()?.currentUser
        uid = user!.uid
        
        //Set up search bar in the header
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        //Navigation button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "All Albums", style: .Plain, target: self, action: #selector(theBeast))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Profile", style: .Plain, target: self, action: #selector(mulan))
        getItemsForSale(unsold)
    }
    
    
    
    
    
    
    //////////////////////////////////// TableView Functions ///////////////////////////////////
    
    
    //Specifies how many items there will be in the table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredNames.count
        }
        //print("num of rows \(actualImages.count)")
        //return actualImages.count
        if thisIsAnnoying {
            count += 1

        }
        return count
    }
    
    
    
    
    //Specify what is in each cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ViewItemsCell = self.tableView.dequeueReusableCellWithIdentifier("photographs") as! ViewItemsCell
        
        let itemName: String
        
        if searchController.active && searchController.searchBar.text != "" { //Filter is active; display only filtered stuff
            itemName = filteredNames[indexPath.row]
            let indexOfFilter = namesOfPics.indexOf(itemName)
            let filterImage = actualImages[indexOfFilter!]
            cell.itemImage.image = filterImage
            
        } else { //Filter is inactive, display pic. as usual
            itemName = namesOfPics[indexPath.row]
            var item: UIImage?
            item = actualImages[indexPath.row]
            
            cell.itemImage.image = item
            
        }
        
        cell.itemLabel.text = itemName
        return cell
    }
    
    
    
    
    
    
    
    //////////////////////////////////// Firebase Functions ///////////////////////////////////
    
    
    //Access the database to get all of that user's items
    func getItemsForSale(unsold: Bool){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in
            if let user = FIRAuth.auth()?.currentUser {
                
                //Get items from the database and storage
                var imageRef: FIRDatabaseReference
                if unsold {
                    imageRef = self.ref.child("/user/\(user.uid)/unsoldItems")
                } else {
                    imageRef = self.ref.child("/user/\(user.uid)/soldItems")
                }
                
                self.itemsListener = imageRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
                    
                    if let allItemsDict = snapshot.value as? [String : AnyObject] {
                        
                        let idArray = Array(allItemsDict.keys) //Array of image IDs
                        var nameArray = [String]() //Will hold image names
                        
                        for id in idArray {
                            let itemInfoDict = allItemsDict[id] as! [String: AnyObject]
                            let name = itemInfoDict["name"] as! String
                            nameArray.append(name)
                        }
                        self.displayedID = idArray
                        self.namesOfPics = nameArray
                        self.getActualImages() //Get actual images from storage
                    }
                })
            }
        }
    }
    
    
    
    
    // Access storage to get images
    func getActualImages(){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in
        
   //     Loop through image IDs, get them from storage, add them in
        for i in 0...(self.displayedID.count - 1) {
            let imageRef: FIRStorageReference
            if self.unsold {
                imageRef = self.storageRef.child("users/\(self.uid!)/unsoldItems/\(self.displayedID[i])") //Path to the image in stoage
            } else {
                imageRef = self.storageRef.child("users/\(self.uid!)/soldItems/\(self.displayedID[i])") //Path to the image in stoage
            }
            
            imageRef.downloadURLWithCompletion{ (URL, error) -> Void in  //Download the image
                if (error != nil) {
                    print("error!!!!!!!!!")
                    print(error)
                } else {
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in
                    if let picData = NSData(contentsOfURL: URL!) { //The pic!!!
                        let image = UIImage(data: picData)!
                        self.actualImages.append(image)
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
    
    
    
    
    
    
    
    //////////////////////////////////// Navigation Functions ///////////////////////////////////
    
    
    //Go to the "All Albums" view
    func theBeast() {
        performSegueWithIdentifier("theBeast", sender: self)
    }
    
    
    
    //Go to the seller's profile
    func mulan() {
        performSegueWithIdentifier("mulan", sender: self)
    }
    
    
    
    //Go to other view controllers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        ref.removeObserverWithHandle(itemsListener!)
        
        
        if segue.identifier == "cruella" { //Called when you click one one of the items
            if let indexPath = self.tableView.indexPathForSelectedRow {
                var picID: String = displayedID[indexPath.row]
                var picName: String = namesOfPics[indexPath.row]
                var pic: UIImage = actualImages[indexPath.row]
                
                //If we're in the middle of filtering, choose indexes differently
                if searchController.active && searchController.searchBar.text != "" {
                    picName = filteredNames[indexPath.row]
                    let indexOfFilter = namesOfPics.indexOf(picName)
                    pic = actualImages[indexOfFilter!]
                    picID = displayedID[indexOfFilter!]
                }
                
                //Send image name, image, ID, and sold status to the next view controller
                let controller = segue.destinationViewController  as! CloseUp
                controller.imageName = picName
                controller.pic = pic
                controller.unsold = unsold
                controller.imageID = picID
            }
        }
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


//Extension that lets us have a search bar (with a filter)
extension ViewItems: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}









