//
//  BTSPulseViewController.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 9/30/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSPulseViewController.h"
#import "BTSAnchorPointLayer.h"

static NSString *const kBTSPulseAnimation = @"BTSPulseAnimation";

//
// This example shows how to create an explicit animation and change the scaling factor to simulate a "pulse" effect. 
//

@interface BTSPulseViewController () {
    CALayer *_layer;
    CGFloat _animationDuration;
    BOOL _autoreverses;
}

@property (strong, nonatomic) IBOutlet UILabel *animationDurationLabel;

@end

@implementation BTSPulseViewController

@synthesize animationDurationLabel = _animationDurationLabel;

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Create a new layer and add it to the view's layer
    _layer = [CALayer layer];
    [_layer setContentsScale:[[UIScreen mainScreen] scale]];
    [_layer setContents:(__bridge id)[[UIImage imageNamed:@"american-flag.png"] CGImage]];
    [_layer setBounds:CGRectMake(0.0, 0.0, 150.0, 150.0)];

    UIView *view = [self view];

    CGRect frame = [view bounds];
    CGFloat x = frame.size.width / 2.0;
    CGFloat y = (frame.size.width / 2.0) + 40.0;
    [_layer setPosition:CGPointMake(x, y)];

    BTSAnchorPointLayer *anchorPointLayer = [[BTSAnchorPointLayer alloc] init];
    [anchorPointLayer setPosition:BTSCalculateAnchorPointPositionForLayer(_layer)];
    [_layer addSublayer:anchorPointLayer];

    [[view layer] addSublayer:_layer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self beginAnimatingLayer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self endAnimatingLayer];
}

#pragma mark - User Interaction Methods

- (IBAction)animationEnabledChanged:(id)sender
{
    [self endAnimatingLayer];
    [self beginAnimatingLayer];
}

- (IBAction)animationDurationChanged:(id)sender
{
    _animationDuration = [(UISlider *)sender value];

    [_animationDurationLabel setText:[NSString stringWithFormat:@"Animation (%1.1f)", _animationDuration]];
    [self endAnimatingLayer];
    [self beginAnimatingLayer];
}

- (IBAction)toggleAnchorPoint:(id)sender
{
    BOOL showAnchorPoint = [(UISwitch *)sender isOn];

    // We know that the anchor point layer is the one and only sublayer
    CALayer *anchorPointLayer = [[_layer sublayers] objectAtIndex:0];
    [anchorPointLayer setOpacity:showAnchorPoint ? 1.0 : 0.0];
}

- (IBAction)autoreversesChanged:(id)sender
{
    _autoreverses = [(UISwitch *)sender isOn];
    [self endAnimatingLayer];
    [self beginAnimatingLayer];
}

#pragma mark - Pulse Animation

- (void)beginAnimatingLayer
{
    // Here we are creating an explicit animation for the layer's "transform" property.
    // - The duration (in seconds) is controlled by the user.
    // - The repeat count is hard coded to go "forever".

    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    [pulseAnimation setDuration:_animationDuration];
    [pulseAnimation setRepeatCount:MAXFLOAT];

    // The built-in ease in/ ease out timing function is used to make the animation look smooth as the layer
    // animates between the two scaling transformations.
    [pulseAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

    // Scale the layer to half the size
    CATransform3D transform = CATransform3DMakeScale(1.5, 1.5, 1.0);

    // Tell CA to interpolate to this transformation matrix
    [pulseAnimation setToValue:[NSValue valueWithCATransform3D:transform]];

    // Tells CA to reverse the animation (e.g. animate back to the layer's transform)
    [pulseAnimation setAutoreverses:_autoreverses];

    // Finally... add the explicit animation to the layer... the animation automatically starts.
    [_layer addAnimation:pulseAnimation forKey:kBTSPulseAnimation];
}

- (void)endAnimatingLayer
{
    [_layer removeAnimationForKey:kBTSPulseAnimation];
}

@end
