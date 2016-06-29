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


class FeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var addItem: UIBarButtonItem!
    let searchController = UISearchController(searchResultsController: nil)
    var categorypics = [Item]()
    var category = "All"
    var college = "hmc"
    var ref = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com")
    var itemsListener: FIRDatabaseHandle?
    var pictures = [Item]()
    //var albums = [Album]() //maybe make another album class
    var albums = [Int : Album]()
    var index = 0
    
//    var pictures = [Item(itemDescription: "Bike in good condition!", tags: "Transportation", itemName: "Bike", price: "$25", picture: UIImage(named: "bike")!, seller: "Preethi Seshadri"),
//                    Item(itemDescription: "Old iPhone 4", tags: "Electronics", itemName: "iPhone 4", price: "$20", picture: UIImage(named: "iPhone")!, seller: "Matthew Guillory"),
//                    Item(itemDescription: "Nice dorm Fridge!", tags: "Appliances", itemName: "Fridge", price: "$30", picture: UIImage(named: "fridge")!, seller: "Colleen Lewis")]
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        print("Feed did load")
        super.viewDidLoad()
        //        self.hideKeyboardWhenTappedAround()
        
        //Get images from Firebase
        //getRecentItems()
        if itemsListener == nil {
            getRecentItems()
        }
        else {
            
        }
        
        
        //Set up search bar
        let prices = ["All", "Free", "< $10", "< $25", "< $50"]
        searchController.searchBar.delegate = self
        searchController.searchBar.scopeButtonTitles = prices
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.collectionView?.addSubview(searchController.searchBar)
        
        
        //Finish setting up the view
        navigationItem.title = "BubbleU Feed"
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        collectionView?.alwaysBounceVertical = true
        
        //Reveals categories when you press the menu button
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //Load the pictures in the right category(or all of them if category is 'All')
        categorypics = pictures.filter { Item in
            if category == "All" {
                print("it's all!!")
                return true
            }
            else {
                print("not all categories")
                if Item.getTags() == category {
                    return true
                }
                else {
                    return false
                }
            }
        }
        
    }
    
    
    
    //Call Firebase to get image IDs from database.
    func getRecentItems() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in
        let feed = self.ref.child("\(self.college)/albums").queryLimitedToLast(15)
        self.itemsListener = feed.observeEventType(FIRDataEventType.ChildAdded, withBlock: { (snapshot) in
            
            if let allAlbumsDict = snapshot.value as? [String : AnyObject] {
                for (unsoldItems, item) in allAlbumsDict { //Key is album ID, value is all the album info
                    print(snapshot)
                    //print(key)
                    print(item)
                    let item = item as! [String : AnyObject]
                   // let unsoldItems = value["unsoldItems"] as! [String: AnyObject]
                    //let items = Array(unsoldItems.keys)
                    //let firstImage = Array(unsoldItems.keys)[0]
                    var newAlbum = Album()
                    newAlbum.createIndex(self.index)
                    self.index -= 1
                    for (imageID, imageInfo) in item {
                        //let imageID = items[i]
                       // let imageInfo = unsoldItems[imageID]
                        let sellerID = imageInfo["sellerId"] as! String
                        let itemDescription = imageInfo["description"] as! String
                        let itemTag = imageInfo["tag"] as! String
                        let itemName = imageInfo["name"] as! String
                        print("Here's the item name!!!!!")
                        print(itemName)
                        let itemPrice = imageInfo["price"] as! String
                        let seller = imageInfo["sellerName"] as! String
                        let albumName = imageInfo["albumName"] as! String
                        let timestamp = imageInfo["timestamp"] as! String
                        newAlbum.albumName = albumName 
                        self.getImage(newAlbum, imageId: imageID, sellerUID: sellerID, description: itemDescription, tag: itemTag, name: itemName, price: itemPrice, seller: seller, timestamp: timestamp)
                    }
                    //self.albums.append(newAlbum)
                    
                }
            }
        })
        }
    }
    
    
    
    
   
    
    
    
    
    
    func getImage(album: Album, imageId: String, sellerUID: String, description: String, tag: String, name: String, price: String, seller: String, timestamp: String){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in
        let imageRef = self.storageRef.child("hmc/user/\(sellerUID)/unsoldItems/\(imageId)")
        imageRef.downloadURLWithCompletion{ (URL, error) -> Void in
            if (error != nil ) {
                print(error?.localizedDescription)
                let triggerTime = (Int64(NSEC_PER_SEC) * 1)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                    self.getImage(album, imageId: imageId, sellerUID: sellerUID, description: description, tag: tag, name: name, price: price, seller: seller, timestamp: timestamp)
                })
            } else {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in
                if let picData = NSData(contentsOfURL: URL!) { //The pic!!!
                    let image = UIImage(data: picData)!
                    let newItem = Item(itemDescription: description, tags: tag, itemName: name, price: price, picture: image, seller: seller, timestamp: timestamp)
                    album.addItem(newItem)
                    if album.unsoldItems.count == 1 {
                        self.albums[album.index] = album
                       // self.albums.append(album)
                    }
                    //self.pictures.append(newItem)
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
        print("number of pics is \(albums.count)")
        return albums.count
        //return pictures.count
    }
    
    
    
    
    //Specify what's in each cell
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Pictures", forIndexPath: indexPath)
        
        //Create label, which contains seller's name and timestamp
        let label = UILabel()
        label.numberOfLines = 2
        //let currAlbum = albums[indexPath.row]
        let sortedKeys = Array(albums.keys).sort(<)
        let currAlbum = albums[sortedKeys[indexPath.row]]
        print(currAlbum!.unsoldItems.count)
        let currPic = currAlbum!.unsoldItems[0]
        let attributedText = NSMutableAttributedString(string: currPic.getSeller(), attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(14)])
//        let attributedText = NSMutableAttributedString(string: pictures[indexPath.row].getSeller(), attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(14)])
        //let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        attributedText.appendAttributedString(NSAttributedString(string: "\n" + currPic.timestamp, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(12)]))
        label.backgroundColor = UIColor(red: 167/255, green: 255/255, blue: 164/255, alpha: 1)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.string.characters.count))
        label.attributedText = attributedText
        
        
        //Create textview, which contains the item name and price
        let textView = UITextView()
        textView.backgroundColor = UIColor(red: 244/255, green: 254/255, blue: 193/255, alpha: 1)
        textView.editable = false
        //textView.text = pictures[indexPath.row].getItemDescription() + "\n" + pictures[indexPath.row].getPrice()
        textView.text = currAlbum!.albumName + "\n" + currPic.getPrice()
        textView.font = UIFont.systemFontOfSize(14)
        
        
        //Create an imageview, which contains the picture of the 1st item in the album
        let imageView = UIImageView()
        imageView.image = currPic.getPicture()
        let newRect = imageView.image!.cropRect()
        if let imageRef = CGImageCreateWithImageInRect(imageView.image!.CGImage!, newRect) {
            imageView.image = UIImage(CGImage: imageRef)
        }
        
        
        //Get rid of old subviews so they don't get layeed on top of each other
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        //Add the views we just created to the cell
        cell.contentView.addSubview(label)
        cell.contentView.addSubview(textView)
        cell.contentView.addSubview(imageView)
        
        
        //Add constraints so the views look nice
        cell.addConstraintsWithFormat("H:|-4-[v0]|", views: label)
        cell.addConstraintsWithFormat("H:|-4-[v0]|", views: textView)
        cell.addConstraintsWithFormat("H:|[v0]|", views: imageView)
        cell.addConstraintsWithFormat("V:|[v0]-4-[v1]-4-[v2(300)]-4-|", views: label, textView, imageView)
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
        categorypics = pictures.filter { Item in
            let priceMatch = (scope == "All") || (Item.getPrice() == scope)
            if searchText == "" {
                return priceMatch
            }
            else {
                return priceMatch && Item.getItemName().lowercaseString.containsString(searchText.lowercaseString)
            }
        }
        
        collectionView!.reloadData()
    }
    
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        if segue.identifier == "Tomessaging" {
    //            print("true")
    //            let backButton = UIBarButtonItem()
    //            backButton.title = "Back"
    //            navigationItem.leftBarButtonItem = backButton
    //        }
    //    }
    
    
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
