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

var homeController: FeedController!

class FeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var addItem: UIBarButtonItem!
    let searchController = UISearchController(searchResultsController: nil)
    var categoryItems = [Item]()
    var category = "all" {
        willSet(newValue) {
            print("changing from \(category) to \(newValue)")
        }
        didSet{
            print("Changed from \(oldValue) to \(category)")
        }
    }
    var college = "hmc"
    var ref = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com")
    var itemsListener: FIRDatabaseHandle?
    var pictures: [Int]?
    //var albums = [Album]() //maybe make another album class
    var albums = [Int : Album]()
    var index = 0
    var menuIsOpen = false
    var allItems = [Item]()
    var showAlbums = true
    var biggestNumber = 0.0
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        homeController = self
        
        
        print("Feed did load")
        super.viewDidLoad()
        
        //        self.hideKeyboardWhenTappedAround()
        //navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Bookmarks, target: self, action: #selector(openMenu))
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "menu"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(openMenu), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 31, 31)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        
        //navigationItem.leftBarButtonItem.setImage(UIImage(named: "fb.png"), forState: UIControlState.Normal)
        
        
        
        
        
        
        //Set up search bar
        let prices = ["All", "Free", "< $10", "< $25", "< $50"]
        searchController.searchBar.delegate = self
        searchController.searchBar.scopeButtonTitles = prices
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        //        self.searchController.loadViewIfNeeded()    // iOS 9
        //        let _ = self.searchController.view
        
        //        self.searchController.view.removeFromSuperview()
        self.collectionView?.addSubview(searchController.searchBar)
        
        
        //Finish setting up the view
        navigationItem.title = "BubbleU Feed"
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        collectionView?.alwaysBounceVertical = true
        
        //Reveals categories when you press the menu button
        print("revewalViewController coming")
        //print(self.revealViewController())
        if self.revealViewController() != nil {
            // menuButton.target = self.revealViewController()
            //menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            // menuButton.action = #selector(openMenu)
            let edgePan = UIScreenEdgePanGestureRecognizer(target:self, action: #selector(screenEdgeSwiped))
            edgePan.edges = .Left
            self.view.addGestureRecognizer(edgePan)
        }
        
        //        print(" in viewDidLoad")
        //        //Load the pictures in the right category(or all of them if category is 'All')
        //
        //        print("allItems part 2")
        //        print (allItems.count)
        //        print("right outside loop")
        //        for item in allItems {
        //            print("running through loop!")
        //            if item.getTags() == category || category == "All"{
        //                categoryItems.append(item)
        //                print(item.getTags())
        //            }
        //        }
        
        
        
        //        categoryItems = allItems.filter { Item in
        //            print("inside categoryItems filtering thing")
        //            if category == "All" {
        //                print("it's all!!!!")
        //                return true
        //            }
        //            else {
        //                if Item.getTags() == category {
        //                    print("category is right: \(category)")
        //                    return true
        //                }
        //                else {
        //                    print("not the right category: \(category)")
        //                    return false
        //                }
        //            }
        //        }
        
        
        
        self.collectionView!.registerClass(FeedCollectionViewCell.self, forCellWithReuseIdentifier: "Pictures")
        if itemsListener == nil {
            getRecentItems()
        }
        else {
            
        }
        
    }
    deinit {
        //        self.searchController.loadViewIfNeeded()    // iOS 9
        //        let _ = self.searchController.view
        self.searchController.view.removeFromSuperview()
    }
    
    func screenEdgeSwiped(recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .Recognized {
            self.revealViewController().revealToggleAnimated(true)
            menuIsOpen = true
        }
    }
    
    
    
    func openMenu() {
        self.revealViewController().revealToggleAnimated(true)
        menuIsOpen = !menuIsOpen
    }
    
    
    //Call Firebase to get image IDs from database.
    func getRecentItems() {
        print("getting recent items")
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in
            let feed = self.ref.child("\(self.college)/albums").queryLimitedToLast(15)
            self.itemsListener = feed.observeEventType(FIRDataEventType.ChildAdded, withBlock: { (snapshot) in
                
                if let allAlbumsDict = snapshot.value as? [String : AnyObject] {
                    for (unsoldItems, item) in allAlbumsDict { //Key is album ID, value is all the album info
                        let item = item as! [String : AnyObject]
                        var newAlbum = Album()
                        newAlbum.createIndex(self.index)
                        self.index -= 1
                        for (imageID, imageInfo) in item {
                            let sellerID = imageInfo["sellerId"] as! String
                            let itemDescription = imageInfo["description"] as! String
                            let itemTag = imageInfo["tag"] as! String
                            let itemName = imageInfo["name"] as! String
                            let itemPrice = imageInfo["price"] as! Double
                            let seller = imageInfo["sellerName"] as! String
                            let albumName = imageInfo["albumName"] as! String
                            let timestamp = imageInfo["timestamp"] as! String
                            newAlbum.albumName = albumName
                            self.getImage(0, album: newAlbum, imageId: imageID, sellerUID: sellerID, description: itemDescription, tag: itemTag, name: itemName, price: itemPrice, seller: seller, timestamp: timestamp)
                        }
                    }
                }
            })
        }
    }
    
    
    
    
    
    
    
    
    
    
    func getImage(repetitions: Int, album: Album, imageId: String, sellerUID: String, description: String, tag: String, name: String, price: String, seller: String, timestamp: String){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in
            let imageRef = self.storageRef.child("hmc/user/\(sellerUID)/unsoldItems/\(imageId)")
            imageRef.downloadURLWithCompletion{ (URL, error) -> Void in
                if (error != nil ) {
                    let triggerTime = (Int64(NSEC_PER_SEC) * 1)
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                        if (repetitions <= 5) {
                            self.getImage(repetitions + 1, album: album, imageId: imageId, sellerUID: sellerUID, description: description, tag: tag, name: name, price: price, seller: seller, timestamp: timestamp)
                        }
                    })
                } else {
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in
                        if let picData = NSData(contentsOfURL: URL!) { //The pic!!!
                            let image = UIImage(data: picData)!
                            let newItem = Item(itemDescription: description, tags: tag, itemName: name, price: price, picture: image, seller: seller, timestamp: timestamp)
                            self.allItems.append(newItem)
                            self.categoryItems.append(newItem)
                            album.addItem(newItem)
                            if album.unsoldItems.count == 1 {
                                self.albums[album.index] = album
                            }
                            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                                self.collectionView!.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    //How many items are in  displayed in the collection view
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("show albums is \(showAlbums)")
        if searchController.active || showAlbums == false {
            print("Category Items .Count")
            print(categoryItems.count)
            return categoryItems.count
        } else {
            return albums.count
        }
    }
    
    
    
    func swiped(swipeGesture: UISwipeGestureRecognizer) {
        let cell = swipeGesture.view as! FeedCollectionViewCell
        switch swipeGesture.direction {
        case UISwipeGestureRecognizerDirection.Right:
            cell.imageIndex -= 1
            if cell.imageIndex < 0 {
                cell.imageIndex = (cell.currentAlbum?.unsoldItems.count)! - 1
            }
            let item = cell.currentAlbum?.unsoldItems[cell.imageIndex]
            let image = item?.getPicture()
            let price = item?.getPrice()
            cell.imageView.image = image
            cell.textView.text = cell.currentAlbum!.albumName + "\n" + price!
        case UISwipeGestureRecognizerDirection.Left:
            if menuIsOpen {
                revealViewController().revealToggleAnimated(true)
                menuIsOpen = false
            } else {
                cell.imageIndex += 1
                if cell.imageIndex > (cell.currentAlbum?.unsoldItems.count)! - 1 {
                    cell.imageIndex = 0
                }
                let item = cell.currentAlbum?.unsoldItems[cell.imageIndex]
                let image = item?.getPicture()
                let price = item?.getPrice()
                cell.imageView.image = image
                cell.textView.text = cell.currentAlbum!.albumName + "\n" + price!
            }
        default:
            print("default")
        }
    }
    
    
    func filterByCategory (category: String) {
        print("the func is actually running!!!")
        showAlbums = false
        self.category = category
        print(self.category)
        categoryItems = allItems.filter { Item in
            print("inside categoryItems filtering thing")
            if category == "all" {
                print("it's all!!!!")
                return true
            }
            else {
                if Item.getTags() == category {
                    print("category is right: \(category)")
                    return true
                }
                else {
                    print("not the right category: \(category)")
                    return false
                }
            }
        }
    }
    
    func biggestNumber(scope: String) -> Double {
        
        if scope == "All" {
            biggestNumber = 10000000
        }
        if scope == "Free" {
            biggestNumber = 0
        }
        if scope == "< $10" {
            biggestNumber = 10
        }
        if scope == "< $25" {
            biggestNumber = 25
        }
        if scope == "< $50" {
            biggestNumber = 50
        }
        return biggestNumber
    }
    
    
    //Specify what's in each cell
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Pictures", forIndexPath: indexPath) as! FeedCollectionViewCell
        print("we created a cell!")
        print("should show album")
        print(showAlbums)
        if searchController.active || showAlbums == false {
            
            
            //Create label, which contains seller's name and timestamp
            cell.label.numberOfLines = 2
            print("before it crashes")
            print(indexPath.row)
            print(categoryItems.count)
            cell.currentItem = categoryItems[indexPath.row]
            
            
            let attributedText = NSMutableAttributedString(string: cell.currentItem!.getSeller(), attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(14)])
            attributedText.appendAttributedString(NSAttributedString(string: "\n" + cell.currentItem!.timestamp, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(12)]))
            cell.label.backgroundColor = UIColor(red: 167/255, green: 255/255, blue: 164/255, alpha: 1)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.string.characters.count))
            cell.label.attributedText = attributedText
            
            
            //Create textview, which contains the item name and price
            //let textView = UITextView()
            cell.textView.backgroundColor = UIColor(red: 244/255, green: 254/255, blue: 193/255, alpha: 1)
            cell.textView.editable = false
            //textView.text = pictures[indexPath.row].getItemDescription() + "\n" + pictures[indexPath.row].getPrice()
            cell.textView.text = cell.currentItem!.getItemName() + "\n" + String(cell.currentItem!.getPrice())
            cell.textView.font = UIFont.systemFontOfSize(14)
            
            
            //Create an imageview, which contains the picture of the 1st item in the album
            //let imageView = UIImageView()
            cell.imageView.image = cell.currentItem!.getPicture()
            let newRect = cell.imageView.image!.cropRect()
            if let imageRef = CGImageCreateWithImageInRect(cell.imageView.image!.CGImage!, newRect) {
                cell.imageView.image = UIImage(CGImage: imageRef)
            }
            
            
            
            
        } else {
            
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
            leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
            cell.addGestureRecognizer(leftSwipe)
            
            let RightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
            RightSwipe.direction = UISwipeGestureRecognizerDirection.Right
            cell.addGestureRecognizer(RightSwipe)
            
            //Create label, which contains seller's name and timestamp
            cell.label.numberOfLines = 2
            let sortedKeys = Array(albums.keys).sort(<)
            let currAlbum = albums[sortedKeys[indexPath.row]]
            let currPic = currAlbum!.unsoldItems[0]
            cell.currentAlbum = currAlbum
            cell.currentItem = currPic
            
            
            let attributedText = NSMutableAttributedString(string: currPic.getSeller(), attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(14)])
            attributedText.appendAttributedString(NSAttributedString(string: "\n" + currPic.timestamp, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(12)]))
            cell.label.backgroundColor = UIColor(red: 167/255, green: 255/255, blue: 164/255, alpha: 1)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.string.characters.count))
            cell.label.attributedText = attributedText
            
            
            //Create textview, which contains the item name and price
            //let textView = UITextView()
            cell.textView.backgroundColor = UIColor(red: 244/255, green: 254/255, blue: 193/255, alpha: 1)
            cell.textView.editable = false
            //textView.text = pictures[indexPath.row].getItemDescription() + "\n" + pictures[indexPath.row].getPrice()
            cell.textView.text = currAlbum!.albumName + "\n" + String(currPic.getPrice())
            cell.textView.font = UIFont.systemFontOfSize(14)
            
            
            //Create an imageview, which contains the picture of the 1st item in the album
            //let imageView = UIImageView()
            cell.imageView.image = currPic.getPicture()
            let newRect = cell.imageView.image!.cropRect()
            if let imageRef = CGImageCreateWithImageInRect(cell.imageView.image!.CGImage!, newRect) {
                cell.imageView.image = UIImage(CGImage: imageRef)
            }
            
        }
        
        //Get rid of old subviews so they don't get layeed on top of each other
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        //Add the views we just created to the cell
        cell.contentView.addSubview(cell.label)
        cell.contentView.addSubview(cell.textView)
        cell.contentView.addSubview(cell.imageView)
        
        
        //Add constraints so the views look nice
        cell.addConstraintsWithFormat("H:|-4-[v0]|", views: cell.label)
        cell.addConstraintsWithFormat("H:|-4-[v0]|", views: cell.textView)
        cell.addConstraintsWithFormat("H:|[v0]|", views: cell.imageView)
        cell.addConstraintsWithFormat("V:|[v0]-4-[v1]-4-[v2(300)]-4-|", views: cell.label, cell.textView, cell.imageView)
        
        return cell
        
    }
    
    
    //Specify how large each cell is
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.frame.width, 390)
        
    }
    
    
    
    //When you click on the plus button, it takes you to the AddNewItem view
    @IBAction func didPressAddItem(sender: AnyObject) {
        performSegueWithIdentifier("addItem", sender: sender)
    }
    

    
    
    //When the user searches, make sure the only items displayed are those which match the category & the search term
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        categoryItems = allItems.filter { Item in
            print("all the filtering info")
            print(scope)
            print(category)
            print(Item.getTags())
            
            let priceMatch = ((scope == "All") && (category == "all" || Item.getTags() == category)) || (biggestNumber(scope) > Item.getPrice()) //|| (Item.getPrice() == scope)
            print(priceMatch)
            if searchText == "" {
                return priceMatch
            }
            else {
                return priceMatch && Item.getItemName().lowercaseString.containsString(searchText.lowercaseString)
            }
        }
        
        collectionView!.reloadData()
    }
    
   
    
    
}

//class FeedCell: UICollectionViewCell {
//
//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var textView: UITextView!
//    @IBOutlet weak var nameLabel: UILabel!
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        setupViews()
//    }
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        imageView = nil
//        nameLabel = nil
//        textView = nil
//    }
//
//    required init?(coder aDecoder: NSCoder){
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    let nameLabel: UILabel = {
//
//        let label = UILabel()
//        label.numberOfLines = 2
//        let attributedText = NSMutableAttributedString(string: "Preethi Seshadri", attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(14)])
//        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
//
//        attributedText.appendAttributedString(NSAttributedString(string: "\n" + timestamp, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(12)]))
//
//
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 4
//
//        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.string.characters.count))
//
//        let attachment = NSTextAttachment()
//        attachment.image = UIImage(named: "globe_small")
//        attachment.bounds = CGRectMake(0, -2, 12, 12)
//        attributedText.appendAttributedString(NSAttributedString(attachment: attachment))
//
//        label.attributedText = attributedText
//
//        return label
//    }()
//
//    let profileImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(named: "profilepic")
//        imageView.contentMode = .ScaleAspectFit
//        imageView.backgroundColor = UIColor.clearColor()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//
//    let statusTextView: UITextView = {
//        let textView = UITextView()
//        textView.editable = false
//        textView.text = "Bike in good condition!"
//        textView.font = UIFont.systemFontOfSize(14)
//        return textView
//    }()
//
//    let statusImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(named: "bike")
//        imageView.contentMode = .ScaleAspectFill
//        imageView.layer.masksToBounds = true
//        return imageView
//    }()
//
//
//    func setupViews() {
//        backgroundColor = UIColor.whiteColor()
//
//        addSubview(nameLabel)
//        addSubview(profileImageView)
//        addSubview(statusTextView)
//        addSubview(statusImageView)
//
//
//        addConstraintsWithFormat("H:|-8-[v0(44)]-8-[v1]|", views: profileImageView, nameLabel)
//        addConstraintsWithFormat("H:|-4-[v0]-4-|", views: statusTextView)
//        addConstraintsWithFormat("H:|[v0]|", views: statusImageView)
//        addConstraintsWithFormat("V:|-12-[v0]", views: nameLabel)
//        addConstraintsWithFormat("V:|-8-[v0(44)]-4-[v1(30)]-4-[v2]|", views: profileImageView, statusTextView, statusImageView)
//
//    }
//}


//Lets you add constraints to any view programmatically
extension UIView {
    
    func addConstraintsWithFormat(format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerate() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
        
    }
    
}


//Filter results when you search
extension FeedController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

//Lets you create a search bar
extension FeedController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}



//Crops the image to make it fit into the feed nicely
extension UIImage {
    func cropRect() -> CGRect {
        let cgImage = self.CGImage!
        let context = createARGBBitmapContextFromImage(cgImage)
        if context == nil {
            return CGRectZero
        }
        
        let height = CGFloat(CGImageGetHeight(cgImage))
        
        let width = CGFloat(CGImageGetWidth(cgImage))
        
        let rect = CGRectMake(0, 0, width, height)
        CGContextDrawImage(context, rect, cgImage)
        
        let data = UnsafePointer<CUnsignedChar>(CGBitmapContextGetData(context))
        
        if data == nil {
            return CGRectZero
        }
        
        let lowX = width
        let lowY = height
        let highX: CGFloat = 0
        let highY: CGFloat = 0
        //
        //        //Filter through data and look for non-transparent pixels.
        //        for (var y: CGFloat = 0 ; y < height ; y++) {
        //            for (var x: CGFloat = 0; x < width ; x++) {
        
        
        let height2 = Int(CGImageGetHeight(cgImage))
        let width2 = Int(CGImageGetWidth(cgImage))
        var lowX2 = width2
        var lowY2 = height2
        var highX2 = 0
        var highY2 = 0
        
        
        //Filter through data and look for non-transparent pixels.
        for y in 0..<height2  {
            for x in 0..<width2 {
                
                let pixelIndex = (width2 * y + x) * 4 /* 4 for A, R, G, B */
                
                if data[Int(pixelIndex)] != 0 { //Alpha value is not zero pixel is not transparent.
                    if (x < lowX2) {
                        lowX2 = x
                    }
                    if (x > highX2) {
                        highX2 = x
                    }
                    if (y < lowY2) {
                        lowY2 = y
                    }
                    if (y > highY2) {
                        highY2 = y
                    }
                }
            }
        }
        
        
        return CGRectMake(lowX, lowY, highX-lowX, highY-lowY)
    }
    
    
    
    func createARGBBitmapContextFromImage(inImage: CGImageRef) -> CGContextRef? {
        
        let width = CGImageGetWidth(inImage)
        let height = CGImageGetHeight(inImage)
        
        let bitmapBytesPerRow = width * 4
        let bitmapByteCount = bitmapBytesPerRow * height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        if colorSpace == nil {
            return nil
        }
        
        let bitmapData = malloc(bitmapByteCount)
        if bitmapData == nil {
            return nil
        }
        
        let context = CGBitmapContextCreate (bitmapData,
                                             width,
                                             height,
                                             8,      // bits per component
            bitmapBytesPerRow,
            colorSpace,
            CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        return context
    }
}
