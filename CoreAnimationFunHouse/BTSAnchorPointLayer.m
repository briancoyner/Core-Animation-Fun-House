//
//  BTSAnchorPointLayer.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/13/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSAnchorPointLayer.h"


// A layer that draws a simple circle with a narrow border. This is useful
// for displaying the super layer's anchor point (for debugging purposes).
//
// Example usage:
//    BTSAnchorPointLayer *anchorPointLayer = [[BTSAnchorPointLayer alloc] init];
//    [anchorPointLayer setPosition:BTSCalculateAnchorPointPositionForLayer(yourSuperLayer)];
//
//    . . .
//
//    [yourSuperLayer addSublayer:anchorPointLayer];
//
// This layer's position does _not_ track the super layer's position. You need to adjust
// this layer's position anytime the super layer's position changes. 

@implementation BTSAnchorPointLayer

- (id)init
{
    self = [super init];
    if (self) {
        [self setBounds:CGRectMake(0.0, 0.0, 20.0, 20.0)];
        [self setContentsScale:[[UIScreen mainScreen] scale]];

        [self setNeedsDisplay];
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context
{
    CGRect bounds = [self bounds];
    CGPoint center = {CGRectGetMidX(bounds), CGRectGetMidY(bounds)};
    
    CGFloat strokeWidth = 2.0;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, center.x, center.y, bounds.size.width / 2 - strokeWidth, 0.0, (CGFloat) (M_PI * 2.0), 0);
    
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, [[UIColor redColor] colorWithAlphaComponent:0.5].CGColor);
    CGContextFillPath(context);

    CGContextAddPath(context, path);
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextStrokePath(context);
    
    CFRelease(path);
}

CGPoint BTSCalculateAnchorPointPositionForLayer(CALayer *superLayer)
{
    CGRect superLayerBounds = [superLayer bounds];
    CGPoint anchorPoint = [superLayer anchorPoint];
    return CGPointMake(superLayerBounds.size.width * anchorPoint.x, superLayerBounds.size.height * anchorPoint.y);
}

@end
