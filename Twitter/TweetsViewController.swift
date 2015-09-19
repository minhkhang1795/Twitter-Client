//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Clover on 9/14/15.
//  Copyright (c) 2015 Clover. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ComposeViewControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var tweets: [Tweet]?
    var tweetCellShown = [Bool]()
    let refreshControl = UIRefreshControl()
    
    var tempTableFooter: UIView!
    var loadingState: UIActivityIndicatorView!
    var noMoreTweetLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeNavBar()
        customizeTableFooterView()
        self.fetchTweets()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 112
        self.refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.insertSubview(refreshControl, atIndex: 0)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func customizeNavBar() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "TwitterLogo_white")
        self.navigationItem.titleView = imageView
    }
    
    func customizeTableFooterView() {
        tempTableFooter = UIView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(view.frame), height: 40))
        loadingState = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadingState.center = tempTableFooter.center
        loadingState.hidden = true
        
        noMoreTweetLabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(view.frame), height: 40))
        noMoreTweetLabel.text = "No More Tweet"
        noMoreTweetLabel.textAlignment = .Center
        noMoreTweetLabel.center = tempTableFooter.center
        noMoreTweetLabel.hidden = true
        
        tempTableFooter.addSubview(loadingState)
        tempTableFooter.addSubview(noMoreTweetLabel)
        
        tableView.tableFooterView = tempTableFooter
    }

    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    // - Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
        cell.tweet = tweets![indexPath.row]
        
        if indexPath.row == tweets!.count - 1 {
            loadingState.startAnimating()
            noMoreTweetLabel.hidden = true
            fetchMoreTweets()
        } else {
            loadingState.stopAnimating()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if tweetCellShown[indexPath.row] == false {
            let rotateAnimation = CATransform3DTranslate(CATransform3DIdentity, +500, 10, -5)
            cell.layer.transform = rotateAnimation
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                cell.layer.transform = CATransform3DIdentity
            })
            tweetCellShown[indexPath.row] = true
        }
    }
   
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func fetchTweets() {
        TwitterClient.sharedInstance.homeTimelineWithParams(tweetCount: 20, maxID: nil, completion: { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            if tweets != nil {
                var totalTweet: Int = tweets!.count
                for indexNumber in 0...totalTweet {
                    self.tweetCellShown.append(false)
                }
            }
        })
    }
    
    func fetchMoreTweets() {
        var moreTweets: [Tweet]!
        if tweets!.count > 0 {
            var maxID = self.tweets![tweets!.count - 1].ID
            TwitterClient.sharedInstance.homeTimelineWithParams(tweetCount: 20, maxID: maxID, completion: { (tweets, error) -> () in
                if tweets == nil {
                    self.noMoreTweetLabel.hidden = false
                } else {
                    self.noMoreTweetLabel.hidden = true
                    for tweet in tweets! {
                        self.tweets?.append(tweet)
                        self.tweetCellShown.append(false)
                    }
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    // - Pull to refresh
    
    func onRefresh() {
        dispatch_async(dispatch_get_main_queue()) {
            self.fetchTweets()
            self.refreshControl.endRefreshing()
        }
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier != "tweetDetails" {
            // Update user's info if needed (for example: when user changes his profile picture on other devices)
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                var user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    println("Error getting current user")
            })
            
            let navigationController = segue.destinationViewController as! UINavigationController
            let composeViewController = navigationController.topViewController as! ComposeViewController
            composeViewController.delegate = self
            
            if segue.identifier == "replying" {
                if let replyingTweetCell = sender!.superview!!.superview as? TweetCell {
                    let replyingTweet = replyingTweetCell.tweet
                    composeViewController.replyingTweet = replyingTweet
                }
            }
            
        } else {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)!
            let tweet = tweets![indexPath.row]
            let tweetDetailsViewController = segue.destinationViewController as! TweetDetailsViewController
            tweetDetailsViewController.tweet = tweet

        }
    }
    
    func composeViewController(composeViewController: ComposeViewController, didComposeTweet newTweet: Tweet) {
        addNewTweet(newTweet)
    }
    
    func addNewTweet(newTweet: Tweet) {
        self.tweets?.insert(newTweet, atIndex: 0)
        self.tweetCellShown.insert(true, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }
}
