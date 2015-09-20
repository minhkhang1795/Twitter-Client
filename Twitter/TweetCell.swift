//
//  TweetCell.swift
//  Twitter
//
//  Created by Clover on 9/14/15.
//  Copyright (c) 2015 Clover. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

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
    
    var tweet: Tweet! {
        didSet {
            userImageView.setImageWithURL(tweet.user?.profileImageURL)
            userImageView.layer.cornerRadius = 9.0
            userImageView.layer.masksToBounds = true
            userNameLabel.text = tweet.user?.name
            userScreenNameLabel.text = tweet.user?.screenname
            tweetLabel.text = tweet.text
            timeLabel.text = tweet.createdAtString
            
            if tweet.retweetCount >= 1000 {
                retweetCountLabel.text = String(format:"%.1fk", tweet.retweetCount!/1000)
            } else {
                retweetCountLabel.text = String(format:"%.0f", tweet.retweetCount!)
            }
            
            if tweet.favoriteCount >= 1000 {
                favoriteCountLabel.text = String(format:"%.1fk", tweet.favoriteCount!/1000)
            } else {
                favoriteCountLabel.text = String(format:"%.0f", tweet.favoriteCount!)
            }
            
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
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tweetLabel.preferredMaxLayoutWidth = tweetLabel.frame.size.width
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tweetLabel.preferredMaxLayoutWidth = tweetLabel.frame.size.width
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onFavorite(sender: UIButton) {
        let id = tweet.ID!
        TwitterClient.sharedInstance.favoriteTweetWithParams(id, isFavorited: tweet.isFavorite, completion: { (returnedTweet, error) -> () in
            if error == nil {
                if self.tweet.isFavorite == false {
                    UIView.animateWithDuration(2.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                        sender.transform = CGAffineTransformMakeScale(2, 2)
                        sender.transform = CGAffineTransformMakeScale(1, 1)
                        sender.setImage(UIImage(named: "favorite_on"), forState: UIControlState.Normal)
                        }, completion: nil)
                    if self.tweet.favoriteCount >= 1000 {
                        self.favoriteCountLabel.text = String(format:"%.1fk", ++self.tweet.favoriteCount!/1000)
                    } else {
                        self.favoriteCountLabel.text = String(format:"%.0f", ++self.tweet.favoriteCount!)
                    }
                    self.tweet.isFavorite = true
                } else {
                    UIView.animateWithDuration(2.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                        sender.transform = CGAffineTransformMakeScale(2, 2)
                        sender.transform = CGAffineTransformMakeScale(1, 1)
                        sender.setImage(UIImage(named: "favorite_off"), forState: UIControlState.Normal)
                        }, completion: nil)
                    if self.tweet.favoriteCount >= 1000 {
                        self.favoriteCountLabel.text = String(format:"%.1fk", --self.tweet.favoriteCount!/1000)
                    } else {
                        self.favoriteCountLabel.text = String(format:"%.0f", --self.tweet.favoriteCount!)
                    }
                    self.tweet.isFavorite = false
                }
            } else {
                NSLog("error tweeting: \(error)")
            }
        })
    }
    
    @IBAction func onRetweet(sender: UIButton) {

        TwitterClient.sharedInstance.retweetWithParams(tweet.ID, isRetweeted: tweet.isRetweeted, completion: { (returnedTweet, error) -> () in
            if error == nil {
                if self.tweet.isRetweeted == false {
                    UIView.animateWithDuration(2.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                        sender.transform = CGAffineTransformMakeScale(2, 2)
                        sender.transform = CGAffineTransformMakeScale(1, 1)
                        sender.setImage(UIImage(named: "retweet_on"), forState: UIControlState.Normal)
                        }, completion: nil)
                    if self.tweet.retweetCount >= 1000 {
                        self.retweetCountLabel.text = String(format:"%.1fk", ++self.tweet.retweetCount!/1000)
                    } else {
                        self.retweetCountLabel.text = String(format:"%.0f", ++self.tweet.retweetCount!)
                    }
                    self.tweet.isRetweeted = true
                } else {
                    UIView.animateWithDuration(2.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                        sender.transform = CGAffineTransformMakeScale(2, 2)
                        sender.transform = CGAffineTransformMakeScale(1, 1)
                        sender.setImage(UIImage(named: "retweet_off"), forState: UIControlState.Normal)
                        }, completion: nil)
                    if self.tweet.retweetCount >= 1000 {
                        self.retweetCountLabel.text = String(format:"%.1fk", --self.tweet.retweetCount!/1000)
                    } else {
                        self.retweetCountLabel.text = String(format:"%.0f", --self.tweet.retweetCount!)
                    }
                    self.tweet.isRetweeted = false
                }
            } else {
                NSLog("error tweeting: \(error)")
            }
        })

    }
}
