//
//  ProfileCell.m
//  week3homework
//
//  Created by Weiyan Lin on 2/16/15.
//  Copyright (c) 2015 Weiyan Lin. All rights reserved.
//

#import "ProfileCell.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"


@interface ProfileCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerCountLabel;

@end

@implementation ProfileCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [[UIColor alloc ]initWithRed:(CGFloat)0.333
                                                  green:(CGFloat)0.67
                                                   blue:(CGFloat)0.93
                                                  alpha:(CGFloat)0.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) setUser:(User *)user{
    [self.profileView setImageWithURL:[NSURL URLWithString:user.profileImageUrl]];
    
    self.nameLabel.text = user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];
    
    
    // use friendly numbers like twitter
    self.tweetCountLabel.text = [self getFriendlyCount:user.tweetCount];
    self.followingCountLabel.text = [self getFriendlyCount:user.friendCount];
    self.followerCountLabel.text = [self getFriendlyCount:user.followerCount];
    
    
}

- (NSString *) getFriendlyCount:(NSInteger)count {
    if (count >= 1000000) {
        return [NSString stringWithFormat:@"%.1fM", (double)count / 1000000];
    } else if (count >= 10000) {
        return [NSString stringWithFormat:@"%.1fK", (double)count / 1000];
    } else if (count >= 1000) {
        return [NSString stringWithFormat:@"%ld,%ld", (long)count / 1000, (long)count % 1000];
    } else {
        return [NSString stringWithFormat:@"%ld", (long)count];
    }
}



@end
