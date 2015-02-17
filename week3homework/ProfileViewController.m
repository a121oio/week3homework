//
//  ProfileViewController.m
//  twitter
//
//  Created by Vince Magistrado on 10/11/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "ProfileViewController.h"
#import "ComposeViewController.h"
#import "ProfileCell.h"
#import "TwitterClient.h"
#import "TweetCell.h"
#import "tweetViewController.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgImageTopConstraint;

@property (strong, nonatomic) NSArray *tweets;
@property (strong, nonatomic) UIRefreshControl *refreshTweetsControl;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    User *user = self.user ? self.user : [User currentUser];
    
    // profile view via profile image
    if (!self.user) {
        // add Sign Out button
        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];
        self.navigationItem.leftBarButtonItem = leftBarButton;
        
        // set up title with long press gesture recognizer
        UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
        navLabel.text = user.name;
        navLabel.textAlignment = NSTextAlignmentCenter;
        navLabel.textColor = [UIColor whiteColor];
        navLabel.font = [UIFont boldSystemFontOfSize:17.0f];    // default font for consistency
        [navLabel setUserInteractionEnabled:YES];
        self.navigationItem.titleView = navLabel;
    
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onNavBarLongPress)];
    
        [navLabel addGestureRecognizer:longPressGestureRecognizer];
    } else {
        self.navigationItem.title = user.name;
    }
    
//    // use banner url if provided, or profile bg url
//    NSString *bannerUrl = user.bannerUrl ? [NSString stringWithFormat:@"%@/mobile_retina", user.bannerUrl] : user.backgroundImageUrl;
//    
//    [self.bgView setImageWithURL:[NSURL URLWithString:bannerUrl]];
    
    // add New button icon
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(post)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    // register profile cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileCell" bundle:nil] forCellReuseIdentifier:@"ProfileCell"];
    
    // register tweet cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 105;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // add pull to refresh tweets control
    self.refreshTweetsControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshTweetsControl];
    [self.refreshTweetsControl addTarget:self action:@selector(refreshProfile) forControlEvents:UIControlEventValueChanged];
    

    if (user) {
        [self refreshProfile];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // unhighlight selection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // do nothing if profile cell
    if (indexPath.row == 0) {
        return;
    }
    
    TweetViewController *vc = [[TweetViewController alloc] init];
    vc.delegate = self;
    vc.tweet = self.tweets[indexPath.row - 1];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 ) {
        ProfileCell *profileCell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
        User *user;
    
        if (self.user) {
            user = self.user;
        } else {
            user = [User currentUser];
        }
        
        [profileCell setUser:user];
        
        // to handle page change event

    
        return profileCell;
    } else {
        TweetCell *tweetCell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
        tweetCell.tweet = self.tweets[indexPath.row - 1];
        tweetCell.delegate = self;

        // if data for the last cell is requested, then obtain more data
        if (indexPath.row == self.tweets.count - 1) {
            NSLog(@"End of list reached...");
            [self getMoreTweets];
        }
        
        return tweetCell;
    }
}

- (void)didTweet:(Tweets *)tweet {
    // only add if own tweet
    if (!self.user) {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:self.tweets];
        [temp insertObject:tweet atIndex:0];
        self.tweets = [temp copy];
        [self.tableView reloadData];
    }
}

- (void)didTweetSuccessfully {
    // so a newly generated tweet can be replied or favorited
    [self.tableView reloadData];
}

- (void)refreshProfile {
    [[TwitterClient sharedInstance] userTimelineWithParams:nil user:self.user completion:^(NSArray *tweets, NSError *error) {
        if (error) {
            NSLog([NSString stringWithFormat:@"Error getting user timeline, too many requests?: %@", error]);
        } else {
            self.tweets = tweets;
            [self.tableView reloadData];
        }
        [self.refreshTweetsControl endRefreshing];
        [self.bgView setHidden:NO];
        [self.tableView setHidden:NO];
    }];
}

- (void)onLogout {
    [User logout];
}

- (void)post{
    ComposeViewController *vc = [[ComposeViewController alloc] init];
    
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    nvc.navigationBar.translucent = NO;
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void)didReply:(Tweets *)tweet {
    [self didTweet:tweet];
}

- (void)didRetweet:(BOOL)didRetweet {
    [self.tableView reloadData];
}

- (void)didFavorite:(BOOL)didFavorite {
    [self.tableView reloadData];
}

- (void) getMoreTweets {
    // if no previous max id str available, then don't do anything
    NSString *maxIdStr = [self.tweets[self.tweets.count - 1] IdStr];
    if (!maxIdStr) {
        return;
    }
    [[TwitterClient sharedInstance] userTimelineWithParams:@{ @"max_id": maxIdStr} user:self.user completion:^(NSArray *tweets, NSError *error) {
        // reload only if there is more data
        if (error) {
            NSLog([NSString stringWithFormat:@"Error getting more tweets, too many requests?: %@", error]);
        } else if (tweets.count > 0) {
            // ignore duplicate requests
            if ([[tweets[tweets.count - 1] IdStr] isEqualToString:[self.tweets[self.tweets.count - 1] IdStr]]) {
                NSLog(@"Ignoring duplicate data");
            } else {
                NSLog([NSString stringWithFormat:@"Got %lu more tweets", (unsigned long)tweets.count]);
                NSMutableArray *temp = [NSMutableArray arrayWithArray:self.tweets];
                [temp addObjectsFromArray:tweets];
                self.tweets = [temp copy];
                [self.tableView reloadData];
            }
        } else {
            NSLog(@"No more tweets retrieved");
        }
    }];
}

- (void)onReply:(TweetCell *)tweetCell {
    ComposeViewController *vc = [[ComposeViewController alloc] init];
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    nvc.navigationBar.translucent = NO;
    // set reply to tweet property
    vc.replyToTweet = tweetCell.tweet;
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void)onProfile:(User *)user {
    
    ProfileViewController *pvc = [[ProfileViewController alloc] init];
    [pvc setUser:user];
    [self.navigationController pushViewController:pvc animated:YES];
}


- (void)pageChanged:(UIPageControl *)pageControl {
    if (pageControl.currentPage == 0) {
        [UIView animateWithDuration:.24 animations:^{
            self.bgView.alpha = 1;
            self.bgImageHeightConstraint.constant = 80;
            [self.view layoutIfNeeded];
        }];
    } else {
        [UIView animateWithDuration:.24 animations:^{
            self.bgView.alpha = .5;
            self.bgImageHeightConstraint.constant = 100;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)onNavBarLongPress {
    [self.delegate onPullForAccounts];
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
