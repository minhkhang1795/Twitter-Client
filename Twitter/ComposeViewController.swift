//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Clover on 9/16/15.
//  Copyright (c) 2015 Clover. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UITextViewDelegate {

    let maxCharacterAllowed = 140
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userScreenNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tweetButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.userImageView.setImageWithURL(User.currentUser!.profileImageURL)
        self.userImageView.layer.cornerRadius = 9.0
        self.userImageView.layer.masksToBounds = true
        self.userNameLabel.text = User.currentUser?.name
        self.userScreenNameLabel.text = User.currentUser!.screenname
        self.characterCountLabel.text = "\(maxCharacterAllowed)/140"
        self.characterCountLabel.textColor = .lightGrayColor()
        self.textView.becomeFirstResponder()
        self.textView.delegate = self
        self.tweetButton.tintColor = .lightGrayColor()
        
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
        self.characterCountLabel.text = "\(charactersRemaining)/140"
        self.characterCountLabel.textColor = charactersRemaining >= 0 ? .lightGrayColor() : .redColor()
        self.tweetButton.tintColor = charactersRemaining == 140 ? .lightGrayColor() : self.view.tintColor
        self.adjustScrollViewContentSize()
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidShowNotification, object: nil, queue: nil) { (notification: NSNotification!) -> Void in
            let userInfo = notification.userInfo!
            let keyboardFrameEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            self.view.frame = CGRectMake(0, 0, keyboardFrameEnd.size.width, keyboardFrameEnd.origin.y)
        }
    }

    @IBAction func onCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onTweet(sender: AnyObject) {
        let tweet = self.textView.text
        if (count(tweet) != 0) {
            var params: NSDictionary = ["status": tweet]
            
            TwitterClient.sharedInstance.tweetWithParams(params, completion: { (status, error) -> () in
                if error != nil {
                    NSLog("error posting status: \(error)")
                }
                NSNotificationCenter.defaultCenter().postNotificationName("StatusPosted", object: status)
                self.dismissViewControllerAnimated(true, completion: nil)
            })

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
