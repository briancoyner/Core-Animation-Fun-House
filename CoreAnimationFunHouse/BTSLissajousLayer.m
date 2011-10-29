//
//  BTSLissajousLayer.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/28/11.
//  Copyright (c) 2011 Black Software, Inc. All rights reserved.
//

#import "BTSLissajousLayer.h"

@interface BTSLissajousLayer() {
    NSTimer *_animationTimer;
    NSMutableArray *_currentAnimations;
}
@end

@implementation BTSLissajousLayer

static NSString *kBTSLissajouseLayerAmplitude = @"amplitude";
static NSString *kBTSLissajousLayerFrequency = @"frequency";
static NSString *kBTSLissajouseLayerPhase = @"phase";

static NSString *kBTSLissajouseLayerA = @"a";
static NSString *kBTSLissajouseLayerB = @"b";

@dynamic phase;
@dynamic frequency;
@dynamic amplitude;

@dynamic a;
@dynamic b;

+ (NSSet *)keyPathsForValuesAffectingContent
{
    static NSSet *keys = nil;
    if (keys == nil) {
        keys = [[NSSet alloc] initWithObjects:kBTSLissajouseLayerAmplitude, kBTSLissajousLayerFrequency, kBTSLissajouseLayerPhase, kBTSLissajouseLayerA, kBTSLissajouseLayerB, nil];
    }
    return keys;
}

#pragma mark - Layer Drawing

- (id)init {
    self = [super init];
    if (self) {
        _currentAnimations = [[NSMutableArray alloc] initWithCapacity:3];
        [self setContentsScale:[[UIScreen mainScreen] scale]];
        
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
    //CGContextSetShadow(context, CGSizeMake(5.0, 2.5), 5.0);
    
    // The layer redraws the content using the current animation's interpolated values. The interpolated
    // values are retrieved from the layer's "presentationLayer".
    CGFloat amplitude = [[(NSValue *)[self presentationLayer] valueForKey:kBTSLissajouseLayerAmplitude] floatValue];
    CGFloat frequency = [[(NSValue *)[self presentationLayer] valueForKey:kBTSLissajousLayerFrequency] floatValue];
    
    CGFloat a = [[(NSValue *)[self presentationLayer] valueForKey:kBTSLissajouseLayerA] floatValue];
    CGFloat b = [[(NSValue *)[self presentationLayer] valueForKey:kBTSLissajouseLayerB] floatValue];

    CGMutablePathRef path = CGPathCreateMutable();
    
    unsigned int stepCount = CGRectGetWidth(bounds);
    for (CGFloat stepIndex = 0.0; stepIndex <= stepCount; stepIndex++) {

        CGFloat temp = stepIndex * frequency;
        CGFloat x = amplitude * sin(a * temp);
        CGFloat y = amplitude * sin(b * temp);
        if (stepIndex == 0.0) {
            CGPathMoveToPoint(path, NULL, x, y);
        } else {
            CGPathAddLineToPoint(path, NULL, x, y);
        }
    }
    
    CGContextAddPath(context, path);
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
        [animation setDuration:2.0];
        
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
            if (_animationTimer == nil) {
                _animationTimer = [NSTimer scheduledTimerWithTimeInterval:1/60 target:self selector:@selector(animationTimerFired:) userInfo:nil repeats:YES];
            }
        }
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [_currentAnimations removeObject:anim];
    if ([_currentAnimations count] == 0) {
        [_animationTimer invalidate];
        _animationTimer = nil;
    }
}

#pragma mark - Timer Callback
- (void)animationTimerFired:(NSTimer *)timer
{
    [self setNeedsDisplay];
}

@end
