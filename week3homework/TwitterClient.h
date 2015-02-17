//
//  TwitterClient.h
//  week3homework
//
//  Created by Weiyan Lin on 2/8/15.
//  Copyright (c) 2015 Weiyan Lin. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"


@interface TwitterClient : BDBOAuth1RequestOperationManager


+ (TwitterClient *) sharedInstance;

-(void) loginWithCompletion:(void (^)(User *user, NSError *error))completion;
-(void) openUrl:(NSURL *) url;
-(void) homeTimeLineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets,NSError *error))completion;

-(void) postStatus:(NSString *)params;

-(void) destroy:(NSString *)tweetId completion:(void (^)())completion;
-(void) retweet:(NSString *)tweetId completion:(void (^)())completion;;
-(void) favorite:(NSString *)idStr completion:(void (^)(NSError *error))completion;
-(void) unfavorite:(NSString *)idStr completion:(void (^)(NSError *error))completion;
- (void)userTimelineWithParams:(NSDictionary *)params user:(User *)user completion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void)mentionsTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;


@end
