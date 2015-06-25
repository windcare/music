//
//  PlayManager.h
//  MyMusic
//
//  Created by sjjwind on 6/24/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MusicInfo.h"
#import "MainWindowController.h"

@interface PlayManager : NSObject

@property (nonatomic, weak) MainWindowController *controller;

+ (instancetype)sharedManager;

- (void)addPlayMusic:(MusicInfo *)musicInfo;
- (void)addPlayMusicList:(NSArray *)musicInfos;
- (void)setPlayMusicList:(NSArray *)musicInfos;
- (void)playMusic:(MusicInfo *)musicInfo;

- (void)playNext;

- (void)playPrevious;

- (void)setVolumn:(double)value;

- (void)pause;

- (void)play;

- (void)setProgress:(NSInteger)progress;

@end
