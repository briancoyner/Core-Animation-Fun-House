//
//  BTSLissajousViewController.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/28/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSLissajousViewController.h"

#import "BTSLissajousLayer.h"

@interface BTSLissajousViewController () {

    IBOutlet UISlider *__weak _amplitudeSlider;
    IBOutlet UIStepper *__weak _aStepper;
    IBOutlet UIStepper *__weak _bStepper;
    IBOutlet UISlider *__weak _deltaSlider;
    IBOutlet UILabel *__weak _deltaLabel;
    IBOutlet UILabel *__weak _aValueLabel;
    IBOutlet UILabel *__weak _bValueLabel;
}

@end

@implementation BTSLissajousViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    BTSLissajousLayer *layer = [self lissajousLayer];
    [layer setContentsScale:[[UIScreen mainScreen] scale]];

    [_amplitudeSlider setMinimumValue:1.0];
    [_amplitudeSlider setMaximumValue:[layer bounds].size.height / 2.0];
    [_amplitudeSlider setValue:[_amplitudeSlider maximumValue] / 2.0];

    [_aStepper setMinimumValue:1.0];
    [_aStepper setMaximumValue:10.0];
    [_aStepper setValue:1.0];

    [_bStepper setMinimumValue:0.0];
    [_bStepper setMaximumValue:10.0];
    [_bStepper setValue:2.0];

    [_deltaSlider setMinimumValue:0.0];
    [_deltaSlider setMaximumValue:(float)(2.0 * M_PI)];
    [_deltaSlider setValue:(float)M_PI];

    [self updateAmplitude:_amplitudeSlider];
    [self updateA:_aStepper];
    [self updateB:_bStepper];
    [self updateDelta:_deltaSlider];
}

#pragma mark - User Interaction Methods

- (IBAction)updateAmplitude:(id)sender
{
    BTSLissajousLayer *layer = [self lissajousLayer];
    float value = [(UISlider *)sender value];
    [layer setAmplitude:(CGFloat)value];
}

- (IBAction)updateA:(id)sender
{
    BTSLissajousLayer *layer = [self lissajousLayer];
    float value = (float)[(UIStepper *)sender value];
    [_aValueLabel setText:[NSString stringWithFormat:@"%0.0f", [_aStepper value]]];

    [layer setA:(CGFloat)value];
}

- (IBAction)updateB:(id)sender
{
    BTSLissajousLayer *layer = [self lissajousLayer];
    float value = (float)[(UIStepper *)sender value];
    [_bValueLabel setText:[NSString stringWithFormat:@"%0.0f", [_bStepper value]]];
    [layer setB:(CGFloat)value];
}

- (IBAction)updateDelta:(id)sender
{
    BTSLissajousLayer *layer = [self lissajousLayer];
    float value = [(UISlider *)sender value];
    [_deltaLabel setText:[NSString stringWithFormat:@"%1.3f (%1.1F°)", value, value * (180.0 / M_PI)]];
    [layer setDelta:(CGFloat)value];
}

- (BTSLissajousLayer *)lissajousLayer
{
    return (BTSLissajousLayer *)[[[self view] viewWithTag:100] layer];
}

@end
