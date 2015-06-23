//
//  MMWindowController.h
//  MyMusic
//
//  Created by sjjwind on 5/27/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MMWindowController : NSWindowController

- (void)setRootView:(NSView *)rootView;

- (void)pushView:(NSView *)view animated:(BOOL)animated;

- (void)popViewAnimated:(BOOL)animated;

- (void)popToRootViewAnimated:(BOOL)animated;

@end
