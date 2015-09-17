//
//  User.swift
//  Twitter
//
//  Created by Clover on 9/14/15.
//  Copyright (c) 2015 Clover. All rights reserved.
//

import UIKit

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    let name: String?
    let screenname: String?
    let profileImageURL: NSURL?
    let tagline: String?
    var dictionary: NSDictionary

    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        let userName = dictionary["name"] as? String
        if userName != nil {
            self.name = userName
        } else {
            self.name = nil
        }
        
        let screenName = dictionary["screen_name"] as? String
        if screenName != nil {
            self.screenname = "@" + screenName!
        } else {
            self.screenname = nil
        }

        var profileImageUrlString = dictionary["profile_image_url"] as? String
        if profileImageUrlString != nil {
            // Get Original User's Image
            let range = profileImageUrlString!.rangeOfString("_normal", options: .RegularExpressionSearch)
            profileImageUrlString = profileImageUrlString!.stringByReplacingCharactersInRange(range!, withString: "")
            self.profileImageURL = NSURL(string: profileImageUrlString!)!
        } else {
            self.profileImageURL = nil
        }
        
        let tagLine = dictionary["description"] as? String
        if tagLine != nil {
            self.tagline = tagLine
        } else {
            self.tagline = nil
        }
    }
    
    func logout() {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                var data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
                if data != nil {
                    var dictionary = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as! NSDictionary
                    _currentUser = User(dictionary: dictionary)
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            
            if _currentUser != nil {
                var data = NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: nil, error: nil)
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}
