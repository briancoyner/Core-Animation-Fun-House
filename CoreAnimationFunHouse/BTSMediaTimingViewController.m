//
//  BTSMediaTimingViewController.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/22/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSMediaTimingViewController.h"
#import "BTSCubicBezierPathView.h"

#import <QuartzCore/QuartzCore.h>

@interface BTSMediaTimingViewController() {
    
    __weak IBOutlet BTSCubicBezierPathView *_bezierPathView;
    __weak IBOutlet UIView *_animationContainer;
    
    CALayer *_animationLayer;
    CALayer *_testLayer;
}

@end

@implementation BTSMediaTimingViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_bezierPathView setLockedForMediaTimingFunction:YES];
    
    CGFloat width = [_animationContainer bounds].size.height * .75;
    
    _animationLayer = [CALayer layer];
    [_animationLayer setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.75].CGColor];
    [_animationLayer setBounds:CGRectMake(0, 0, width, width)];
    [_animationLayer setPosition:CGPointMake([_bezierPathView frame].origin.x, CGRectGetMidY([_animationContainer bounds]))];
    
    _testLayer = [CALayer layer];
    [_testLayer setMasksToBounds:YES];
    [_testLayer setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.5].CGColor];
    [_testLayer setBounds:CGRectMake(0, 0, width, width)];
    [_testLayer setPosition:CGPointMake([_bezierPathView frame].origin.x, CGRectGetMidY([_animationContainer bounds]))];
    [_testLayer setCornerRadius:[_testLayer bounds].size.width / 2];
    
    CALayer *layer = [_animationContainer layer];
    [layer addSublayer:_animationLayer];
    [layer addSublayer:_testLayer];
}

- (void)viewDidUnload
{   
    _bezierPathView = nil;
    _animationContainer = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (IBAction)animate:(id)sender {
    
    CGPoint newPosition = CGPointMake(290, [_animationLayer position].y);
    [_animationLayer setPosition:newPosition];
    [_testLayer setPosition:newPosition];
    
    CAMediaTimingFunction *timingFunction = [_bezierPathView currentMediaTimingFunction];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:timingFunction];
    [animation setDuration:2.0];
    [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake([_bezierPathView frame].origin.x, CGRectGetMidY([_animationContainer bounds]))]];
    [animation setToValue:[NSValue valueWithCGPoint:newPosition]];
    
    [_animationLayer addAnimation:animation forKey:@"position"];
    
    
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [_testLayer addAnimation:animation forKey:@"position"];
}

- (IBAction)makeLinear:(id)sender {
    [_bezierPathView transitionToMediaTimingFunctionWithName:kCAMediaTimingFunctionLinear];    
}

- (IBAction)makeEaseIn:(id)sender {
    [_bezierPathView transitionToMediaTimingFunctionWithName:kCAMediaTimingFunctionEaseIn];    
}


- (IBAction)makeEaseOut:(id)sender {
    [_bezierPathView transitionToMediaTimingFunctionWithName:kCAMediaTimingFunctionEaseOut];    
}

- (IBAction)makeEaseInEaseOut:(id)sender {
    [_bezierPathView transitionToMediaTimingFunctionWithName:kCAMediaTimingFunctionEaseInEaseOut];        
}
@end