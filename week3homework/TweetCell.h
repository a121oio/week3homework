//
//  TweetCell.h
//  TW33Tme
//
//  Created by Amie Kweon on 6/21/14.
//  Copyright (c) 2014 Amie Kweon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweets.h"


@protocol TweetCellDelegate <NSObject>

- (void)onProfile:(User *)user;

@end

@interface TweetCell : UITableViewCell

@property (strong, nonatomic) Tweets *tweet;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *profile;

- (void)refreshView:(Tweets *)tweet;

@property (nonatomic, weak) id <TweetCellDelegate> delegate;

@end
