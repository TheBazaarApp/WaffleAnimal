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

class AddNewItem: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    //Outlets from text fields on the screen
    @IBOutlet weak var albumName: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var location: UITextField!
    
    var uid: String?
    let storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com") //Create storage reference
    var ref = FIRDatabase.database().reference() //Root of the realtime database
    var items = [Item]()
    let college = "hmc"
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = FIRAuth.auth()?.currentUser
        uid = user!.uid
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(addNewAlbum))
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddNewItem.dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    //////////////////////////////////// Saving Info/Pics in the Database ////////////////////////////////////
    
    
    
    //Save a new album into the database; called when you click the save button
    func addNewAlbum() {
        
        
        
        //If there are no items in the album, show an alert popup.
        if collectionView.visibleCells().count == 0 {
            
            let ac = UIAlertController(title: "Missing Name", message: "You fool!  How dare you save an album without any items!", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            
            
            //Check whether there are unnamed items or items without prices; (*** Maybe later we should also require tag as well)
            var theresAnUnnamedItem = false
            for cell in collectionView.visibleCells() as! [CollectionViewCell] {
                if (cell.itemName.text == "" || cell.itemPrice.text == "") {
                    theresAnUnnamedItem = true
                    break
                }
            }
            
            
            //If an item or the album are missing a name, show an alert popup.
            if (theresAnUnnamedItem || albumName.text == "") {
                
                let ac = UIAlertController(title: "Missing Name", message: "You imbecil!  The album and all of the items need names and prices!!!!", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                presentViewController(ac, animated: true, completion: nil)
            } else {
                
                
                //If there are no problems, save the items
                var counter = 0
                let key = ref.child("\(college)/user/\(uid!)/albums").childByAutoId().key //Generate a unique album ID (***Later, change this to the path which is directly under college (not under user))
                for cell in collectionView.visibleCells() as! [CollectionViewCell] { //Loop through the cells (each of which represents one item)
                    
                    let imageKey = ref.child("\(college)/user/\(uid!)/unsoldItems").childByAutoId().key //Generate a unique album ID
                    
                    let image = items[counter].getPicture()
                    
                    
                    let imageRef = self.storageRef.child(college).child("user").child(self.uid!).child("unsoldItems").child("\(imageKey)")
                    
                    
                    
                    let imageData: NSData = UIImagePNGRepresentation((image))!
                    imageRef.putData(imageData, metadata: nil) { metadata, error in
                        if (error != nil) {
                            print ("Great scott!  We have encountered a problem!")
                        }
                    }
                    
                    
                    counter += 1
                    
                    
                    //Store item details in the database in two different places (by album, and just by image) (*** Maybe one more place as well)
                    let name = cell.itemName.text! //as NSString
                    let description = cell.itemDescription.text! //as NSString
                    let price = cell.itemPrice.text! //as NSString
                    let loc = location.text! //as NSString
                    let nameOfAlbum = albumName.text!
                    
                    
                    
                    
                    let details = ["price": price,
                                   "description": description,
                                   "tag": "electronics",
                                   "name": name]
                    
                    // (**** Add in item-based album tags)
                    let imageDetail = ["name": name,
                                       "price": price,
                                       "description": description,
                                       "location": loc,
                                       "albumName": nameOfAlbum]
                    
                    
                    
                    let imageDetail2 = ["name": name,
                                       "price": price,
                                       "description": description,
                                       "user": uid! as NSString,
                                       "location": loc,
                                       "albumName": nameOfAlbum]
                    
                    let childUpdates = ["\(college)/user/\(uid!)/albums/\(key)/unsoldItems/\(imageKey)": details,
                                        "\(college)/albums/\(key)/unsoldItems/\(imageKey)": details,
                                        "\(college)/user/\(uid!)/unsoldItems/\(imageKey)": imageDetail,
                                        "\(college)/unsoldItems/\(imageKey)": imageDetail2]
                    
                    
                    ref.updateChildValues(childUpdates as [NSObject : AnyObject])
                }
                
                
                //Store the album details
                let details = ["albumName": self.albumName.text!,
                               "location": location.text! as NSString]
                
                let childUpdates = ["\(college)/user/\(uid!)/albums/\(key)/albumDetails": details,
                                    "\(college)/albums/\(key)/unsoldItems/": ["albumName" : albumName]]
                
                ref.updateChildValues(childUpdates as [NSObject : AnyObject]) //(*** Try to do this all in on ref.updateChildValues call so it's all atomic)
                
                
                //Go back to the profile
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    //////////////////////////////////// Image Picker Functions ////////////////////////////////////
    
    
    
    
    //Open the picker when you click Add Item (*** Maybe later we should give an option to add an item w/o a pic)
    @IBAction func addItemButton(sender: UIButton) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true //Allow people to crop images
        picker.delegate = self
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
        
        let item = Item(itemDescription: "description", tags: "", itemName: "", price: "", picture: newImage, seller: "")
        items.append(item)
        collectionView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
    //////////////////////////////////// Collection View Functions ////////////////////////////////////
    
    
    //Returns the number of items that should show up in the collection view
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    
    
    //Puts the right item in each cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Image", forIndexPath: indexPath) as! CollectionViewCell
        cell.initializeListeners() // (*** Ideally, these should go in the init() function of CollectionViewCell, but it keeps giving an error :(
        
        //Specify what happens when X button is pressed
        cell.deleteButton?.addTarget(self, action: #selector(AddNewItem.xButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.deleteButton?.layer.setValue(indexPath.row, forKey: "index")
        
        let item = items[indexPath.item]
        cell.item = item //Add item to cell
        
        //Add border and curved edges to the cell
        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor
        cell.imageView.layer.borderWidth = 2
        cell.layer.cornerRadius = 7
        
        //Fill cell with info
        cell.imageView.image = item.getPicture()
        cell.itemName.text = item.itemName
        cell.itemPrice.text = item.price
        cell.itemDescription.text = item.itemDescription
        
        return cell
    }
    
    
    
    //Delete the item if you click the X-button on it
    @IBAction func xButtonPressed(sender: UIButton) {
        let i : Int = (sender.layer.valueForKey("index")) as! Int
        items.removeAtIndex(i)
        collectionView.reloadData()
    }
    
    
    
    
}
