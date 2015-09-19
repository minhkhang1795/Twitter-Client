//
//  TweetDetailsViewController.swift
//  Twitter
//
//  Created by Clover on 9/19/15.
//  Copyright (c) 2015 Clover. All rights reserved.
//

import UIKit

class TweetDetailsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userScreenNameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    
    var tweet: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        userImageView.setImageWithURL(tweet.user?.profileImageURL)
        userImageView.layer.cornerRadius = 9.0
        userImageView.layer.masksToBounds = true
        userNameLabel.text = tweet.user?.name
        userScreenNameLabel.text = tweet.user?.screenname
        tweetLabel.text = tweet.text
        
        var createdAtStringformatter = NSDateFormatter()
        createdAtStringformatter.dateFormat = "HH:mm MM/dd/yyyy"
        timeLabel.text = createdAtStringformatter.stringFromDate(tweet.createdAt!)
        
        retweetCountLabel.text = String(format:"%.0f", tweet.retweetCount!)
        favoriteCountLabel.text = String(format:"%.0f", tweet.favoriteCount!)
        
        if tweet.isFavorite == true {
            self.favoriteButton.setImage(UIImage(named: "favorite_on"), forState: UIControlState.Normal)
        } else {
            self.favoriteButton.setImage(UIImage(named: "favorite_off"), forState: UIControlState.Normal)
        }
        
        if tweet.isRetweeted == true {
            self.retweetButton.setImage(UIImage(named: "retweet_on"), forState: UIControlState.Normal)
        } else {
            self.retweetButton.setImage(UIImage(named: "retweet_off"), forState: UIControlState.Normal)
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
