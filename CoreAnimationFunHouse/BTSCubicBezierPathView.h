//
//  BTSCubicBezierPathView.h
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/9/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CAMediaTimingFunction;

@interface BTSCubicBezierPathView : UIView

// Call to get the current bezier path.
- (CGPathRef)bezierPath;

@end
