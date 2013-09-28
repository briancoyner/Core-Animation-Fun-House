//
//  BTSSineWaveLayer.h
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/15/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface BTSSineWaveLayer : CALayer

@property (nonatomic, assign, readwrite) CGFloat amplitude;
@property (nonatomic, assign, readwrite) CGFloat frequency;
@property (nonatomic, assign, readwrite) CGFloat phase;

@end
