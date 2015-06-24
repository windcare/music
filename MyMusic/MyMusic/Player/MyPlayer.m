//
//  MyPlayer.m
//  MyMusic
//
//  Created by sjjwind on 5/14/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MyPlayer.h"
#import "MusicFile.h"
#import "DOUAudioStreamer.h"

@interface MyPlayer()

@property (nonatomic, strong) DOUAudioStreamer *streamer;
@property (nonatomic, strong) NSMutableArray *playList;

@end

@implementation MyPlayer

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)setMusicList:(NSArray *)musicList {
    _playList = [NSMutableArray arrayWithArray:musicList];
}

- (void)play {
    dispatch_async(dispatch_get_main_queue(), ^{
        MusicFile *music = self.playList[0];
        self.streamer = [DOUAudioStreamer streamerWithAudioFile:music];
        [self.streamer play];
    });
}

- (void)pause {
    
}

- (void)stop {
    
}

- (void)playNext {
    
}

- (void)playPrevious {
    
}

@end
