//
//  AddNewItem.swift
//  buy&sell
//
//  Created by cssummer16 on 6/13/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.
//

import UIKit
import Firebase
import Photos

class AddNewItem: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
    
    //MARK: OUTLETS AND VARIABLES
    
    //Outlets from text fields on the screen
    @IBOutlet weak var albumName: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationDetails: UILabel!
    @IBOutlet weak var tagAllField: UITextField!
    @IBOutlet weak var cancel: UIImageView!
    @IBOutlet weak var locationPin: UIImageView!
    @IBOutlet weak var add: UIImageView!
    
    
    
    
    //Probs w. pics
    
    
    var uid: String?
    let storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com") //Create storage reference
    var ref = FIRDatabase.database().reference() //Root of the realtime database
    var items = [Item]()
    let college = mainClass.domainBranch!
    var userName: String?
    var lat: Double?
    var long: Double?
    var location: String?
    var locDefault: String?
    var latDefault: Double?
    var longDefault: Double?
    var album: String?
    var albumID: String?
    var key: String!
    var segueLoc: String?
    var imageKey: String?
    var tagAll = true
    var categoriesArray = ["None", "Fashion", "Electronics", "Appliances", "Transportation", "Furniture", "School Supplies", "Services", "In Search Of", "Other"]
    var picker = UIPickerView()
    var childUpdates = [String : AnyObject]()
    let user = FIRAuth.auth()?.currentUser
    var buyListener: FIRDatabaseHandle?
    var currentlySaving = false
    var cancelButton: UITapGestureRecognizer?
    var addButton: UITapGestureRecognizer?
    var firstFailure = true
    var addingNewItem = true
    var imagePickingIndex = 0
    var showedISOPopupAlready = false
    
    
    
    //MARK: SETUP FUNCTIONS
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        howToPopup()
        let tagAllBox = NSAttributedString(string: "Tag All", attributes:[NSForegroundColorAttributeName:UIColor.whiteColor()])
        tagAllField.attributedPlaceholder = tagAllBox
        tagAllField.layer.borderColor = UIColor.whiteColor().CGColor
        tagAllField.layer.borderWidth = 3
        tagAllField.layer.cornerRadius = 11
        self.tagAllField.clipsToBounds = true
        self.automaticallyAdjustsScrollViewInsets = false
        let user = FIRAuth.auth()?.currentUser
        uid = user!.uid
        userName = user?.displayName
        picker.delegate = self
        picker.dataSource = self
        tagAllField.inputView = picker
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        if segueLoc == "EditAlbums" {
            editAlbum()
            listenForBuyer()
        }
        
        getDefault()
        cancelButton = UITapGestureRecognizer(target:self, action: #selector(cancelTapped))
        cancel.addGestureRecognizer(cancelButton!)
        let locationButton = UITapGestureRecognizer(target:self, action: #selector(locationTapped))
        locationPin.addGestureRecognizer(locationButton)
        addButton = UITapGestureRecognizer(target:self, action: #selector(addTapped))
        add.addGestureRecognizer(addButton!)
        albumName.delegate = self
        collectionView.keyboardDismissMode = .Interactive
    }
    
    func howToPopup() {
        hideablePopup("Adding Items", message: "Add multiple items to your album by tapping the '+' button.", defaultsKey: "AddNewItemHowTo")
    }
    
    
    func isoPopup() {
        if !showedISOPopupAlready {
            hideablePopup("ISO Album", message: "If you include ISOs in your album, all items in the album must be ISOs.", defaultsKey: "ISOHowTo")
            showedISOPopupAlready = true
        }
    }
    
    
    func hideablePopup(title: String, message: String, defaultsKey: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let hidePopup = defaults.boolForKey(defaultsKey)
        if !hidePopup {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Don't Show This Again", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
                defaults.setBool(true, forKey: defaultsKey)
            }))
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    override func viewDidDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = true
    }
    
    
    
    func locationTapped() {
        self.performSegueWithIdentifier("Aurora", sender: self)
    }
    
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.accessibilityIdentifier == "albumName" {
            let maxLength = 40
            let currentString: NSString = albumName.text!
            let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: string)
            return newString.length <= maxLength
        }
        return true
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = self.collectionView.frame.width
        let height: CGFloat = 280.0
        return CGSizeMake(width, height)
    }
    
    //MARK: PICKERVIEW FUNCTIONS
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoriesArray.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 { //If you just selected "none"
            tagAllField.text = ""
        } else {
            tagAllField.text = categoriesArray[row]
            for item in items {
                item.tag = tagAllField.text!
            }
            for cell in collectionView.visibleCells() {
                let collectionViewCell = cell as! CollectionViewCell
                collectionViewCell.tagField.text = collectionViewCell.item!.tag
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoriesArray[row]
    }
    
    
    
    
    //MARK: FIREBASE FUNCTIONS
    
    
    func getDefault(){
        if let user = FIRAuth.auth()?.currentUser {
            let dataRef = ref.child("\(self.college)/user/\(user.uid)/profile")
            dataRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                let data = snapshot.value as? [String : AnyObject]
                if let locText = data?["defaultLocation"] as? String {
                    self.locDefault = locText
                }
                if let latText = data?["defaultLatitude"] as? Double {
                    self.latDefault = latText
                }
                if let longText = data?["defaultLongitude"] as? Double {
                    self.longDefault = longText
                }
            })
        }
    }
    
    
    func listenForBuyer() {
        if let user = user {
            let buyRef = ref.child("\(self.college)/user/\(user.uid)/albums/\(albumID!)/unsoldItems")
            buyListener = buyRef.observeEventType(.ChildRemoved, withBlock: { (snapshot) in
                if !self.currentlySaving {
                    let itemInfo = snapshot.value as! [String : AnyObject]
                    let itemName = itemInfo["name"]
                    mainClass.simpleAlert("Someone has bought one of your items", message: "Someone bought your \(itemName!)! This item will not be edited", viewController: self)
                    for (index, item) in self.items.enumerate().reverse() {
                        if item.imageKey == snapshot.key {
                            self.items.removeAtIndex(index)
                            self.collectionView.reloadData()
                        }
                    }
                }
            })
        }
    }
    
    
    
    func editAlbum() {
        if let user = user {
            let dataRef = ref.child("\(self.college)/user/\(user.uid)/albums/\(albumID!)")
            dataRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                let data = snapshot.value as? [String : AnyObject]
                let albumDetails = data?["albumDetails"]
                self.albumName.text = albumDetails?["albumName"] as? String
                if let labelText = albumDetails?["location"] as? String {
                    self.location = labelText
                    self.locationDetails.text = labelText
                    
                }
                let timestamp = albumDetails!["timestamp"] as! Double
                if let latText = albumDetails?["locationLat"] as? Double {
                    self.lat = latText
                }
                if let longText = albumDetails?["locationLong"] as? Double {
                    self.long = longText
                }
                let unsoldItems = data?["unsoldItems"] as! [String : AnyObject]
                for (imageKey,item) in unsoldItems {
                    let descriptionText = item["description"] as! String?
                    let name = item["name"] as! String?
                    let price = item["price"] as! Double?
                    let tag = item["tag"] as! String?
                    let newItem = Item(itemDescription: descriptionText!, tag: tag!, itemName: name!, price: price!, timestamp: timestamp)
                    newItem.imageKey = imageKey
                    if tag == "In Search Of" {
                        if (item["hasPic"] as? Bool) != nil {
                            newItem.hasPic = false
                        }
                    }
                    self.items.append(newItem)
                    if newItem.hasPic {
                        self.getImage(newItem, imageID: imageKey)
                    } else {
                        newItem.picture = UIImage(named: "Add Image")
                    }
                    self.collectionView.reloadData()
                }
                if self.tagAll == true {
                    self.tagAllField.text = self.items[self.items.count-1].tag
                }
            })
        }
    }
    
    
    
    
    
    func getImage(item: Item, imageID: String) {
        if let user = user {
            let imageRef = storageRef.child("\(self.college)/user/\(user.uid)/images/\(imageID)")
            imageRef.downloadURLWithCompletion{ (URL, error) -> Void in
                if (error != nil) {
                    item.picture = mainClass.defaultPic(item.tag)
                } else {
                    if let data = NSData(contentsOfURL: URL!) {
                        item.picture = UIImage(data: data)
                        
                        if self.items.count != 1  && self.items[self.items.count-2].tag != item.tag {
                            self.tagAll = false
                        }
                        self.collectionView.reloadData()
                    }
                }
            }
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    //Save a new album into the database; called when you click the save button
    func addNewAlbum() {
        if !currentlySaving {
            currentlySaving = true
            let timestamp = NSDate().timeIntervalSince1970 * -1
            
            //If there are no items in the album, show an alert popup.
            if collectionView.visibleCells().count == 0 {
                currentlySaving = false
                mainClass.simpleAlert("Missing Name", message: "You can't save an album without any items!", viewController: self)
            } else {
                
                
                //Check whether there are unnamed items or items without prices; (*** Maybe later we should also require tag as well)
                var hasISO = false
                var hasNonISO = false
                
                for item in items {
                    if (item.itemName == "") {
                        mainClass.simpleAlert("Missing Name", message: "All of the items need names.", viewController: self)
                        currentlySaving = false
                        return
                    }
                    if (item.price == -0.1134 && item.tag != "In Search Of") {
                        mainClass.simpleAlert("Missing Price", message: "All items except ISOs need prices.", viewController: self)
                        currentlySaving = false
                        return
                    }
                    if (item.itemDescription == "" && item.tag == "In Search Of") {
                        mainClass.simpleAlert("Missing Description", message: "All ISOs require descriptions", viewController: self)
                        currentlySaving = false
                        return
                    }
                    if (!item.hasPic && item.tag != "In Search Of") {
                        mainClass.simpleAlert("Missing Image", message: "All items (except ISOs) require images.", viewController: self)
                        currentlySaving = false
                        return
                    }
                    if ( (hasISO && item.tag != "In Search Of") || (hasNonISO && item.tag == "In Search Of") ) {
                        mainClass.simpleAlert("Can't Mix ISOs and Other Items", message: "Either all of your items must have the 'In Search Of' tag or none of them can have it.", viewController: self)
                        currentlySaving = false
                        return
                    }
                    if item.tag == "In Search Of" {
                        hasISO = true
                    } else {
                        hasNonISO = true
                    }
                }
                
                if albumName.text == "" {
                    mainClass.simpleAlert("Missing Album Name", message: "", viewController: self)
                    currentlySaving = false
                    return
                }
                
                
                //If an item or the album are missing a name, show an alert popup.
                if segueLoc == "EditAlbums" {
                    key = albumID!
                }
                else {
                    
                    //If there are no problems, save the items
                    key = ref.child("\(college)/user/\(uid!)/albums").childByAutoId().key //Generate a unique album ID (***Later, change this to the path which is directly under college (not under user))
                }
                for item in items {
                    if segueLoc == "EditAlbums"  && item.imageKey != "" {
                        imageKey = item.imageKey
                    }
                    else {
                        imageKey = ref.child("\(college)/user/\(uid!)/unsoldItems").childByAutoId().key //Generate a unique album ID
                    }
                    
                    if item.hasPic {
                        let image = item.picture
                        let imageRef = self.storageRef.child("\(college)/user/\(self.uid!)/images/\(imageKey!)")
                        let imageData: NSData = UIImagePNGRepresentation((image)!)!
                        imageRef.putData(imageData, metadata: nil) { metadata, error in
                            if let top = UIApplication.topViewController() {
                                if error != nil {
                                    mainClass.simpleAlert("Error Saving Album Pictures", message: "You can add the correct pictures by editing your album.", viewController: top)
                                }
                            }
                        }
                    }
                    
                    
                    //Store item details in the database in two different places (by album, and just by image) (*** Maybe one more place as well)
                    let name = item.itemName //as NSString
                    let description = item.itemDescription //as NSString
                    let price = item.price //as NSString
                    
                    let nameOfAlbum = albumName.text!
                    
                    
                    var detailsUnderItems = [String: AnyObject]()
                    var detailsUnderAlbums = [String: AnyObject]()
                    
                    if uid != nil {
                        
                        detailsUnderAlbums = ["price": price,
                                              "description": description,
                                              "tag": item.tag,
                                              "name": name]
                        
                        
                        detailsUnderItems = ["price": price,
                                             "description": description,
                                             "tag": item.tag,
                                             "sellerId": uid! as NSString,
                                             "sellerName": userName!,
                                             "timestamp": timestamp,
                                             "name": name,
                                             "albumName": nameOfAlbum,
                                             "albumKey": key]
                        
                        
                        if item.tag == "In Search Of" && !item.hasPic {
                            detailsUnderItems["hasPic"] = false
                            detailsUnderAlbums["hasPic"] = false
                        }
                        
                        detailsUnderItems["locationLat"] = lat ?? NSNull()
                        detailsUnderItems["locationLong"] = long ?? NSNull()
                        detailsUnderItems["location"] = location ?? NSNull()
                    }
                    
                    childUpdates["\(college)/user/\(uid!)/albums/\(key)/unsoldItems/\(imageKey!)"] = detailsUnderAlbums
                    childUpdates["\(college)/albums/\(key)/unsoldItems/\(imageKey!)"] = detailsUnderAlbums
                    childUpdates["\(college)/user/\(uid!)/unsoldItems/\(imageKey!)"] = detailsUnderItems
                    
                }
                
                
                
                //Store the album details
                
                
                
                var albumDetailsUnderUser = ["albumName": self.albumName.text!,
                                             "timestamp": timestamp] as [String : AnyObject]
                
                var albumDetailsUnderCollege = ["albumName": self.albumName.text!,
                                                "sellerID": uid! as NSString,
                                                "sellerName": userName!,
                                                "timestamp": timestamp] as [String: AnyObject]
                
                albumDetailsUnderUser["locationLat"] = lat ?? NSNull()
                albumDetailsUnderUser["locationLong"] = long ?? NSNull()
                albumDetailsUnderUser["location"] = location ?? NSNull()
                albumDetailsUnderCollege["locationLat"] = lat ?? NSNull()
                albumDetailsUnderCollege["locationLong"] = long ?? NSNull()
                albumDetailsUnderCollege["location"] = location ?? NSNull()
                
                
                
                childUpdates["\(college)/user/\(uid!)/albums/\(key)/albumDetails"] = albumDetailsUnderUser
                childUpdates["\(college)/albums/\(key)/albumDetails"] = albumDetailsUnderCollege
                
                ref.updateChildValues(childUpdates as [NSObject : AnyObject])
                
                //Go back to the profile
                self.navigationController?.popViewControllerAnimated(true)
                
            }
        }
    }
    
    
    
    func deleteOldItems(){ //Possibly put this in the last function? Make sure it's called before addAlbum
        //Get all of the user's unsold items in this album
        let pathToAlbum = ref.child("\(college)/user/\(uid!)/albums/\(albumID!)/unsoldItems")
        pathToAlbum.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            let itemsDict = snapshot.value as! [String : AnyObject]
            var unsoldItemIDs = Array(itemsDict.keys)
            
            for (index, itemID) in unsoldItemIDs.enumerate().reverse() { //Loop through items in the database; delete any that are still here
                for item in self.items {
                    if item.imageKey == itemID { //If we have an image key match
                        unsoldItemIDs.removeAtIndex(index)
                        break
                    }
                }
                
            }
            
            //All items left in the list are items in the database which have been deleted (theoretically).  Let's get rid of them.
            
            for deletedItem in unsoldItemIDs {
                self.deleteItem(deletedItem)
                self.deleteImage(deletedItem)
            }
            
            self.addNewAlbum()
            
        })
    }
    
    
    
    
    func deleteItem(imageID: String) {
        let pathToUserUnsoldItems = "/\(self.college)/user/\(self.uid!)/unsoldItems/\(imageID)"
        let pathToUserAlbums = "/\(self.college)/user/\(self.uid!)/albums/\(albumID!)/unsoldItems/\(imageID)"
        let pathToCollegeAlbums = "/\(self.college)/albums/\(albumID!)/unsoldItems/\(imageID)"
        
        childUpdates[pathToUserUnsoldItems] = NSNull()
        childUpdates[pathToUserAlbums] = NSNull()
        childUpdates[pathToCollegeAlbums] = NSNull()
        
        
    }
    
    
    
    func deleteImage(imageID: String) {
        let imagePath = self.storageRef.child("\(self.college)/user/\(self.uid!)/images/\(imageID)")
        imagePath.deleteWithCompletion { (error) -> Void in }
    }
    
    
    
    
    
    
    
    
    
    //MARK: IMAGE PICKER FUNCTIONS
    
    func addTapped() {
        addingNewItem = true
        showPicOptions(nil)
    }
    
    
    
    func showPicOptions (imageButton: UIButton?) {
        let optionsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        optionsMenu.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
            self.openImagePicker(false)
        }))
        optionsMenu.addAction(UIAlertAction(title: "Take Photo", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
            self.openImagePicker(true)
        }))
        if addingNewItem {
            optionsMenu.addAction(UIAlertAction(title: "Add Item Without Image", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
                if self.addingNewItem {
                    self.createNewItem(nil)
                }
            }))
        }
        if let imageButton = imageButton {
            if self.items[self.imagePickingIndex].hasPic {
                optionsMenu.addAction(UIAlertAction(title: "Delete Photo", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
                    imageButton.setImage(UIImage(named: "Add Image"), forState: .Normal)
                    self.items[self.imagePickingIndex].hasPic = false
                }))
            }
        }
        optionsMenu.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler:  nil))
        presentViewController(optionsMenu, animated: true, completion: nil)
    }
    
    
    
    
    func openImagePicker(camera: Bool) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true //Allow people to crop images
        if camera {
            picker.sourceType = .Camera
            picker.cameraDevice = .Rear
        }
        presentViewController(picker, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    //When the user pushes cancel on the image Picker, just close it.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    //When the user has picked an image, add it to a new item and display it
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var newImage: UIImage
        
        if let possibleImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        if addingNewItem {
            createNewItem(newImage)
        } else {
            items[imagePickingIndex].picture = newImage
            items[imagePickingIndex].hasPic = true
            collectionView.reloadData()
        }
        
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func createNewItem(image: UIImage?) {
        let item = Item()
        if let image = image {
            item.picture = image
        } else {
            item.hasPic = false
            item.picture = UIImage(named: "Add Image")
        }
        item.tag = tagAllField.text!
        
        items.append(item)
        collectionView.reloadData()
        let newItem = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
        let lastItemIndex = NSIndexPath(forItem: newItem, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(lastItemIndex, atScrollPosition: .Top, animated: false)
    }
    
    
    
    
    
    
    
    
    
    //MARKK: COLLECTION VIEW FUNCTIONS
    
    
    //Returns the number of items that should show up in the collection view
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    
    
    //Puts the right item in each cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Image", forIndexPath: indexPath) as! CollectionViewCell
        cell.initializeListeners() // (*** Ideally, these should go in the init() function of CollectionViewCell, but it keeps giving an error :(
        cell.addNewItemClass = self
        let deleteButton = UITapGestureRecognizer(target:self, action: #selector(deleteTapped(_:)))
        cell.deleteButton.addGestureRecognizer(deleteButton)
        cell.deleteButton.tag = indexPath.row
        
        let imageTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        cell.itemImage.addGestureRecognizer(imageTapRecognizer)
        cell.itemImage.tag = indexPath.row
        
        let item = items[indexPath.item]
        cell.item = item //Add item to cell
        cell.tag = indexPath.row
        //Add border and curved edges to the cell
        cell.itemImage.layer.cornerRadius = 5
        cell.itemImage.clipsToBounds = true
        
        
        //Fill cell with info
        if let pic = item.picture {
            cell.itemImage.setImage(pic, forState: .Normal)
        }
        cell.itemName.text = item.itemName
        cell.tagField.text = item.tag
        if item.price ==  -0.1134 {
            cell.itemPrice.text = ""
        } else {
            cell.itemPrice.text = String(item.price)
        }
        
        cell.itemDescription.text = item.itemDescription
        cell.itemDescription.layer.cornerRadius = 5
        cell.layer.cornerRadius = cell.frame.size.width/50
        cell.clipsToBounds = true
        
        return cell
    }
    
    
    
    
    
    
    func imageTapped(gestureRec: UITapGestureRecognizer) {
        addingNewItem = false
        let imageView = gestureRec.view as! UIButton
        imagePickingIndex = imageView.tag
        showPicOptions(imageView)
    }
    
    
    
    func deleteTapped(gestureRec: UITapGestureRecognizer) {
        let delete = gestureRec.view as! UIImageView
        let i = delete.tag
        items.removeAtIndex(i)
        collectionView.reloadData()
    }
    
    
    
    
    
    
    override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    
    
    
    
    //MARK: NAVIGATION FUNCTIONS
    
    
    
    
    
    func cancelTapped() {
        cancel.removeGestureRecognizer(cancelButton!)
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func saveTapped(sender: UIButton) {
        if let nameOfAlbum = albumName.text {
            if let alert = nameOfAlbum.removeBadWords() {
                self.presentViewController(alert, animated: true, completion: nil)
                currentlySaving = false
                return
            }
        }
        for cell in self.collectionView.visibleCells() {
            let itemCell = cell as! CollectionViewCell
            if let name = itemCell.itemName.text {
                if let alert = name.removeBadWords() {
                    self.presentViewController(alert, animated: true, completion: nil)
                    currentlySaving = false
                    return
                }
            }
            if let description = itemCell.itemDescription.text {
                if let alert = description.removeBadWords() {
                    self.presentViewController(alert, animated: true, completion: nil)
                    currentlySaving = false
                    return
                }
            }
        }
        if let locationDescription = location {
            if let alert = locationDescription.removeBadWords() {
                self.presentViewController(alert, animated: true, completion: nil)
                currentlySaving = false
                return
            }
        }
        if segueLoc == "EditAlbums" {
            deleteOldItems()
        } else {
            addNewAlbum()
        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "Aurora" { //Called when the user clicks on the "Location" button
            if let destination = segue.destinationViewController as? MapViewController {
                destination.segueLoc = "AddNewItem"
                destination.latDefault = latDefault
                destination.defaultLoc = locDefault
                destination.longDefault = longDefault
                if lat != nil {
                    destination.lat = lat
                    destination.long = long
                    destination.preexistingLocation = true
                    if location != nil {
                        destination.locationDescription = location!
                    }
                }
            }
        }
    }
    
    
    
    
    
    deinit {
        if buyListener != nil {
            ref.removeObserverWithHandle(buyListener!)
        }
    }
    
    
    
    
}

