//
//  BTSSinWaveView.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/15/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSSineWaveView.h"
#import "BTSSineWaveLayer.h"

@implementation BTSSineWaveView

+ (Class)layerClass
{
    return [BTSSineWaveLayer class];
}

@end
