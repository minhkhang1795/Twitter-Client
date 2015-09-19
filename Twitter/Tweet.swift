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
    var retweetCount: Double?
    var favoriteCount: Double?
    let ID: String?
    var isFavorite: Bool?
    var isRetweeted: Bool?

    init(dictionary: NSDictionary) {
        self.user = User(dictionary: dictionary["user"] as! NSDictionary)
        self.text = dictionary["text"] as? String
        
        let createdAtStringTemp = dictionary["created_at"] as? String
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        self.createdAt = formatter.dateFromString(createdAtStringTemp!)
        
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
            // If tweet is created more than 1 day
            var getHourFormatter = NSDateFormatter()
            getHourFormatter.dateFormat = "MM/dd/yyyy"
            self.createdAtString = getHourFormatter.stringFromDate(createdAt!)
        }
        
        var retweetedID = dictionary.valueForKeyPath("retweeted_status.id_str") as? String
        
        if retweetedID == nil {
            // Tweet is not retweeted
            self.ID = dictionary["id_str"] as? String
            self.retweetCount = dictionary["retweet_count"] as? Double
            self.favoriteCount = dictionary["favorite_count"] as? Double
            self.isFavorite = dictionary["favorited"] as? Bool
            self.isRetweeted = dictionary["retweeted"] as? Bool
        } else {
            // Tweet is retweeted
            self.ID = retweetedID
            self.retweetCount = dictionary.valueForKeyPath("retweeted_status.retweet_count") as? Double
            self.favoriteCount = dictionary.valueForKeyPath("retweeted_status.favorite_count") as? Double
            self.isFavorite = dictionary.valueForKeyPath("retweeted_status.favorited") as? Bool
            self.isRetweeted = dictionary.valueForKeyPath("retweeted_status.retweeted") as? Bool
        }
        
    

    }
    
    class func tweetWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        return tweets
    }
    
    
}
