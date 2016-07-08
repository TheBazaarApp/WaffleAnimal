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
        return 11
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CategoryCellWithButton
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Categories"
        }
        
        if indexPath.row == 1 {
            cell.cellButton.setTitle("Album View", forState: .Normal)
        }
        
        if indexPath.row == 2 {
            cell.cellButton.setTitle("All", forState: .Normal)
            //cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
        }
        if indexPath.row == 3 {
            cell.cellButton.setTitle("Fashion", forState: .Normal)
            //            cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
        }
        if indexPath.row == 4 {
            cell.cellButton.setTitle("Electronics", forState: .Normal)
            //            cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
        }
        
        
        if indexPath.row == 5 {
            cell.cellButton.setTitle("Appliances", forState: .Normal)
            //            cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
        }
        
        if indexPath.row == 6 {
            cell.cellButton.setTitle("Transportation", forState: .Normal)
            //            cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
        }
        
        if indexPath.row == 7 {
            cell.cellButton.setTitle("Furniture", forState: .Normal)
            //            cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
        }
        
        if indexPath.row == 8 {
            cell.cellButton.setTitle("Books & School Supplies", forState: .Normal)
            //            cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
        }
        
        if indexPath.row == 9 {
            cell.cellButton.setTitle("Services", forState: .Normal)
            //            cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
            
        }
        
        if indexPath.row == 10 {
            cell.cellButton.setTitle("Other", forState: .Normal)
            //            cell.cellButton.addTarget(self, action: #selector(didTapCategory), forControlEvents: .TouchUpInside)
        }
        
        
        return cell
    }
    

    
    
    
    @IBAction func catButtonPushed(sender: AnyObject) {
        if let cat = sender.currentTitle {
            if cat == "Album View" {
                homeController.showAlbums = true
            }
            else {
                homeController.category = cat!.lowercaseString
                homeController.showAlbums = false
                homeController.filterByCategory(cat!.lowercaseString)
            }
            homeController.menuIsOpen = false
            homeController.collectionView!.reloadData()
            self.revealViewController().revealToggleAnimated(true)
        }
    }
}




