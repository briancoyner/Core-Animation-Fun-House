//
//  BTSBasicLayerPropertiesViewController.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 9/22/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSBasicLayerPropertiesViewController.h"
#import "BTSAnchorPointLayer.h"

// This view controller shows how various Core Animation CALayer properties implicitly animate.
// - position, corner radius, border, color, size, etc.

@interface BTSBasicLayerPropertiesViewController() {
    CALayer *_layer;
    
    CGFloat _animationDuration;
    IBOutlet UISlider *_animationDurationSlider;
    IBOutlet UISwitch *_enableAnimations;
}

@property (strong, nonatomic) IBOutlet UILabel *animationDurationLabel;

@end

@implementation BTSBasicLayerPropertiesViewController
@synthesize animationDurationLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // A switch that allows the user to toggle CA implicit animations. The default is to animate.
    [_enableAnimations setOn:YES];
    
    // Set the default animation duration to 1/2 second and sync the model and view
    [_animationDurationSlider setValue:0.5];
    [self animationDurationChanged:_animationDurationSlider];
    
    // This example uses a single CALayer positioned new the top of the view.
    _layer = [CALayer layer];
    [_layer setContentsScale:[[UIScreen mainScreen] scale]];
    [_layer setBackgroundColor:[UIColor blueColor].CGColor];
    [_layer setBounds:CGRectMake(0.0, 0.0, 200.0, 200.0)];
    
    CGPoint anchorPoint = {0.5, 0.0};
    [_layer setAnchorPoint:anchorPoint];
    [_layer setMasksToBounds:NO];
    [_layer setNeedsDisplay];
    
    BTSAnchorPointLayer *anchorPointLayer = [[BTSAnchorPointLayer alloc] init];
    [anchorPointLayer setPosition:BTSCalculateAnchorPointPositionForLayer(_layer)];
    [_layer addSublayer:anchorPointLayer];
    
    
    CGRect frame = [[self view] bounds];
   
    // Because the CALayer anchor point is {0.5,0.0}, we can simply set X to the center of the width.
    // This centers the layer on the X axis.
    CGFloat x = frame.size.width / 2.0;

    // Position the layer 10 points from the top of the view.
    CGFloat y = 10.0;
    [_layer setPosition:CGPointMake(x, y)];    

    [[[self view] layer] addSublayer:_layer];
}

- (void)viewDidUnload
{
    [self setAnimationDurationLabel:nil];
    _enableAnimations = nil;
    _animationDurationSlider = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)animationDurationChanged:(id)sender {
    
    _animationDuration = [(UISlider *)sender value];
    [animationDurationLabel setText:[NSString stringWithFormat:@"Animation (%1.1f)", _animationDuration]];
}

- (IBAction)toggleRoundCorners:(id)sender {
    
    [CATransaction setDisableActions:![_enableAnimations isOn]];
    [CATransaction setAnimationDuration:_animationDuration];
    
    [_layer setCornerRadius:([_layer cornerRadius] == 0.0 ? 25.0 : 0.0)];
}

- (IBAction)toggleColor:(id)sender {
    [CATransaction setDisableActions:![_enableAnimations isOn]];
    [CATransaction setAnimationDuration:_animationDuration];
    
    [_layer setBackgroundColor:([_layer backgroundColor] == [UIColor blueColor].CGColor ? [UIColor greenColor].CGColor : [UIColor blueColor].CGColor)]; 
}

- (IBAction)toggleBorder:(id)sender {
    
    [CATransaction setDisableActions:![_enableAnimations isOn]];
    [CATransaction setAnimationDuration:_animationDuration];

    [_layer setBorderWidth:([_layer borderWidth] == 0.0 ? 10 : 0.0)];
}

- (IBAction)toggleOpacity:(id)sender {
    
    [CATransaction setDisableActions:![_enableAnimations isOn]];
    [CATransaction setAnimationDuration:_animationDuration];
    
    [_layer setOpacity:([_layer opacity] == 1.0 ? 0.2 : 1.0)];
}

- (IBAction)toggleSize:(id)sender 
{
    [CATransaction setDisableActions:![_enableAnimations isOn]];
    [CATransaction setAnimationDuration:_animationDuration];
    
    CGRect layerBounds = _layer.bounds;
    layerBounds.size.width  = (layerBounds.size.width == layerBounds.size.height) ? 250.0 : 200.0;
    [_layer setBounds:layerBounds];
    
    BTSAnchorPointLayer *anchorPointLayer = [[_layer sublayers] objectAtIndex:0];
    [anchorPointLayer setPosition:BTSCalculateAnchorPointPositionForLayer(_layer)];
}

- (IBAction)toggleAll:(id)sender {

    [self toggleBorder:nil];
    [self toggleColor:nil];     
    [self toggleOpacity:nil];
    [self toggleRoundCorners:nil];
    [self toggleSize:nil];
}

@end


