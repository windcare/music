//
//  NSView+MCAdditions.m
//  MyMusic
//
//  Created by sjjwind on 6/23/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "NSView+MCAdditions.h"

@implementation NSView (MCAdditions)

-(CALayer *)layerFromContents
{
//    return self.layer;
    CALayer *newLayer = [CALayer layer];
    newLayer.bounds = self.bounds;
    NSBitmapImageRep *bitmapRep = [self bitmapImageRepForCachingDisplayInRect:self.bounds];
    [self cacheDisplayInRect:self.bounds toBitmapImageRep:bitmapRep];
    newLayer.contents = (id)bitmapRep.CGImage;
    newLayer.masksToBounds = NO;
    newLayer.backgroundColor = (__bridge CGColorRef)([NSColor whiteColor]);
    newLayer.opacity = 1.0f;
    return newLayer;
}

@end
