//
//  ProfileViewController.swift
//  buy&sell
//
//  Created by cssummer16 on 6/15/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GameplayKit
import GameKit
import NVActivityIndicatorView


class ProfileViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    //MARK: OUTLETS AND VARIABLES
    
    @IBOutlet weak var unsoldImage1: UIImageView!
    @IBOutlet weak var unsoldImage2: UIImageView!
    @IBOutlet weak var unsoldImage3: UIImageView!
    @IBOutlet weak var soldImage1: UIImageView!
    @IBOutlet weak var soldImage2: UIImageView!
    @IBOutlet weak var soldImage3: UIImageView!
    @IBOutlet weak var purchased1: UIImageView!
    @IBOutlet weak var purchased2: UIImageView!
    @IBOutlet weak var purchased3: UIImageView!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star5: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var university: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var scrolling: UIScrollView!
    @IBOutlet weak var soldButton: UIButton!
    @IBOutlet weak var purchasedItemsButton: UIButton!
    @IBOutlet weak var logoutButtonStory: UIButton!
    @IBOutlet weak var editAlbums: UIBarButtonItem!
    @IBOutlet weak var editProfile: UIBarButtonItem!
    @IBOutlet weak var viewInsideScrollview: UIView!
    @IBOutlet weak var moreUnsold: UIButton!
    @IBOutlet weak var morePurchased: UIButton!
    @IBOutlet weak var moreSold: UIButton!
    
    
    
    
    
    
    
    var ref = FIRDatabase.database().reference() //create database reference
    let storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com") //create storage reference
    var uid: String?
    var profileDetails: FIRDatabaseHandle?
    var college: String?
    var unsoldItemsArray = [Item]()
    var soldItemsArray = [Item]()
    var purchasedItemsArray = [Item]()
    var itemsDict = [String: [Item]]()
    var viewsDict = [String: [UIImageView]]()
    var starsArray = [UIButton]()
    var segueLoc = ""
    var profilePicData = NSData()
    var moreButtonsDict = [String: UIButton]()
    var otherPersonsProfile = false
    var loadingCircle: NVActivityIndicatorView!
    var loadingBackground: UIView!
    var picsComing = 10 {
        didSet {
            print("pics coming: \(picsComing)")
            if picsComing == 0 {
                considerRemovingCircle()
            }
        }
    }
    var startPayingAttention = true
    var hasPic = false
    
    //MARK: SETUP FUNCTIONS
    
    
    func considerRemovingCircle() {
        print("considering removing")
        if startPayingAttention {
            print("gonna hide")
            // (possibly) remove circle
            let triggerTime = (Int64(NSEC_PER_SEC) * 1)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                print("hiding now")
                self.hideLoadingCircle()
            })
        }
    }
    
    
    override func viewDidLoad() {
        showLoadingCircle()
        super.viewDidLoad()
        moreUnsold.hidden = true
        moreSold.hidden = true
        morePurchased.hidden = true
        
        if uid == nil {
            let user = FIRAuth.auth()?.currentUser
            uid = user!.uid
            college = mainClass.domainBranch!
        }
        if let userID = FIRAuth.auth()?.currentUser?.uid {
            if uid! != userID { //Viewing someone else's profile
                hideExtraViews()
                
            } else { //viewing your own profile
                purchasedItemsButton.addTarget(self, action: #selector(purchase), forControlEvents: .TouchUpInside)
                logoutButtonStory.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
            }
        }
        
        
        getProfileInfo()
        
        
        self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2
        self.profilePic.clipsToBounds = true
        let imageViews = [unsoldImage1, unsoldImage2, unsoldImage3, soldImage1, soldImage2, soldImage3, purchased1, purchased2, purchased3]
        for view in imageViews {
            let newTapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(imageTapped))
            view.addGestureRecognizer(newTapGestureRecognizer)
        }
        
        itemsDict["unsold"] = unsoldItemsArray
        itemsDict["sold"] = soldItemsArray
        itemsDict["purchased"] = purchasedItemsArray
        
        viewsDict["unsold"] = [unsoldImage1, unsoldImage2, unsoldImage3]
        viewsDict["sold"] = [soldImage1, soldImage2, soldImage3]
        viewsDict["purchased"] = [purchased1, purchased2, purchased3]
        
        moreButtonsDict["unsold"] = moreUnsold
        moreButtonsDict["sold"] = moreSold
        moreButtonsDict["purchased"] = morePurchased
        
        starsArray = [star1, star2, star3, star4, star5]
        
    }
    
    
    
    
    func hideExtraViews() {
        picsComing -= 6
        otherPersonsProfile = true
        addButton.removeFromSuperview()
        soldButton.removeFromSuperview()
        soldImage1.removeFromSuperview()
        soldImage2.removeFromSuperview()
        soldImage3.removeFromSuperview()
        purchased1.removeFromSuperview()
        purchased2.removeFromSuperview()
        purchased3.removeFromSuperview()
        moreSold.removeFromSuperview()
        morePurchased.removeFromSuperview()
        purchasedItemsButton.removeFromSuperview()
        logoutButtonStory.removeFromSuperview()
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        view.translatesAutoresizingMaskIntoConstraints = true
        viewInsideScrollview.translatesAutoresizingMaskIntoConstraints = true
        let height = view.frame.height - self.navigationController!.navigationBar.frame.height - self.tabBarController!.tabBar.frame.height
        let width = view.frame.width
        scrolling.frame = CGRectMake(0, 0, width, height)
        viewInsideScrollview.frame = CGRectMake(0, 0, width, height)
        scrolling.contentSize = CGSizeMake(width, 1)
        
    }
    
    
    
    
    func showLoadingCircle() {
        let quarterWidth = self.view.frame.width/4
        loadingCircle = NVActivityIndicatorView(frame: CGRectMake(quarterWidth, quarterWidth * 2, quarterWidth * 2, quarterWidth * 2), type: .BallSpinFadeLoader, color: mainClass.ourGold)
        loadingBackground = UIView()
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
        loadingCircle.stopAnimation()
        loadingCircle.removeFromSuperview()
        loadingBackground.removeFromSuperview()
    }
    
    
    
    
    func buttonAction(sender: UIButton!) {
        let ac = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .Alert)
        let sign = { (action: UIAlertAction) -> Void in
            try! FIRAuth.auth()!.signOut()
            mainClass.loginTime = true
            self.performSegueWithIdentifier("tiana", sender: sender)
        }
        ac.addAction(UIAlertAction(title: "Okay", style: .Default, handler: sign))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        tabBarController?.tabBar.hidden = false
        navigationController?.navigationBarHidden = false
        super.viewWillAppear(animated)
        navigationController?.title = "Profile"
    }
    
    
    
    func purchase(sender: UIButton) {
        self.performSegueWithIdentifier("nala", sender: self)
    }
    
    
    
    
    
    //MARK: DISPLAY PROFILE INFO FUNCTIONS
    
    
    //Calls functions to get and display profile pics
    func getProfileInfo () {
        self.startPayingAttention = true
        getProfilePic()
        getNormalProfileInfo()
        getThree("unsold")
        if !otherPersonsProfile {
            getThree("sold")
            getThree("purchased")
        }
    }
    
    
    
    
    //Gets profile pic from database and displays it
    func getProfilePic() {
        if uid == mainClass.uid {
            //If you're viewing your own profile, get the pic from local storage
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            // Get the Document directory path
            let documentDirectorPath:String = paths[0]
            // Get the path for the images folder
            let imagesDirectoryPath = documentDirectorPath.stringByAppendingString("/ImagePicker/profilePic.png")
            if let profilePicData = NSFileManager.defaultManager().contentsAtPath(imagesDirectoryPath) {
                self.profilePicData = profilePicData
                let image = UIImage(data: profilePicData)
                self.profilePic.image = image!
                self.hasPic = true
            }
        }
        //Get pic from storage
        let imageRef = storageRef.child("\(self.college!)/user/\(uid!)/ProfilePic")
        imageRef.downloadURLWithCompletion { (URL, error) -> Void in
            
            if error != nil {
                self.profilePic.image = UIImage(named: "ic_profile")
                self.hasPic = false
                self.picsComing -= 1
            }
            else {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
                    if let data = NSData(contentsOfURL: URL!) {
                        if self != nil {
                            if !self!.profilePicData.isEqual(data) {
                                self!.savePicInLocalStorage(data)
                            }
                            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                                if self != nil {
                                    self!.profilePic.image = UIImage(data: data)
                                    self!.hasPic = true
                                    self!.picsComing -= 1
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    func savePicInLocalStorage(data: NSData) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        let imagesDirectoryPath = documentDirectorPath.stringByAppendingString("/ImagePicker")
        var objcBool:ObjCBool = true
        let isExist = NSFileManager.defaultManager().fileExistsAtPath(imagesDirectoryPath, isDirectory: &objcBool)
        // If the folder with the given path doesn't exist already, create it
        if isExist == false{
            do{
                try NSFileManager.defaultManager().createDirectoryAtPath(imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                //do nothing
            }
        }
        let imagePath = imagesDirectoryPath.stringByAppendingString("/profilePic.png")
        NSFileManager.defaultManager().createFileAtPath(imagePath, contents: data, attributes: nil)
    }
    
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    
    
    
    
    //Gets personal info from the database - name, college, etc.
    func getNormalProfileInfo() {
        //Get general profile info from database
        let dataRef = ref.child("\(self.college!)/user/\(uid!)/profile")
        dataRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            
            let data = snapshot.value as? [String : AnyObject]
            if let colName = mainClass.emailGetter.getNameFromDomain(self.college!) {
                self.university.text = colName
            }
            self.name.text = data?["name"] as? String
            if let rating = data?["rating"] as? Double {
                self.getRating(rating)
                self.showStars(false)
            } else {
                self.showStars(true) //If you don't have a rating, hide the stars
            }
        })
    }
    
    
    
    func showStars(show: Bool) {
        for star in self.starsArray {
            star.hidden = show
        }
    }
    
    
    
    func getRating(rating: Double) {
        for i in (0..<5) {
            let index = Double(i + 1)
            let star = starsArray[i]
            if rating + 1 <= index {
                //empty
                star.setImage(UIImage(named: "rating"), forState: .Normal)
            } else {
                if rating > index {
                    //filled
                    star.setImage(UIImage(named: "Filled Star"), forState: .Normal)
                } else {
                    let none =  abs(index - rating - 1)
                    let quarter = abs(index - rating - 0.75)
                    let half = abs(index - rating - 0.5)
                    let threeQuarters = abs(index - rating - 0.25)
                    let full = abs(index - rating)
                    let diffArray = [none, quarter, half, threeQuarters, full]
                    let minIndex = diffArray.indexOf(diffArray.minElement()!)
                    if minIndex == 0 {
                        star.setImage(UIImage(named: "rating"), forState: .Normal)
                    }
                    if minIndex == 1 {
                        star.setImage(UIImage(named: "Quarter Star"), forState: .Normal)
                    }
                    if minIndex == 2 {
                        star.setImage(UIImage(named: "Half Star"), forState: .Normal)
                    }
                    if minIndex == 3 {
                        star.setImage(UIImage(named: "Three Quarters Star"), forState: .Normal)
                    }
                    if minIndex == 4 {
                        star.setImage(UIImage(named: "Filled Star"), forState: .Normal)
                    }
                }
            }
        }
    }
    
    
    //MARK: FIREBASE FUNCTIONS
    
    func getThree(category: String){
        
        
        //Get unsold items from the database and storage
        let dataRef = ref.child("\(self.college!)/user/\(uid!)/\(category)Items")
        dataRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            print("PAY ATTENTION!  We just observed an event \(dataRef)")
            
            if let allItems = snapshot.value as? [String : AnyObject] {
                var imageIDArray = Array(allItems.keys) //String array of item IDs
                
                self.setButton(category, count: imageIDArray.count)
                
                
                //loop through current items, see if they're still there
                //Record the indices of any pic that's missing OR not enough pics
                var imageSlotsToFill = [Int]()
                
                var itemsList = self.itemsDict[category]!
                for (index, item) in itemsList.enumerate().reverse() {
                    if !imageIDArray.contains(item.imageKey) { //If you're currently displaying a deleted item
                        imageSlotsToFill.append(index) //Re-fill this index
                    } else {
                        imageIDArray.removeAtIndex(imageIDArray.indexOf(item.imageKey)!) //Remove the item so it doesn't get displayed twice
                    }
                }
                
                
                
                if itemsList.count < 3 {
                    //If you have blank spaces just because you don't have enough pics, fill them now.
                    for index in itemsList.count..<3 {
                        imageSlotsToFill.append(index)
                    }
                }
                
                
                let picsMissing = 3 - imageSlotsToFill.count
                self.picsComing -= picsMissing
                
                
                let shuffledArray = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(imageIDArray) //Randomize array
                
                
                
                
                var counter = 0
                
                //Loop through the slots you want to fill with images.
                //Slot refers to which imageView should be filled.
                for (index, slot) in imageSlotsToFill.enumerate() {
                    if index < shuffledArray.count {
                        let id = shuffledArray[index]
                        let itemInfo = allItems[id as! String] as! [String: AnyObject]
                        let albumKey = itemInfo["albumKey"] as! String
                        let description = itemInfo["description"] as! String
                        let name = itemInfo["name"] as! String
                        let price = itemInfo["price"] as! Double
                        let tag = itemInfo["tag"] as! String
                        let newItem = Item(itemDescription: description, tag: tag, itemName: name, price: price, timestamp: 0)
                        newItem.imageKey = id as! String
                        if let location = itemInfo["location"] as? String {
                            newItem.location = location
                        }
                        if let long = itemInfo["locationLong"] as? Double {
                            newItem.long = long
                        }
                        if let lat = itemInfo["locationLat"] as? Double {
                            newItem.lat = lat
                        }
                        if category != "purchased" {
                            newItem.sellerCollege = self.college
                            newItem.uid = self.uid
                        } else {
                            newItem.sellerCollege = itemInfo["sellerCollege"] as? String
                            newItem.uid = itemInfo["sellerId"] as? String
                        }
                        newItem.albumKey = albumKey
                        newItem.seller = mainClass.displayName!
                        
                        //If not enough, add it
                        //If already there, set it
                        if itemsList.count < slot + 1 {
                            itemsList.append(newItem)
                        } else {
                            itemsList[slot] = newItem
                        }
                        let imageViews = self.viewsDict[category]!
                        self.getActualImage(0, i: slot, item: newItem, imageView: imageViews[slot])
                        
                        counter += 1
                    } else {
                        let currImageView = self.viewsDict[category]![slot]
                        currImageView.image = nil
                    }
                }
                self.itemsDict[category]! = itemsList
            }
            self.startPayingAttention = true
        })
    }
    
    
    
    

    
    
    
    func setButton(category: String, count: Int) {
        let button = moreButtonsDict[category]!
        if count < 4 {
            button.hidden = true
        } else {
            button.setTitle("\(count - 3) more", forState: .Normal)
            button.hidden = false
        }
    }
    
    
    
    
    
    func getActualImage(repetitions: Int, i: Int, item: Item, imageView: UIImageView) {
        let imageRef = storageRef.child("\(item.sellerCollege!)/user/\(item.uid!)/images/\(item.imageKey)") //Path to the image in storage
        imageRef.downloadURLWithCompletion{ (URL, error) -> Void in  //Download the image
            
            if (error != nil) {
                let triggerTime = (Int64(NSEC_PER_SEC) * 1)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                    
                    if (repetitions <= 3) {
                        self.getActualImage(repetitions + 1, i: i, item: item, imageView: imageView)
                    }
                    else {
                        imageView.image = mainClass.defaultPic(item.tag) //TODO: Crash here
                        imageView.tag = i
                        self.picsComing -= 1
                    }
                })
            } else {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
                    if let picData = NSData(contentsOfURL: URL!) { //The pic!!!
                        let image = UIImage(data: picData)!
                        dispatch_async(dispatch_get_main_queue()) { [weak self] in
                            imageView.image = image
                            imageView.tag = i
                            self!.picsComing -= 1
                        }
                    }
                }
                
            }
        }
    }
    
    
    @IBAction func pressedMoreUnsold(sender: AnyObject) {
        performSegueWithIdentifier("cinderella", sender: nil)
    }
    
    
    @IBAction func pressedMoreSold(sender: AnyObject) {
        performSegueWithIdentifier("zazu", sender: nil)
    }
    
    
    @IBAction func pressedMorePurchased(sender: AnyObject) {
        performSegueWithIdentifier("nala", sender: nil)
    }
    
    
    
    
    
    
    
    
    //MARK: NAVIGATION AND SEGUES
    
    
    func imageTapped(gestureRec: UITapGestureRecognizer) {
        let imgView = gestureRec.view as! UIImageView
        if imgView.image != nil {
            performSegueWithIdentifier("hannahMontana", sender: imgView)
        }
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "cinderella" { //Called when the user clicks on the "Unsold Items" button
            if let destination = segue.destinationViewController as? ViewItems {
                destination.college = college!
                destination.uid = uid!
            }
        }
        
        if segue.identifier == "anna" { //Editing profile
            let backItem = UIBarButtonItem()
            backItem.title = "Cancel"
            navigationItem.backBarButtonItem = backItem //Add a back button
            
            let destination = segue.destinationViewController as! EditProfile
            destination.profilePic = profilePic.image
            destination.hasPic = hasPic
        }
        
        if segue.identifier == "tarzan" { //Called when user clicks "Edit Albums" icon
            if let destination = segue.destinationViewController as? ViewAlbum {
                destination.segueLoc = "profile"
                destination.college = college!
            }
        }
        
        if segue.identifier == "hannahMontana" { //Go to close up after selecting image
            let pic = sender as! UIImageView
            let identity = pic.accessibilityIdentifier
            let closeUp = segue.destinationViewController as! CloseUp
            closeUp.pic = pic.image!
            let item = itemsDict[identity!]![pic.tag]
            closeUp.sellerCollege = item.sellerCollege
            closeUp.imageID = item.imageKey
            closeUp.name = item.itemName
            closeUp.🔥 = String(item.price)
            closeUp.descript = item.itemDescription
            closeUp.seller = item.seller
            closeUp.albumID = item.albumKey
            closeUp.sellerUID = item.uid
            closeUp.category = identity!
            if item.long != nil {
                closeUp.long = item.long!
                closeUp.lat = item.lat!
            }
            if item.location != nil {
                closeUp.location = item.location
            }
        }
    }
    
}



    