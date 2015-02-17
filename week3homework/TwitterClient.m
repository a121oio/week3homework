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

-(void) postStatus:(NSString *)params {
    
    NSDictionary *parameters = @{@"status": params};

    [self POST:@"1.1/statuses/update.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@" %@",responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@" failed to Post");
        
    }];

}

-(void) retweet:(NSString *)tweetId completion:(void (^)())completion{
    
    NSString *postUrl = [NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", tweetId] ;
    
    [self POST: [postUrl  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@" %@",responseObject);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@" failed to retweet");

    }];

    
}

-(void) destroy:(NSString *)tweetId completion:(void (^)())completion{
    
    [self POST:[NSString stringWithFormat:@"1.1/statuses/destroy/%@.json", tweetId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@" %@",responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@" failed to destroy");
        
    }];

    
}

- (void)favorite:(NSString *)idStr completion:(void (^)(NSError *error))completion {
    NSString *postUrl = [NSString stringWithFormat:@"1.1/favorites/create.json?id=%@", idStr];
    
    [self POST:[postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"successfully favorited tweet");
        
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed favorited tweet");
        completion(error);
    }];
}

- (void)unfavorite:(NSString *)idStr completion:(void (^)(NSError *error))completion {
    NSString *postUrl = [NSString stringWithFormat:@"1.1/favorites/destroy.json?id=%@", idStr];
    
    [self POST:[postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"successfully unfavorited tweet");
        completion(nil);


    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error);
        NSLog(@"failed unfavorited tweet");
    }];
}


- (void)mentionsTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/mentions_timeline.json?include_my_retweet=1" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog([NSString stringWithFormat:@"mentions timeline: %@", responseObject]);
        NSArray *tweets = [Tweets tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}


- (void)userTimelineWithParams:(NSDictionary *)params user:(User *)user completion:(void (^)(NSArray *tweets, NSError *error))completion {
    User *forUser = user ? user : [User currentUser];
    NSString *getUrl = [NSString stringWithFormat:@"1.1/statuses/user_timeline.json?count=20&screen_name=%@", forUser.screenName];
    [self GET:getUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog([NSString stringWithFormat:@"user timeline: %@", responseObject]);
        NSArray *tweets = [Tweets tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
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
