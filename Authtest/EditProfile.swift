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
    @IBOutlet weak var university: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    
    var ref = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com") //create storage reference
    var needToSavePic = false
    let college = "hmc"
    
    var latDefault: Double?
    var longDefault: Double?
    
    
    
    //MARK: SETUP FUNCTIONS
    ///////////////////////////////////////////////////////////////////////
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getProfileInfo()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddNewItem.dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.clipsToBounds = true
    }
    
    
    override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    //Get profile info from the database and display it
    func getProfileInfo(){
        if let user = FIRAuth.auth()?.currentUser {
            name.text = user.displayName
            let dataRef = ref.child("\(self.college)/user/\(user.uid)/profile")
            _ = dataRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                let data = snapshot.value as? [String : AnyObject]
                self.university.text = data?["college"] as? String
                self.name.text = data?["name"] as? String
                if let labelText = data?["defaultLocation"] as? String {
                    self.locationLabel.text = labelText
                }
                if let latText = data?["defaultLatitude"] as? Double {
                    self.latDefault = latText
                }
                if let longText = data?["defaultLongitude"] as? Double {
                    self.longDefault = longText
                }
                else {
                    self.latDefault = 0.0
                    self.longDefault = 0.0
                }
            })
            
            
            let imageRef = storageRef.child("ProfilePics/\(user.uid)")
            imageRef.downloadURLWithCompletion{ (URL, error) -> Void in
                if (error != nil) {
                    print ("ERROR LOADING PIC 1!!!")
                } else {
                    if let data = NSData(contentsOfURL: URL!) {
                        self.profileImage.setImage(UIImage(data: data), forState: .Normal)
                        
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    //MARK: NAVIGATION AND SEGUES
    ///////////////////////////////////////////////////////////////////////
    
    
    //Just go back
    @IBAction func cancelButon(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    //When save button is pressed, save stuff in the database and storage
    @IBAction func saveButton(sender: AnyObject) {
        
        let user = FIRAuth.auth()?.currentUser
        if let user = user {
            let uid = user.uid
            
            var details = ["college": university.text! as NSString,
                           "name": name.text! as NSString] as [String : AnyObject]
            
            if locationLabel.text! != "no default location set" {
                details["defaultLocation"] = locationLabel.text!
                details["defaultLatitude"] = latDefault
                details["defaultLongitude"] = longDefault
            }
            
            
            let childUpdates = ["\(self.college)/user/\(uid)/profile": details]
            ref.updateChildValues(childUpdates)
            
            
            //Only save image if it's been changed
            if needToSavePic{
                //Saving image
                let image = profileImage.currentImage
                let imageData: NSData = UIImagePNGRepresentation((image)!)!
                let imageRef = self.storageRef.child("ProfilePics/\(user.uid)")
                imageRef.putData(imageData, metadata: nil) { metadata, error in
                    if (error != nil) {
                        print ("Great scott!  We have encountered a problem!")
                    }
                }
            }
            
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "olaf" { //Called when the user clicks on the "Unsold Items" button
            if let destination = segue.destinationViewController as? MapViewController {
                destination.defaultLoc = locationLabel.text!
                destination.latDefault = latDefault
                destination.longDefault = longDefault
                destination.segueLoc = "EditProfile"
            }
        }
    }
    
    
    
    
    
    
    
    
    //MARK: IMAGE PICKER FUNCTIONS
    
    
    //Open the image picker when you click on the picture (which is actually a button)
    @IBAction func profileImage(sender: AnyObject) {
        needToSavePic = true
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
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
        profileImage.setImage(newImage, forState: UIControlState.Normal)
        dismissViewControllerAnimated(true, completion: nil) //Get rid of image picker
    }
    
}
