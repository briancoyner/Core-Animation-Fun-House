//
//  BTSLissajousLayer.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/28/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSLissajousLayer.h"

#import <QuartzCore/QuartzCore.h>

@interface BTSLissajousLayer() {
    CADisplayLink *_displayLink;
    NSMutableArray *_currentAnimations;
}
@end

@implementation BTSLissajousLayer

static NSString *kBTSLissajouseLayerAmplitude = @"amplitude";
static NSString *kBTSLissajouseLayerA = @"a";
static NSString *kBTSLissajouseLayerB = @"b";
static NSString *kBTSLissajouseLayerDelta = @"delta";

@dynamic amplitude;
@dynamic a;
@dynamic b;
@dynamic delta;

+ (NSSet *)keyPathsForValuesAffectingContent
{
    static NSSet *keys = nil;
    if (keys == nil) {
        keys = [[NSSet alloc] initWithObjects:kBTSLissajouseLayerAmplitude, kBTSLissajouseLayerA, kBTSLissajouseLayerB, kBTSLissajouseLayerDelta, nil];
    }
    return keys;
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
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat increment = 2 * M_PI / (a * b * 40);
    for (CGFloat t = 0.0; t < 2 * M_PI + increment; t = t + increment) {
        CGFloat x = amplitude * sin(a * t + delta);
        CGFloat y = amplitude * sin(b * t);
        if (t == 0.0) {
            CGPathMoveToPoint(path, NULL, x, y);
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
    // Called when layer's property changes.
    
    if ([[BTSLissajousLayer keyPathsForValuesAffectingContent] member:event]) {
        
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

#pragma mark - Animation Delegate Callbacks

- (void)animationDidStart:(CAAnimation *)anim
{
    if ([anim isKindOfClass:[CAPropertyAnimation class]]) {
        NSSet *internalKeys = [BTSLissajousLayer keyPathsForValuesAffectingContent];
        if ([internalKeys member:[(CAPropertyAnimation *)anim keyPath]]) {
            
            [_currentAnimations addObject:anim];
            if (_displayLink == nil) {
                _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationTimerFired:)];
                [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            }
        }
    }
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    [_currentAnimations removeObject:animation];
    if ([_currentAnimations count] == 0) {
        [_displayLink invalidate];
        _displayLink = nil;
        
        // hmmm... the use of CADisplayLink seems to miss the final set of interpolated values... let's force a final paint.
        // note... this was not necessary when using an explicit NSTimer (need to investigate more).
        [self setNeedsDisplay];
    }
}

#pragma mark - Timer Callback
- (void)animationTimerFired:(CADisplayLink *)displayLink
{    
    [self setNeedsDisplay];
}

@end
