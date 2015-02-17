//
//  tweetsViewController.m
//  week3homework
//
//  Created by Weiyan Lin on 2/8/15.
//  Copyright (c) 2015 Weiyan Lin. All rights reserved.
//

#import "tweetsViewController.h"
#import "User.h"
#import "TwitterClient.h"
#import "Tweets.h"
#import "TweetCell.h"
#import "UIView+SuperView.h"
#import "ComposeViewController.h"
#import "MTLJSONAdapter.h"
#import "TweetViewController.h"
#import "ProfileViewController.h"

@interface tweetsViewController () <UITableViewDelegate,UITableViewDataSource,TweetCellDelegate>

@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *twTableView;
@property (strong, nonatomic) NSArray *tweets;

@end

@implementation tweetsViewController

- (void)onLogout {
    
    [User logout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.twTableView.dataSource = self;
    self.twTableView.delegate = self;
    self.refreshControl = [[UIRefreshControl alloc]init];
    
    [self.refreshControl addTarget:self action:@selector(refreshList) forControlEvents:UIControlEventValueChanged];
    self.title = @"Tweeter";
    [self.twTableView insertSubview:self.refreshControl atIndex:0];
    self.tweets = [NSMutableArray array];
    
    [self.twTableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
    /* setup navigation left Button */
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(onPostButton)];
    
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];

    self.navigationItem.rightBarButtonItem.tintColor=[UIColor whiteColor];
    self.navigationItem.leftBarButtonItem.tintColor=[UIColor whiteColor];

    
    
    /* setup navigation Bar */
    self.title = @"Twitter";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [[UIColor alloc ]initWithRed:(CGFloat)0.333
                                                                                  green:(CGFloat)0.67
                                                                                   blue:(CGFloat)0.93
                                                                                  alpha:(CGFloat)0.0];
    self.navigationController.navigationBar.translucent = NO;

    
    [self refreshList];
    [self.twTableView reloadData];
   
    
}

- (void)onProfile:(User *)user {
    ProfileViewController *pvc = [[ProfileViewController alloc] init];
    [pvc setUser:user];
    [self.navigationController pushViewController:pvc animated:YES];
}

- (void)didReply:(Tweets *)tweet {
   
}

- (void)didRetweet:(BOOL)didRetweet {
    [self.twTableView reloadData];
}

- (void)didFavorite:(BOOL)didFavorite {
    [self.twTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(void) onPostButton{
    
    ComposeViewController *cv = [[ComposeViewController alloc]init];
    
    UINavigationController *navBar = [[UINavigationController alloc]initWithRootViewController:cv];
    
    [self presentViewController:navBar animated:YES completion:nil];
    
    
}

-(void) refreshList{
    
    [[TwitterClient sharedInstance] homeTimeLineWithParams:nil completion:^(NSArray *tweets, NSError *error) {

        if(tweets == nil){
            
        } else {
            
            self.tweets = [[NSArray alloc]initWithArray:tweets];
            

            [self.twTableView reloadData];
            NSLog(@"%@",self.tweets);
        }
        
        [self.refreshControl endRefreshing];
        
        
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 20;
    
}

- (void)configureCell:(TweetCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.tweet = self.tweets[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // unhighlight selection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TweetViewController *vc = [[TweetViewController alloc] init];
    vc.delegate = self;
    vc.tweet = self.tweets[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    [cell.replyButton addTarget:self action:@selector(replyButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    [cell.retweetButton addTarget:self action:@selector(retweetButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    [cell.favoriteButton addTarget:self action:@selector(favoriteButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    
    if ([self.tweets count] != 0){
    //Tweets *tweet = self.tweets[indexPath.row];
        
    //NSLog(@"text: %@",tweet.text);
        [self configureCell:cell atIndexPath:indexPath];
        
    }
    [cell refreshView:cell.tweet];
    cell.delegate = self;
    return cell;
}



- (void)replyButtonClicked:(id)sender {
    TweetCell *cell = (TweetCell *)[sender findSuperViewWithClass:[TweetCell class]];
    
    NSIndexPath *indexPath = [self.twTableView indexPathForCell: cell];
    
    ComposeViewController *composeViewController = [[ComposeViewController alloc] init];
    composeViewController.replyTo = self.tweets[indexPath.row];
    UINavigationController *navBar = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [self presentViewController:navBar animated:YES completion:nil];
    
}


- (void)retweetButtonClicked:(id)sender {
    TweetCell *cell = (TweetCell *)[sender findSuperViewWithClass:[TweetCell class]];
    NSIndexPath *indexPath = [self.twTableView indexPathForCell: cell];
    
    Tweets *currentTweet = self.tweets[indexPath.row];
    TwitterClient *client = [TwitterClient sharedInstance];
    NSString *retweetId = [currentTweet user].dictionary[@"id_str"];
    
    if (currentTweet.retweeted) {
        
        
        [client destroy:currentTweet.retweetIdStr completion:nil];
        currentTweet.retweeted = NO;
        currentTweet.retweetCount -= 1;
        currentTweet.retweetIdStr =@"";
        
        } else {
            
            [client retweet:retweetId  completion:nil];
            
            currentTweet.retweetIdStr = retweetId;
            currentTweet.retweeted = YES;
            currentTweet.retweetCount += 1;
        }
    [cell refreshView:currentTweet];
    
}


//- (void)updateCount {
//    self.retweetCountLabel.text = [NSString stringWithFormat:@"%d", self.tweet.retweetCount];
//    self.retweetWordLabel.text = (self.tweet.retweetCount > 2) ? @"RETWEETS" : @"RETWEET";
//    self.retweetWordLabel.textColor = [Utils getTwitterGray];
//    
//    self.favoritesCountLabel.text = [NSString stringWithFormat:@"%d", self.tweet.favouritesCount];
//    self.favoritesWordLabel.text = (self.tweet.favouritesCount > 2) ? @"FAVORITES" : @"FAVORITE";
//    self.favoritesWordLabel.textColor = [Utils getTwitterGray];
//    
//    if (self.tweet.retweeted) {
//        [self.retweetButton setAlpha:0.5];
//    } else {
//        [self.retweetButton setAlpha:1];
//    }
//    if (self.tweet.favorited) {
//        [self.favoriteButton setAlpha:0.5];
//    } else {
//        [self.favoriteButton setAlpha:1];
//    }
//}


- (void)favoriteButtonClicked:(id)sender {
    TweetCell *cell = (TweetCell *)[sender findSuperViewWithClass:[TweetCell class]];
    NSIndexPath *indexPath = [self.twTableView indexPathForCell: cell];
    
    
    TwitterClient *client = [TwitterClient sharedInstance];
    [self.tweets[indexPath.row] setFavorited:! [self.tweets[indexPath.row] favorited]];
    if ([self.tweets[indexPath.row] favorited]) {
        [client favorite:[self.tweets[indexPath.row] IdStr] completion:^(NSError *error) {
            NSLog(@"[HomeViewController favorite] failure: %@", error.description);
        }];
        } else {
            [client unfavorite:[self.tweets[indexPath.row] IdStr] completion:^(NSError *error) {
                NSLog(@"[HomeViewController favorite] failure: %@", error.description);
            }];

                }
    
    [cell refreshView:self.tweets[indexPath.row]];
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
