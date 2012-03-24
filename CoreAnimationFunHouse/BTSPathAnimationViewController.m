//
//  BTSPathAnimationViewController.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/8/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSPathAnimationViewController.h"
#import <QuartzCore/QuartzCore.h>

static const CGPoint kBTSPathEndPoint = {300.0, 300.0};

@interface BTSPathAnimationViewController() {
    CGMutablePathRef _path;
}

@end

// This example shows just how easy it is to animate a layer along an arbitrary path.
@implementation BTSPathAnimationViewController 

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
        CGPathMoveToPoint(_path, NULL, 15.0, 15.0);
        CGPathAddLineToPoint(_path, NULL, 100.0, 100.0);
        CGPathAddArc(_path, NULL, 100.0, 100.0, 75.0, 0.0, (CGFloat) M_PI, 1);
        CGPathAddLineToPoint(_path, NULL, 200.0, 150.0);
        CGPathAddCurveToPoint(_path, NULL, 150.0, 150.0, 50.0, 350.0, kBTSPathEndPoint.x, kBTSPathEndPoint.y);
    }
    
    // This is the layer that animates along the path. 
    CALayer *layer = [CALayer layer];
    
    [layer setShadowColor:[UIColor blackColor].CGColor];
    [layer setContents:(__bridge id)[UIImage imageNamed:@"american-flag.png"].CGImage];
    [layer setBounds:CGRectMake(0.0, 0.0, 75.0, 75.0)];
    [layer setPosition:CGPointMake(15.0, 15.0)];
    [layer setShadowPath:[UIBezierPath bezierPathWithRect:[layer bounds]].CGPath];
    [layer setShadowOpacity:0.8];
    [layer setShadowOffset:CGSizeMake(5.0, 5.0)];
    
    [[[self view] layer] addSublayer:layer];
    
    [self addPathAnimationToLayer:layer shouldRepeat:YES];
    
    // Set the view layer's delegate to the view controller. The delegate simply draws the path.
    [[[self view] layer] setContentsScale:[[UIScreen mainScreen] scale]];
    [[[self view] layer] setDelegate:self];
    [[[self view] layer] setNeedsDisplay];
}

- (void)viewDidUnload
{
    if  (_path) {
        CFRelease(_path);
        _path = nil;
    }
    
    // Yes... I like the brackets.. I am not a fan of the "dot" syntax. :-)
    [[[[[self view] layer] sublayers] objectAtIndex:0] setDelegate:nil];
    
    [super viewDidUnload];
}

#pragma mark - Path Drawing

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

- (IBAction)updateAnimation:(id)sender {
    BOOL shouldRepeat = [(UISwitch *)sender isOn];

    CALayer *layer = [[[[self view] layer] sublayers] objectAtIndex:0];
    [self addPathAnimationToLayer:layer shouldRepeat:shouldRepeat];
}

- (void)addPathAnimationToLayer:(CALayer *)layer shouldRepeat:(BOOL)shouldRepeat
{
    [layer removeAllAnimations];
    
    // To animate along a path is drop-dead easy. 
    // - Create a "key frame animation" for the "position"
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [animation setPath:_path]; // here is the magic!
    [animation setDuration:2.5];

    [animation setCalculationMode:kCAAnimationCubic];
    [animation setRotationMode:kCAAnimationRotateAuto]; // pass nil to turn off rotation model

    if (shouldRepeat) {
        [animation setAutoreverses:YES];
        [animation setRepeatCount:MAXFLOAT];
    } else {
        [animation setAutoreverses:NO];
        [animation setRepeatCount:1];
    
        // NOTE: 
        // Move the layer to end of the path. This will implicitly animate. However, 
        // the implicit animation is replaced when adding the key frame animation to the 
        // layer (see the "addAnimation:forKey:" method below. 
        [layer setPosition:kBTSPathEndPoint];
    }
    
    // Start animating the layer along the path.
    //
    // Important Note:
    // Every layer maintains a map of animations keyed by various property values. 
    // In this case, the key frame animation replaces the "implicit property" animation.
    // This is important in order to override any existing implicit animation caused 
    // by setting the layer's position. 
    [layer addAnimation:animation forKey:@"position"];
}
@end
