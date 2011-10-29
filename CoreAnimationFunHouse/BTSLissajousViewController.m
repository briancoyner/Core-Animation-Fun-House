//
//  BTSLissajousViewController.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/28/11.
//  Copyright (c) 2011 Black Software, Inc. All rights reserved.
//

#import "BTSLissajousViewController.h"

#import "BTSLissajousView.h"
#import "BTSLissajousLayer.h"

@interface BTSLissajousViewController() {
    
    __weak IBOutlet UISlider *_amplitudeSlider;
    __weak IBOutlet UISlider *_frequencySlider;
    __weak IBOutlet UIStepper *_aStepper;
    __weak IBOutlet UIStepper *_bStepper;
    __weak IBOutlet UILabel *_aValueLabel;
    __weak IBOutlet UILabel *_bValueLabel;
}
- (IBAction)updateAmplitude:(id)sender;
- (IBAction)updateFrequency:(id)sender;
- (IBAction)updateA:(id)sender;
- (IBAction)updateB:(id)sender;
@end

@implementation BTSLissajousViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BTSLissajousLayer *layer = (BTSLissajousLayer *)[[[self view] viewWithTag:100] layer];
    
    [_amplitudeSlider setMinimumValue:0.0];
    [_amplitudeSlider setMaximumValue:[layer bounds].size.height / 2.0 - 5.0];
    [_amplitudeSlider setValue:[_amplitudeSlider maximumValue] / 2.0];
    
    [_frequencySlider setMinimumValue:0.0];
    [_frequencySlider setMaximumValue:(2 * M_PI / [layer bounds].size.width)];
    [_frequencySlider setValue:[_frequencySlider maximumValue]];
    
    [_aStepper setMinimumValue:0.0];
    [_aStepper setMaximumValue:10.0];
    [_aStepper setValue:1.0];

    [_bStepper setMinimumValue:0.0];
    [_bStepper setMaximumValue:10.0];
    [_bStepper setValue:2.0];

    
    [self updateAmplitude:_amplitudeSlider];
    [self updateFrequency:_frequencySlider];
    [self updateA:_aStepper];
    [self updateB:_bStepper];
    
    [layer setNeedsDisplay];
}

- (void)viewDidUnload
{

    _amplitudeSlider = nil;
    _frequencySlider = nil;
    _aStepper = nil;
    _bStepper = nil;
    _aValueLabel = nil;
    _bValueLabel = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)updateAmplitude:(id)sender {
    BTSLissajousLayer *layer = (BTSLissajousLayer *)[[[self view] viewWithTag:100] layer]; 
    float value = [(UISlider *)sender value];
    [layer setAmplitude:(CGFloat)value];
}

- (IBAction)updateFrequency:(id)sender {
    BTSLissajousLayer *layer = (BTSLissajousLayer *)[[[self view] viewWithTag:100] layer]; 
    float value = [(UISlider *)sender value];
    [layer setFrequency:value];
}

- (IBAction)updateA:(id)sender {
    BTSLissajousLayer *layer = (BTSLissajousLayer *)[[[self view] viewWithTag:100] layer]; 
    float value = [(UIStepper *)sender value];
    [_aValueLabel setText:[NSString stringWithFormat:@"%0.0f", [_aStepper value]]];


    [layer setA:(CGFloat)value];
}

- (IBAction)updateB:(id)sender {
    BTSLissajousLayer *layer = (BTSLissajousLayer *)[[[self view] viewWithTag:100] layer]; 
    float value = [(UIStepper *)sender value];
    [_bValueLabel setText:[NSString stringWithFormat:@"%0.0f", [_bStepper value]]];    
    [layer setB:(CGFloat)value];
}


@end

