//
//  Tweets.h
//  week3homework
//
//  Created by Weiyan Lin on 2/8/15.
//  Copyright (c) 2015 Weiyan Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"


@interface Tweets : NSObject


@property (nonatomic,strong) NSString    *text;
@property (nonatomic,strong) NSDate *createdAT;
@property (nonatomic,strong) User *user;
@property BOOL retweeted;
@property BOOL favorited;
@property (assign) int retweetCount;
@property (assign) int favouritesCount;
@property (nonatomic, strong) Tweets *retweetedStatus;
@property NSNumber *id;
@property (nonatomic,strong) NSString *retweetIdStr;
@property (nonatomic,strong) NSString *IdStr;



-(Tweets *) initWithDictionary:(NSDictionary *)dict;

+(NSArray *) tweetsWithArray:(NSArray *)array;


@end
