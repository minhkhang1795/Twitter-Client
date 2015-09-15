//
//  Tweet.swift
//  Twitter
//
//  Created by Clover on 9/14/15.
//  Copyright (c) 2015 Clover. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    let user: User?
    let text: String?
    let createdAtString: String?
    let createdAt: NSDate?

    init(dictionary: NSDictionary) {
        self.user = User(dictionary: dictionary["user"] as! NSDictionary)
        self.text = dictionary["text"] as? String
        
        var created_AtString = dictionary["created_at"] as? String
        var formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        self.createdAt = formatter.dateFromString(created_AtString!)
        
        if NSCalendar().isDateInToday(createdAt!) == false {
            var getHourFormatter = NSDateFormatter()
            getHourFormatter.dateFormat = "H"
            self.createdAtString = getHourFormatter.stringFromDate(createdAt!) + "h"
        } else {
            var getHourFormatter = NSDateFormatter()
            getHourFormatter.dateFormat = "MM/dd/yyyy"
            self.createdAtString = getHourFormatter.stringFromDate(createdAt!)
        }
    }
    
    class func tweetWithArray(array: [NSDictionary]) -> [Tweet]{
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
}
