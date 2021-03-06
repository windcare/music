//
//  CAAnimation+MCAdditions.h
//  MyMusic
//
//  Created by sjjwind on 6/23/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (MCAdditions)

+(CAAnimation *)flipAnimationWithDuration:(NSTimeInterval)duration forLayerBeginningOnTop:(BOOL)beginsOnTop scaleFactor:(CGFloat)scaleFactor;

@end
