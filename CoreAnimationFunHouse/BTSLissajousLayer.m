//
//  BTSLissajousLayer.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/28/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSLissajousLayer.h"

#import <QuartzCore/QuartzCore.h>

static NSString* const kBTSLissajouseLayerAmplitude = @"amplitude";
static NSString* const kBTSLissajouseLayerA = @"a";
static NSString* const kBTSLissajouseLayerB = @"b";
static NSString* const kBTSLissajouseLayerDelta = @"delta";

static const CGFloat TWO_PI = M_PI * 2.0f;

@interface BTSLissajousLayer() {
    NSMutableArray *_currentAnimations;
}
@end

@implementation BTSLissajousLayer

@dynamic amplitude;
@dynamic a;
@dynamic b;
@dynamic delta;

+ (NSSet *)keyPathsForCustomDisplayDrawing
{
    static NSSet *keys = nil;
    if (keys == nil) {
        keys = [[NSSet alloc] initWithObjects:kBTSLissajouseLayerAmplitude, kBTSLissajouseLayerA, kBTSLissajouseLayerB, kBTSLissajouseLayerDelta, nil];
    }
    return keys;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    return [[self keyPathsForCustomDisplayDrawing] containsObject:key]; 
}

#pragma mark - Layer Drawing

- (id)init {
    
    self = [super init];
    if (self) {
        _currentAnimations = [[NSMutableArray alloc] initWithCapacity:3];
        [self setContentsScale:[[UIScreen mainScreen] scale]];;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
    
    CGRect bounds = [self bounds];
    
    CGContextTranslateCTM(context, CGRectGetWidth(bounds) / 2, CGRectGetHeight(bounds) / 2.0);    
    
    BTSDrawCoordinateAxes(context);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetShadow(context, CGSizeMake(0.0, 2.5), 5.0);
    
    // The layer redraws the curve using the current animation's interpolated values. The interpolated
    // values are retrieved from the layer's "presentationLayer".
    CGFloat amplitude = [[(NSValue *)[self presentationLayer] valueForKey:kBTSLissajouseLayerAmplitude] floatValue];
    CGFloat a = [[(NSValue *)[self presentationLayer] valueForKey:kBTSLissajouseLayerA] floatValue];
    CGFloat b = [[(NSValue *)[self presentationLayer] valueForKey:kBTSLissajouseLayerB] floatValue];
    CGFloat delta = [[(NSValue *)[self presentationLayer] valueForKey:kBTSLissajouseLayerDelta] floatValue];
    
    CGFloat increment = TWO_PI / (a * b * 40.0f);
    CGMutablePathRef path = CGPathCreateMutable();
    
    BOOL shouldMoveToPoint = YES;
    
    for (CGFloat t = 0.0; t < TWO_PI + increment; t = t + increment) {
        CGFloat x = amplitude * sin(a * t + delta);
        CGFloat y = amplitude * sin(b * t);
        if (shouldMoveToPoint) {
            CGPathMoveToPoint(path, NULL, x, y);
            shouldMoveToPoint = NO;
        } else {
            CGPathAddLineToPoint(path, NULL, x, y);
        }
    }
    
    CGContextAddPath(context, path);
    CGContextSetLineJoin(context, kCGLineJoinBevel);
    CGContextStrokePath(context);
    CFRelease(path);
}

- (id<CAAction>)actionForKey:(NSString *)event
{
    // Called when a property changes.
    
    if ([[BTSLissajousLayer keyPathsForCustomDisplayDrawing] member:event]) {
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:event];
        NSValue *valueForKey = [[self presentationLayer] valueForKey:event];
        
        [animation setFromValue:valueForKey];
        [animation setDelegate:self];
        [animation setDuration:1.0];
        
        return animation;
        
    } else {
        return [super actionForKey:event];
    }
}

@end
