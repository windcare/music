//
//  MMWindowController.h
//  MyMusic
//
//  Created by sjjwind on 5/27/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum : NSInteger {
    PushTypeFromLeft = 0x01,
    PushTypeFromRight = 0x02,
}PushType;

@interface MMWindowController : NSWindowController

- (void)setRootView:(NSView *)rootView;

- (void)pushView:(NSView *)view animated:(BOOL)animated;

- (void)popViewAnimated:(BOOL)animated;

- (void)popToRootViewAnimated:(BOOL)animated;

- (void)pushSmallView:(NSView *)pushView fromView:(NSView *)fromView type:(PushType)type;

@end
