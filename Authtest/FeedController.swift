//
//  FeedViewController.swift
//  Authtest
//
//  Created by CSSummer16 on 6/14/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import Firebase
import NVActivityIndicatorView

var homeController: FeedController!

class FeedController: SearchBarTableViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    //MARK: VARIABLES AND OUTLETS
    
    var categoryItems = [Item]()
    var category: String = "Album View" {
        didSet {
            navigationItem.title = category
        }
    }
    var currIndex: Int?
    var college = mainClass.domainBranch
    var albums =  [Album]()
    var menuIsOpen = false
    var allItems = [Item]()
    var showAlbums = true
    var biggestNumber = 0.0
    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    private let queue = dispatch_queue_create("pleasepleasework", DISPATCH_QUEUE_CONCURRENT)
    var collegeTradingList = [String]()
    var listeners = [FIRDatabaseHandle] ()
    var dragging = false
    var loadingCircle: NVActivityIndicatorView!
    var loadingBackground = UIView()
    var overlayBackground = UIView()
    var notFoundLabel = UILabel()
    var pleaseDontWork = [FeedTableViewCell]()
    
    
    //MARK: SETUP
    
    override func viewDidLoad() {
        //showLoadingCircle() //TODO: add back in
        homeController = self
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        self.view.endEditing(true)
        //Create ways to open the sidebar menu
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        let menuImage = UIImage(named: "ic_menu")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        button.tintColor = mainClass.ourGold //TODO: Choose better name for this!
        button.setImage(menuImage, forState: UIControlState.Normal)
        button.frame = CGRectMake(0, 0, 30, 30)
        button.addTarget(self, action: #selector(toggleMenu), forControlEvents: UIControlEvents.TouchUpInside)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = button
        self.navigationItem.leftBarButtonItem = leftBarButton
        if self.revealViewController() != nil {
            let edgePan = UIScreenEdgePanGestureRecognizer(target:self, action: #selector(screenEdgeSwiped))
            edgePan.edges = .Left
            self.view.addGestureRecognizer(edgePan)
            self.revealViewController().tapGestureRecognizer()
        }
        let addButton = UIButton(type: .Custom)
        let addImage = UIImage(named: "ic_add")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        addButton.tintColor = mainClass.ourGold
        addButton.setImage(addImage, forState: .Normal)
        addButton.addTarget(self, action: #selector(goToAddItem), forControlEvents: .TouchUpInside)
        //Set up search bar
        addButton.frame = CGRectMake(0, 0, 30, 30)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = addButton
        self.navigationItem.rightBarButtonItem = rightBarButton
        definesPresentationContext = true
        let point = CGPointMake(0, 44)
        tableView?.setContentOffset(point, animated: true)
        notFoundLabel.frame = CGRectMake(0, 50, self.view.frame.width, 300)
        notFoundLabel.text = "Sorry, no items found." //TODO: Better, more specific text.
        notFoundLabel.textAlignment = .Center
        notFoundLabel.font = UIFont.boldSystemFontOfSize(CGFloat(20.0))
        
        overlayBackground.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        overlayBackground.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        //scrollview.decelerationRate = 1.0
        addSearchBar()
        
        //Finish setting up the view
        
        
        mainClass.loginTime = false
        tableView?.backgroundColor = UIColor.whiteColor()
        tableView?.alwaysBounceVertical = true
        getRecentItems()
        
        
    }
    
    
    
    func showLoadingCircle() {
        let quarterWidth = self.view.frame.width/4
        loadingCircle = NVActivityIndicatorView(frame: CGRectMake(quarterWidth, quarterWidth * 2, quarterWidth * 2, quarterWidth * 2), type: .BallSpinFadeLoader, color: mainClass.ourGold)
        loadingBackground.frame = CGRectMake(0, 0, self.view.frame.width, 10000)
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
    
    
    
    
    func hideNow() {
        //        loadingCircle.stopAnimation() //TODO: add this back in
        //        loadingCircle.removeFromSuperview()
        //        loadingBackground.removeFromSuperview()
    }
    
    
    
    func goToAddItem() {
        performSegueWithIdentifier("FeedToAdd", sender: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        navigationItem.title = category
        if FIRAuth.auth()?.currentUser == nil {
            self.tabBarController!.tabBar.hidden = true
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Options", style: .Plain, target: self, action: #selector(showOptionsSheet))
        }
        else {
            tabBarController?.tabBar.hidden = false
        }
    }
    
    
    
    
    func showOptionsSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Register/Login", style: .Default) { (action) in
            mainClass.loginTime = true
            self.performSegueWithIdentifier("suiteLife", sender: nil)
            })
        actionSheet.addAction(UIAlertAction(title: "Choose Different Colleges", style: .Default) { (action) in
            self.performSegueWithIdentifier("peterPan", sender: nil)
            })
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    
    func resetCollegeListeners(){
        albums = [Album]()
        allItems = [Item]()
        self.tableView!.reloadData()
        for listener in listeners {
            ref.removeObserverWithHandle(listener)
        }
        getRecentItems()
        
    }
    
    
    
    
    
    //WE SHOULD USE THIS MORE OFTEN!
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let tableViewCell = cell as! FeedTableViewCell
        tableViewCell.setCollectionViewDataSourceDelegate(self, row: indexPath.row)
        print("will display a tableview cell")
    }
    
    
    
    
    
    
    
    
    
    
    
    //MARK: FIREBASE FUNCTIONS
    
    
    
    //Call Firebase to get image IDs from database.
    func getRecentItems() {
        if mainClass.user != nil {
            self.collegeTradingList.append(self.college!)
            //get colleges
            let collegesRef = self.ref.child("\(self.college!)/user/\(self.user!.uid)/settings/colleges")
            collegesRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
                self.albums = [Album]()
                self.allItems = [Item]()
                self.tableView!.reloadData()
                let collegeArray = snapshot.value as? NSArray
                if collegeArray != nil {
                    self.collegeTradingList += collegeArray as! [String]
                }
                self.listenToColleges()
            })
        } else {
            let defaults = NSUserDefaults.standardUserDefaults()
            let colList = defaults.objectForKey("skipAndBrowseColleges")
            if let list = colList as? [String] {
                self.collegeTradingList = list
                self.listenToColleges()
            }
        }
    }
    
    
    
    
    func listenToColleges() {
        for college in self.collegeTradingList {
            let feed = self.ref.child("\(college)/albums").queryLimitedToLast(100)
            self.createChildAddedListener(feed, college: college)
            self.createChildChangedListener(feed, college: college)
            self.createChildRemovedListener(feed)
        }
    }
    
    
    
    
    func createChildAddedListener(feed: FIRDatabaseQuery, college: String)
    {
        let feed2 = feed.queryOrderedByChild("albumDetails/timestamp")
        let albumAddedListener = feed2.observeEventType(FIRDataEventType.ChildAdded, withBlock: { (snapshot) in
            let albumCheck = snapshot.value as? [String : AnyObject]
            if albumCheck!["unsoldItems"] != nil {//Creating a new album
                let newAlbum = Album()
                
                if let currAlbumDict = snapshot.value as? [String : AnyObject] {
                    
                    let albumID = snapshot.key
                    
                    //Add album details
                    let albumDetails = currAlbumDict["albumDetails"] as! [String: AnyObject]
                    let timestamp = albumDetails["timestamp"] as! Double
                    newAlbum.albumName = albumDetails["albumName"] as! String
                    if let loc = albumDetails["location"] {
                        newAlbum.location = loc as! String
                        newAlbum.locationLat = albumDetails["locationLat"] as? Double
                        newAlbum.locationLong = albumDetails["locationLong"] as? Double
                    } else {
                        newAlbum.location = "no location selected"
                    }
                    
                    newAlbum.albumID = albumID
                    newAlbum.sellerID = albumDetails["sellerID"]  as! String
                    newAlbum.seller = albumDetails["sellerName"] as! String
                    newAlbum.sellerCollege = college
                    
                    
                    if let itemList = currAlbumDict["unsoldItems"] as? [String : AnyObject] {
                        for (imageKey, imageInfo) in itemList {
                            let itemDescription = imageInfo["description"] as! String
                            let itemTag = imageInfo["tag"] as! String
                            let itemName = imageInfo["name"] as! String
                            let itemPrice = (imageInfo["price"]!!).doubleValue
                            
                            let newItem = Item(itemDescription: itemDescription, tag: itemTag, itemName: itemName, price: itemPrice, timestamp: timestamp)
                            newItem.imageKey = imageKey
                            if itemTag == "In Search Of" {
                                newAlbum.isISO = true
                                if let noPic = imageInfo["hasPic"] as? Bool {
                                    newItem.hasPic = noPic
                                }
                            }
                            newAlbum.addItem(newItem)
                            self.insertItem(newItem)
                            self.getImage(0, album: newAlbum, imageId: imageKey, item: newItem)
                        }
                        self.insertAlbum(newAlbum)
                    }
                }
            }
        })
        listeners.append(albumAddedListener)
    }
    
    
    
    
    //Sort items with most recent albums first
    func insertAlbum(newAlbum: Album){
        dispatch_barrier_async(self.queue) {
            var inserted = false
            for (index, album) in self.albums.enumerate() {
                if album.unsoldItems[0].timestamp > newAlbum.unsoldItems[0].timestamp {
                    self.albums.insert(newAlbum, atIndex: index)
                    inserted = true
                    break
                }
            }
            if !inserted {
                self.albums.append(newAlbum)
            }
        }
    }
    
    
    
    //Sort items with most recent items first
    func insertItem(newItem: Item){
        dispatch_barrier_async(self.queue) {
            var inserted = false
            for (index, item) in self.allItems.enumerate() {
                if item.timestamp > newItem.timestamp {
                    self.allItems.insert(newItem, atIndex: index)
                    inserted = true
                    break
                }
            }
            if !inserted {
                self.allItems.append(newItem)
            }
        }
    }
    
    
    
    
    
    func createChildChangedListener(feed: FIRDatabaseQuery, college: String) {
        let albumChangedListener = feed.observeEventType(FIRDataEventType.ChildChanged, withBlock: { (snapshot) in
            //let triggerTime = (Int64(NSEC_PER_SEC) * 2)
            //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            print("child changed!!!")
            let albumID = snapshot.key
            
            for album in self.albums { //Loop through albums, find matching album
                if album.albumID == albumID { //If they're the same album
                    
                    var timestamp = 0.0
                    
                    //Update Album Details
                    if let albumDetails = snapshot.value!["albumDetails"] as? [String : AnyObject] {
                        album.albumName = albumDetails["albumName"] as! String
                        album.seller = albumDetails["sellerName"] as! String
                        if let loc = albumDetails["location"]  {
                            album.location = loc as! String
                            album.locationLat = albumDetails["locationLat"] as? Double
                            album.locationLong = albumDetails["locationLong"] as? Double
                        }
                        timestamp = albumDetails["timestamp"] as! Double
                    }
                    
                    
                    
                    //boolean array of whether the current item has a match
                    var currentItemMatches = [Bool]()
                    for _ in album.unsoldItems {
                        currentItemMatches.append(false)
                    }
                    
                    if let unsoldItems = snapshot.value!["unsoldItems"] as? [String : AnyObject] {
                        for (imageKey,newItem) in unsoldItems { //Loop through new items; if you have an item which matches, update it's data
                            //let imageKey = newItem["imageKey"] as! String
                            var foundMatch = false
                            for i in 0..<album.unsoldItems.count {//Loop through items currently in the album, see if they match
                                let currItem = album.unsoldItems[i]
                                if currItem.imageKey == imageKey { //Image keys match - same item!
                                    currentItemMatches[i] = true
                                    currItem.itemDescription = newItem["description"] as! String
                                    currItem.tag = newItem["tag"] as! String
                                    if currItem.tag == "In Search Of" {
                                        album.isISO = true
                                    }
                                    currItem.timestamp = timestamp
                                    currItem.itemName = newItem["name"] as! String
                                    currItem.price = (newItem["price"]!!).doubleValue
                                    currItem.imageKey = imageKey
                                    let triggerTime = (Int64(NSEC_PER_SEC) * 2) //TODO: Get rid of this!!
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                                        self.getImage(0, album: album, imageId: imageKey, item: currItem)
                                    })
                                    foundMatch = true
                                    break
                                }
                            }
                            if (!foundMatch) { //If there's no match, assume it's a new item
                                let itemDescription = newItem["description"] as! String
                                let itemTag = newItem["tag"] as! String
                                if itemTag == "In Search Of" {
                                    album.isISO = true
                                }
                                let itemName = newItem["name"] as! String
                                let itemPrice = (newItem["price"]!!).doubleValue
                                let newItem = Item(itemDescription: itemDescription, tag: itemTag, itemName: itemName, price: itemPrice, timestamp: timestamp)
                                
                                newItem.imageKey = imageKey
                                album.addItem(newItem)
                                self.insertItem(newItem)
                                self.getImage(0, album: album, imageId: imageKey, item: newItem)
                            }
                        }
                    } else {
                        //No unsold items, so delete the album
                        self.ref.child("\(college)/albums/\(albumID)").removeValue()
                        if let albumDetails = snapshot.value!["albumDetails"] as? [String : AnyObject] {
                            let sellerID = albumDetails["sellerID"] as! String
                            self.ref.child("\(college)/user/\(sellerID)/albums/\(albumID)").removeValue()
                        }
                    }
                    
                    
                    //There's an item in the feed which isn't in the database any more.  Get rid of it!
                    
                    for i in (0..<currentItemMatches.count).reverse() { //Loop through items which should have matches
                        if currentItemMatches[i] == false { //If they don't have a match, you know you have to delete something from allItems
                            let item = album.unsoldItems[i]
                            album.unsoldItems.removeAtIndex(i)
                            print("removed from unsold items")
                            
                            //Loop through allItems, if you find the item you want to remove, delete it!
                            for (index,testItem) in self.allItems.enumerate().reverse() {
                                if testItem.imageKey == item.imageKey { //If the imageKeys match, assume they're the same
                                    self.allItems.removeAtIndex(index)
                                    print("removed from allItems")
                                }
                            }
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                self?.tableView?.reloadData()
            }
        })
        //    })
        listeners.append(albumChangedListener)
    }
    
    
    
    func createChildRemovedListener(feed: FIRDatabaseQuery) {
        let albumRemovedListener = feed.observeEventType(FIRDataEventType.ChildRemoved, withBlock: { (snapshot) in
            print("item got removed")
            let albumID = snapshot.key
            
            var album: Album?
            
            for currAlbum in self.albums {
                if currAlbum.albumID == albumID {
                    album = currAlbum
                    break
                }
            }
            
            //Get rid of items in a specific album
            for (index, item) in self.allItems.enumerate().reverse() {
                if item.album == album {
                    self.allItems.removeAtIndex(index)
                    print("removed from all items")
                }
            }
            
            if !self.showAlbums {
                self.filterByCategory(self.category)
            }
            if self.searchBarActive {
                self.filterContentForSearchText(self.searchBar!.text!)
            }
            
            dispatch_barrier_async(self.queue) {
                if let album = album {
                    self.albums.removeAtIndex(self.albums.indexOf(album)!)
                    
                }
            }
            self.tableView!.reloadData()
        })
        listeners.append(albumRemovedListener)
    }
    
    
    
    
    
    
    
    
    //Get image from Firebase database
    func getImage(repetitions: Int, album: Album, imageId: String, item: Item) {
        let storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com")
        
        let id = album.sellerID
        
        let imageRef = storageRef.child("\(album.sellerCollege)/user/\(id)/images/\(imageId)")
        imageRef.downloadURLWithCompletion{ (URL, error) -> Void in
            if (error != nil ) {
                //If there's an error (probably b/c the image is not yet saved in storage), wait one second, then try to retrieve it again
                //Stop after 3 times
                let triggerTime = (Int64(NSEC_PER_SEC) * 1)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                    if (repetitions <= 3) {
                        self.getImage(repetitions + 1, album: album, imageId: imageId, item: item)
                    }
                    else {
                        item.picture = mainClass.defaultPic(item.tag)
                        dispatch_async(dispatch_get_main_queue()) { [weak self] in
                            self?.tableView?.reloadData()
                        }
                    }
                })
            } else {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
                    if let picData = NSData(contentsOfURL: URL!) {
                        if self != nil {
                            dispatch_barrier_async(self!.queue) {
                                item.picture = UIImage(data: picData)!
                                print("got the pic")
                                self!.hideLoadingCircle()
                            }
                        }
                        dispatch_async(dispatch_get_main_queue()) { [weak self] in
                            self?.tableView!.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    //MARK: COLLECTION VIEW FUNCTIONS
    
    
    
    
    //How many items are in  displayed in the collection view
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if searchBarActive || showAlbums == false {
            count = categoryItems.count
            // return count
        } else {
            objc_sync_enter(self.albums)
            count = albums.count
            objc_sync_exit(self.albums)
            
            // return count
        }
        //showNoResultsFound(count == 0) TODO: Add back in
        print("the count is \(count)")
        return count
    }
    
    
    func showNoResultsFound(shouldShow: Bool) {
        if shouldShow {
            if !loadingCircle.isDescendantOfView(self.view) {
                self.view.addSubview(notFoundLabel)
            }
        } else {
            notFoundLabel.removeFromSuperview()
        }
    }
    
    
    
    
    func getCurrentItem(index: Int) -> Item? {
        print("called getCurrentItem")
        var currItem: Item?
        if searchBarActive || showAlbums == false {
            objc_sync_enter(self.categoryItems)
            currItem = categoryItems[index]
            objc_sync_exit(self.categoryItems)
            return currItem
        } else {
            if let currAlbum = getCurrentAlbum(index) {
                print ("imageindex is \(currAlbum.imageIndex) but unsold items is only \(currAlbum.unsoldItems.count)")
                if currAlbum.unsoldItems.count > currAlbum.imageIndex {
                    return currAlbum.unsoldItems[currAlbum.imageIndex] //TODO: Crashed when I deleted the second item in the album, going decently fast. //TODO: Also crashed when another person bought the last item on the feed
                }
            }
        }
        return nil
    }
    
    
    func getCurrentAlbum(index: Int) -> Album? {
        if index < self.albums.count {
            return self.albums[index]
        }
        return nil
    }
    
    
    
    
    
    //Specify what's in each cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Show Items
        print("about to call getCurrentItem from cellForRow")
        if let currItem = getCurrentItem(indexPath.row) {
            var cell: FeedTableViewCell!
            
            if currItem.tag == "In Search Of" {
                cell = tableView.dequeueReusableCellWithIdentifier("iso") as! FeedTableViewCell
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("normal", forIndexPath: indexPath) as! FeedTableViewCell
            }
            
            cell.currentItem = currItem
            
            cell.removeDots()
            cell.linkItems()
            cell.collectionView.allowsSelection = true
            cell.currentAlbum = currItem.album!
            if searchBarActive || !showAlbums {
                cell.currentAlbum = currItem.album
                cell.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            } else {
                cell.updateIndex(cell.currentAlbum!.visibleItemIndex)
                cell.collectionView.setContentOffset(CGPoint(x: (self.view.frame.width + 10) * CGFloat(cell.currentAlbum!.visibleItemIndex), y: 0), animated: false)
                cell.shouldSnap = true
                snap(cell, position: cell.currentAlbum!.visibleItemIndex)
            }
            if pleaseDontWork.count >= indexPath.row {
                pleaseDontWork.append(cell)
            } else {
                pleaseDontWork[indexPath.row] = cell
            }
            
            return cell
        }
        return tableView.dequeueReusableCellWithIdentifier("normal", forIndexPath: indexPath) as! FeedTableViewCell
    }
    
    
    
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return view.frame.width + 63
    }
    
    
    
    
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dragging = false
    }
    
    
    
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        dragging = true
        let tableViewCell = getTableViewCell(scrollView.tag)
        tableViewCell.shouldSnap = true
    }
    
    
    
    
    
    
    //MARK: SEARCH BAR/FILTERING/MENU FUNCTIONS
    
    
    
    
    func filterByCategory (category: String) {
        self.category = category
        objc_sync_enter(self.allItems)
        categoryItems = allItems.filter { Item in
            if category == "All Items" {
                return true
            }
            else {
                if Item.tag == category {
                    return true
                }
                else {
                    return false
                }
            }
        }
        tableView.reloadData()
        objc_sync_exit(self.allItems)
    }
    
    
    
    
    
    
    //When the user searches, make sure the only items displayed are those which match the category & the search term
    override func filterContentForSearchText(searchText: String){
        categoryItems = allItems.filter { Item in
            let priceMatch = (category == "All Items" || category == "Album View" || Item.tag == category)
            if searchText == "" {
                return priceMatch
            }
            else {
                let allTogetherString = Item.itemName + Item.tag + Item.itemDescription + Item.album!.seller + Item.album!.albumName
                return priceMatch && allTogetherString.lowercaseString.containsString(searchText.lowercaseString)
            }
        }
        tableView.reloadData()
    }
    
    
    
    
    func screenEdgeSwiped(recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .Recognized {
            self.revealViewController().revealToggleAnimated(true)
            menuIsOpen = true
            showMenuOpenOverlay(menuIsOpen)
        }
    }
    
    
    
    func toggleMenu() {
        menuIsOpen = !menuIsOpen
        showMenuOpenOverlay(menuIsOpen)
        revealViewController().revealToggleAnimated(true)
    }
    
    
    
    func showMenuOpenOverlay(shouldShow: Bool) {
        if shouldShow {
            let tapRecognizer = UITapGestureRecognizer(target:self, action: #selector(toggleMenu)) //TODO:Change
            overlayBackground.addGestureRecognizer(tapRecognizer)
            tabBarController!.tabBar.userInteractionEnabled = false
            
            //            let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(toggleMenu))
            //            swipeRecognizer.direction = UISwipeGestureRecognizerDirection.Right
            //            overlayBackground.addGestureRecognizer(swipeRecognizer)
            
            self.view.addSubview(overlayBackground)
            
            self.tableView.scrollEnabled = false
        } else {
            overlayBackground.removeFromSuperview()
            self.tableView.scrollEnabled = true
            tabBarController!.tabBar.userInteractionEnabled = true
        }
    }
    
    
    
    
    
    
    
    
    
    
    //MARK: COLLECTION VIEW FUNCTIONS
    
    
    //Tutorial for how to put a collectionview inside a tableview:
    //Created by Ash Furrow: "Putting a UICollectionView in a UITableViewCell in Swift"
    //https://ashfurrow.com/blog/putting-a-uicollectionview-in-a-uitableviewcell-in-swift/
    //License https://creativecommons.org/licenses/by/4.0/
    
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !showAlbums || searchBarActive {
            return 1
        } else {
            if let album = getCurrentAlbum(collectionView.tag) {//Set to be equal to the indexPath.row of tableView
                return album.unsoldItems.count
            }
        }
        return 0
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell: FeedCollectionCell!
        var item: Item!
        var album: Album!
        let tableViewCell = getTableViewCell(collectionView.tag)
        if !showAlbums || searchBarActive {
            item = tableViewCell.currentItem!
            album = tableViewCell.currentAlbum!
        } else {
            album = getCurrentAlbum(collectionView.tag)
            item = album?.unsoldItems[indexPath.item]
        }
        if item.tag == "In Search Of" {
            if item.hasPic {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier("yesPic", forIndexPath: indexPath) as! FeedCollectionCell
            } else {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier("noPic", forIndexPath: indexPath) as! FeedCollectionCell
            }
        } else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("normal", forIndexPath: indexPath) as! FeedCollectionCell
        }
        
        cell.linkItems()
        let tapRec = UITapGestureRecognizer(target:self, action: #selector(cellTapped2(_:)))
        cell.addGestureRecognizer(tapRec)
        cell.formatCell(item, album: album)
        print("cell for items")
        print(tableView.numberOfRowsInSection(0))
        return cell
    }
    
    
    
    func getTableViewCell(row: Int) -> FeedTableViewCell {
        print("really?  REALLY??")
        //let tableViewIndexPath = NSIndexPath(forItem: row, inSection: 0)
        //return tableView.cellForRowAtIndexPath(tableViewIndexPath) as? FeedTableViewCell
        return pleaseDontWork[row]
    }
    
    
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        print("ended displaying cell")
        if showAlbums && !searchBarActive {
            let cell = cell as! FeedCollectionCell
            let tableViewCell = getTableViewCell(collectionView.tag)
            let disappearingViewIndex = indexPath.item
            let maxCount = cell.currentAlbum!.unsoldItems.count
            let imageIndex = cell.currentAlbum!.imageIndex
            if (disappearingViewIndex == 1 && imageIndex == 0) {
                tableViewCell.shouldSnap = true
                snap(tableViewCell, position: 0)
            }
            if (disappearingViewIndex == maxCount - 2 && imageIndex == maxCount - 1 ) { //If we're on the edge
                tableViewCell.shouldSnap = true
                snap(tableViewCell, position: maxCount - 1)
            }
        }
        
    }
    
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let tableViewCell = getTableViewCell(collectionView.tag)
        if !searchBarActive && showAlbums {
            let oldIndex = tableViewCell.currentAlbum?.imageIndex
            if indexPath.row > oldIndex { //Scrolling right (by moving thumb left)
                snap(tableViewCell, position: indexPath.row - 1)
            } else { //Scrolling left (by moving thumb right)
                if indexPath.row < oldIndex {
                    snap(tableViewCell, position: indexPath.row + 1)
                }
            }
        } else {
            tableViewCell.showPrice(-1, isAlbumView: false)
        }
        tableViewCell.updateIndex(indexPath.item)
        
    }
    
    
    func snap(tableViewCell: FeedTableViewCell, position: Int){
        if tableViewCell.shouldSnap {
            tableViewCell.currentAlbum?.visibleItemIndex = position
            tableViewCell.showPrice(position, isAlbumView: true)
            tableViewCell.setDots(position)
        }
        if !dragging && tableViewCell.shouldSnap {
            tableViewCell.shouldSnap = false
            tableViewCell.updateIndex(position)
            tableViewCell.updateCellUI(true)
            tableViewCell.collectionView.setContentOffset(CGPoint(x: (self.view.frame.width + 10) * CGFloat(position), y: 0), animated: true)
        }
    }
    
    //Test when snap is called
    //Test whether problem is with albums vs individual items or whether it's related to everything below the first or what
    //Test when the label gets updated.
    //Test when things get shuffled.  Why would that be bad???
    
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        print("tag is \(collectionView.tag)")
        print("num is \(tableView.numberOfRowsInSection(0))")
        let tableViewCell = getTableViewCell(collectionView.tag)
        print("tableviewcell is \(tableViewCell)")
        print("currentAlbum is \(tableViewCell.currentAlbum)")
        if tableViewCell.currentAlbum!.isISO { //TODO: Crashed here!!!
            //return CGSize(width: self.view.frame.width, height: self.view.frame.width - 85)
            return CGSize(width: self.view.frame.width, height: self.view.frame.width - 55)
        }
        
        return CGSize(width: self.view.frame.width, height: self.view.frame.width)
        //return CGSize(width: self.view.frame.width, height: self.view.frame.width - 30)
    }
    
    
    
    
    func cellTapped2(gestureRec: UITapGestureRecognizer) {
        let cell = gestureRec.view as! FeedCollectionCell
        performSegueWithIdentifier("theWolf", sender: cell)
    }
    
    
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    
    
    
    
    //MARK: ACTIONS AND SEGUES
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "theWolf" { //Go to Closeup
            let cell = sender as! FeedCollectionCell
            let item = cell.currentItem!
            let album = cell.currentAlbum!
            let detailView: CloseUp = segue.destinationViewController as! CloseUp
            detailView.name = item.itemName
            detailView.descript = item.itemDescription
            detailView.🔥 = String(item.price)
            detailView.sellerUID = album.sellerID
            detailView.sellerCollege = album.sellerCollege
            detailView.seller = album.seller
            detailView.pic = item.picture
            detailView.albumID = album.albumID
            detailView.imageID = item.imageKey
            if let long = album.locationLong  {
                detailView.long = long
                detailView.lat = album.locationLat!
                detailView.location = cell.currentAlbum!.location
            }
        }
        if segue.identifier == "peterPan" { //Person pushed skip and browse, and is now changing the colleges they're trading with
            if let destination = segue.destinationViewController as? CollegeChooser {
                destination.segueLoc = "feed"
                var collegeNames = [String]()
                for col in collegeTradingList {
                    if let colName = mainClass.emailGetter.getNameFromDomain(col) {
                        collegeNames.append(colName)
                    }
                }
                destination.previousColleges = collegeNames
            }
        }
    }
}
