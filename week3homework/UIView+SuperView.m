//
//  UIView+SuperView.m
//  TW33Tme
//
//  Created by Amie Kweon on 6/23/14.
//  Copyright (c) 2014 Amie Kweon. All rights reserved.
//

#import "UIView+SuperView.h"

@implementation UIView (SuperView)

- (UIView *)findSuperViewWithClass:(Class)superViewClass {

    UIView *superView = self.superview;
    UIView *foundSuperView = nil;

    while (nil != superView && nil == foundSuperView) {
        if ([superView isKindOfClass:superViewClass]) {
            foundSuperView = superView;
        } else {
            superView = superView.superview;
        }
    }
    return foundSuperView;
}

@end
