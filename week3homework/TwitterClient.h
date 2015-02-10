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



@end
