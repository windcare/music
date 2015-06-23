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

@end

@implementation MyPlayer

- (instancetype)init {
    if (self = [super init]) {
        MusicFile *music = [[MusicFile alloc] init];
        music.albumName = @"好的";
        music.artistName = @"嗯";
        music.musicId = 251;
        music.audioFileURL = [[NSURL alloc] initWithString:@"http://yinyueshiting.baidu.com/data2/music/31920734/27913422320024.m4a?xcode=69404bd53a8251ceed71fcb93a5bbd78517fef1ee82b5622"];
        self.streamer = [DOUAudioStreamer streamerWithAudioFile:music];
//        [self.streamer play];
//        [self.streamer pause];
//        [self.streamer setCurrentTime:100];
        [self.streamer play];
    }
    return self;
}

- (void)setPlayList:(NSArray *)musicList {
    
}

- (void)play {
    
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
