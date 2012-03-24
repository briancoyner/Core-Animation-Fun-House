//
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <stdio.h>
#import "BTSCoreGraphics.h"

static void BTSPrintCurrentCTM(CGContextRef context) 
{
    CGAffineTransform t = CGContextGetCTM(context);
    fprintf(stderr, "Current CTM: a=%f, b=%f, c=%f, d=%f, tx=%f, ty=%f\n", t.a, t.b, t.c, t.d, t.tx, t.ty);
}

static void BTSDrawPoint(CGContextRef context, CGPoint point)
{
    CGContextSaveGState(context);
    
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    CGContextSetLineWidth(context, 5);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGContextMoveToPoint(context, point.x, point.y);
    CGContextAddLineToPoint(context, point.x, point.y);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    
}

static const float kBTSTickLength = 5.0;
static const float kAxesLength = 1000;

static void BTSDrawCoordinateAxes(CGContextRef context)
{
    CGContextSaveGState(context);
    
    CGContextBeginPath(context);
    
    // Paint the X axis green
    CGContextSetRGBStrokeColor(context, 0, 1, 0, 1);
    CGContextMoveToPoint(context, -kBTSTickLength, 0.0);
    CGContextAddLineToPoint(context, kAxesLength, 0.0);
    CGContextDrawPath(context, kCGPathStroke);
    
    // Paint the Y axis red
    CGContextSetRGBStrokeColor(context, 1, 0, 0, 1);
    CGContextMoveToPoint(context, 0.0, -kBTSTickLength);
    CGContextAddLineToPoint(context, 0.0, kAxesLength);
    CGContextDrawPath(context, kCGPathStroke);
    
    
    CGContextRestoreGState(context);
}

