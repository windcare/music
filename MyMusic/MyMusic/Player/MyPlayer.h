//
//  MyPlayer.h
//  MyMusic
//
//  Created by sjjwind on 5/14/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicFile.h"

@protocol MyPlayerDelegate <NSObject>

// play
- (void)onPlaying;
- (void)onPaused;
- (void)onStoped;
- (void)onIdle;
- (void)onFinished;
- (void)onError;
- (void)onDownloadComplete;

@end

@interface MyPlayer : NSObject

@property (nonatomic, strong) id<MyPlayerDelegate> delegate;

- (void)play:(MusicFile *)music;
- (void)resume;
- (void)pause;
- (void)stop;
- (void)setVolumn:(double)value;
- (double)getVolumn;
- (void)setProgress:(NSTimeInterval)progress;
- (NSTimeInterval)getProgress;
- (NSInteger)getTotalTime;
- (NSURL *)getCacheFilePath;
- (BOOL)isPlaying;

@end
