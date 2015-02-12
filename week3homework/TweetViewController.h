//
//  TweetViewController.h
//  twitter
//
//  Created by Vince Magistrado on 10/4/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweets.h"
#import "ComposeViewController.h"

@protocol TweetViewControllerDelegate <NSObject>

- (void)didReply:(Tweets *)tweet;
- (void)didRetweet:(BOOL)didRetweet;
- (void)didFavorite:(BOOL)didFavorite;

@end

@interface TweetViewController : UIViewController <ComposeViewControllerDelegate>

@property (nonatomic, strong) Tweets *replyToTweet;
@property (nonatomic, strong) Tweets *tweet;

@property (nonatomic, weak) id <TweetViewControllerDelegate> delegate;

@end
