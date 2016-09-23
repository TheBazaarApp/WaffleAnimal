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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
//    
//    
//    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
////        if item.title == "Register/Login" {
////            if user == nil {
////                let SB = UIStoryboard(name: "Main", bundle: nil)
////                let controller = SB.instantiateViewControllerWithIdentifier("ViewController")
////                self.presentViewController(controller, animated: true, completion: nil)
////            }
////        }
//        print("selected item")
//        if item.title == "Feed" {
//            print("title is feed")
//            
//            
//    
//            var currController = UIApplication.sharedApplication().keyWindow?.rootViewController
//                while (currController != nil) {
//                    print("got another controller")
//                    print(currController.dynamicType)
//                    print(currController is FeedController)
//                    print(currController is UITableViewController)
//                    print(currController is SearchBarTableViewController)
//                    print(currController?.presentedViewController)
//                    if let stack = currController!.navigationController?.viewControllers {
//                        print(stack.count)
//                    }
//                    if let feedController = currController as? FeedController {
//                        print ("it's a feed controller")
//                        if feedController.menuIsOpen {
//                            print("toggling menu")
//                            feedController.toggleMenu()
//                        }
//                        break
//                    }
//                    currController = currController?.presentedViewController
//                }
//            }
//            
//            
////            
////            
////            if let top = UIApplication.topViewController() {
////                print("there is a top controller")
////                print (top.dynamicType)
////            }
////            if let topController = UIApplication.topViewController() as? FeedController {
////                print("top controller is feedcontorller")
////                if topController.menuIsOpen {
////                    print("toggling menu")
////                    topController.toggleMenu()
////                }
////            }
// //       }
//    }
    
    
    
}
