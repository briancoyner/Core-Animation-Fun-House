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

// set to YES to anchor the beginning point to the lower left and the ending point to the upper right.
// set to NO to allow the user to move the begin and end points. 
@property (nonatomic, assign) BOOL lockedForMediaTimingFunction;

// Call to get the current bezier path.
- (CGPathRef)bezierPath;

// Call to get the current media timing function based on the current bezier curve. 
// NOTE: this should only be called if the view is "locked for media timing function".
- (CAMediaTimingFunction *)currentMediaTimingFunction;

// Move the begin control point and end control point to the default positions based on the 
// timing function name.
- (void)transitionToMediaTimingFunctionWithName:(NSString *)functionName;

@end
