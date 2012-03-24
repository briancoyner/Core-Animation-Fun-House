//
//  BTSReflectionViewController.m
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/4/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import "BTSReflectionViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BTSReflectionViewController() {
    CALayer *_imageLayer;
}

@end

@implementation BTSReflectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //
    // Yes, this is a very long method. I find it easier to explain what is happening by 
    // keeping the code in a single location (instead of breaking it up over multiple methods).
    // 
    
    // Load the image to "reflect"
    UIImage *image = [UIImage imageNamed:@"american-flag.png"];
    
    // The replicator layer is where all of the magic happens
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    [replicatorLayer setContentsScale:[[UIScreen mainScreen] scale]];
    
    // The replicator layer's height is 1.5 times the size of the image. This means that 
    // we will effectively clip/ fade out our "reflection".
    //
    // ********    <- any y-flipping is performed along this plane
    // *  %%  *
    // *      *    image height
    // *  ^^  *
    // ********
    // ========
    // =  ^^  =  + half height (mask to bounds effectively clips the reflected image)
    // =      =
    // 
    //           = total height of layer
    [replicatorLayer setBounds:CGRectMake(0.0, 0.0, [image size].width, [image size].height * 1.5)];
    
    // This ensures that the replicated image is clipped to the replicator's height
    [replicatorLayer setMasksToBounds:YES];
    
    // Position the replicator layer at the top of the view
    // - use the x center point to make the math easy (place in center of view)
    // - use the y upper point to position the layer 10 points below the top of the view (just a little bit of padding)
    [replicatorLayer setAnchorPoint:CGPointMake(0.5, 0.0)];
    [replicatorLayer setPosition:CGPointMake([self view].frame.size.width / 2.0, 10.0)];

    // We need two instances: 
    //   1) the main image layer 
    //   2) a replicated layer for the reflection
    [replicatorLayer setInstanceCount:2];

    // Create a transform used by the replicator layer to "flip" and position our reflected layer below the original image
    //
    // I will see if I can explain this.
    // For clarity... we start with an identity
    CATransform3D transform = CATransform3DIdentity;
       
    // 
    // @*******    <- this is the top of the replicator layer (the X,Y origin is at the @, with Y going down)
    // *  %%  *
    // *      *    
    // *  ^^  *
    // ********    
    //
    //
    // Apply a negative scale to y (effectively flips)
    //
    // For example, hold your right hand in front of your face (knuckles facing you, thumb down). Now flip your 
    // hand up keeping your pinky finger in place (i.e. your pinky is a hinge). 
    //
    // ========    <- will draw a flipped version up here
    // =  ^^  =
    // =      =
    // =  %%  =
    // ========
    // ********    <- the "flip" is performed along here
    // *  %%  *
    // *      *    image height
    // *  ^^  *
    // ********    
    transform = CATransform3DScale(transform, 1.0, -1.0, 1.0);
    
    // translate down by 2x height to position the "flipped" layer below the main layer
    // - 2x moves the flipped image under the main image giving us the "reflection"
    //
    // ********    <- y plane (any flipping is performed along this plane)
    // *  %%  *
    // *      *    image height
    // *  ^^  *
    // ********    
    // ========      
    // =  ^^  =
    // =      =    <-- Remember: only half of the "relection" layer renders because the replicator layer clips to bounds.
    // =  %%  =
    // ========  
    transform = CATransform3DTranslate(transform, 0.0, -[image size].height * 2.0, 1.0);
       
    [replicatorLayer setInstanceTransform:transform];
    
    // Next we create a layer that displays the American flag image.
    _imageLayer = [CALayer layer];
    [_imageLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [_imageLayer setContents:(__bridge id)image.CGImage];
    [_imageLayer setBounds:CGRectMake(0.0, 0.0, [image size].width, [image size].height)];
    [_imageLayer setAnchorPoint:CGPointMake(0.0, 0.0)];

    [replicatorLayer addSublayer:_imageLayer];
    
    // Finally overlay a gradient layer on top of the "reflection" layer. 
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    [gradientLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [gradientLayer setColors:[NSArray arrayWithObjects:(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:0.25].CGColor, [UIColor whiteColor].CGColor, nil]];
    
    // Remember that the reflected layer is half the size, which is why the height of the gradient layer is cut in half.
    [gradientLayer setBounds:CGRectMake(0.0, 0.0, replicatorLayer.frame.size.width, [image size].height * 0.5 + 1.0)];
    [gradientLayer setAnchorPoint:CGPointMake(0.5, 0.0)];
    [gradientLayer setPosition:CGPointMake([self view].frame.size.width / 2, [image size].height + 10.0)];
    [gradientLayer setZPosition:1]; // make sure the gradient is placed on top of the reflection.

    [[[self view] layer] addSublayer:replicatorLayer];
    [[[self view] layer] addSublayer:gradientLayer];
    
    // One final (and fun step): 
    //   Create a text layer that is a sublayer of the image layer.
    //   Core Animation will animate the text in all replicated layers. VERY COOL!!
    CATextLayer *textLayer = [CATextLayer layer];
    [textLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [textLayer setString:@"U.S.A."];
    [textLayer setFontSize:38];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setShadowColor:[UIColor blackColor].CGColor];
    [textLayer setShadowOpacity:1.0];
    [textLayer setShadowOffset:CGSizeMake(-4.0, -4.0)];
    [textLayer setBounds:CGRectMake(0.0, 0.0, [_imageLayer frame].size.width, 30.0)];
    [textLayer setPosition:CGPointMake([_imageLayer frame].size.width / 2.0, [_imageLayer frame].size.height - 25.0)];
    [textLayer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [_imageLayer addSublayer:textLayer];
    
    // When the user taps, start animating the image's text layer up and down.
    [[self view] setUserInteractionEnabled:YES];
    [[self view] setMultipleTouchEnabled:YES];
    [[self view] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateTextLayer:)]];
}

- (void)animateTextLayer:(UIGestureRecognizer *)recognizer
{   
    CALayer *textLayer = (CALayer *)[[_imageLayer sublayers] objectAtIndex:0];
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position.y"];
    
    CGFloat halfBoxHeight = [textLayer frame].size.height / 2.0;
    [anim setFromValue:[NSNumber numberWithFloat:[textLayer frame].origin.y + halfBoxHeight]];
    [anim setToValue:[NSNumber numberWithFloat:halfBoxHeight]];
    [anim setDuration:3.0];
    [anim setRepeatCount:MAXFLOAT];
    [anim setAutoreverses:YES];
    
    [textLayer addAnimation:anim forKey:nil];

}

@end
