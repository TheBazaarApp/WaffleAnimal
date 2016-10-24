//
//  NewKeyword.swift
//  Authtest
//
//  Created by HMCloaner on 9/2/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import Firebase

class NewKeyword: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var isCategorySwitch: UISwitch!
    @IBOutlet weak var keywordTextbox: UITextField!
    @IBOutlet weak var categoryTableView: UITableView!
    
    let uid = mainClass.uid!
    let college = mainClass.domainBranch!
    let ref = mainClass.ref
    let categories = ["None", "Fashion", "Electronics", "Appliances", "Transportation", "Furniture", "School Supplies", "Services", "In Search Of", "Other"]
    let blue = mainClass.ourBlue
    var cellBackgroundColor = UIColor.lightGrayColor()
    var cellTextColor = UIColor.darkGrayColor()
    var selectedRowIndex: Int?
    var termsFollowing: [(keyTerm: String, type: KeywordListener.ListenerType, key: String)]? //(Term, Type, Key)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(saveNewKeyword))
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        formatKeywordTextbox(true)
        formatCategoryTableView(false)
    }
    
    
    func saveNewKeyword() {
        var keyTerm = ""
        var type = "Keyword"
        
        if isCategorySwitch.on {
            type = "Category"
            if let index = selectedRowIndex {
                keyTerm = categories[index]
            } else {
                mainClass.simpleAlert("Can't Save", message: "Please select a category.", viewController: self)
                return
            }
        } else {
            type = "Keyword"
            if keywordTextbox.text == nil || keywordTextbox.text == "" {
                mainClass.simpleAlert("Can't Save", message: "Please enter a keyword into the text box.", viewController: self)
                return
            } else {
                keyTerm = keywordTextbox.text!
            }
        }
        
        let convertedType = KeywordListener().convertStringToListenerType(type)
        for term in termsFollowing! {
            if term.type == convertedType && term.keyTerm == keyTerm {
                mainClass.simpleAlert("Can't Save", message: "You are already following this key term", viewController: self)
                return
            }
        }
        // If we're still here, it's a valid key term to save
        
        
        
        let key = ref.child("\(college)/user/\(uid)/following").childByAutoId().key
        
        
        let userData = [ "keyTerm" : keyTerm,
                             "type": type]
        
        var childUpdates = ["\(college)/user/\(uid)/following/\(key)": userData]
        
        
        for college in mainClass.collegeTradingList {
            let pathKey = "\(college)/\(type)/\(keyTerm)"
            let colUpdates = [uid : "OTHER ID"]
            childUpdates[pathKey] = colUpdates
        }
        
        
        ref.updateChildValues(childUpdates)
        
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    
    //Specify what is in each cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        if selectedRowIndex != nil && indexPath.row == selectedRowIndex! && isCategorySwitch.on {
            cell.backgroundColor = mainClass.ourGold
            cell.textLabel?.textColor = .blackColor()
            
        } else {
            cell.backgroundColor = cellBackgroundColor
            cell.textLabel?.textColor = cellTextColor
        }
        cell.textLabel!.text = categories[indexPath.row]
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRowIndex = indexPath.row
        categoryTableView.reloadData()
    }
    
    
    
    
    
    @IBAction func didChangeCategorySwitch(isCategory: UISwitch) {
        formatKeywordTextbox(!isCategory.on)
        formatCategoryTableView(isCategory.on)
    }
    
    
    func formatKeywordTextbox(on: Bool) {
        keywordTextbox.userInteractionEnabled = on
        if on {
            keywordTextbox.backgroundColor = blue
            keywordTextbox.tintColor = .whiteColor()
            keywordTextbox.textColor = .whiteColor()
            keywordTextbox.becomeFirstResponder()
        } else {
            keywordTextbox.backgroundColor = .lightGrayColor()
            keywordTextbox.tintColor = .darkGrayColor()
            keywordTextbox.tintColor = .darkGrayColor()
            keywordTextbox.resignFirstResponder()
        }
    }
    
    
    func formatCategoryTableView(on: Bool) {
        categoryTableView.userInteractionEnabled = on
        if on {
            cellBackgroundColor = blue
            cellTextColor = .whiteColor()
        } else {
            cellBackgroundColor = .lightGrayColor()
            cellTextColor = .darkGrayColor()
        }
        categoryTableView.reloadData()
    }
    
    
    
    
}
