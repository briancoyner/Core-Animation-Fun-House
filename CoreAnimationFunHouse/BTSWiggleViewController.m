//
//  BTSWiggleViewController.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/5/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSWiggleViewController.h"
#import "CALayer+WiggleAnimationAdditions.h"

@implementation BTSWiggleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self view] setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    
    CALayer *layer = [CALayer layer];
    [layer setContents:(__bridge id)[UIImage imageNamed:@"american-flag.png"].CGImage];
    [layer setContentsScale:[[UIScreen mainScreen] scale]];
    [layer setBounds:CGRectMake(0.0, 0.0, 200.0, 200.0)];

    CGRect viewBounds = [[self view] frame];
    [layer setPosition:CGPointMake(viewBounds.size.width / 2.0, viewBounds.size.height / 2.0 - viewBounds.origin.y)];
    [layer setShadowColor:[UIColor blackColor].CGColor];
    [layer setShadowOpacity:0.9];
    [layer setShadowRadius:[layer bounds].size.width / 18.0];
    [layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    [layer setShadowPath:[UIBezierPath bezierPathWithRect:[layer bounds]].CGPath];
    
    [[[self view] layer] addSublayer:layer];
    
    // Start wiggling after pressing anywhere in the view for a "long" time
    UILongPressGestureRecognizer *startWiggling = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startWiggling:)];
    [[self view] addGestureRecognizer:startWiggling];

    // Double-tap anywhere in the view to stop wiggling
    UITapGestureRecognizer *stopWiggling = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopWiggling:)];
    [stopWiggling setNumberOfTapsRequired:2];
    [[self view] addGestureRecognizer:stopWiggling];
}

- (void)startWiggling:(UIGestureRecognizer *)gesture
{
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        CALayer *wiggleLayer = [[[[self view] layer] sublayers] lastObject];
        [wiggleLayer bts_startWiggling];
    }
}

- (void)stopWiggling:(UIGestureRecognizer *)gesture
{
    // remember discrete gestures are simply recognized
    if ([gesture state] == UIGestureRecognizerStateRecognized) {
        CALayer *wiggleLayer = [[[[self view] layer] sublayers] lastObject];
        [wiggleLayer bts_stopWiggling];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end