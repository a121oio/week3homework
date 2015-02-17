//
//  User.m
//  week3homework
//
//  Created by Weiyan Lin on 2/8/15.
//  Copyright (c) 2015 Weiyan Lin. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"


NSString * const UserDidLoginNotification = @"UserDidLoginNotification";
NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";

@interface User()

@end

@implementation User


-(id) initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];
    if (self){
        self.dictionary = dict;
        self.name = dict[@"name"];
        self.screenName = dict[@"screen_name"];
        self.profileImageUrl = dict[@"profile_image_url"];
        self.tagline = dict[@"description"];
        self.bannerUrl = dict[@"profile_banner_url"];
        self.tweetCount = [dict[@"statuses_count"] integerValue];
        self.friendCount = [dict[@"friends_count"] integerValue];
        self.followerCount = [dict[@"followers_count"] integerValue];
    }
    
    return self;
    
}

static User *_currentUser = nil;

NSString *const kCurrentUserKey = @"kCurrentUserKey";

+(User *) currentUser{
    if (_currentUser ==nil){
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentUserKey];
        if(data != nil){
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            _currentUser = [[User alloc] initWithDictionary:dictionary];
            
        }
    }
    
    return _currentUser;
}


+(void) setCurrentUser:(User *)currentUser{
    _currentUser = currentUser;
    
    if (_currentUser != nil){
        NSData *data = [NSJSONSerialization dataWithJSONObject:currentUser.dictionary options:0 error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentUserKey];
        
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCurrentUserKey];
        
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(void) logout{
    [User setCurrentUser:nil];
    [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
    
    
}


@end
