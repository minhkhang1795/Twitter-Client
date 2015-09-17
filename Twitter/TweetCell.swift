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
            userNameLabel.text = tweet.user?.name
            userScreenNameLabel.text = tweet.user?.screenname
            tweetLabel.text = tweet.text
            timeLabel.text = tweet.createdAtString
            retweetCountLabel.text = "\(tweet.retweetCount!)"
            favoriteCountLabel.text = "\(tweet.favoriteCount!)"
            if tweet.isFavorite == 1 {
                favoriteButton.setImage(UIImage(named: "star_gold"), forState: UIControlState.Normal)
            } else {
                favoriteButton.setImage(UIImage(named: "star_gray"), forState: UIControlState.Normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tweetLabel.sizeToFit()
        tweetLabel.preferredMaxLayoutWidth = tweetLabel.frame.size.width
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tweetLabel.sizeToFit()
        tweetLabel.preferredMaxLayoutWidth = tweetLabel.frame.size.width
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onFavorite(sender: UIButton) {
        var params: NSDictionary = ["id": tweet.ID!]
        TwitterClient.sharedInstance.favoriteTweetWithParams(params, isFavorited: tweet.isFavorite, completion: { (returnedTweet, error) -> () in
            if returnedTweet != nil {
                self.tweet.isFavorite = returnedTweet!.isFavorite
                if self.tweet.isFavorite == 1 {
                    sender.setImage(UIImage(named: "star_gold"), forState: UIControlState.Normal)
                    self.favoriteCountLabel.text = "\(++self.tweet.favoriteCount!)"
                } else {
                    sender.setImage(UIImage(named: "star_gray"), forState: UIControlState.Normal)
                    self.favoriteCountLabel.text = "\(--self.tweet.favoriteCount!)"
                }
            }
            if error != nil {
                NSLog("error tweeting: \(error)")
            }
        })
    }
    
}
