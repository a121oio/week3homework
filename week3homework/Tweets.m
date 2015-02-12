//
//  Tweets.m
//  week3homework
//
//  Created by Weiyan Lin on 2/8/15.
//  Copyright (c) 2015 Weiyan Lin. All rights reserved.
//

#import "Tweets.h"
#import "TwitterClient.h"

@implementation Tweets

-(Tweets *) initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];
    if (self){
        self.text = [[NSString alloc] initWithString:dict[@"text"]];
        
//        self.text = dict[@"text"];
        self.user = [[User alloc] initWithDictionary:dict[@"user"]];
        NSString *createdAtString = dict[@"created_at"];
        self.retweeted = NO;
        self.favorited = NO;
        self.retweetCount = [dict[@"retweet_count"] integerValue];
        self.favouritesCount = [dict[@"favorite_count"] integerValue];
        self.IdStr = dict[@"id_str"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        self.retweetIdStr = dict[@"id_str"];
        self.createdAT = [formatter dateFromString:createdAtString];
        if (dict[@"retweeted_status"]) {
            self.retweetedTweet = [[Tweets alloc] initWithDictionary:dict[@"retweeted_status"]];
        }
    }
    return self;
}

+ (NSArray *) tweetsWithArray:(NSArray *)array{
    NSMutableArray *tweets = [NSMutableArray array];
    
    for (NSDictionary *dict in array ){
        Tweets *tweet = [[Tweets alloc] initWithDictionary:dict];
        [tweets addObject:tweet];
        
    }

    return tweets;
}

- (BOOL)retweet {
    self.retweeted = !self.retweeted;
    if (self.retweeted) {
        self.retweetCount++;
        // retweet
        [[TwitterClient sharedInstance] retweet:self.IdStr completion:^ (NSError *error) {
            if (error) {
                NSLog(@"Retweet failed");
            } else {
                NSLog([NSString stringWithFormat:@"Retweet successful, retweet_id_str: %@", self.IdStr]);
                // set retweet id string so it can be unretweeted
                self.retweetIdStr = self.IdStr;
            }
        }];
    } else {
        self.retweetCount--;
        // unretweet
        [[TwitterClient sharedInstance] destroy:self.retweetIdStr completion:^(NSError *error) {
            if (error) {
                NSLog(@"Unretweet failed");
            } else {
                NSLog(@"Unretweet successful");
            }
        }];
    }
    
    return self.retweeted;
}

- (BOOL)favorite {
    self.favorited = !self.favorited;
    if (self.favorited) {
        self.favouritesCount++;
        // favorite
        [[TwitterClient sharedInstance] favorite:self.IdStr completion:^(NSError *error) {
            if (error) {
                NSLog(@"Favorite failed");
            } else {
                NSLog(@"Favorite successful");
            }
        }];
    } else {
        self.favouritesCount--;
        // unfavorite
        [[TwitterClient sharedInstance] unfavorite:self.IdStr completion:^(NSError *error) {
            if (error) {
                NSLog(@"Unfavorite failed");
            } else {
                NSLog(@"Unfavorite successful");
            }
        }];
    }
    
    return self.favorited;
}

@end
