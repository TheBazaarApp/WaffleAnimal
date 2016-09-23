//
//  ItemTableViewController.swift
//  Authtest
//
//  Created by HMCloaner on 8/20/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class ItemTableViewController: SearchBarTableViewController {
    
    var uid: String?
    var items: [Int: Item] = [:]
    var filteredItems: [Item] = []
    var ref = FIRDatabase.database().reference() //create database reference
    let storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com") //create storage reference
    var college = mainClass.domainBranch!
    let queue = dispatch_queue_create("viewItemsQueue", DISPATCH_QUEUE_CONCURRENT)
    var index = 0
    var itemAddedListener: FIRDatabaseHandle?
    var itemChangedListener: FIRDatabaseHandle?
    var itemRemovedListener: FIRDatabaseHandle?
    var count = 0
    var isAlbumView = false
    var loadingCircle: NVActivityIndicatorView!
    var loadingBackground: UIView!
    var picsComing = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if uid == nil {
            let user = FIRAuth.auth()?.currentUser
            uid = user!.uid
        }
        showLoadingCircle()
        makeSureTheyreComing()
    }
    
    
    

    
    
    func showLoadingCircle() {
        let quarterWidth = self.view.frame.width/4
        loadingCircle = NVActivityIndicatorView(frame: CGRectMake(quarterWidth, quarterWidth * 2, quarterWidth * 2, quarterWidth * 2), type: .BallSpinFadeLoader, color: mainClass.ourGold)
        loadingBackground = UIView()
        loadingBackground.frame = CGRectMake(0, 50, self.view.frame.width, 10000)
        loadingBackground.backgroundColor = .whiteColor()
        self.view.addSubview(loadingBackground)
        self.view.addSubview(loadingCircle)
        loadingCircle.startAnimation()
        let triggerTime = (Int64(NSEC_PER_SEC) * 10)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.hideLoadingCircle()
        })
    }
    
    
    func hideLoadingCircle() {
        let triggerTime = (Int64(NSEC_PER_SEC) * 2)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.hideNow()
        })
    }
    
    
    
    func makeSureTheyreComing() {
        let triggerTime = (Int64(NSEC_PER_SEC) * 1)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            if !self.picsComing {
                self.hideNow()
            }
            
        })
    }
    
    
    
    func hideNow() {
        loadingCircle.stopAnimation()
        loadingCircle.removeFromSuperview()
        loadingBackground.removeFromSuperview()
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBarHidden = false
    }
    
    
    
    //Specifies how many items there will be in the table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBarActive && searchBar!.text != "" {
            return filteredItems.count
        }
        return items.count
    }
    
    
    
    //MARK: Tableview functions
    
    
    //Specify what is in each cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = getItem(indexPath.row)
        let cell = getCell(indexPath.row)
        
        formatCell(cell, item: item)
        
        return cell
    }
    
    
    
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item = getItem(indexPath.row)
        let viewWidth = self.view.frame.size.width
        if item.tag == "In Search Of" {
            if item.hasPic {
                return mainClass.heightForView(item.itemName + "\n" + item.itemDescription, font: UIFont.boldSystemFontOfSize(18), width: viewWidth - 10) + 120 + viewWidth
            } else {
                return mainClass.heightForView(item.itemName + "\n" + item.itemDescription, font: UIFont.boldSystemFontOfSize(18), width: viewWidth - 10) + 120
            }
        } else {
            return viewWidth + 68
        }
    }
    
    
    
    
    
    func getCell(index: Int) -> ViewItemsCell {
        let item = getItem(index)
        if item.tag == "In Search Of" {
            if item.hasPic {
                return tableView.dequeueReusableCellWithIdentifier("isoCellWithPic") as! ViewItemsCell
            } else {
                return tableView.dequeueReusableCellWithIdentifier("isocell") as! ViewItemsCell
            }
        } else {
            return tableView.dequeueReusableCellWithIdentifier("photographs") as! ViewItemsCell
        }
    }
    
    
    func getItem(index: Int) -> Item {
        if searchBarActive && searchBar!.text != "" { //Filter is active; display only filtered stuff
            return filteredItems[index]
        } else { //Filter is inactive, display pic. as usual
            let itemKey = items.keys.sort()[index]
            return items[itemKey]!
        }
    }
    
    func getIdentifiers() -> [String] {
        return ["", ""]
    }
    
    
    
    
    //Access the database to get all of that user's items
    func childAddedListener(path: String){
        //Get items from the database and storage
        let dataRef = self.ref.child(path).queryOrderedByChild("timestamp")
        
        self.itemAddedListener = dataRef.observeEventType(FIRDataEventType.ChildAdded, withBlock: { (snapshot) in
            
            let newItem = Item()
            self.childAddedDetails(newItem, snapshot: snapshot)
            self.items[self.index] = newItem
            self.index = self.index + 1
            if newItem.hasPic {
                self.picsComing = true
                print("about to get image")
                self.getActualImages(self.index - 1) //Get actual images from storage
                
            } else {
                if self.isAlbumView {
                    newItem.picture = UIImage(named: "Album Default")
                } else {
                    newItem.picture = mainClass.defaultPic(newItem.tag)
                }
            }
            
        })
    }
    
    
    
    
    
    //Listen for changes in Items
    func childChangedListener(path: String){
        //Get items from the database and storage
        let dataRef = self.ref.child(path).queryOrderedByChild("timestamp")
        self.itemChangedListener = dataRef.observeEventType(FIRDataEventType.ChildChanged, withBlock: { (snapshot) in
            self.childChangedDetails(snapshot) //potentially problematic
            self.tableView.reloadData()
        })
    }
    
    
    
    
    
    
    func childRemovedListener(path: String) {
        //Get reference to album cover pic from database
        let dataRef = self.ref.child(path)
        self.itemRemovedListener = dataRef.observeEventType(FIRDataEventType.ChildRemoved, withBlock: { (snapshot) in
            let imageID = snapshot.key
            let indexList = Array(self.items.keys)
            for index in 0..<indexList.count {
                let key = indexList[index]
                let item = self.items[key]
                if self.isAlbumView {
                    if item!.albumKey == imageID {
                        self.items[key] = nil
                    }
                } else {
                    if item!.imageKey == imageID {
                        self.items[key] = nil
                    }
                }
            }
            
            if self.searchBarActive {
                self.filterContentForSearchText(self.searchBar!.text!)
            }
            self.tableView.reloadData()
        })
    }
    
    
    
    func childAddedDetails(item: Item, snapshot: FIRDataSnapshot) {}
    
    func childChangedDetails(snapshot: FIRDataSnapshot) {}
    
    func formatCell(cell: ViewItemsCell, item: Item) {}
    
    
    
    
    
    
    
    
    func getActualImages(index: Int){
        print("getting image")
        let item = self.items[index]!
        let imageRef = self.storageRef.child("\(item.sellerCollege!)/user/\(item.uid!)/images/\(item.imageKey)") //Path to the image in storage
        imageRef.downloadURLWithCompletion{ (URL, error) -> Void in  //Download the image
            if (error != nil) {
                if self.isAlbumView {
                    item.picture = UIImage(named: "Album Default")
                } else {
                    item.picture = mainClass.defaultPic(item.tag)
                }
                dispatch_async(dispatch_get_main_queue()) { [weak self] in
                    self?.tableView.reloadData()
                }
            } else {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
                    if self != nil {
                        dispatch_barrier_async(self!.queue) {
                            
                            if let picData = NSData(contentsOfURL: URL!) { //The pic!!!
                                let image = UIImage(data: picData)!
                                item.picture = image
                                print("got a pic!")
                            } else {
                                if self!.isAlbumView {
                                    item.picture = UIImage(named: "Album Default")
                                } else {
                                    item.picture = mainClass.defaultPic(item.tag)
                                }
                                
                            }
                            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                                self?.hideLoadingCircle() //new
                                self?.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    //MARK: Search Bar Functions
    
    
    //When you're searching, filter results in tableview
    override func filterContentForSearchText(searchText: String) {
        filteredItems = items.values.filter { Item in
            var allTogetherString = Item.itemName + Item.tag + Item.itemDescription
            if let albumName = Item.albumName {
                allTogetherString += albumName
            }
            return allTogetherString.lowercaseString.containsString(searchText.lowercaseString)
        }
    }
    
    

    
    deinit {
        ref.removeObserverWithHandle(itemAddedListener!)
        ref.removeObserverWithHandle(itemChangedListener!)
        ref.removeObserverWithHandle(itemRemovedListener!)
    }
    
    
    
}
