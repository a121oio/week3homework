//
//  TwitterClient.m
//  week3homework
//
//  Created by Weiyan Lin on 2/8/15.
//  Copyright (c) 2015 Weiyan Lin. All rights reserved.
//

#import "TwitterClient.h"
#import "Tweets.h"


NSString * const kTwitterConsumerKey =@"hXlDXu08bDAF7t2kce97Len3B";
NSString * const kTwitterConsumerSecret = @"RJ5C98s90HMCPU0MO48igPrAwOA7jx1cTy1nRjvzIk55Rgihdw";

NSString * const kTwitterBaseUrl = @"https://api.twitter.com";

@interface TwitterClient()

@property (nonatomic , strong) void (^loginCompletion) (User *user, NSError *error);




@end


@implementation TwitterClient

+ (TwitterClient *) sharedInstance{
    static TwitterClient *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil){
            instance = [[TwitterClient alloc]initWithBaseURL:[NSURL URLWithString: kTwitterBaseUrl] consumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
            
        }
        
    });
    
    return instance;
    
}

-(void) loginWithCompletion:(void (^)(User *user, NSError *error))completion{
    
    
    
    self.loginCompletion = completion;
    
    [self.requestSerializer removeAccessToken];
    
    [self fetchRequestTokenWithPath:@"oauth/request_token"  method:@"GET" callbackURL:[NSURL URLWithString:@"cptwitterdemo://oauth"]  scope:nil success:^(BDBOAuth1Credential *requestToken) {
        NSLog(@"Got Token");
        
        NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat: @"https://api.twitter.com/oauth/authorize?oauth_token=%@",requestToken.token]];
        [[UIApplication sharedApplication] openURL:authURL];
        
        
    } failure:^(NSError *error) {
        NSLog(@"Fail to get Token");
        self.loginCompletion(nil,error);
        
        
    }];
    
}


-(void) openUrl:(NSURL *)url{
    
    [self fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query] success:^(BDBOAuth1Credential *accessToken) {
        NSLog(@"got the access token");
        [self.requestSerializer saveAccessToken:accessToken];
        
        [self GET:@"1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            User *user = [[User alloc] initWithDictionary:responseObject];
            [User setCurrentUser:user];
            
            NSLog(@"current user: %@" , user.name);
            self.loginCompletion(user,nil);
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failed getting current user");
            self.loginCompletion(nil,error);
            
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"failed to got the access token!");
        self.loginCompletion(nil,error);

    }];

    
}

-(void) homeTimeLineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets,NSError *error))completion{
    [self GET:@"1.1/statuses/home_timeline.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tweets = [Tweets tweetsWithArray:responseObject];
        NSLog(@" %@",responseObject);
        completion(tweets,nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil,error);
    }];
    
     
}


@end
