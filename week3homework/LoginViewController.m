//
//  LoginViewController.m
//  week3homework
//
//  Created by Weiyan Lin on 2/8/15.
//  Copyright (c) 2015 Weiyan Lin. All rights reserved.
//

#import "LoginViewController.h"
#import "TwitterClient.h"
#import "tweetsViewController.h"
#import "MenuViewController.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

- (IBAction)loginButton:(id)sender {
    [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
        if(user != nil){
            //modally present tweets view
            NSLog(@"User name %@",user.name);
            
            MenuViewController *mv = [[MenuViewController alloc] init];

            mv.title = @"Twitter";
            
            [self presentViewController:mv animated:YES completion:nil ];
            
            
            
        } else {
            NSLog(@"error login");
        }
    }];
    
  
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Tweetter";
 

    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
