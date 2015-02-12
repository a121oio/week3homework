//
//  ComposeViewController.h
//  TW33Tme
//
//  Created by Amie Kweon on 6/21/14.
//  Copyright (c) 2014 Amie Kweon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweets.h"
@protocol ComposeViewControllerDelegate <NSObject>

- (void)didTweet:(Tweets *)tweet;

@optional
- (void)didTweetSuccessfully;

@end



@interface ComposeViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) Tweets *replyTo;
@property (nonatomic, strong) Tweets *replyToTweet;

@property (nonatomic, weak) id <ComposeViewControllerDelegate> delegate;

@end
