//
//  BTSAnchorPointLayer.h
//  CoreAnimationFunHouse
//
//  Created by Brian Coyner on 10/13/11.
//  Copyright (c) 2011 Brian Coyner. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

// Convenience function to calculate a point within the superlayer's coordinate system representing the given layer's anchor point.
// - x = superLayerBounds.size.width * anchorPoint.x
// - y = superLayerBounds.size.height * anchorPoint.y

extern CGPoint BTSCalculateAnchorPointPositionForLayer(CALayer *superLayer);

@interface BTSAnchorPointLayer : CALayer

@end
