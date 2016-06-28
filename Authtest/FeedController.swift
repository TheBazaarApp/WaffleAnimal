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
//    var pictures = [Item]()
    var categorypics = [Item]()
    var category = "All"

    var pictures = [Item(itemDescription: "Bike in good condition!", tags: "Transportation", itemName: "Bike", price: "$25", picture: UIImage(named: "bike")!, seller: "Preethi Seshadri"),
                Item(itemDescription: "Old iPhone 4", tags: "Electronics", itemName: "iPhone 4", price: "$20", picture: UIImage(named: "iPhone")!, seller: "Matthew Guillory"),
                Item(itemDescription: "Nice dorm Fridge!", tags: "Appliances", itemName: "Fridge", price: "$30", picture: UIImage(named: "fridge")!, seller: "Colleen Lewis")]
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        print("Feed did load")
        super.viewDidLoad()
//        self.hideKeyboardWhenTappedAround()
        
        let prices = ["All", "Free", "< $10", "< $25", "< $50"]
        searchController.searchBar.delegate = self
        searchController.searchBar.scopeButtonTitles = prices
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.collectionView?.addSubview(searchController.searchBar)
        

        navigationItem.title = "BubbleU Feed"
        
        
        
        
        
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        // Do any additional setup after loading the view, typically from a nib.

        
        collectionView?.alwaysBounceVertical = true
        
        
        if self.revealViewController() != nil {
            //print(true)
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        categorypics = pictures.filter { Item in
            if category == "All" {
                return true
            }
            else {
                if Item.getTags() == category {
                    return true
                }
                else {
                    return false
                }
            }
        }

    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categorypics.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
            print(indexPath.row)
        
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Pictures", forIndexPath: indexPath)
            
            let label = UILabel()
            label.numberOfLines = 2
            let attributedText = NSMutableAttributedString(string: categorypics[indexPath.row].getSeller(), attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(14)])
            let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
            
            attributedText.appendAttributedString(NSAttributedString(string: "\n" + timestamp, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(12)]))
        
            label.backgroundColor = UIColor(red: 167/255, green: 255/255, blue: 164/255, alpha: 1)
        
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            
            attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.string.characters.count))
            
            let attachment = NSTextAttachment()
            //attachment.image = UIImage(named: "globe_small")
            attachment.bounds = CGRectMake(0, -2, 12, 12)
            attributedText.appendAttributedString(NSAttributedString(attachment: attachment))
            
            label.attributedText = attributedText
            label.tag = 1
            
            let textView = UITextView()
            textView.tag = 2
            textView.backgroundColor = UIColor(red: 244/255, green: 254/255, blue: 193/255, alpha: 1)
            textView.editable = false
            //textView.scrollEnabled = false
            textView.text = categorypics[indexPath.row].getItemDescription() + "\n" + categorypics[indexPath.row].getPrice()
            textView.font = UIFont.systemFontOfSize(14)
    
            let imageView = UIImageView()
            imageView.image = categorypics[indexPath.row].getPicture()
            let newRect = imageView.image!.cropRect()
            if let imageRef = CGImageCreateWithImageInRect(imageView.image!.CGImage!, newRect) {
            imageView.image = UIImage(CGImage: imageRef)
            imageView.tag = 3

            // Use this new Image
        }
        for subview in cell.contentView.subviews {
            print("removed subview")
            subview.removeFromSuperview()
        }
            cell.contentView.addSubview(label)
            cell.contentView.addSubview(textView)
            cell.contentView.addSubview(imageView)
        
            cell.addConstraintsWithFormat("H:|-4-[v0]-4-|", views: label)
            cell.addConstraintsWithFormat("H:|-4-[v0]|", views: textView)
            cell.addConstraintsWithFormat("H:|[v0]|", views: imageView)
            cell.addConstraintsWithFormat("V:|[v0]-4-[v1]-4-[v2(300)]-4-|", views: label, textView, imageView)
            return cell
        
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        print(view.frame.width)
        return CGSizeMake(view.frame.width, 390)

    }
    
    @IBAction func didPressAddItem(sender: AnyObject) {
        print("segue")
        performSegueWithIdentifier("addItem", sender: sender)
    }
    
    
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

extension FeedController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension FeedController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

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
        
        var lowX = width
        var lowY = height
        var highX: CGFloat = 0
        var highY: CGFloat = 0
        
        //Filter through data and look for non-transparent pixels.
        for (var y: CGFloat = 0 ; y < height ; y++) {
            for (var x: CGFloat = 0; x < width ; x++) {
                let pixelIndex = (width * y + x) * 4 /* 4 for A, R, G, B */
                
                if data[Int(pixelIndex)] != 0 { //Alpha value is not zero pixel is not transparent.
                    if (x < lowX) {
                        lowX = x
                    }
                    if (x > highX) {
                        highX = x
                    }
                    if (y < lowY) {
                        lowY = y
                    }
                    if (y > highY) {
                        highY = y
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
