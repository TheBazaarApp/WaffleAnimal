/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Firebase
import JSQMessagesViewController
import OneSignal

class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: OUTLETS AND VARIABLES
    
    var messages: [JSQMessage] = []
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var receiveruid: String = ""
    let rootRef = FIRDatabase.database().referenceFromURL("https://bubbleu-app.firebaseio.com")
    var messageRef: FIRDatabaseReference!
    var receiver: String = ""
    var userIsTypingRef: FIRDatabaseReference!
    var usersTypingQuery: FIRDatabaseQuery!
    var storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com")
    var repetitions = 0
    var segueLoc: String?
    var bought = false
    var messageListener: FIRDatabaseHandle?
    var typingListener: FIRDatabaseHandle?
    let myCollege = mainClass.domainBranch!
    let myUID = FIRAuth.auth()!.currentUser!.uid
    var otherPersonsCollege: String?
    var sendable = true
    var holder = IDHolder()
    
    
    private var localTyping = false
    var isTyping: Bool {
        
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Profile", style: .Plain, target: self, action: #selector(viewProfile))
        title = receiver
        senderId = FIRAuth.auth()?.currentUser?.uid
        senderDisplayName = FIRAuth.auth()!.currentUser!.displayName ?? "" as String
        setupBubbles()
        // No avatars!
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        self.hideKeyboardWhenTappedAround()
        getOtherPersonsCollege()
        observeMessages()
        mainClass.getNotificationID(receiveruid, holder: holder)
        deleteNotification()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
        tabBarController?.tabBar.hidden = true
    }
    
    
    
    func getOtherPersonsCollege() {
        let pathToCollege = rootRef.child("\(myCollege)/user/\(senderId!)/messages/all/\(receiveruid)/college")
        pathToCollege.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if let college = snapshot.value as? String {
                self.otherPersonsCollege = college
            } else {
                if self.otherPersonsCollege != nil {
                    self.rootRef.child("\(self.myCollege)/user/\(self.senderId!)/messages/all/\(self.receiveruid)/college").setValue(self.otherPersonsCollege!)
                    self.rootRef.child("\(self.otherPersonsCollege!)/user/\(self.receiveruid)/messages/all/\(self.senderId!)/college").setValue(self.myCollege)
                }
            }
            self.observeTyping()
        })
    }
    
    
    
    func checkUserStillExists() {
        let pathToUser = self.rootRef.child("\(self.otherPersonsCollege)/user/\(receiveruid)/profile/name")
        pathToUser.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if snapshot.value == nil {
                mainClass.simpleAlert("User No Longer Exists", message: "The account you are trying to message has been deleted", viewController: self)
                self.sendable = false
            }
        })
    }
    
    
    func deleteNotification() {
        let pathToNotification = rootRef.child("\(myCollege)/user/\(senderId!)/notifications/\(receiveruid)")
        pathToNotification.removeValue()
    }
    
    
    
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        deleteNotification()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        self.inputToolbar.contentView.textView.resignFirstResponder()
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let photo = UIAlertAction(title: "Send photo", style: .Default) { (action) in
            self.sendPhoto()
            
            
            
        }
        
        let location = UIAlertAction(title: "Send location", style: .Default) { (action) in
            self.sendLocation()
            
        }
        actionSheet.addAction(photo)
        actionSheet.addAction(location)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(actionSheet, animated: true, completion: nil)
        
    }
    
    
    func sendLocation() {
        
    }
    
    
    
    func sendPhoto() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var newImage: UIImage
        
        if let possibleImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        
        let itemRefSender = rootRef.child("\(myCollege)/user/\(myUID)/messages/all/\(receiveruid)").childByAutoId()
        let imageKey = itemRefSender.key
        let itemRefReceiver = rootRef.child("\(otherPersonsCollege!)/user/\(receiveruid)/messages/all/\(self.senderId)").childByAutoId()
        let recentsSender = rootRef.child("\(myCollege)/user/\(myUID)/messages/recents/\(receiveruid)")
        let recentsReceiver = rootRef.child("\(otherPersonsCollege!)/user/\(receiveruid)/messages/recents/\(self.senderId)")
        let imageStorageSender = self.storageRef.child("\(myCollege)/user").child(senderId).child("messageImages").child("\(imageKey)")
        let imageStorageReceiver = self.storageRef.child("\(otherPersonsCollege!)/user").child(receiveruid).child("messageImages").child("\(imageKey)")
        
        
        let imageData: NSData = UIImagePNGRepresentation(newImage)!
        imageStorageSender.putData(imageData, metadata: nil) { metadata, error in
            if error != nil {
                mainClass.simpleAlert("Error Sending Picture", message: "", viewController: self)
            }
        }
        
        imageStorageReceiver.putData(imageData, metadata: nil) { metadata, error in
            if error != nil {
                mainClass.simpleAlert("Error Sending Picture", message: "", viewController: self)
            }
        }
        
        
        let date = NSDate()
        
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        
        formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let utcTimeZoneStr = formatter.stringFromDate(date)
        
        let photoItem = [
            "imageId": imageKey,
            "senderId": senderId
        ]
        
        let messageName = [
            "name": receiver,
            "timestamp": utcTimeZoneStr
        ]
        let senderName = [
            "name": senderDisplayName,
            "timestamp": utcTimeZoneStr
        ]
        
        itemRefSender.setValue(photoItem)
        itemRefReceiver.setValue(photoItem)
        recentsSender.setValue(messageName)
        recentsReceiver.setValue(senderName)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        let message = messages[indexPath.row]
        if message.isMediaMessage {
            let messageMedia = message.media as! JSQPhotoMediaItem
            if let pic = messageMedia.image {
                performSegueWithIdentifier("jafar", sender: pic)
            }
            
        }
        
    }
    
    
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            return cell
        }
        if message.senderId == senderId {
            cell.textView.textColor = UIColor.whiteColor()
        } else {
            cell.textView.textColor = UIColor.blackColor()
        }
        return cell
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        if sendable {
            let senderKey = rootRef.child("\(myCollege)/user/\(myUID)/messages/all/\(receiveruid)").childByAutoId().key
            let itemRefSender = "\(myCollege)/user/\(myUID)/messages/all/\(receiveruid)/\(senderKey)"
            let receiverKey = rootRef.child("\(otherPersonsCollege!)/user/\(receiveruid)/messages/all/\(self.senderId)").childByAutoId().key
            let itemRefReceiver = "\(otherPersonsCollege!)/user/\(receiveruid)/messages/all/\(self.senderId)/\(receiverKey)"
            let recentsSender = "\(myCollege)/user/\(myUID)/messages/recents/\(receiveruid)"
            let recentsReceiver = "\(otherPersonsCollege!)/user/\(receiveruid)/messages/recents/\(self.senderId)"
            let notifyMessaged = "\(otherPersonsCollege!)/user/\(receiveruid)/notifications/\(self.senderId)"
            
            
            let date = NSDate()
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
            
            formatter.timeZone = NSTimeZone(abbreviation: "UTC")
            let utcTimeZoneStr = formatter.stringFromDate(date)
            
            let messageItem = [
                "text": text!,
                "senderId": senderId!
            ]
            let messageName = [
                "name": receiver,
                "timestamp": utcTimeZoneStr
            ]
            let senderName = [
                "name": senderDisplayName!,
                "timestamp": utcTimeZoneStr
            ]
            let notificationItem = [
                "message" : "\(senderDisplayName) messaged you.",
                "type" : "MessageReceived",
                "receiveruid": senderId!,
                "receiver": senderDisplayName!]
            
            OneSignal.postNotification(["contents": ["en": text], "headings": ["en": "\(senderDisplayName) messaged you!"], "include_player_ids": [holder.id]])
            
            
            let childUpdates = [itemRefSender : messageItem,
                                itemRefReceiver : messageItem,
                                recentsSender : messageName,
                                recentsReceiver : senderName,
                                notifyMessaged : notificationItem ]
            
            
            rootRef.updateChildValues(childUpdates)
            
            
            
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            
            finishSendingMessage()
            isTyping = false
        }
    }
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    private func observeMessages() {
        let messagesQuerySender = rootRef.child("\(myCollege)/user/\(myUID)/messages/all/\(receiveruid)").queryLimitedToLast(75)
        messageListener = messagesQuerySender.observeEventType(.ChildAdded, withBlock: { snapshot in
            if snapshot.key != "college" {
                let id = snapshot.value!["senderId"] as! String
                if let imageId = snapshot.value!["imageId"] as? String {
                    let image = UIImage(named: "loading-media")
                    let photo = JSQPhotoMediaItem(image: image)
                    let message = JSQMessage(senderId: id, displayName: self.senderDisplayName, media: photo)
                    self.messages.append(message)
                    let index = self.messages.indexOf(message)
                    self.loadImage(imageId, index: index!, senderID: id)
                } else {
                    let text = snapshot.value!["text"] as! String
                    self.addMessage(id, text: text)
                    self.finishReceivingMessage()
                }
            }
        })
    }
    
    
    
    func loadImage(imageId: String, index: Int, senderID: String) {
        let imageLocation = self.storageRef.child("\(myCollege)/user/\(self.senderId)/messageImages/\(imageId)")
        imageLocation.downloadURLWithCompletion{ (URL, error) -> Void in
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
                if error != nil {
                    if (self?.repetitions <= 10) {
                        self?.repetitions += 1
                        self?.loadImage(imageId, index: index, senderID: senderID)
                    }
                }
                else {
                    if let picData = NSData(contentsOfURL: URL!) {
                        let image = UIImage(data: picData)
                        let photo = JSQPhotoMediaItem(image: image)
                        let message = JSQMessage(senderId: senderID, displayName: self?.senderDisplayName, media: photo)
                        dispatch_async(dispatch_get_main_queue()) { [weak self] in
                            self?.messages[index] = message
                            self?.finishReceivingMessage()
                        }
                    }
                }
            }
        }
    }
    
    
    
    private func observeTyping() {
        let typingIndicatorRef = rootRef.child("\(otherPersonsCollege!)/user/\(receiveruid)/messages/all/typingIndicator")
        userIsTypingRef = rootRef.child("\(myCollege)/user/\(myUID)/messages/all/typingIndicator")
        typingIndicatorRef.onDisconnectRemoveValue()
        
        ///usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
        typingListener = typingIndicatorRef.observeEventType(.Value, withBlock: { snapshot in
            if let typing = snapshot.value as? Bool {
                if typing {
                    self.showTypingIndicator = true
                } else {
                    self.showTypingIndicator = false
                }
            } else {
                self.showTypingIndicator = false
            }
            
            self.scrollToBottomAnimated(true)
        })
    }
    
    
    
    
    
    
    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: self.senderDisplayName, text: text)
        messages.append(message)
    }
    
    
    
    
    func addMedia(media:JSQMediaItem) {
        let message = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: media)
        self.messages.append(message)
        
    }
    
    
    func viewProfile() {
        performSegueWithIdentifier("pumbaa", sender: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pumbaa" {
            if let nextController = segue.destinationViewController as? ProfileViewController {
                nextController.uid = receiveruid
                nextController.college = otherPersonsCollege!
                nextController.segueLoc = "chat"
            }
        }
        if segue.identifier == "jafar" {
            let messageFull = segue.destinationViewController as! FullScreenViewController
            messageFull.image = sender as! UIImage
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        userIsTypingRef.setValue(false)
    }
    
    
    
    
    deinit {
        
        rootRef.removeObserverWithHandle(messageListener!)
        rootRef.removeObserverWithHandle(typingListener!)
    }
    
    
    
    
    
    
}
