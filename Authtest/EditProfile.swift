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
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var profileImage: UIButton!
    @IBOutlet weak var college: UITextField!
    var ref = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com") //create storage reference
    var needToSavePic = false
    
    
    
    
    
    //////////////////////////////////// Setup Functions ///////////////////////////////////
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getProfileInfo()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddNewItem.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    
    override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    
    //Get profile info from the database and display it
    func getProfileInfo(){
        if let user = FIRAuth.auth()?.currentUser {
            name.text = user.displayName
            let dataRef = ref.child("/user/\(user.uid)/profile")
            _ = dataRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                let data = snapshot.value as? [String : AnyObject]
                self.college.text = data?["college"] as? String
                self.name.text = data?["name"] as? String
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
    
    
    
    
    
    
    
    
    //////////////////////////////////// Navigation and Segues ///////////////////////////////////
    
    
    //Just go back
    @IBAction func cancelButon(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    //When save button is pressed, save stuff in the database and storage
    @IBAction func saveButton(sender: AnyObject) {
        
        let user = FIRAuth.auth()?.currentUser
        if let user = user {
            let uid = user.uid
            let details = ["college": college.text! as NSString,
                           "name": name.text! as NSString]
            let childUpdates = ["/user/\(uid)/profile": details]
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
    
    
    
    
    
    
    
    
    //////////////////////////////////// Image Picker Functions ///////////////////////////////////
    
    
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
