//
//  EditProfile.swift
//  buy&sell
//
//  Created by cssummer16 on 6/15/16.
//  Copyright © 2016 Daksha Agarwal. All rights reserved.

//
import UIKit
import FirebaseAuth
import Firebase

class EditProfile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    //MARK: VARIABLES AND OUTLETS
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var profileImage: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var cancelButton: UIImageView!
    
    var ref = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com") //create storage reference
    var needToSavePic = false
    let college = mainClass.domainBranch!
    let uid = mainClass.uid!
    var profilePic: UIImage?
    var rating: Int?
    var latDefault: Double?
    var longDefault: Double?
    var location: String?
    var currentlySaving = false
    var ratingCount: Int?
    var hasPic = false
    
    //MARK: SETUP FUNCTIONS
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getProfileInfo()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddNewItem.dismissKeyboard))
        view.addGestureRecognizer(tap)
        let cancel = UITapGestureRecognizer(target: self, action: #selector(cancelTapped))
        cancelButton.addGestureRecognizer(cancel)
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.clipsToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
        tabBarController?.tabBar.hidden = false
    }
    
    
    
    
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    
    
    
    override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    func cancelTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    
    //Get profile info from the database and display it
    func getProfileInfo(){
        profileImage.setImage(profilePic!, forState: .Normal)
        if let user = FIRAuth.auth()?.currentUser {
            name.text = user.displayName
            let dataRef = ref.child("\(self.college)/user/\(user.uid)/profile")
            _ = dataRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                let data = snapshot.value as? [String : AnyObject]
                self.name.text = data?["name"] as? String
                if let starRating = data?["rating"] as? Int {
                    self.rating = starRating
                }
                if let starRatingCount = data?["ratingCount"] as? Int {
                    self.ratingCount = starRatingCount
                }
                if let latText = data?["defaultLatitude"] as? Double {
                    self.latDefault = latText
                }
                if let longText = data?["defaultLongitude"] as? Double {
                    self.longDefault = longText
                }
                if let labelText = data?["defaultLocation"] as? String {
                    self.location = labelText
                    self.locationLabel.text = labelText
                } else {
                    if self.latDefault != nil {
                        self.locationLabel.text = "Default Coordinates: \(Double(round(1000*self.latDefault!)/1000)), \(Double(round(1000*self.longDefault!)/1000))"
                        
                    }
                }
            })
        }
    }
    
    
    
    
    
    
    
    //MARK: NAVIGATION AND SEGUES
    
    
    
    
    
    //When save button is pressed, save stuff in the database and storage
    @IBAction func savePressed(sender: AnyObject) {
        if !currentlySaving {
            currentlySaving = true
            let user = FIRAuth.auth()?.currentUser
            if let user = user {
                if let username = name.text {
                    if let alert = username.removeBadWords() {
                        self.presentViewController(alert, animated: true, completion: nil)
                        currentlySaving = false
                        return
                    }
                }
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = name.text!
                changeRequest.commitChangesWithCompletion { error in
                    if error != nil {
                        mainClass.simpleAlert("Error Saving Display Name", message: "\(error!.localizedDescription) \n You can re-save your name later by editing your profile.", viewController: self)
                    }
                }
                
                var details = ["name": name.text! as NSString,
                               "rating": self.rating ?? NSNull(),
                               "ratingCount": self.ratingCount ?? NSNull()] as [String : AnyObject]
                
                details["defaultLatitude"] = latDefault ?? NSNull()
                details["defaultLongitude"] = longDefault ?? NSNull()
                details["defaultLocation"] = location ?? NSNull()
                
                
                
                let childUpdates = ["\(self.college)/user/\(uid)/profile": details]
                ref.updateChildValues(childUpdates)
                
                
                //Only save image if it's been changed
                if needToSavePic{
                    savePicInFirebase()
                    savePicInLocalStorage()
                } else {
                    navigationController!.popViewControllerAnimated(true)
                }
            } else {
                navigationController!.popViewControllerAnimated(true)
            }
        }
    }
    
    
    
    
    
    
    func openImagePicker(camera: Bool) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true //Allow people to crop images
        if camera {
            picker.sourceType = .Camera
            picker.cameraDevice = .Front
        }
        presentViewController(picker, animated: true, completion: nil)
    }
    
    
    
    
    
    
    func showPicOptions () {
        let optionsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        optionsMenu.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
            self.openImagePicker(false)
        }))
        optionsMenu.addAction(UIAlertAction(title: "Take Photo", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
            self.openImagePicker(true)
        }))
        if hasPic {
            optionsMenu.addAction(UIAlertAction(title: "Delete Photo", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
                self.hasPic = false
                self.needToSavePic = true
                self.profileImage.setImage(UIImage(named: "ic_profile"), forState: .Normal)
            }))
        }
        optionsMenu.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(optionsMenu, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    func savePicInFirebase() {
        let imageRef = self.storageRef.child("\(self.college)/user/\(uid)/ProfilePic")
        
        if let stack = self.navigationController?.viewControllers {
            if let previousViewController = stack[stack.count-2] as? ProfileViewController {
                previousViewController.profilePic.image = self.profileImage.imageView!.image!
                previousViewController.hasPic = self.hasPic
            }
        }
        
        
        if hasPic {
        let image = profileImage.currentImage
        let imageData: NSData = UIImagePNGRepresentation((image)!)!
            
            
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if (error != nil) {
                mainClass.simpleAlert("Error Saving Profile Pic", message: error!.localizedDescription + "\n Please try saving again.", viewController: self)
            } else {
                self.navigationController!.popViewControllerAnimated(true)
            }
        }
        } else {
            imageRef.deleteWithCompletion { (error) -> Void in
                self.navigationController!.popViewControllerAnimated(true)
            }
        }
    }
    
    func savePicInLocalStorage() {
        let image = self.profileImage.currentImage
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        let imagesDirectoryPath = documentDirectorPath.stringByAppendingString("/ImagePicker")
        let imagePath = imagesDirectoryPath.stringByAppendingString("/profilePic.png")
        if hasPic {
        var objcBool:ObjCBool = true
        let isExist = NSFileManager.defaultManager().fileExistsAtPath(imagesDirectoryPath, isDirectory: &objcBool)
        // If the folder with the given path doesn't exist already, create it
        if isExist == false{
            do{
                try NSFileManager.defaultManager().createDirectoryAtPath(imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                mainClass.simpleAlert("Error Saving Profile Pic", message: "Please try again.", viewController: self)
            }
        }
        let data = UIImagePNGRepresentation(image!)
        NSFileManager.defaultManager().createFileAtPath(imagePath, contents: data, attributes: nil)
        } else {
            do {
            try NSFileManager.defaultManager().removeItemAtPath(imagePath)
            } catch {
                mainClass.simpleAlert("Error Removing Profile Pic", message: "Please try again.", viewController: self) //TODO: Probs if you're popping while this pops up?
            }
        }
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "olaf" { //Called when the user clicks on the "Location" button
            if let destination = segue.destinationViewController as? MapViewController {
                destination.defaultLoc = locationLabel.text!
                destination.latDefault = latDefault
                destination.longDefault = longDefault
                if self.locationLabel.text != "no default location set" {
                    destination.locationDescription = self.locationLabel.text!
                }
                destination.segueLoc = "EditProfile"
            }
        }
        
    }
    
    
    
    
    
    
    
    
    //MARK: IMAGE PICKER FUNCTIONS
    
    
    //Open the image picker when you click on the picture (which is actually a button)
    @IBAction func profileImage(sender: AnyObject) {
        showPicOptions()
    }
    
    
    
    //When the user clicks cancel on the image picker, just close it
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    //When the user selects an image picture, do stuff with it
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var newImage: UIImage
        
        if let possibleImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        needToSavePic = true
        profileImage.setImage(newImage, forState: UIControlState.Normal)
        hasPic = true
        dismissViewControllerAnimated(true, completion: nil) //Get rid of image picker
    }
    
}
