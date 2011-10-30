//
//  BTSSineWaveLayer.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/15/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSSineWaveLayer.h"

@interface BTSSineWaveLayer() {
    NSTimer *_animationTimer;
    NSMutableArray *_currentAnimations;
}
@end

@implementation BTSSineWaveLayer

static NSString *kBTSSineWaveLayerAmplitude = @"amplitude";
static NSString *kBTSSineWaveLayerFrequency = @"frequency";
static NSString *kBTSSineWaveLayerPhase = @"phase";

// CALayer calls 'actionForKey:' for any custom dynmamic property. 
@dynamic phase;
@dynamic frequency;
@dynamic amplitude;

+ (NSSet *)keyPathsForValuesAffectingContent
{
    static NSSet *keys = nil;
    if (keys == nil) {
        keys = [[NSSet alloc] initWithObjects:kBTSSineWaveLayerAmplitude, kBTSSineWaveLayerFrequency, kBTSSineWaveLayerPhase, nil];
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

- (void)drawInContext:(CGContextRef)context;
{
    [super drawInContext:context];
    
    CGRect bounds = [self bounds];
    
    CGContextTranslateCTM(context, 0.0, CGRectGetHeight(bounds) / 2.0);    
    
    BTSDrawCoordinateAxes(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    //CGContextSetShadow(context, CGSizeMake(5.0, 2.5), 5.0);
    
    // The layer redraws the content using the current animation's interpolated values. The interpolated
    // values are retrieved from the layer's "presentationLayer".
    CGFloat amplitude = [[(NSValue *)[self presentationLayer] valueForKey:kBTSSineWaveLayerAmplitude] floatValue];
    CGFloat frequency = [[(NSValue *)[self presentationLayer] valueForKey:kBTSSineWaveLayerFrequency] floatValue];
    CGFloat phase = [[(NSValue *)[self presentationLayer] valueForKey:kBTSSineWaveLayerPhase] floatValue];
    
    unsigned int stepCount = CGRectGetWidth(bounds);
    for (int stepIndex = 0; stepIndex < stepCount; stepIndex++) {
        CGFloat x = stepIndex;
        CGFloat y = amplitude * sin(x * frequency + phase);
        
        if (stepIndex == 0) {
            CGContextMoveToPoint(context, x, y);
        } else {
            CGContextAddLineToPoint(context, x, y);
        }
    }
    
    CGContextStrokePath(context);
}

#pragma mark - Layer Delegate Callbacks

- (id<CAAction>)actionForKey:(NSString *)event
{
    // Called when layer's property changes.

    if ([[BTSSineWaveLayer keyPathsForValuesAffectingContent] member:event]) {
        
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
        NSSet *internalKeys = [BTSSineWaveLayer keyPathsForValuesAffectingContent];
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