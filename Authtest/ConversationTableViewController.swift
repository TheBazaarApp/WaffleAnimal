//
//  ConversationTableViewController.swift
//  Authtest
//
//  Created by CSSummer16 on 6/22/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

class ConversationViewController: UITableViewController {
    let rootRef = FIRDatabase.database().reference()
    var conversations = [String]()
    var chatting = [String]()
    var college = mainClass.domainBranch
    
    
    
    //MARK: SETUP FUNCTIONS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        title = "Messages"
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
        tabBarController?.tabBar.hidden = false
        let messageRoot = self.rootRef.child("\(college!)/user/\(FIRAuth.auth()!.currentUser!.uid)/messages/recents").queryOrderedByChild("timestamp")
        messageRoot.observeEventType(.ChildAdded, withBlock: { snapshot in
            let chat = snapshot.key
            self.chatting.append(chat) //TODO: Someone messages you while you're looking at this page - what happens?
            
            if let convos = snapshot.value as? [String: String] {
                let name = convos["name"]
                self.conversations.append(name!)
            }
            self.conversations = self.conversations.reverse()
            self.chatting = self.chatting.reverse()
            self.tableView.reloadData()
        })
    }
    
    
    
    
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        conversations.removeAll()
        chatting.removeAll()
    }
    
    
    
    
    // MARK: - TABLE VIEW FUNCTIONS
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!) as! contactsCell
        performSegueWithIdentifier("ursula", sender: currentCell)
        
        
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("conversing", forIndexPath: indexPath) as! contactsCell
        cell.nameLabel.text = conversations[indexPath.row]
        cell.nameLabel.textColor = UIColor(red: 37/255, green: 137/255, blue: 189/255, alpha: 1)
        cell.receiveruid = chatting[indexPath.row]
        return cell
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let otherPersonsID = chatting[indexPath.row]
            let pathToOtherPerson = self.rootRef.child("\(college!)/user/\(FIRAuth.auth()!.currentUser!.uid)/messages/recents/\(otherPersonsID)")
            pathToOtherPerson.removeValue()
            chatting.removeAtIndex(indexPath.row)
            conversations.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    
    
    
    
    //MARK: NAVIGATION FUNCTIONS
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ursula" {
            segue.destinationViewController.hidesBottomBarWhenPushed = true
            let chitChat: ChatViewController = segue.destinationViewController as! ChatViewController
            let talking = sender as! contactsCell
            chitChat.receiver = talking.nameLabel.text!
            chitChat.receiveruid = talking.receiveruid
        }
    }
    
}







//Table View is editable!
func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
}








