//
//  TwitterClient.swift
//  Twitter
//
//  Created by YouGotToFindWhatYouLove on 2/16/16.
//  Copyright © 2016 Candy. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let twitterConsumerKey = "qUWzB9zQEdLMLq0uv1jhKvL39"
let twitterConsumerSecret = "cnvltSyf0MuzGDnm7Y6Aif7fysfiBIYuUGKiTJi7iMUoMj0rGV"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1SessionManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        
        return Static.instance
    }
    
    func homeTimelineWithParams(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        var requestUrl = "1.1/statuses/home_timeline.json"
        if params != nil {
            let countParam = String(params!["count"] as! Int)
            requestUrl = "1.1/statuses/home_timeline.json?count=" + countParam
        }
        
        GET(requestUrl, parameters: params, success: {(operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweets: tweets, error: nil)
            
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error getting current user")
                completion(tweets: nil, error: error)
        })
        
    }
    
    func retweet(id: String, completion: () -> ()) {
        let requestUrl = "1.1/statuses/retweet/" + id + ".json"
        
        POST(requestUrl, parameters: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            completion()
            print("retweet succedded!")
        }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            print("retweet failed!")
        }
    }
    
    func unRetweet(id: String, completion: () -> ()) {
        let originalTweetId = id
        var requestUrl = "1.1/statuses/show.json?" + "include_my_retweet=1&id=" + originalTweetId
        
        GET(requestUrl, parameters: nil, success: {(task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let currentUserRetweet = response!["current_user_retweet"] as! NSDictionary
            let retweetId = currentUserRetweet["id_str"] as! String
            requestUrl = "1.1/statuses/destroy/" + retweetId + ".json"
            self.POST(requestUrl, parameters: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                completion()
                print("destroy succedded")
                }, failure: { (tasks: NSURLSessionDataTask?, errors: NSError) -> Void in
                    print("destroy failed")
            })
        
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print("UnRetweet unfailed")
        }
    }
    
    func tweet(var tweetText: String, replyToStatusId: String?, var tweets: [Tweet]?) {
        tweetText = tweetText.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        var requestUrl = "1.1/statuses/update.json?status="+"\(tweetText)"
        if let replyToStatusId = replyToStatusId {
            requestUrl = requestUrl + "&in_reply_to_status_id=" + replyToStatusId
        }
        print("requestUrl: \(requestUrl)")
        POST(requestUrl, parameters: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            print("tweet successful")
            tweets = [Tweet(dictionary: response as! NSDictionary)] + tweets!
            Tweet.kingTweets = tweets
            NSNotificationCenter.defaultCenter().postNotificationName("updated kingTweets", object: nil)

            print(Tweet.kingTweets)
            print("hello 1")
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print("tweet failed")
        }
    }
    
    func favorite(id: String, completion: () -> ()) {
        let requestUrl = "1.1/favorites/create.json?id=" + id
        
        POST(requestUrl, parameters: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            completion()
            print("favorite successful")
            
        }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            print("favorite failed")
        }
    }
    
    // unfavorite a tweet
    func unfavorite(id: String, completion: () -> ()) {
        let requestUrl = "1.1/favorites/destroy.json?id=" + id
        
        POST(requestUrl, parameters: nil, success: {(task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                completion()
                print("unfavorite successful")
            
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print("unfavorite failed")
                
        }
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        
        // Fetch request token & redirect to authorization page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "Get", callbackURL: NSURL(string: "cptwitterdemo://oauth"), scope: nil, success: {(requestToken: BDBOAuth1Credential!) -> Void in
            print("Got the request token")
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authURL!)
            
            }) {(error: NSError!) -> Void in
                print("Failed to get request token")
                self.loginCompletion?(user: nil, error: error)
        }
        
        
    }
    
    func openURL(url: NSURL) {
        
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: {(accessToken: BDBOAuth1Credential!) -> Void in
            print("Got the access token")
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            
            
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: {(operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in

                let user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                
                self.loginCompletion?(user: user, error: nil)
                }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                    print("error getting current user")
                    self.loginCompletion?(user: nil, error: error)
            })
            
            }) { (error: NSError!) -> Void in
                print("Failed to receive access token")
                self.loginCompletion?(user: nil, error: error)
        }
    }
    

}
