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



@interface tweetsViewController () <UITableViewDelegate,UITableViewDataSource>

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
    
   
    return cell;
}


/*
- (void)replyButtonClicked:(id)sender {
    TweetCell *cell = (TweetCell *)[sender findSuperViewWithClass:[TweetCell class]];
    
    NSIndexPath *indexPath = [self.twTableView indexPathForCell: cell];
    
    //ComposeViewController *composeViewController = [[ComposeViewController alloc] init];
    //composeViewController.replyTo = self.tweets[indexPath.row];
    UINavigationController *navBar = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [self presentViewController:navBar animated:YES completion:nil];
}

- (void)retweetButtonClicked:(id)sender {
    TweetCell *cell = (TweetCell *)[sender findSuperViewWithClass:[TweetCell class]];
    NSIndexPath *indexPath = [self.twTableView indexPathForCell: cell];
    
    Tweets *currentTweet = self.tweets[indexPath.row];
    TwitterClient *client = [TwitterClient instance];
    if (currentTweet.retweeted) {
        NSNumber *retweetId = currentTweet.id;
        if (currentTweet.retweetedStatus) {
            retweetId = currentTweet.retweetedStatus.id;
        }
        [client destroyWithId:retweetId
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          NSLog(@"[HomeViewController retweet destroy] success");
                          currentTweet.retweeted = NO;
                          currentTweet.retweetCount -= 1;
                          [cell refreshView:currentTweet];
                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          NSLog(@"[HomeViewController retweet destroy] failure: %@", error.description);
                      }];
    } else {
        [client retweetWithId:currentTweet.id
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          NSLog(@"[HomeViewController retweet] success");
                          currentTweet.retweeted = YES;
                          currentTweet.retweetCount += 1;
                          currentTweet.retweetedStatus = [MTLJSONAdapter modelOfClass:Tweet.class fromJSONDictionary:responseObject error:nil];
                          [cell refreshView:currentTweet];
                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          NSLog(@"[HomeViewController retweet] failure: %@", error.description);
                      }];
    }
}


- (void)favoriteButtonClicked:(id)sender {
    TweetCell *cell = (TweetCell *)[sender findSuperViewWithClass:[TweetCell class]];
    NSIndexPath *indexPath = [self.tableView indexPathForCell: cell];
    
    Tweet *currentTweet = self.tweets[indexPath.row];
    TwitterClient *client = [TwitterClient instance];
    if (currentTweet.favorited) {
        [client removeFavoriteWithId:currentTweet.id
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 NSLog(@"[HomeViewController unfavorite] success");
                                 currentTweet.favorited = NO;
                                 currentTweet.favouritesCount -= 1;
                                 [cell refreshView:currentTweet];
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"[HomeViewController unfavorite] failure: %@", error.description);
                             }];
    } else {
        [client favoriteWithId:currentTweet.id
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           NSLog(@"[HomeViewController favorite] success");
                           currentTweet.favorited = YES;
                           currentTweet.favouritesCount += 1;
                           [cell refreshView:currentTweet];
                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           NSLog(@"[HomeViewController favorite] failure: %@", error.description);
                       }];
    }
}
*/


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
