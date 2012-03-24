//
//  BTSCubicBezierPathView.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/9/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSCubicBezierPathView.h"

#import <QuartzCore/QuartzCore.h>

// Simple layer that draws a control point.
@interface BTSControlPointLayer : CALayer
@end

// Simple layer that draws a control point.
@interface BTSEndPointLayer : CALayer
@end

//
// This a multi-touch view that allows the user to manipulate a cubic bezier curve (2 control points, 2 end points)
// This example shows how a bezier curve editor might be implemented. 
//
// This example takes a few shortcuts to keep things "simple"
// 1) we use the control point layers as part of the view's model (points needed for drawing the curve)
// 2) we use CALayer's ability to store arbitrary values to stash away the "touch location offset".
//    - a better approach may be to use the layer's sublayer array (which includes Z-ordering).
// 3) store an internal array of the control point layers to make easier to handle the touches (can use a loop instead of if/else)
// 4) use a CAShapeLayer to draw the bezier curve (instead of using a CALayer delegate that draws the curve with Core Graphics)
//    - this could actually be beneficial to represent the curve as a layer because then we can animate it (color, opacity, etc.)

@interface BTSCubicBezierPathView() {
    
    CALayer *_beginPointLayer;
    CALayer *_endPointLayer;
    
    CALayer *_beginPointControlPointLayer;
    CALayer *_endPointControlPointLayer;
    
    CAShapeLayer *_shapeLayer;
    CFMutableDictionaryRef _touchesToLayers;
    
    NSArray *_hitTestLayers;
}

CGPathRef BTSPathCreateForCurrentControlPointPositions(CALayer *beginPointLayer, CALayer *endPointLayer, CALayer *beginPointControlPointLayer, CALayer *endPointControlPointLayer);

@end

@implementation BTSCubicBezierPathView

static NSString *kBTSCubicBezierPathLocationOffset = @"BTSCubicBezierPathLocationOffset";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initLayers];
        
        // we have at most four layers we can move.
        _touchesToLayers = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
        _hitTestLayers = [NSArray arrayWithObjects:_beginPointControlPointLayer, _endPointControlPointLayer, _beginPointLayer, _endPointLayer, nil];
        
        // Turn on multi-touch
        [self setUserInteractionEnabled:YES];
        [self setMultipleTouchEnabled:YES];
    }
    
    return self;
}

- (void)dealloc
{
    if (_touchesToLayers) {
        CFRelease(_touchesToLayers);
    }
}

#pragma mark - Bezier Path

// Returns the current underlying shape layer's path.
- (CGPathRef)bezierPath
{
    return [_shapeLayer path];
}

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint touchLocationInView = [touch locationInView:self];
        
        for (CALayer *layer in _hitTestLayers) {
            
            // We don't use the layer's 'hitTest' method because we want to expand the touch region to make it easier 
            // to pick up and move a control point layer. 
            CGRect hitTestRect = [layer convertRect:[layer bounds] toLayer:[layer superlayer]];
            
            CGRect hitBounds = CGRectInset(hitTestRect, -20.0, -20.0);
            if (CGRectContainsPoint(hitBounds, touchLocationInView)) {
                CFDictionarySetValue(_touchesToLayers, (__bridge CFTypeRef)touch, (__bridge CFTypeRef)layer);                
                
                CGPoint offsetFromCenter = CGPointMake([layer position].x - touchLocationInView.x, [layer position].y - touchLocationInView.y);
                [layer setValue:[NSValue valueWithCGPoint:offsetFromCenter] forKey:kBTSCubicBezierPathLocationOffset];
                
                break;
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (CFDictionaryGetCount(_touchesToLayers) == 0) {
        return;
    }
    
    // Turn off implicit actions for the rest of the current run loop.
    // - we do this so that the layer is not implicitly animated when changing the position.
    [CATransaction setDisableActions:YES]; 
    
    CGRect bounds = [self bounds];
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
    for (UITouch *currentTouch in touches) {
        CALayer *layerToMove = (__bridge CALayer *)CFDictionaryGetValue(_touchesToLayers, (__bridge CFTypeRef)currentTouch);
        CGPoint locationInView = [currentTouch locationInView:self];
        
        CGPoint offsetFromCenter = [(NSValue *)[layerToMove valueForKey:kBTSCubicBezierPathLocationOffset] CGPointValue];
        CGFloat x = MAX(0, locationInView.x + offsetFromCenter.x);
        x = MIN(width, x);
        
        CGFloat y = MAX(0, locationInView.y + offsetFromCenter.y);
        y = MIN(height, y);
        CGPoint newPosition = CGPointMake(x, y);
        
        [layerToMove setPosition:newPosition];
    }
    
    CGPathRef path = BTSPathCreateForCurrentControlPointPositions(_beginPointLayer, _endPointLayer, _beginPointControlPointLayer, _endPointControlPointLayer);
    [_shapeLayer setPath:path];
    CFRelease(path);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (CFDictionaryGetCount(_touchesToLayers) == 0) {
        return;
    }
    
    for (UITouch *currentTouch in touches) {
        
        CALayer *layer = (__bridge CALayer *)CFDictionaryGetValue(_touchesToLayers, (__bridge CFTypeRef)currentTouch);
        [layer setValue:nil forKey:kBTSCubicBezierPathLocationOffset];
        
        CFDictionaryRemoveValue(_touchesToLayers, (__bridge CFTypeRef)currentTouch);
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - Private Helper Methods

- (void)initLayers
{
    CGFloat midX = CGRectGetMidX([self bounds]);
    CGFloat midY = CGRectGetMidY([self bounds]);
    
    _beginPointLayer = [BTSEndPointLayer layer];
    [_beginPointLayer setPosition:CGPointMake(midX, 40.0)];
    
    _endPointLayer = [BTSEndPointLayer layer];
    [_endPointLayer setPosition:CGPointMake(midX, [self bounds].size.height - 40.0)];
    
    _beginPointControlPointLayer = [BTSControlPointLayer layer];
    [_beginPointControlPointLayer setPosition:CGPointMake(40.0, midY)];
    
    _endPointControlPointLayer = [BTSControlPointLayer layer];
    [_endPointControlPointLayer setPosition:CGPointMake([self bounds].size.width - 40.0, midY)];
    
    // create the initial path
    CGPathRef path = BTSPathCreateForCurrentControlPointPositions(_beginPointLayer, _endPointLayer, _beginPointControlPointLayer, _endPointControlPointLayer);
    
    _shapeLayer = [CAShapeLayer layer];
    [_shapeLayer setPath:path];
    [_shapeLayer setFillRule:kCAFillRuleEvenOdd];
    [_shapeLayer setFillColor:[UIColor clearColor].CGColor];
    [_shapeLayer setStrokeColor:[UIColor blackColor].CGColor];
    [_shapeLayer setLineWidth:2.0];
    
    CFRelease(path);
    
    CALayer *rootLayer = [self layer];
    [rootLayer addSublayer:_shapeLayer];
    [rootLayer addSublayer:_beginPointLayer];
    [rootLayer addSublayer:_endPointLayer];
    [rootLayer addSublayer:_beginPointControlPointLayer];
    [rootLayer addSublayer:_endPointControlPointLayer];
}

// ownership is transferred to the caller
CGPathRef BTSPathCreateForCurrentControlPointPositions(CALayer *beginPointLayer, CALayer *endPointLayer, CALayer *beginPointControlPointLayer, CALayer *endPointControlPointLayer)
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, [beginPointLayer position].x, [beginPointLayer position].y);
    CGPathAddCurveToPoint(path, NULL, [beginPointControlPointLayer position].x, [beginPointControlPointLayer position].y, [endPointControlPointLayer position].x, [endPointControlPointLayer position].y, [endPointLayer position].x, [endPointLayer position].y);
    return path;
}
@end

#pragma mark - Private CALayers

// TODO: merge the layers and parameterize the color and size.

@implementation BTSControlPointLayer

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
    [super drawInContext:context];
    
    CGContextSetFillColorWithColor(context, [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor);
    
    CGFloat centerX = CGRectGetMidX([self bounds]);
    CGFloat centerY = CGRectGetMidY([self bounds]);
    CGFloat radius = MIN(CGRectGetWidth([self bounds]) / 2.0, CGRectGetHeight([self bounds]) / 2.0) - 2.0;
    
    CGContextAddArc(context, centerX, centerY, radius, 0.0, (CGFloat) (M_PI * 2.0), 0);
    CGContextFillPath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddArc(context, centerX, centerY, radius, 0.0, (CGFloat) (M_PI * 2.0), 0);
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokePath(context);
}

@end

@implementation BTSEndPointLayer

- (id)init
{
    self = [super init];
    if (self) {
        [self setBounds:CGRectMake(0.0, 0.0, 30.0, 20.0)];
        [self setContentsScale:[[UIScreen mainScreen] scale]];
        [self setNeedsDisplay];
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
    
    CGContextSetFillColorWithColor(context, [[UIColor blueColor] colorWithAlphaComponent:0.5].CGColor);
    
    CGFloat centerX = CGRectGetMidX([self bounds]);
    CGFloat centerY = CGRectGetMidY([self bounds]);
    CGFloat radius = MIN(CGRectGetWidth([self bounds]) / 2.0, CGRectGetHeight([self bounds]) / 2.0) - 2.0;
    
    CGContextAddArc(context, centerX, centerY, radius, 0.0, (CGFloat) (M_PI * 2.0), 0);
    CGContextFillPath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddArc(context, centerX, centerY, radius, 0.0, (CGFloat) (M_PI * 2.0), 0);
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokePath(context);
}

@end


