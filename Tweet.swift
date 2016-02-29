//
//  Tweet.swift
//  Twitter
//
//  Created by YouGotToFindWhatYouLove on 2/18/16.
//  Copyright © 2016 Candy. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var user: User?
    var text: String?
    var createdAtString: String?
    var createdAt: NSDate?
    var tweetId: String?
    var retweetCount: String?
    var favoriteCount: String?
    var favorited: Bool?
    var retweeted: Bool?
    var mediaImageUrl: String?
    
    init(var dictionary: NSDictionary) {
        if dictionary["retweeted_status"] != nil {
            dictionary = dictionary["retweeted_status"] as! NSDictionary
        }
        
        if let entities = dictionary["extended_entities"] as? NSDictionary {
            if let media = entities["media"] as? [NSDictionary] {
                let firstMedia = media[0] as! NSDictionary
                mediaImageUrl = firstMedia["media_url"] as? String
            }
        } else {
            mediaImageUrl = nil
        }
                        
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        createdAtString = dictionary["created_at"] as? String
        tweetId = dictionary["id_str"] as? String
        retweetCount = String(dictionary["retweet_count"] as! Int)
        favoriteCount = String(dictionary["favorite_count"] as! Int)
        if dictionary["favorited"] as! Int == 0 {
            favorited = false
        } else {
            favorited = true
        }
        
        if dictionary["retweeted"] as! Int == 0{
            retweeted = false
        } else {
            retweeted = true
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Month, .Day, .Year], fromDate: createdAt!)
        createdAtString = "\(components.month)/\(components.day)/\(components.year%2000)"
        
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
    

}
