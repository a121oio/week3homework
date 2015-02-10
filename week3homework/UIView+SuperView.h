//
//  UIView+SuperView.h
//  TW33Tme
//
//  Created by Amie Kweon on 6/23/14.
//  Copyright (c) 2014 Amie Kweon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SuperView)

- (UIView *)findSuperViewWithClass:(Class)superViewClass;

@end
