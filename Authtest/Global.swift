//
//  global.swift
//  Authtest
//
//  Created by cssummer16 on 8/8/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import Firebase

class Main {
    var collegeDomain: String?
    var domainBranch: String?
    var collegeName: String?
    let ref = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().referenceForURL("gs://bubbleu-app.appspot.com")
    let emailGetter: EmailDomainGetter
    let ourBlue = UIColor(red: 37/255, green: 137/255, blue: 189/255, alpha: 1.0)
    let ourGold = UIColor(red: 1, green: 186/255, blue: 0, alpha: 1.0)
    var user = FIRAuth.auth()?.currentUser
    var uid = FIRAuth.auth()?.currentUser?.uid
    var displayName = FIRAuth.auth()?.currentUser?.displayName
    var email = FIRAuth.auth()?.currentUser?.email
    var loginTime = true
    var collegeLocation: [Double]?
    var initialized = false
    
    init() {
        emailGetter = EmailDomainGetter()
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if user != nil {
                self.user = user
                self.uid = user!.uid
                self.displayName = user!.displayName
                self.email = user!.email
                
                let emailArray = self.email?.componentsSeparatedByString("@")
                self.collegeDomain = emailArray![emailArray!.count - 1]
                print("college domain is \(self.collegeDomain)")
                self.domainBranch = self.emailGetter.getRealDomain(self.collegeDomain!)
                print("domain branch is \(self.domainBranch)")
                self.collegeName = self.emailGetter.getNameFromDomain(self.domainBranch!)
                self.initialized = true
                self.getCollegeLocation()
            }
        }
    }
    
    
    
    func getCollegeLocation() {
        let dataRef = ref.child("collegeLocations/\(domainBranch!)")
        dataRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if let coordinateArray = snapshot.value as? NSArray {
                self.collegeLocation = coordinateArray as? [Double]
            }
        })
    }
    
    
//    
//    func getTopController() {
//        if var nextController = SharedApplication.rootViewController {
//            var topController = self.window!.rootViewController!
//            while let presentedViewController = nextController.presentedViewController {
//                if !(presentedViewController is UINavigationController) {
//                    topController = presentedViewController
//                }
//                nextController = presentedViewController
//            }
//    }
//    
    
    
    
    func defaultPic(tag: String) -> UIImage? {
        switch tag {
        case "Appliances":
            return UIImage(named : "Appliances Default")
        case "Fashion":
            return UIImage(named : "Fashion Default")
        case "Furniture":
            return UIImage(named : "Furniture Default")
        case "In Search Of":
            return UIImage(named : "In Search Of Default")
        case "School Supplies":
            return UIImage(named : "School Supplies Default")
        case "Services":
            return UIImage(named : "Services Default")
        default:
            return UIImage(named : "No Category Default")
            
            
        }
    }
    
    
    func simpleAlert(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    
    
    
    
}

extension String {
    func removeBadWords() -> UIAlertController? {
        for word in self.componentsSeparatedByString(" ") {
            if badWords.contains(word.lowercaseString) {
                let ac = UIAlertController(title: "Inappropriate Language", message: "We detected an inappropriate word :(. Please remove the word and try again", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                return ac
            }
        }
        return nil
    }
}


extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}


