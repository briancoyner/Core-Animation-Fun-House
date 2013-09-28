//
//  BTSLissajousLayer.h
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/28/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface BTSLissajousLayer : CALayer

@property (nonatomic, assign) CGFloat amplitude;
@property (nonatomic, assign) CGFloat a;
@property (nonatomic, assign) CGFloat b;
@property (nonatomic, assign) CGFloat delta;

@end
