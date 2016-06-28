//
//  ViewAlbum.swift
//  buy&sell
//
//  Created by cssummer16 on 6/21/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.
//

import UIKit
import Firebase


class ViewAlbum: UITableViewController {
    
    
    @IBOutlet var myTableView: UITableView!
    
    var ref = FIRDatabase.database().reference() //create database reference
    let storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com") //create storage reference
    var uid: String?
    var unsold = true
    var namesOfAlbums = [String]()
    var idArray = [String]()
    var albumIDs = [String]()
    var actualImages = [UIImage]()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredNames = [String]()
    var albumsListener: FIRDatabaseHandle?
    var thisIsAnnoying = false
    var count = 0

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = FIRAuth.auth()?.currentUser
        uid = user!.uid
        
        //Set search bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        //Add navigation buttons
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "All Images", style: .Plain, target: self, action: #selector(belle))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Profile", style: .Plain, target: self, action: #selector(tremaine))
        getAlbums()
        
    }
    
    
    
    
    
    
    
    //////////////////////////////////// TableView Functions ///////////////////////////////////
    
    
    //Specifies how many items there will be in the table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredNames.count
        }
        //return namesOfAlbums.count
        if thisIsAnnoying {
            count += 1
            
        }
        return count

    }
    
    
    
    
    //Specify what is in each cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ViewItemsCell = self.tableView.dequeueReusableCellWithIdentifier("ariel") as! ViewItemsCell
        
        
        let filter: String
        if searchController.active && searchController.searchBar.text != "" { //Filter is active; display only filtered stuff
            filter = filteredNames[indexPath.row]
            let indexOfFilter = namesOfAlbums.indexOf(filter)
            let filterImage = actualImages[indexOfFilter!]
            cell.albumImage.image = filterImage
            
        } else { //Filter is inactive, display pic. as usual
            
            filter = namesOfAlbums[indexPath.row]
            var item: UIImage?
            item = actualImages[indexPath.row]
            cell.albumImage.image = item
            
        }
        
        cell.albumLabel.text = filter
        return cell
    }
    
    
    
    
    
    
    
    //////////////////////////////////// Firebase Functions ///////////////////////////////////
    
    
    //Access the database to get all of the seller's albums
    func getAlbums(){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in

        if let user = FIRAuth.auth()?.currentUser {
            
            
            //Get reference to album cover pic from database
            var imageRef: FIRDatabaseReference
            imageRef = self.ref.child("/user/\(user.uid)/albums")
            self.albumsListener = imageRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
                
                
                if let allAlbumsDict = snapshot.value as? [String : AnyObject] {
                    
                    let albumIDs = Array(allAlbumsDict.keys) //Keys for the albums
                    
                    for albumID in albumIDs {
                        let albumInfo = allAlbumsDict[albumID] as! [String: AnyObject]
                        if let unsoldItemsDict = albumInfo["unsoldItems"] as? [String: AnyObject] {
                            let listOfImageIDs = Array(unsoldItemsDict.keys)
                            let idOfFirstImage = listOfImageIDs[0] as String
                            self.idArray.append(idOfFirstImage)
                            let albumDetails = albumInfo["albumDetails"]
                            let albumName = albumDetails!["albumName"] as! String
                            self.namesOfAlbums.append(albumName)
                            self.albumIDs.append(albumID)
                        }
                    }
                    self.getActualImages()
                }
            })
            }}
    }
    
    
    
    // Access storage to get images
    func getActualImages(){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in

//        //Put the default image in the array enough times that the array has enough spots to accomodate the images we're going to add
//        let dummyImage = UIImage(named: "PrettySunset.jpg")
//        for _ in 0...(self.idArray.count - 1) {
//            self.actualImages.append(dummyImage!)
//        }
        
        
        //Loop through image IDs, get them from storage, add them in
        for i in 0...(self.idArray.count - 1) {
            let imageRef: FIRStorageReference
            
            imageRef = self.storageRef.child("users/\(self.uid!)/unsoldItems/\(self.idArray[i])") //Path to the image in stoage
            
            imageRef.downloadURLWithCompletion{ (URL, error) -> Void in  //Download the image
                if (error != nil) {
                    
                } else {
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in

                    if let picData = NSData(contentsOfURL: URL!) { //The pic!!!
                        let image = UIImage(data: picData)!
                        self.actualImages.append(image)
                        self.thisIsAnnoying = true

                        //self.myTableView.reloadData()
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
    
    
    //Go to the "All Items" view
    func belle() {
        performSegueWithIdentifier("belle", sender: self)
    }
    
    
    //Go to the seller's profile
    func tremaine() {
        performSegueWithIdentifier("tremaine", sender: self)
    }
    
    
    
    //Go to other view controllers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        ref.removeObserverWithHandle(albumsListener!)
        
        if segue.identifier == "snowwhite" { //Called when you click on an album
            if let indexPath = self.tableView.indexPathForSelectedRow {
                var albumName = namesOfAlbums[indexPath.row]
                
                //If we're in the middle of filtering, choose index differently
                if searchController.active && searchController.searchBar.text != "" {
                    albumName = filteredNames[indexPath.row]
                }
                
                //Pass data to the next view controller
                let controller = segue.destinationViewController  as! AlbumImages
                controller.albumName = albumName
                controller.albumID = albumIDs[indexPath.row]
            }
        }
    }
    
    
    
    
    
    
    //////////////////////////////////// Filtering Functions ///////////////////////////////////
    
    
    //When you're searching, filter results in tableview
    func filterContentForSearchText(searchText: String, scope: String = "AllImages") {
        filteredNames = namesOfAlbums.filter { filter in
            return filter.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }
    
    
    
    
}

extension ViewAlbum: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}







