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


class ProfileViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var unsoldImage1: UIImageView!
    @IBOutlet weak var unsoldImage2: UIImageView!
    @IBOutlet weak var unsoldImage3: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var college: UILabel!
    
    
    var ref = FIRDatabase.database().reference() //create database reference
    let storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com") //create storage reference
    var displayedUnsold = [String]()
    var uid: String?
    var profileDetails: FIRDatabaseHandle?
    
    
    
    override func viewDidLoad() {
        print("profile did load")
        super.viewDidLoad()
        //login() //*** Take this out later after we integrate
        let user = FIRAuth.auth()?.currentUser
        uid = user!.uid
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(goToEditProfile)) //Edit profile button
        self.navigationItem.setHidesBackButton(true, animated: true) //Hide back button
        getProfileInfo()
        
    }
    
    
    
    
    
    
    
    
    //////////////////////////////////// Display Profile Information ///////////////////////////////////
    
    
    
    
    
    //Calls functions to get and display profile pics
    func getProfileInfo () {
        getProfilePic()
        getNormalProfileInfo()
        getItemsForSale() //Get unsold items
    }
    
    
    
    
    //Gets profile pic from database and displays it
    func getProfilePic() {
        if let user = FIRAuth.auth()?.currentUser {
            let imageRef = storageRef.child("ProfilePics/\(user.uid)")
            imageRef.downloadURLWithCompletion{ (URL, error) -> Void in
                if (error != nil) {
                    print ("ERROR LOADING PIC 2!!!")
                } else {
                    if let data = NSData(contentsOfURL: URL!) {
                        self.profilePic.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    //Gets personal info from the database - name, college, etc.
    func getNormalProfileInfo() {
        if let user = FIRAuth.auth()?.currentUser {
            //Get general profile info from database
            let dataRef = ref.child("/user/\(user.uid)/profile")
            _ = dataRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
                let data = snapshot.value as? [String : AnyObject]
                self.college.text = data?["college"] as? String
                self.name.text = data?["name"] as? String
            })
        }
        
    }
    
    
    
    
    
    ////////////////////////////////////Display Sold/Unsold Items ///////////////////////////////////
    
    
    
    //Access the storage and the database to get and display 3 unsold items
    func getItemsForSale(){
        
        if let user = FIRAuth.auth()?.currentUser {
            
            //Get unsold items from the database and storage
            let imageRef = ref.child("/user/\(user.uid)/unsoldItems")
            _ = imageRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                
                if let allItems = snapshot.value as? [String : AnyObject] {
                    let imageIDArray = Array(allItems.keys) //String array of item IDs
                    let shuffledArray = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(imageIDArray) //Randomize array
                    
                    if shuffledArray.count < 3 {
                        self.displayedUnsold = shuffledArray as! [String]
                    } else {
                        self.displayedUnsold = [shuffledArray[0] as! String, shuffledArray[1] as! String, shuffledArray[2] as! String] //There's got to be a better way to do this
                    }
                    self.showUnsold()
                }
                else {
                    print ("no items")
                }
            })
        }
    }
    
    
    
    
    
    
    
    //Display up to 3 unsold items
    func showUnsold(){
        let imageViews = [unsoldImage1, unsoldImage2, unsoldImage3]
        for i in 0...(displayedUnsold.count - 1) {
            let imageRef = storageRef.child("users/\(uid!)/unsoldItems/\(displayedUnsold[i])") //Path to the image in stoage
            imageRef.downloadURLWithCompletion{ (URL, error) -> Void in  //Download the image
                if (error != nil) {
                    print("displayedID")
                    print(self.displayedUnsold[i])
                    print ("ERROR LOADING PIC 3!!!")
                    print(error)
                } else {
                    if let picData = NSData(contentsOfURL: URL!) { //The pic!!!
                        let image = UIImage(data: picData)!
                        imageViews[i].image = image
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    //////////////////////////////////// Navigation and Segues ///////////////////////////////////
    
    
    
    func goToEditProfile(){
        performSegueWithIdentifier("editProfile", sender: self)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "cinderella" { //Called when the user clicks on the "Unsold Items" button
            if let destination = segue.destinationViewController as? ViewItems {
                destination.unsold = true


            }
        } else {
            if segue.identifier == "editProfile " {
                let backItem = UIBarButtonItem()
                backItem.title = "Cancel"
                navigationItem.backBarButtonItem = backItem //Add a back button
            }
        }
    }
    
    
    
    
    
    
    
    
    //////////////////////////////////// Login; ***Take this out later! ///////////////////////////////////
    
    
    
    
    func login() {
        FIRAuth.auth()?.signInWithEmail("dagarwal@g.hmc.edu", password:"21081997", completion: {
            user, error in
            if error != nil{
                print("Entered incorrectly! Are you an imbicile?")
            } else {
            }
        })
    }
    
    
    
    
}