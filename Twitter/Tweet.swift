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
    let ID: String?
    let isFavorite: Int?

    init(dictionary: NSDictionary) {
        self.user = User(dictionary: dictionary["user"] as! NSDictionary)
        self.text = dictionary["text"] as? String
        
        var created_AtString = dictionary["created_at"] as? String
        var formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        self.createdAt = formatter.dateFromString(created_AtString!)
        
        if NSCalendar().isDateInToday(createdAt!) == false {
            var timeInterval = createdAt!.timeIntervalSinceNow
            let timeIntervalRounded = NSInteger(-timeInterval)
            if timeIntervalRounded < 3600 {
                if timeIntervalRounded < 60 {
                    // If tweet is created within 1 minute
                    self.createdAtString = "\(timeIntervalRounded%60)s"
                
                } else {
                    // If tweet is created within 1 hour
                    self.createdAtString = "\((timeIntervalRounded/60)%60)m"
                }
            
            } else {
                // If tweet is created more than 1 hour ago
                self.createdAtString = "\(timeIntervalRounded/3600)h"
            }
            
        } else {
            var getHourFormatter = NSDateFormatter()
            getHourFormatter.dateFormat = "MM/dd/yyyy"
            self.createdAtString = getHourFormatter.stringFromDate(createdAt!)
        }
        
        self.ID = dictionary["id_str"] as? String
        self.isFavorite = dictionary["favorited"] as? Int
    }
    
    class func tweetWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
    
    
}
