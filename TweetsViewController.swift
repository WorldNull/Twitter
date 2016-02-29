//
//  TweetsViewController.swift
//  Twitter
//
//  Created by YouGotToFindWhatYouLove on 2/20/16.
//  Copyright © 2016 Candy. All rights reserved.
//

import UIKit
import GIFRefreshControl

class TweetsViewController: UIViewController {

    var tweets: [Tweet]?
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    var refreshControl: GIFRefreshControl!
    var gifArray = ["giphy", "giphy1", "giphy2", "giphy3", "giphy4"]
    var gifIndex = 0
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
                
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        
        let URL = NSBundle.mainBundle().URLForResource(gifArray[gifIndex], withExtension: "gif")
        let data = NSData(contentsOfURL: URL!)
        
        refreshControl = GIFRefreshControl()
        refreshControl.animatedImage = GIFAnimatedImage(data: data!)
        refreshControl.contentMode = .ScaleAspectFill
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        TwitterClient.sharedInstance.homeTimelineWithParams(nil) { (tweets, error) -> () in
            self.tweets = tweets
            
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if let tweets = tweets {
            print("inside TweetsViewController\(tweets.count)")
        }
        
        tableView.reloadData()
    }
    
    func refresh() {
        delay(2, closure: {
           TwitterClient.sharedInstance.homeTimelineWithParams(nil) { (tweets, error) -> () in
                self.tweets = tweets
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                self.gifIndex = self.gifIndex + 1
            
                if self.gifIndex == 5 {
                    self.gifIndex = 0
                }
            
                let URL = NSBundle.mainBundle().URLForResource(self.gifArray[self.gifIndex], withExtension: "gif")
                let data = NSData(contentsOfURL: URL!)
                self.refreshControl.animatedImage = GIFAnimatedImage(data: data!)
            }
        })

    }
    
    @IBAction func composeMessage(sender: AnyObject) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("ComposePage") as! UINavigationController
        
        let ComposePageVc = controller.viewControllers[0] as! ComposePageViewController
        if let tweets = self.tweets {
            ComposePageVc.tweets = tweets
        }
        
        self.presentViewController(controller, animated: true, completion: nil)
        
    }

    
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func onRetweet(sender: AnyObject) {
        let retweetButton = sender as! UIButton
        let view = retweetButton.superview!
        let cell = view.superview?.superview?.superview?.superview?.superview as! TweetCell
        let tweetId = cell.tweetId
        
        if cell.retweeted == true {
            print("retweeted true")
            TwitterClient.sharedInstance.unRetweet(tweetId!) {
                let currentRetweetCount = Int(cell.retweetCountLabel.text!)!
                cell.retweetCountLabel.text = String(currentRetweetCount - 1)
                cell.reTweetButton.setImage(UIImage(named: "retweet"), forState: .Normal)
                cell.retweeted = false
            }
        } else {
            print("retweeted false")
            TwitterClient.sharedInstance.retweet(tweetId!) {
                () -> () in
                let currentRetweetCount = Int(cell.retweetCountLabel.text!)!
                cell.retweetCountLabel.text = String(currentRetweetCount + 1)
                cell.reTweetButton.setImage(UIImage(named: "onRetweet"), forState: .Normal)
                cell.retweeted = true
            }
            
        }
    }
    
    @IBAction func onReply(sender: AnyObject) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("ComposePage") as! UINavigationController
        let ComposePageVc = controller.viewControllers[0] as! ComposePageViewController
        
        if let tweets = self.tweets {
            ComposePageVc.tweets = tweets
        }
        
        let replyButton = sender as! UIButton
        let cell = replyButton.superview?.superview?.superview?.superview as! TweetCell
        ComposePageVc.replyToId = cell.tweetId
        ComposePageVc.toName = cell.screenNameLabel.text
        
        self.presentViewController(controller, animated: true, completion: nil)

        
        
        
    }
    
    @IBAction func onFavorite(sender: AnyObject) {
        let favoriteButton = sender as! UIButton
        let view = favoriteButton.superview!
        let cell = view.superview?.superview?.superview?.superview?.superview as! TweetCell
        let tweetId = cell.tweetId
        
        if cell.favorited == true {
            TwitterClient.sharedInstance.unfavorite(tweetId!) {
                () -> () in
                cell.favorited = false
                cell.favoriteButton.setImage(UIImage(named: "like"), forState: .Normal)
                let currentFavoriteCount = Int(cell.favoriteCountLabel.text!)
                cell.favoriteCountLabel.text = String(currentFavoriteCount! - 1)
                
            }

        } else {
            TwitterClient.sharedInstance.favorite(tweetId!) {
                () -> () in
                    let currentFavoriteCount = Int(cell.favoriteCountLabel.text!)
                    cell.favoriteCountLabel.text = String(currentFavoriteCount! + 1)
                    cell.favorited = true
                    cell.favoriteButton.setImage(UIImage(named: "onLike"), forState: .Normal)
            }
        }
    }
    
    
    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        print("segue worked")
        
        if (segue.identifier == "TweetDetails") {
            let cell = sender as! TweetCell
            let indexPath = tableView.indexPathForCell(cell)
            let tweet = tweets![indexPath!.row]
        
            let tweetDetailViewController = segue.destinationViewController as! TweetDetailsViewController
            tweetDetailViewController.tweet = tweet
            tweetDetailViewController.cell = cell
        }
        
        if (segue.identifier == "toProfile") {
            let gestureRecognizer = sender as! UITapGestureRecognizer
            let profileImageView = gestureRecognizer.view as! UIImageView
            let cell = profileImageView.superview?.superview as! TweetCell
            let indexPath = tableView.indexPathForCell(cell)
            let tweet = tweets![indexPath!.row]
            
            let profileVc = segue.destinationViewController as! profileViewController
            profileVc.user = tweet.user
        }
    }
}

extension TweetsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        let tweetInfo = tweets![indexPath.row]
        cell.accessoryType =  .None
        cell.profileImageView.setImageWithURL(NSURL(string: (tweetInfo.user?.profileImageUrl)!)!)
        cell.nameLabel.text = tweetInfo.user?.name
        cell.screenNameLabel.text = "@" + (tweetInfo.user?.screenname)!
        cell.createdAtLabel.text = tweetInfo.createdAtString
        cell.tweetTextLabel.text = tweetInfo.text
        cell.retweetCountLabel.text = tweetInfo.retweetCount!
        cell.favoriteCountLabel.text = tweetInfo.favoriteCount!
        cell.tweetId = tweetInfo.tweetId
        cell.favorited = tweetInfo.favorited
        cell.retweeted = tweetInfo.retweeted
        
        var imageToTextConstraint: NSLayoutConstraint!
        var reTweetToImageConstraint: NSLayoutConstraint!
        var leadingLedgeConstraint: NSLayoutConstraint!
        
        if let mediaImageUrl = tweetInfo.mediaImageUrl {
            
            cell.mediaImageView.setImageWithURL(NSURL(string: tweetInfo.mediaImageUrl!)!)

        } else {
            
            cell.mediaImageView.hidden = true
            
        }
        
        
        if cell.favorited == true {
            cell.favoriteButton.setImage(UIImage(named: "onLike"), forState: .Normal)
        } else {
            cell.favoriteButton.setImage(UIImage(named: "like"), forState: .Normal)
        }
        
        if cell.retweeted == true {
            cell.reTweetButton.setImage(UIImage(named: "onRetweet"), forState: .Normal)
        } else {
            cell.reTweetButton.setImage(UIImage(named: "retweet"), forState: .Normal)
        }
        
        // The onCustomTap: method will be defined in Step 3 below.
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onCustomTap:")
        
        // Optionally set the number of required taps, e.g., 2 for a double click
        tapGestureRecognizer.numberOfTapsRequired = 1;
        
        cell.profileImageView.userInteractionEnabled = true
        cell.profileImageView.addGestureRecognizer(tapGestureRecognizer)

        
        
        return cell
    }
    
    func onCustomTap(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier("toProfile", sender: sender)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = tweets {
            return tweets.count
        } else {
            return 0
        }
    
        
    }
}

extension TweetsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Handle scroll behavior here
        if (!isMoreDataLoading) {
            
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ... Code to load more results ...
                if let tweets = tweets {
                TwitterClient.sharedInstance.homeTimelineWithParams(["count": tweets.count+20]) { (tweets, error) -> () in
                    self.tweets = tweets
                    
                    // Update flag
                    self.isMoreDataLoading = false
                    
                    // Stop the loading indicator
                    self.loadingMoreView!.stopAnimating()
                    
                    self.tableView.reloadData()
 
                    
                    }
                } else {
                    self.loadingMoreView!.stopAnimating()
                }
            }
        
        }
        
        
    }
    
}
