//
//  EmailDomainGetter.swift
//  Authtest
//
//  Created by cssummer16 on 8/8/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import Foundation
import Firebase

class EmailDomainGetter: NSObject {
    
    var domainsDict = [String: String]() //domains are the keys; .edu is still in the domain
    var namesDict = [String: String]() //college names are keys
    var domainChanger = [String: String]() //If a college has multiple domains (or if the domain isn't the branch root), then the key will be the domain, and the value will be the branch root
    let ref = FIRDatabase.database().reference()
    
    override init() {
        super.init()
        getCols()
        setUpDicts()
    }
    
    
    
    
    func setUpDicts() {
        let otherCollegesRef = ref.child("otherColleges/")
        otherCollegesRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let domain = snapshot.key
            let info = snapshot.value as! [String: AnyObject]
            let collName = info["collegeName"] as! String
            self.domainsDict[domain] = collName
            if let realDomain = info["addToDomain"] as? String {
                self.domainChanger[domain] = realDomain
            } else {
                self.namesDict[collName] = domain
            }
        })
    }
    
    
    
    
    func getCols() {
        do {
            if let dataPath = NSBundle.mainBundle().pathForResource("collegeList", ofType: "txt") {
                let dataLines = try WordReader(filepath: dataPath).words
                for line in dataLines {
                    let dataArray = line.componentsSeparatedByString(": ") //Should be ["domain.edu", "College Name"]
                    if dataArray.count >= 2 {
                        let college = dataArray.suffixFrom(1).joinWithSeparator(": ")
                        let domain = dataArray[0].stringByReplacingOccurrencesOfString(".", withString: "_")
                        if let realDomain = namesDict[college] {
                            domainChanger[domain] = realDomain
                        } else {
                           namesDict[college] = domain
                        }
                        domainsDict[domain] = college
                    }
                }
            }
        }
        catch {
            //Don't do anything; you're just out of luck with colleges
        }
    }
    
    
    func getNameFromDomain(domain: String) -> String? {
        if let realDomain = domainChanger[domain] {
            return domainsDict[realDomain]
        }
        return domainsDict[domain]
    }
    
    
    func getRealDomain(domain: String) -> String? {
        let formattedDomain = domain.stringByReplacingOccurrencesOfString(".", withString: "_")
        if let realDomain = domainChanger[formattedDomain] {
            return realDomain
        }
        return formattedDomain
    }
    
    
    
    func getDomainFromName(name: String) -> String? {
        return namesDict[name]
    }
    
    
    
}