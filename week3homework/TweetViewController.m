//
//  TweetViewController.m
//  twitter
//
//  Created by Vince Magistrado on 10/4/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "TweetViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ComposeViewController.h"
#import "TwitterClient.h"

@interface TweetViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *retweetView;
@property (weak, nonatomic) IBOutlet UILabel *retweetedByLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topProfileImageConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topNameConstraint;

@end

@implementation TweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set title
    self.navigationItem.title = @"Tweet";
    
    // add Reply button icon
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onReply)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    if (_tweet) {
        User *user = _tweet.user;
        Tweets *tweetToDisplay;
        
        if (_tweet.retweetedTweet) {
            tweetToDisplay = _tweet.retweetedTweet;
            self.retweetedByLabel.text = [NSString stringWithFormat:@"%@ retweeted", user.name];
            [self.retweetView setHidden:NO];
            [self.retweetedByLabel setHidden:NO];
            // update constraints dynamically
            self.topProfileImageConstraint.constant = 32;
            self.topNameConstraint.constant = 32;
        } else {
            tweetToDisplay = _tweet;
            [self.retweetView setHidden:YES];
            [self.retweetedByLabel setHidden:YES];
            self.topProfileImageConstraint.constant = 16;
            self.topNameConstraint.constant = 16;
        }
        
        // rounded corners for profile images
        CALayer *layer = [self.profileImageView layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:3.0];
        [self.profileImageView setImageWithURL:[NSURL URLWithString:tweetToDisplay.user.profileImageUrl]];

        self.nameLabel.text = tweetToDisplay.user.name;
        self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", tweetToDisplay.user.screenName];
        self.tweetLabel.text = tweetToDisplay.text;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"M/d/yy, h:mm a"];
        self.timestampLabel.text = [dateFormat stringFromDate:tweetToDisplay.createdAT];
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_tweet.retweetCount];
        self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweetToDisplay.favouritesCount];
        
        // set action button highlight states
        [self highlightButton:self.retweetButton highlight:_tweet.retweeted];
        [self highlightButton:self.favoriteButton highlight:_tweet.favorited];
        
        // if this tweet has no id, then disable all actions
        UIImage *replyIcon = [UIImage imageNamed:@"ReplyIcon"];
        UIImage *retweetIcon = [UIImage imageNamed:@"RetweetIcon"];
        UIImage *favIcon = [UIImage imageNamed:@"FavIcon"];
        
        [self.replyButton setTitle:@"" forState:UIControlStateNormal];
        [self.replyButton setBackgroundImage:replyIcon forState:UIControlStateNormal];
        
        [self.retweetButton setTitle:@"" forState:UIControlStateNormal];
        [self.retweetButton setBackgroundImage:retweetIcon forState:UIControlStateNormal];
        
        [self.favoriteButton setTitle:@"" forState:UIControlStateNormal];
        [self.favoriteButton setBackgroundImage:favIcon forState:UIControlStateNormal];
        
        // if this is the user's own tweet, disable retweet
        if (!_tweet.retweetedTweet && [[[User currentUser] screenName] isEqualToString:user.screenName]) {
            self.retweetButton.enabled = NO;
        }
    }
     [self refreshView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onReply {
    
    ComposeViewController *composeViewController = [[ComposeViewController alloc] init];
    composeViewController.replyTo = _tweet;
    UINavigationController *navBar = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [self presentViewController:navBar animated:YES completion:nil];
}



- (void)setTweet:(Tweets *)tweet {
    _tweet = tweet;
}

- (IBAction)onReply:(id)sender {
    [self onReply];
}

- (IBAction)onRetweet:(id)sender {
    [_tweet retweet];
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_tweet.retweetCount];
    [self highlightButton:self.retweetButton highlight:_tweet.retweeted];
    [self.delegate didRetweet:_tweet.retweeted];
    [self refreshView];
    
}

- (IBAction)onFavorite:(id)sender {
    // favorite the original tweet if applicable
    Tweets *tweetToFavorite;
    if (_tweet.retweetedTweet) {
        tweetToFavorite = _tweet.retweetedTweet;
    } else {
        tweetToFavorite = _tweet;
    }
    
    BOOL favorited = [tweetToFavorite favorite];
    
    // favorite/unfavorite the source
    if (_tweet.retweetedTweet) {
        _tweet.favorited = favorited;
    }
    
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweetToFavorite.favouritesCount];
    [self highlightButton:self.favoriteButton highlight:favorited];
    [self.delegate didFavorite:favorited];
    [self refreshView ];
    
}

- (void)highlightButton:(UIButton *)button highlight:(BOOL)highlight {
    if (highlight) {
        [button setSelected:YES];
    } else {
        [button setSelected:NO];
    }
}

- (void) didTweet:(Tweets *)tweet {
    [self.delegate didReply:tweet];
}

- (void)refreshView {
    if (_tweet.retweeted) {
        [self.retweetButton setAlpha:1];
    } else {
        [self.retweetButton setAlpha:0.5];
    }
    if (_tweet.favorited) {
        [self.favoriteButton setAlpha:1];
    } else {
        [self.favoriteButton setAlpha:0.5];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
