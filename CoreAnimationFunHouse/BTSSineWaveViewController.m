//
//  BTSSineWaveViewController.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/15/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSSineWaveViewController.h"
#import "BTSSineWaveLayer.h"

@interface BTSSineWaveViewController () {
    IBOutlet UISlider *__weak _amplitudeSlider;
    IBOutlet UISlider *__weak _frequencySlider;
    IBOutlet UISlider *__weak _phaseSlider;
}

@end

@implementation BTSSineWaveViewController

#pragma mark - Object Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // The sine wave layer uses the following equation to draw the sine wave:
    // y = A * sin(ωt + phase)
    //  where A = amplitude
    //        ω = angular frequency -> (2PI * "width of pie layer" * 8.0); draw up to 8 sine waves in the layer 
    //
    // The "frequency slider" contains the possible angular frequency values so that the layer does not have to 
    // calculate the angular frequency while drawing. 

    BTSSineWaveLayer *layer = [self sineWaveLayer];
    [layer setContentsScale:[[UIScreen mainScreen] scale]];

    CGRect layerBounds = [layer bounds];

    [_amplitudeSlider setMinimumValue:0.0];
    [_amplitudeSlider setMaximumValue:layerBounds.size.height / 2.0 - 5.0];
    [_amplitudeSlider setValue:[_amplitudeSlider maximumValue] / 2.0];

    [_frequencySlider setMinimumValue:0.0];
    [_frequencySlider setMaximumValue:(float)((2 * M_PI / layerBounds.size.width) * 10.0)];
    [_frequencySlider setValue:[_frequencySlider maximumValue] / 2.0];

    [_phaseSlider setMinimumValue:(float)-M_PI];
    [_phaseSlider setMaximumValue:(float)M_PI];
    [_phaseSlider setValue:0.0];

    [layer setAmplitude:[_amplitudeSlider value]];
    [layer setFrequency:[_frequencySlider value]];
    [layer setPhase:[_phaseSlider value]];

    [layer setNeedsDisplay];
}

#pragma mark - User Interaction Methods

- (IBAction)updateAmplitude:(id)sender
{
    BTSSineWaveLayer *layer = [self sineWaveLayer];
    float amplitude = [(UISlider *)sender value];
    [layer setAmplitude:(CGFloat)amplitude];
    [layer setNeedsDisplay];
}

- (IBAction)updateFrequency:(id)sender
{
    BTSSineWaveLayer *layer = [self sineWaveLayer];
    float frequency = [(UISlider *)sender value];
    [layer setFrequency:(CGFloat)frequency];
    [layer setNeedsDisplay];
}

- (IBAction)updatePhase:(id)sender
{
    BTSSineWaveLayer *layer = [self sineWaveLayer];
    float phase = [(UISlider *)sender value];
    [layer setPhase:(CGFloat)phase];
    [layer setNeedsDisplay];
}

- (BTSSineWaveLayer *)sineWaveLayer
{
    return (BTSSineWaveLayer *)[[[self view] viewWithTag:100] layer];
}

@end
