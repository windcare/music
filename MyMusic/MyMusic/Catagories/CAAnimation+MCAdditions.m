//
//  CAAnimation+MCAdditions.m
//  MyMusic
//
//  Created by sjjwind on 6/23/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "CAAnimation+MCAdditions.h"

@implementation CAAnimation (MCAdditions)

+(CAAnimation *)flipAnimationWithDuration:(NSTimeInterval)aDuration forLayerBeginningOnTop:(BOOL)beginsOnTop scaleFactor:(CGFloat)scaleFactor {    
    // Rotating halfway (pi radians) around the Y axis gives the appearance of flipping
    CABasicAnimation *flipAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    CGFloat startValue = beginsOnTop ? 0.0f : M_PI;
    CGFloat endValue = beginsOnTop ? -M_PI : 0.0f;
    flipAnimation.fromValue = [NSNumber numberWithDouble:startValue];
    flipAnimation.toValue = [NSNumber numberWithDouble:endValue];
    
    // Shrinking the view makes it seem to move away from us, for a more natural effect
    // Can also grow the view to make it move out of the screen
    CABasicAnimation *shrinkAnimation = nil;
    if ( scaleFactor != 1.0f ) {
        shrinkAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        shrinkAnimation.toValue = [NSNumber numberWithFloat:scaleFactor];
        
        // We only have to animate the shrink in one direction, then use autoreverse to "grow"
        shrinkAnimation.duration = aDuration * 0.5;
        shrinkAnimation.autoreverses = YES;
    }
    
    // Combine the flipping and shrinking into one smooth animation
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = [NSArray arrayWithObjects:flipAnimation, shrinkAnimation, nil];
    
    // As the edge gets closer to us, it appears to move faster. Simulate this in 2D with an easing function
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animationGroup.duration = aDuration;
    
    // Hold the view in the state reached by the animation until we can fix it, or else we get an annoying flicker
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    
    return animationGroup;
}

@end
