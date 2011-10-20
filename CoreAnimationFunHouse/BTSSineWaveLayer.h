//
//  BTSSineWaveLayer.h
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/15/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface BTSSineWaveLayer : CALayer

@property (nonatomic, assign) CGFloat amplitude;
@property (nonatomic, assign) CGFloat frequency;
@property (nonatomic, assign) CGFloat phase;

@end