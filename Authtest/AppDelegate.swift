//
//  AppDelegate.swift
//  Authtest
//
//  Created by CSSummer16 on 6/13/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import FirebaseMessaging
import FirebaseInstanceID
import Firebase
import GoogleMaps
import OneSignal

var mainClass: Main!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var userVerified = false
    
    
    override init() {
        FIRApp.configure()
        GMSServices.provideAPIKey("AIzaSyCPYSYVpF0ruyvsMS4Au8-NB3fDaqrIHmc")
    }
    
    
    func backToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        self.window?.rootViewController = initialViewController
    }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        mainClass = Main()
        listenForLogin()
        formatNavBar()
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: "b12a0a39-2757-422b-ae30-4f775385c1f6")
        
        
        return true
    }
    
    
    func listenForLogin() {
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if var nextController = self.window!.rootViewController {
                var topController = self.window!.rootViewController!
                while let presentedViewController = nextController.presentedViewController {
                    if !(presentedViewController is UINavigationController) {
                        topController = presentedViewController
                    }
                    nextController = presentedViewController
                }
                if user != nil && mainClass.loginTime {
                    //topController is the current VC
                    if !user!.emailVerified {
                        if topController is ViewController {
                            let loginScreen =  self.window!.rootViewController! as! ViewController
                            loginScreen.notVerifiedAlert()
                        }
                    } else {
                        //User is verified; go to feed
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
                        self.window?.rootViewController = initialViewController
                    }
                }
                else {
                    //we have a new user! Make sure to get their notifications ID
                    if topController is ViewController {
                        let loginScreen =  self.window!.rootViewController! as! ViewController
                        OneSignal.IdsAvailable({ (userId, pushToken) in
                            print("user notifications id is \(userId)")
                            loginScreen.notificationsID = userId
                        })
                    }
                }
            }
        }
    }
    
    
    
    func formatNavBar() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = mainClass.ourBlue
        navigationBarAppearance.tintColor = UIColor(red: 255/255, green: 186/255, blue: 0/255, alpha: 1)
        navigationBarAppearance.translucent = false
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 255/255, green: 186/255, blue: 0/255, alpha: 1)]
    }
    
    
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
    }
    
    
    
    
    
    func registerForNotifications(application: UIApplication) {
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

