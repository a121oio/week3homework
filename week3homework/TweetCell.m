//
//  TweetCell.m
//  TW33Tme
//
//  Created by Amie Kweon on 6/21/14.
//  Copyright (c) 2014 Amie Kweon. All rights reserved.
//

#import "TweetCell.h"
//#import "ComposeViewController.h"
#import "NSDate+DateTools.h"
#import "UIImageView+AFNetworking.h"




@interface TweetCell ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopSpace;
@property (weak, nonatomic) IBOutlet UIView *retweetView;

@end

@implementation TweetCell

@synthesize textLabel;
@synthesize imageView;

- (void)awakeFromNib
{
    CALayer *layer = [self.imageView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:7.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTweet:(Tweets *)tweet {
    UIImage *replyIcon = [UIImage imageNamed:@"ReplyIcon"];
    UIImage *retweetIcon = [UIImage imageNamed:@"RetweetIcon"];
    UIImage *favIcon = [UIImage imageNamed:@"FavIcon"];

    self.textLabel.text = [tweet text];
    self.nameLabel.text = [tweet user].name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@",[tweet user].screenName];
    [self.imageView setImageWithURL:[NSURL URLWithString:[tweet user].profileImageUrl]];
     
    //self.screenNameLabel.textColor = [Utils getTwitterGray];
    self.timeLabel.text = [tweet createdAT].shortTimeAgoSinceNow;
    
    //self.timeLabel.textColor = [Utils getTwitterGray];
    
    if (tweet.retweeted) {
        self.retweetView.hidden = NO;
        self.retweetLabel.text = [NSString stringWithFormat:@"%@ retweeted", tweet.user.name];
        [self.imageViewTopSpace setConstant:30];
        [self.viewTopSpace setConstant:30];
        //self.retweetLabel.textColor = [Utils getTwitterGray];
    } else {
        [self.imageViewTopSpace setConstant:8];
        [self.viewTopSpace setConstant:8];
        self.retweetView.hidden = YES;
    }

    // Reply button
    [self.replyButton setTitle:@"" forState:UIControlStateNormal];
    [self.replyButton setBackgroundImage:replyIcon forState:UIControlStateNormal];

    [self.retweetButton setTitle:@"" forState:UIControlStateNormal];
    [self.retweetButton setBackgroundImage:retweetIcon forState:UIControlStateNormal];

    [self.favoriteButton setTitle:@"" forState:UIControlStateNormal];
    [self.favoriteButton setBackgroundImage:favIcon forState:UIControlStateNormal];

    [self refreshView:tweet];
}

- (void)refreshView:(Tweets *)tweet {
    if (tweet.retweeted) {
        [self.retweetButton setAlpha:0.5];
    } else {
        [self.retweetButton setAlpha:1];
    }
    if (tweet.favorited) {
        [self.favoriteButton setAlpha:0.5];
    } else {
        [self.favoriteButton setAlpha:1];
    }
}
@end
