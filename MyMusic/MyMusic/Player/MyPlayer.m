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

static NSString *MMAudioCoreStatusKeyPath = @"status";
static NSString *MMAudioCoreDurationKeyPath = @"duration";
static NSString *MMAudioCoreBufferingRatioKeyPath = @"bufferingRatio";

static void *MMAudioCoreStatusContext = &MMAudioCoreStatusContext;
static void *MMAudioCoreDurationContext = &MMAudioCoreDurationContext;
static void *MMAudioCoreBufferingRatioContext = &MMAudioCoreBufferingRatioContext;

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

- (void)dealloc {
    [self removeKVOsIfNeeded];
}

- (void)addKVOs {
    if (self.streamer) {
        [self.streamer addObserver:self
                        forKeyPath:MMAudioCoreStatusKeyPath
                           options:NSKeyValueObservingOptionNew
                           context:MMAudioCoreStatusContext];
        
        [self.streamer addObserver:self
                        forKeyPath:MMAudioCoreDurationKeyPath
                           options:NSKeyValueObservingOptionNew
                           context:MMAudioCoreDurationContext];
        
        [self.streamer addObserver:self
                        forKeyPath:MMAudioCoreBufferingRatioKeyPath
                           options:NSKeyValueObservingOptionNew
                           context:MMAudioCoreBufferingRatioContext];
    }
}

- (void)removeKVOsIfNeeded {
    if (self.streamer) {
        [self.streamer removeObserver:self
                           forKeyPath:MMAudioCoreStatusKeyPath
                              context:MMAudioCoreStatusContext];
        
        [self.streamer removeObserver:self
                           forKeyPath:MMAudioCoreDurationKeyPath
                              context:MMAudioCoreDurationContext];
        
        [self.streamer removeObserver:self
                           forKeyPath:MMAudioCoreBufferingRatioKeyPath
                              context:MMAudioCoreBufferingRatioContext];
    }
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == MMAudioCoreStatusContext) {
        [self performSelectorOnMainThread:@selector(handleStatusChange)
                               withObject:nil
                            waitUntilDone:NO];
    } else if (context == MMAudioCoreDurationContext) {
        [self performSelectorOnMainThread:@selector(handleDurationChange)
                               withObject:nil
                            waitUntilDone:NO];
    } else if (context == MMAudioCoreBufferingRatioContext) {
        [self performSelectorOnMainThread:@selector(handleBufferingRatioChange)
                               withObject:nil
                            waitUntilDone:NO];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - Status Change Handler

- (void)handleStatusChange {
    switch (self.streamer.status) {
        case DOUAudioStreamerPlaying:
            if ([self.delegate respondsToSelector:@selector(onPlaying)]) {
                [self.delegate onPlaying];
            }
            break;
        case DOUAudioStreamerPaused:
            if ([self.delegate respondsToSelector:@selector(onPaused)]) {
                [self.delegate onPaused];
            }
            break;
        case DOUAudioStreamerIdle:
            if ([self.delegate respondsToSelector:@selector(onIdle)]) {
                [self.delegate onIdle];
            }
            break;
        case DOUAudioStreamerFinished:
            if ([self.delegate respondsToSelector:@selector(onFinished)]) {
                [self.delegate onFinished];
            }
            break;
        case DOUAudioStreamerBuffering:
            break;
        case DOUAudioStreamerError:
            if ([self.delegate respondsToSelector:@selector(onError)]) {
                [self.delegate onError];
            }
            break;
    }
}

- (void)handleDurationChange {
}

- (void)handleBufferingRatioChange {
}


- (void)setMusicList:(NSArray *)musicList {
    _playList = [NSMutableArray arrayWithArray:musicList];
}

- (void)play:(MusicFile *)music {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeKVOsIfNeeded];
        self.streamer = [DOUAudioStreamer streamerWithAudioFile:music];
        [self addKVOs];
        [self.streamer play];
    });
}

- (void)resume {
    [self.streamer play];
}

- (void)pause {
    [self.streamer pause];
}

- (void)stop {
    [self.streamer stop];
}

- (void)setVolumn:(double)value {
    [self.streamer setVolume:value];
}

- (double)getVolumn {
    return self.streamer.volume;
}

- (void)setProgress:(NSTimeInterval)progress {
    self.streamer.currentTime = progress;
}

- (NSTimeInterval)getProgress {
    return self.streamer.currentTime;
}

- (NSInteger)getTotalTime {
    return self.streamer.duration;
}

@end
