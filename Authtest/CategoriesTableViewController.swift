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
        
        cell.backgroundColor = .clearColor() //or our blue
        cell.cellButton.titleLabel?.textColor = .whiteColor()
        cell.cellButton.contentHorizontalAlignment = .Left
        cell.cellButton.setTitle(getTitle(indexPath.row), forState: .Normal)
        
        
        if indexPath.row == 0 {
            cell.cellButton.enabled = false
            cell.cellButton.titleLabel?.textColor = mainClass.ourGold
        }
        
        return cell
    }
    
    
    
    func getTitle(index: Int) -> String {
        let titles = ["Categories", "Album View", "All Items", "Fashion", "Electronics", "Appliances", "Transportation", "Furniture", "School Supplies", "Services", "Other", "In Search Of"]
        return titles[index]
        
    }
    
    
    
    //MARK: ACTION FUNCTIONS
    
    
    
    @IBAction func catButtonPushed(sender: AnyObject) {
        if let cat = sender.currentTitle {
            homeController.showAlbums = (cat == "Album View")
            homeController.category = cat!
            if cat != "Album View" {
                homeController.filterByCategory(cat!)
            }
            homeController.toggleMenu()
            homeController.tableView!.reloadData()
        }
    }
    
    
}




