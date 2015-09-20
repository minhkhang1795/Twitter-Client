//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Clover on 9/16/15.
//  Copyright (c) 2015 Clover. All rights reserved.
//

import UIKit

@objc protocol ComposeViewControllerDelegate {
    optional func composeViewController(composeViewController: ComposeViewController, didComposeTweet newTweet: Tweet)
}

class ComposeViewController: UIViewController, UITextViewDelegate {

    let maxCharacterAllowed = 140
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userScreenNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tweetButton: UIBarButtonItem!
    @IBOutlet weak var inReplyToLabel: UILabel!
    @IBOutlet weak var inReplyToView: UIImageView!
    
    weak var delegate: ComposeViewControllerDelegate?
    
    /* Determine whether user is replying or tweeting
    If user is replying to another tweet, then replyingTweet != nil */
    var replyingTweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customizeNavBar()
        customizeTweetView()
    }
    
    func customizeNavBar() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "TwitterLogo_white")
        self.navigationItem.titleView = imageView
        self.navigationItem.leftBarButtonItem?.image = UIImage(named: "back")
    }
    
    func customizeTweetView() {
        self.userImageView.setImageWithURL(User.currentUser!.profileImageURL)
        self.userImageView.layer.cornerRadius = 9.0
        self.userImageView.layer.masksToBounds = true
        self.userNameLabel.text = User.currentUser?.name
        self.userScreenNameLabel.text = User.currentUser!.screenname
        self.characterCountLabel.textColor = .lightGrayColor()
        self.textView.becomeFirstResponder()
        self.textView.delegate = self
        self.tweetButton.tintColor = .lightGrayColor()
        
        if replyingTweet != nil {
            let authorScreenName = replyingTweet!.user!.screenname
            let originAuthorScreenName = replyingTweet!.originauthorscreenname
            
            if originAuthorScreenName == nil {
                self.textView.text = "\(authorScreenName!) "
            } else {
                // Get retweeting author + original author's screen names
                self.textView.text = "\(authorScreenName!) \(originAuthorScreenName!) "
            }
            
            let authorName = replyingTweet!.user!.name
            inReplyToLabel.text = "In reply to \(authorName!)"
            inReplyToView.alpha = 1
            inReplyToLabel.alpha = 1
            
            let charactersRemaining = maxCharacterAllowed - count(self.textView.text)
            self.characterCountLabel.text = "\(charactersRemaining)"
        } else {
            inReplyToView.alpha = 0
            inReplyToLabel.alpha = 0
            self.characterCountLabel.text = "\(maxCharacterAllowed)"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        self.adjustScrollViewContentSize()
    }
    
    func textViewDidChange(textView: UITextView) {
        let tweetText = textView.text
        let charactersRemaining = maxCharacterAllowed - count(tweetText)
        self.characterCountLabel.text = "\(charactersRemaining)"
        self.characterCountLabel.textColor = charactersRemaining > 10 ? .lightGrayColor() : .redColor()
        self.tweetButton.tintColor = (count(tweetText) > 0 && count(tweetText) <= 140) ? .whiteColor() : .grayColor()
        self.adjustScrollViewContentSize()
    }
    

    @IBAction func onCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onTweet(sender: AnyObject) {
        let tweetText = self.textView.text
        
        if (count(tweetText) > 0 && count(tweetText) <= 140) {
            if replyingTweet != nil {
                // User is Replying
                TwitterClient.sharedInstance.replyTweetWithParam(tweetText, id: replyingTweet!.ID!, completion: { (tweet, error) -> () in
                    if let tweet = tweet {
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.delegate?.composeViewController?(self, didComposeTweet: tweet)
                        })
                    }
                    if error != nil {
                        NSLog("error posting status: \(error)")
                    }
                })
            
            } else {
                // User is Tweeting
                TwitterClient.sharedInstance.tweetWithParams(tweetText, completion: { (tweet, error) -> () in
                    if let tweet = tweet {
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.delegate?.composeViewController?(self, didComposeTweet: tweet)
                        })
                    }
                    if error != nil {
                        NSLog("error posting status: \(error)")
                    }
                })
            }
            
        }
    }
    
    func adjustScrollViewContentSize() {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.textView.frame.origin.y + self.textView.frame.size.height)
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
