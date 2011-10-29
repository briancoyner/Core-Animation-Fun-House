//
//  BTSLissajousLayer.h
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/28/11.
//  Copyright (c) 2011 Black Software, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface BTSLissajousLayer : CALayer

@property (nonatomic, assign) CGFloat amplitude;
@property (nonatomic, assign) CGFloat frequency;
@property (nonatomic, assign) CGFloat phase;

@property (nonatomic, assign) CGFloat a;
@property (nonatomic, assign) CGFloat b;


@end
