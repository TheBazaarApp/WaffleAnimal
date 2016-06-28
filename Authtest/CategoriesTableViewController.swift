//
//  CategoriesTableViewController.swift
//  Authtest
//
//  Created by CSSummer16 on 6/20/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CategoryCellWithButton
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Categories"
        }
        if indexPath.row == 1 {
            cell.cellButton.setTitle("All", forState: .Normal)
            //cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
        }
        if indexPath.row == 2 {
            cell.cellButton.setTitle("Fashion", forState: .Normal)
//            cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
        }
        if indexPath.row == 3 {
            cell.cellButton.setTitle("Electronics", forState: .Normal)
//            cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
        }
        
        
        if indexPath.row == 4 {
            cell.cellButton.setTitle("Appliances", forState: .Normal)
//            cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
        }
        
        if indexPath.row == 5 {
            cell.cellButton.setTitle("Transportation", forState: .Normal)
//            cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
        }
        
        if indexPath.row == 6 {
            cell.cellButton.setTitle("Furniture", forState: .Normal)
//            cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
        }
        
        if indexPath.row == 7 {
            cell.cellButton.setTitle("Books & School Supplies", forState: .Normal)
//            cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
        }
        
        if indexPath.row == 8 {
            cell.cellButton.setTitle("Services", forState: .Normal)
//            cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
            
        }
        
        if indexPath.row == 9 {
            cell.cellButton.setTitle("Other", forState: .Normal)
//            cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
        }
        
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(true)
        let Feed: FeedController = segue.destinationViewController.childViewControllers[0].childViewControllers[0] as! FeedController
        if let cat = sender?.currentTitle {
            print("category passed on")
            print(cat)
            Feed.category = cat!
        }
    }
    
//    func didTapCategory(button: UIButton) {
//        performSegueWithIdentifier("categoryid", sender: button)
//    }
    
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
