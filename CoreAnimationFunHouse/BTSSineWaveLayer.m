//
//  BTSSineWaveLayer.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/15/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSSineWaveLayer.h"

static NSString * const kBTSSineWaveLayerAmplitude = @"amplitude";
static NSString * const kBTSSineWaveLayerFrequency = @"frequency";
static NSString * const kBTSSineWaveLayerPhase = @"phase";

@interface BTSSineWaveLayer() {
    CADisplayLink *_displayLink;
    NSMutableArray *_currentAnimations;
}
@end

@implementation BTSSineWaveLayer

// NOTE: This shows a technique for capturing screen refreshes that allow the layer to redraw.
//       You can actually remove the CADisplayLink and simply override the 'needsDisplayForKey:'
//       method to return the dynamic property key names. This example, thought, I show how to capture 
//       a "screen refresh". This technique is useful if you need more logic than simply "re-drawing".
//       See my 'Core Animation Pie Chart' example on GitHub.
//
// NOTE: Sometimes the 'needsDisplayForKey:' can produce undesired 'flickering' effects. I have yet to 
//       see any undesired 'flickering' effects using the CADisplayLink approach.

// CALayer calls 'actionForKey:' for any custom dynmamic property. 
@dynamic phase;
@dynamic frequency;
@dynamic amplitude;

+ (NSSet *)keyPathsForDynamicProperties
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
    CGContextSetShadow(context, CGSizeMake(5.0, 2.5), 5.0);
    
    // The layer redraws the content using the current animation's interpolated values. The interpolated
    // values are retrieved from the layer's "presentationLayer".
    CGFloat amplitude = [[(NSValue *)[self presentationLayer] valueForKey:kBTSSineWaveLayerAmplitude] floatValue];
    CGFloat frequency = [[(NSValue *)[self presentationLayer] valueForKey:kBTSSineWaveLayerFrequency] floatValue];
    CGFloat phase = [[(NSValue *)[self presentationLayer] valueForKey:kBTSSineWaveLayerPhase] floatValue];
    
    unsigned int stepCount = (unsigned int) CGRectGetWidth(bounds);
    for (int t = 0; t <= stepCount; t++) {
        CGFloat y = (CGFloat) (amplitude * sin(t * frequency + phase));
        
        if (t == 0) {
            CGContextMoveToPoint(context, t, y);
        } else {
            CGContextAddLineToPoint(context, t, y);
        }
    }
    
    CGContextSetLineJoin(context, kCGLineJoinBevel);
    CGContextStrokePath(context);
}

#pragma mark - Layer Delegate Callbacks

- (id<CAAction>)actionForKey:(NSString *)event
{
    // Called when layer's property changes.

    if ([[BTSSineWaveLayer keyPathsForDynamicProperties] member:event]) {
        
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
        NSSet *internalKeys = [BTSSineWaveLayer keyPathsForDynamicProperties];
        if ([internalKeys member:[(CAPropertyAnimation *)anim keyPath]]) {

            [_currentAnimations addObject:anim];
            if (_displayLink == nil) {
                _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationTimerFired:)];
                [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            }
        }
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [_currentAnimations removeObject:anim];
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