//
//  BTSPathAnimationViewController.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/8/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSPathAnimationViewController.h"
#import <QuartzCore/QuartzCore.h>

//
// This example shows just how easy it is to animate a layer along an arbitrary path.
@implementation BTSPathAnimationViewController {
    CGMutablePathRef _path;
}

- (void)dealloc
{
    if (_path) {
        CFRelease(_path);
    }
    [[[[[self view] layer] sublayers] objectAtIndex:0] setDelegate:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    {   // Create a path to animate a layer on. We will also draw the path.
        _path = CGPathCreateMutable();
        CGPathMoveToPoint(_path, NULL, 15, 15);
        CGPathAddLineToPoint(_path, NULL, 100, 100);
        CGPathAddArc(_path, NULL, 100, 100, 75, 0.0, M_PI, 1);
        CGPathAddLineToPoint(_path, NULL, 200, 150);
        CGPathAddCurveToPoint(_path, NULL, 150, 150, 50, 350, 300, 300);
    }
    
    // This is the layer that animates along the path. 
    CALayer *layer = [CALayer layer];

    [layer setShadowColor:[UIColor blackColor].CGColor];
    [layer setContents:(id)[UIImage imageNamed:@"american-flag.png"].CGImage];
    [layer setBounds:CGRectMake(0, 0, 75, 75)];
    [layer setPosition:CGPointMake(15, 15)];
    [layer setShadowPath:[UIBezierPath bezierPathWithRect:[layer bounds]].CGPath];
    [layer setShadowOpacity:0.8];
    [layer setShadowOffset:CGSizeMake(5.0, 5.0)];
    
    [[[self view] layer] addSublayer:layer];

    // To animate along a path is drop-dead easy. 
    // - Create a "key frame animation" for the "position"
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [animation setPath:_path]; // here is the magic!
    [animation setDuration:5.0];
    [animation setAutoreverses:YES];
    [animation setCalculationMode:kCAAnimationCubic];
    [animation setRotationMode:kCAAnimationRotateAuto]; // pass nil to turn off rotation model
    [animation setRepeatCount:MAXFLOAT];
    
    // start animating the layer along the path.
    [layer addAnimation:animation forKey:nil];
    
    // Set the view layer's delegate to the view controller. The delegate simply draws the path.
    [[[self view] layer] setContentsScale:[[UIScreen mainScreen] scale]];
    [[[self view] layer] setDelegate:self];
    [[[self view] layer] setNeedsDisplay];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    if  (_path) {
        CFRelease(_path);
        _path = nil;
    }
    
    // Yes... I like the brackets.. I am not a fan of the "dot" syntax. :-)
    [[[[[self view] layer] sublayers] objectAtIndex:0] setDelegate:nil];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{  
    CGContextAddPath(ctx, _path);
    CGContextSetShadow(ctx, CGSizeMake(2.5, 2.5), 2.0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
    CGContextStrokePath(ctx);
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
