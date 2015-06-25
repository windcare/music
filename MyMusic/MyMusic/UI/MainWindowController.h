//
//  MainWindowController.h
//  MyMusic
//
//  Created by sjjwind on 5/26/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MMWindowController.h"

@interface MainWindowController : MMWindowController

+ (MainWindowController *)sharedMainWindowController;

- (void)setMusicName:(NSString *)musicName authorName:(NSString *)artist;
- (void)setDuration:(NSTimeInterval)duration;
- (void)setProgress:(NSTimeInterval)progress;
- (void)setCover:(NSImage *)coverImage;
- (void)setVolumn:(CGFloat)volumn;
- (void)startAnimation;
- (void)stopAnimation;

- (void)toggleWindow;

@end
