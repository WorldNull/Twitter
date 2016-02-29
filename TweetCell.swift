//
//  TweetCell.swift
//  Twitter
//
//  Created by YouGotToFindWhatYouLove on 2/21/16.
//  Copyright © 2016 Candy. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var screenNameLabel: UILabel!

    @IBOutlet weak var createdAtLabel: UILabel!
    
    @IBOutlet weak var tweetTextLabel: UITextView!
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    @IBOutlet weak var reTweetButton: UIButton!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var mediaImageView: UIImageView!
    
    
    var favorited: Bool!
    var retweeted: Bool!
    var tweetId: String!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //tweetTextLabel.delegate = self
        tweetTextLabel.scrollEnabled = false
        tweetTextLabel.textContainerInset = UIEdgeInsetsZero;
        tweetTextLabel.textContainer.lineFragmentPadding = 0;
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

/*
extension TweetCell: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame;
    }
}
*/

