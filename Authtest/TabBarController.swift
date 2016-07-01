//
//  TabBarController.swift
//  Authtest
//
//  Created by CSSummer16 on 6/30/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import Firebase

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var user: FIRUser?
    
    
//    init(){
//      //super.init()
//        if let user = FIRAuth.auth()?.currentUser {
//        }
//    }
    
    required init?(coder aDecoder: NSCoder) {
        user = (FIRAuth.auth()?.currentUser)
        super.init(coder: aDecoder)
        if user == nil {
            if let items = self.tabBar.items {
                for item in items {
                    if item.title == "Profile" {
                        item.title = "Register/Login"
                    }
                }
            }
        }
    }
    
    
    
    
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item.title == "Register/Login" {
            if user == nil {
                let SB = UIStoryboard(name: "Main", bundle: nil)
                let controller = SB.instantiateViewControllerWithIdentifier("ViewController")
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
    
    
    
    
    
    
    

}
