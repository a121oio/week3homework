//
//  User.h
//  week3homework
//
//  Created by Weiyan Lin on 2/8/15.
//  Copyright (c) 2015 Weiyan Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const UserDidLoginNotification ;
extern NSString *  const UserDidLogoutNotification ;


@interface User : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *screenName;
@property (nonatomic,strong) NSString *profileImageUrl;
@property (nonatomic,strong) NSString *tagline;
@property (nonatomic,strong) NSDictionary *dictionary;
@property (nonatomic, strong) NSString *bannerUrl;
@property (nonatomic) NSInteger tweetCount;
@property (nonatomic) NSInteger friendCount;
@property (nonatomic) NSInteger followerCount;


-(id) initWithDictionary:(NSDictionary *)dict;

+(User *) currentUser;
+(void) setCurrentUser:(User *)currentUser;

+(void) logout;


@end
