//
//  Tweets.m
//  week3homework
//
//  Created by Weiyan Lin on 2/8/15.
//  Copyright (c) 2015 Weiyan Lin. All rights reserved.
//

#import "Tweets.h"

@implementation Tweets

-(Tweets *) initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];
    if (self){
        self.text = [[NSString alloc] initWithString:dict[@"text"]];
        
//        self.text = dict[@"text"];
        self.user = [[User alloc] initWithDictionary:dict[@"user"]];
        NSString *createdAtString = dict[@"created_at"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        
        self.createdAT = [formatter dateFromString:createdAtString];
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


@end
