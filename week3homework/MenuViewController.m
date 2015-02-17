//
//  MenuViewController.m
//  twitter
//
//  Created by Vince Magistrado on 10/11/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "MenuViewController.h"
#import "ProfileViewController.h"
#import "tweetsViewController.h"
#import "MentionsViewController.h"
#import "TwitterClient.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *accountsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewYConstraint;
@property (strong, nonatomic) UIColor *twitter;
@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) UIViewController *currentVC;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set bg color
    self.view.backgroundColor = [[UIColor alloc ]initWithRed:(CGFloat)0.333
                                                       green:(CGFloat)0.67
                                                        blue:(CGFloat)0.93
                                                       alpha:(CGFloat)1.0];;
    _twitter = [[UIColor alloc ]initWithRed:(CGFloat)0.333
                                     green:(CGFloat)0.67
                                      blue:(CGFloat)0.93
                                     alpha:(CGFloat)1.0];
    
    // reset constraint
    self.contentViewXConstraint.constant = 0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self initViewControllers];
    [self.tableView reloadData];
}

- (void)initViewControllers {
    
    // Profile View
    ProfileViewController *pvc = [[ProfileViewController alloc] init];
    UINavigationController *pnvc = [[UINavigationController alloc] initWithRootViewController:pvc];
    pnvc.navigationBar.barTintColor = _twitter;
    pnvc.navigationBar.tintColor = [UIColor whiteColor];
    [pnvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    pnvc.navigationBar.translucent = NO;
    
    
    // Timeline
    tweetsViewController *tvc = [[tweetsViewController alloc] init];
    UINavigationController *tnvc = [[UINavigationController alloc] initWithRootViewController:tvc];
    tnvc.navigationBar.barTintColor = _twitter;
    tnvc.navigationBar.tintColor = [UIColor whiteColor];
    [tnvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    tnvc.navigationBar.translucent = NO;
    
    // Mentions
    MentionsViewController *mvc = [[MentionsViewController alloc] init];
    UINavigationController *mnvc = [[UINavigationController alloc] initWithRootViewController:mvc];
    mnvc.navigationBar.barTintColor = _twitter;
    mnvc.navigationBar.tintColor = [UIColor whiteColor];
    [mnvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    mnvc.navigationBar.translucent = NO;
    
    self.viewControllers = [NSArray arrayWithObjects:pnvc, tnvc, mnvc, nil];
    
    // set profile as initial view
    self.currentVC = pnvc;
    self.currentVC.view.frame = self.contentView.bounds;
    [self.contentView addSubview:self.currentVC.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        // add new
        [self removeCurrentViewController];
        self.currentVC = self.viewControllers[indexPath.row];
        [self setContentController];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableView.bounds.size.height / 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Profile";
            break;
        case 1:
            cell.textLabel.text = @"Timeline";
            break;
        case 2:
            cell.textLabel.text = @"Mentions";
            break;
        case 3:
            cell.textLabel.text = @"Accounts";
            break;
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = _twitter;
    
    return cell;
}

- (IBAction)didSwipeRight:(id)sender {
    NSLog(@"Swipe right detected");
    // reload data to handle height change since row heights are based on table height
    [self.tableView reloadData];
    [UIView animateWithDuration:.24 animations:^{
        self.contentViewXConstraint.constant = -200;
        //[self.view layoutIfNeeded];
    }];
}

- (IBAction)didSwipeLeft:(id)sender {
    NSLog(@"Swipe left detected");
    [UIView animateWithDuration:.24 animations:^{
        self.contentViewXConstraint.constant = 0;
        //[self.view layoutIfNeeded];
    }];
}



- (void)removeCurrentViewController {
//    [self.currentVC willMoveToParentViewController:nil];
//    [self.currentVC.view removeFromSuperview];
//    [self.currentVC removeFromParentViewController];
}

- (void)setContentController {
    self.currentVC.view.frame = self.contentView.bounds;
    [self.contentView addSubview:self.currentVC.view];
    [self.currentVC didMoveToParentViewController:self];
    
    [UIView animateWithDuration:.24 animations:^{
        self.contentViewXConstraint.constant = 0;
        self.contentViewYConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (void)showProfileViewController {
    [self removeCurrentViewController];
    self.currentVC = self.viewControllers[0];
    [self setContentController];
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
