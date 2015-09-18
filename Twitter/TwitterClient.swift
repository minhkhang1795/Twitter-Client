//
//  TwitterClient.swift
//  Twitter
//
//  Created by Clover on 9/14/15.
//  Copyright (c) 2015 Clover. All rights reserved.
//

import UIKit

let twitterConsumerKey = "8qK3WiIAwigu40GXXpI7sxZo8"
let twitterConsumerSecret = "Wdt4L63WNINrPa5jsasMHoVlcoD3ll6HPWQzRdasLpewiaHrtg"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        return Static.instance
    }
    
    func homeTimelineWithParams(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        TwitterClient.sharedInstance.GET("1.1/statuses/home_timeline.json", parameters: params,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                var tweets = Tweet.tweetWithArray(response as! [NSDictionary])
                completion(tweets: tweets, error: nil)
                
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(tweets: nil, error: error)
                if error != nil {
                    println(error)
                }
        })
    }
    
    func tweetWithParams(params: NSDictionary?, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        TwitterClient.sharedInstance.POST("1.1/statuses/update.json", parameters: params,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                var tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet: tweet, error: nil)
                
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("error posting tweet")
                completion(tweet: nil, error: error)
        }
    }
    
    func favoriteTweetWithParams(params: NSDictionary?, isFavorited: Bool?, completion: (returnedTweet: Tweet?, error: NSError?) -> ()) {
        var URL: String?
        URL = isFavorited! ? "1.1/favorites/destroy.json" : "1.1/favorites/create.json"
        println(URL)
        TwitterClient.sharedInstance.POST(URL, parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            var tweet = Tweet(dictionary: response as! NSDictionary)
            completion(returnedTweet: tweet, error: nil)
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(returnedTweet: nil, error: error)
        }
    }
    
    func retweetWithParams(id: String?, isRetweeted: Bool?, completion: (returnedTweet: Tweet?, error: NSError?) -> ()) {
        var URL: String?
        var params: NSDictionary?
        
        if isRetweeted! == false {
            // Retweet
            URL = "/1.1/statuses/retweet/\(id!).json"
            params = ["id": id!]
            TwitterClient.sharedInstance.POST(URL, parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                var tweet = Tweet(dictionary: response as! NSDictionary)
                completion(returnedTweet: tweet, error: nil)
               
                }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    completion(returnedTweet: nil, error: error)
            }
        
        } else {
            // Unretweet
            params = ["id": id!, "include_my_retweet": true]
            
            // Get current user's ID
            TwitterClient.sharedInstance.GET("1.1/statuses/show/\(id!).json", parameters: params,
                success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                    var dictionary = response as! NSDictionary
                    var idOfCurrentUser = dictionary.valueForKeyPath("current_user_retweet.id_str") as! String
                    URL = "1.1/statuses/destroy/\(idOfCurrentUser).json"
                    params = ["id": idOfCurrentUser]
                
                    TwitterClient.sharedInstance.POST(URL, parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                        var tweet = Tweet(dictionary: response as! NSDictionary)
                        completion(returnedTweet: tweet, error: nil)
                        
                        }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                            completion(returnedTweet: nil, error: error)
                    }
                }, failure: nil)
        }
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        self.loginCompletion = completion
    
        // Fetch request token & redirect to authorization page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterdemo://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            println("Got the request token")
            var authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authURL!)
            
            }) { (error: NSError!) -> Void in
                println("Failed to get the request token")
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func openURL(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            
            println("Got the access token!")
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                var user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                self.loginCompletion?(user: user, error: nil)
                
                }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    println("Error getting current user")
                    self.loginCompletion?(user: nil, error: error)
            })
            }) { (error: NSError!) -> Void in
                println("Failed to get the access token")
                self.loginCompletion?(user: nil, error: error)
        }
    }
}

