//
//  PlayManager.m
//  MyMusic
//
//  Created by sjjwind on 6/24/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "PlayManager.h"
#import "MyPlayer.h"
#import "MusicManager.h"

@interface PlayManager() <MyPlayerDelegate>

@property (nonatomic, strong) NSMutableArray *musicList;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) MyPlayer *player;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation PlayManager

- (instancetype)init {
    if (self = [super init]) {
        self.musicList = [NSMutableArray array];
        self.player = [[MyPlayer alloc] init];
        self.player.delegate = self;
    }
    return self;
}

+ (instancetype) sharedManager {
    static dispatch_once_t onceToken;
    static PlayManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[PlayManager alloc] init];
    });
    
    return manager;
}

- (void)addPlayMusic:(MusicInfo *)musicInfo {
    [self.musicList addObject:musicInfo];
}

- (void)addPlayMusicList:(NSArray *)musicInfos {
    [self.musicList addObjectsFromArray:musicInfos];
}

- (void)setPlayMusicList:(NSArray *)musicInfos {
    self.musicList = [NSMutableArray arrayWithArray:musicInfos];
    self.currentIndex = 0;
}

- (void)playMusic:(MusicInfo *)musicInfo {
    [self.musicList enumerateObjectsUsingBlock:^(MusicInfo *info, NSUInteger idx, BOOL *stop) {
        if (info.musicId == musicInfo.musicId) {
            self.currentIndex = idx;
            *stop = YES;
        }
    }];
    [self.controller setDuration:(NSTimeInterval)musicInfo.duration];
    [self.controller setProgress:0.0f];
    [self.controller setMusicName:musicInfo.musicName authorName:musicInfo.musicAuthor];
    [[MusicManager sharedManager] downloadMusic:musicInfo.musicId complete:^(int errorCode, NSString *path) {
        if (errorCode == -1) {
            MusicFile *musicFile = [[MusicFile alloc] init];
            musicFile.audioFileURL = [NSURL URLWithString:path];
            [self.player play:musicFile]; 
            [self.controller startParserLyric:musicInfo];
        }
        else {
            
        }
    }];
    [[MusicManager sharedManager] downloadCoverImage:musicInfo.musicId complete:^(int errorCode, NSString *path) {
        [self.controller setCover:[[NSImage alloc] initWithContentsOfFile:path]];
    }];
}

- (void)playNext {
    if (self.currentIndex + 1 < self.musicList.count) {
        self.currentIndex++;
        MusicInfo *musicInfo = self.musicList[self.currentIndex];
        [self playMusic:musicInfo];
    }
}

- (void)playPrevious {
    if (self.currentIndex - 1 >= 0) {
        self.currentIndex--;
        MusicInfo *musicInfo = self.musicList[self.currentIndex];
        [self playMusic:musicInfo];    
    }
}

- (void)setVolumn:(double)value {
}

- (void)pause {
    [self.player pause];
}

- (void)play {
    [self.player resume];
}

- (void)setProgress:(NSInteger)progress {
    [self.player setProgress:progress];
}

// play
- (void)onPlaying {
    [self startTimer];
    [self.controller startAnimation];
}

- (void)onPaused {
    [self stopTimer];
    [self.controller stopAnimation];
}

- (void)onStoped {
    [self stopTimer];
    [self.controller stopAnimation];
}

- (void)onIdle {
    [self stopTimer];
}

- (void)onFinished {
    [self stopTimer];
    [self.controller stopAnimation];
    [self playNext];
}

- (void)onError {
    [self stopTimer];
}

- (void)startTimer {
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(handleMaxShowTimer:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer fire];
        self.timer = nil;
    }
}

-(void)handleMaxShowTimer:(NSTimer *)theTimer {
    NSTimeInterval progress = [self.player getProgress];
    [self onProgress:progress];
}

- (void)onProgress:(NSTimeInterval)progress {
    [self.controller setProgress:progress];
}

@end
