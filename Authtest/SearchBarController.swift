//
//  SearchBarController.swift
//  Authtest
//
//  Created by HMCloaner on 8/22/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit

class SearchBarTableViewController: UITableViewController, UISearchBarDelegate {
    
    var searchBar: UISearchBar?
    var searchBarActive = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar?.resignFirstResponder()
        addSearchBar()
    }
    
    
    func addSearchBar(){
        if self.searchBar == nil{
            
            self.searchBar = UISearchBar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 44))
            self.searchBar!.searchBarStyle       = UISearchBarStyle.Minimal
            self.searchBar!.tintColor            = UIColor.blackColor()
            self.searchBar!.barTintColor         = UIColor.whiteColor()
            self.searchBar!.delegate             = self
            self.searchBar!.placeholder          = "search here"
        }
        
        if !self.searchBar!.isDescendantOfView(self.view){
            self.view .addSubview(self.searchBar!)
        }
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // user did type something, check our datasource for text that looks the same
        if searchText.characters.count > 0 {
            // search and reload data source
            searchBarActive = true
            filterContentForSearchText(searchText)
            tableView?.reloadData()
        } else {
            // if text length == 0
            // we will consider the searchbar is not active
            searchBarActive = false
            tableView?.reloadData()
        }
        
    }
    
    
    
    func filterContentForSearchText(searchText: String) {
        //Override this in subclasses
    }
    
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.cancelSearching()
        self.tableView?.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar!.resignFirstResponder()
    }
    
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar!.setShowsCancelButton(true, animated: true)
    }
    
    
    
    
    func cancelSearching(){
        searchBarActive = false
        searchBar!.resignFirstResponder()
        searchBar!.text = ""
        searchBar!.setShowsCancelButton(false, animated: false)
    }
    
}
