//
//  MainWindowController.h
//  MyMusic
//
//  Created by sjjwind on 5/26/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MMWindowController.h"
#import "MusicInfo.h"

@class MMSongTable;
@class MMView;
@class MMRankPageView;
@interface MainWindowController : MMWindowController

+ (MainWindowController *)sharedMainWindowController;

- (MMSongTable *)getSongTable;
- (MMView *)getCenterView;
- (MMRankPageView *)getRankPageView;
- (void)setCurrentView:(NSView *)view;
- (void)startParserLyric:(MusicInfo *)music;
- (void)setMusicName:(NSString *)musicName authorName:(NSString *)artist;
- (void)setDuration:(NSTimeInterval)duration;
- (void)setProgress:(NSTimeInterval)progress;
- (void)setCover:(NSImage *)coverImage;
- (void)setVolumn:(CGFloat)volumn;
- (void)startAnimation;
- (void)stopAnimation;
- (void)setLoveMusic:(BOOL)isMyLove;
- (void)toggleWindow;
- (void)setMusicList:(NSArray *)musicList;
- (void)refreshMusicList;

@end
