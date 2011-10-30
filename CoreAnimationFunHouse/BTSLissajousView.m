//
//  BTSLissajousView.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/28/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSLissajousView.h"

#import "BTSLissajousLayer.h"

@implementation BTSLissajousView

+ (Class)layerClass
{
    return [BTSLissajousLayer class];
}

@end
