//
//  KeywordListener.swift
//  Authtest
//
//  Created by HMCloaner on 9/2/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import Firebase


class KeywordListener: UITableViewController {
    
    var termsFollowing = [(keyTerm: String, type: ListenerType, key: String)]() //(Term, Type, Key)
    let ref = FIRDatabase.database().reference()
    let college = mainClass.domainBranch!
    let uid = mainClass.uid!
    
    
    
    enum ListenerType: String {
        case Keyword
        case Category
    }
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setEditing(false, animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(showOptionsPopup))
        listenForNewKeywords()
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    
    
    func showOptionsPopup() {
            let optionsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            optionsMenu.addAction(UIAlertAction(title: "Add New Key Term", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
                self.followNewTerm()
            }))
            optionsMenu.addAction(UIAlertAction(title: "Delete Key Terms", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
                self.tableView.setEditing(true, animated: true)
            }))
            optionsMenu.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler:  nil))
            presentViewController(optionsMenu, animated: true, completion: nil)
    }
    
    
    
    
    
    func followNewTerm() {
        performSegueWithIdentifier("vader", sender: nil)
    }
    
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Key Terms"
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBarHidden = false
    }
    
    
    

    
    


    
    func listenForNewKeywords() {
        let followingRef = ref.child("\(college)/user/\(uid)/following")
        followingRef.observeEventType(FIRDataEventType.ChildAdded, withBlock: { (snapshot) in
            let followingData = snapshot.value as! [String : AnyObject]
            let keyTerm = followingData["keyTerm"] as! String
            let type = self.convertStringToListenerType(followingData["type"] as! String)
            let key = snapshot.key
            self.termsFollowing.append((keyTerm: keyTerm, type: type, key: key))
            self.tableView.reloadData()
                    })
    }
    
    
    

    
    
    
    
    
    func convertStringToListenerType(type: String) -> ListenerType {
        switch type {
        case "Category":
            return .Category
        case "Keyword":
            return .Keyword
        default:
            return .Keyword
        }
        
    }
    
    // MARK: - Table view data source
    
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! KeyTermCell
        let keyTermTuple = termsFollowing[indexPath.row]
        cell.formatCell(keyTermTuple.keyTerm, type: keyTermTuple.type)
        return cell
    }
    
    



    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return termsFollowing.count
    }

    

 

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let termToDelete = termsFollowing[indexPath.row]
            ref.child("\(college)/user/\(uid)/following/\(termToDelete.key)").setValue(NSNull())
            termsFollowing.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "vader" {
            let destination = segue.destinationViewController as! NewKeyword
            destination.termsFollowing = termsFollowing
        }
    }
    
    

 




}
