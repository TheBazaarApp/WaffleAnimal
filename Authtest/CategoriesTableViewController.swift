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
        self.view.backgroundColor = UIColor(red: 37/255, green: 137/255, blue: 189/255, alpha: 1.0)
    }
    
    
    
    
    // MARK: TABLEVIEW FUNCTIONS
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 12
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CategoryCellWithButton
        //CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        if indexPath.row == 0 {
            cell.cellButton.enabled = false
            cell.textLabel?.text = "Categories"
            cell.textLabel?.backgroundColor = UIColor(red: 37/255, green: 137/255, blue: 189/255, alpha: 1.0)
            cell.textLabel!.textColor = UIColor.whiteColor()
        }
        
        if indexPath.row == 1 {
            cell.cellButton.setTitle("Album View", forState: .Normal)
            cell.cellButton.contentHorizontalAlignment = .Left
            cell.cellButton.backgroundColor = UIColor.clearColor()
            cell.cellButton.titleLabel?.textColor = UIColor.whiteColor()
        }
        if indexPath.row == 2 {
            cell.cellButton.setTitle("All Items", forState: .Normal)
            cell.cellButton.contentHorizontalAlignment = .Left
            cell.cellButton.backgroundColor = UIColor.clearColor()
            cell.cellButton.titleLabel?.textColor = UIColor.whiteColor()
        }
        if indexPath.row == 3 {
            cell.cellButton.setTitle("Fashion", forState: .Normal)
            cell.cellButton.contentHorizontalAlignment = .Left
            cell.cellButton.backgroundColor = UIColor.clearColor()
            cell.cellButton.titleLabel?.textColor = UIColor.whiteColor()
        }
        if indexPath.row == 4 {
            cell.cellButton.setTitle("Electronics", forState: .Normal)
            cell.cellButton.contentHorizontalAlignment = .Left
            cell.cellButton.backgroundColor = UIColor.clearColor()
            cell.cellButton.titleLabel?.textColor = UIColor.whiteColor()
        }
        
        if indexPath.row == 5 {
            cell.cellButton.setTitle("Appliances", forState: .Normal)
            cell.cellButton.contentHorizontalAlignment = .Left
            cell.cellButton.backgroundColor = UIColor.clearColor()
            cell.cellButton.titleLabel?.textColor = UIColor.whiteColor()
        }
        
        if indexPath.row == 6 {
            cell.cellButton.setTitle("Transportation", forState: .Normal)
            cell.cellButton.contentHorizontalAlignment = .Left
            cell.cellButton.backgroundColor = UIColor.clearColor()
            cell.cellButton.titleLabel?.textColor = UIColor.whiteColor()
        }
        
        if indexPath.row == 7 {
            cell.cellButton.setTitle("Furniture", forState: .Normal)
            cell.cellButton.contentHorizontalAlignment = .Left
            cell.cellButton.backgroundColor = UIColor.clearColor()
            cell.cellButton.titleLabel?.textColor = UIColor.whiteColor()
        }
        
        if indexPath.row == 8 {
            cell.cellButton.setTitle("School Supplies", forState: .Normal)
            cell.cellButton.contentHorizontalAlignment = .Left
            cell.cellButton.backgroundColor = UIColor.clearColor()
            cell.cellButton.titleLabel?.textColor = UIColor.whiteColor()
        }
        
        if indexPath.row == 9 {
            cell.cellButton.setTitle("Services", forState: .Normal)
            cell.cellButton.contentHorizontalAlignment = .Left
            cell.cellButton.backgroundColor = UIColor.clearColor()
            cell.cellButton.titleLabel?.textColor = UIColor.whiteColor()
        }
        
        if indexPath.row == 10 {
            cell.cellButton.setTitle("Other", forState: .Normal)
            cell.cellButton.contentHorizontalAlignment = .Left
            cell.cellButton.backgroundColor = UIColor.clearColor()
            cell.cellButton.titleLabel?.textColor = UIColor.whiteColor()
        }
        
        if indexPath.row == 11 {
            cell.cellButton.setTitle("In Search Of", forState: .Normal)
            cell.cellButton.contentHorizontalAlignment = .Left
            cell.cellButton.backgroundColor = UIColor.clearColor()
            cell.cellButton.titleLabel?.textColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    
    
    //MARK: ACTION FUNCTIONS
    
    
    
    @IBAction func catButtonPushed(sender: AnyObject) {
        if let cat = sender.currentTitle {
            homeController.showAlbums = (cat == "Album View")
            homeController.category = cat!
            if cat != "Album View" {
                homeController.filterByCategory(cat!)
            }
            //homeController.menuIsOpen = false
            homeController.toggleMenu()
            homeController.tableView!.reloadData()
            ///self.revealViewController().revealToggleAnimated(true)
        }
    }
    
    
}




