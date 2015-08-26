//
//  MMSongTableCellView.m
//  MyMusic
//
//  Created by sjjwind on 8/12/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMSongTableCellView.h"
#import "MusicManager.h"

static const NSInteger kMaxRetryCount = 3;

@interface MMSongTableCellView()

@property (nonatomic, assign) BOOL isHightlight;
@property (nonatomic, assign) NSInteger songIndex;
@property (nonatomic, assign) NSTimeInterval lastClickTime;
@property (nonatomic, assign) NSInteger clickCount;

@property (nonatomic, weak) IBOutlet NSTextField *indexField;
@property (nonatomic, weak) IBOutlet NSTextField *songNameField;
@property (nonatomic, weak) IBOutlet NSTextField *albumNameField;
@property (nonatomic, weak) IBOutlet NSTextField *durationField;
@property (nonatomic, weak) IBOutlet NSTextField *backgroundField;
@property (nonatomic, weak) IBOutlet NSImageView *musicImageView;

@end

@implementation MMSongTableCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setIsHighlight:(BOOL)isHightLight {
    self.isHightlight = isHightLight;
    if (isHightLight) {
        [self.backgroundField setBackgroundColor:[NSColor colorWithCalibratedRed:0.149 green:0.729 blue:0.376 alpha:1.0]];
        self.songNameField.textColor = [NSColor whiteColor];
        self.albumNameField.textColor = [NSColor whiteColor];
        self.durationField.textColor = [NSColor whiteColor];
        self.indexField.textColor = [NSColor whiteColor];
    } else {
        [self.backgroundField setBackgroundColor:[NSColor clearColor]];
        NSColor *textColor = [NSColor colorWithCalibratedRed:0.345 green:0.345 blue:0.345 alpha:1.0];
        self.songNameField.textColor = textColor;
        self.albumNameField.textColor = textColor;
        self.durationField.textColor = textColor;
        self.indexField.textColor = textColor;
    }
}

- (BOOL)getIsHighlight {
    return self.isHightlight;
}

- (void)setMusicName:(NSString *)musicName artistName:(NSString *)artistName {
  NSString *showName = nil;
  if (artistName.length) {
    showName = [NSString stringWithFormat:@"%@ - %@", musicName, artistName];
  } else {
    showName = musicName;
  }
  self.songNameField.stringValue = showName;
}

- (void)setAlbumName:(NSString *)albumName {
  self.albumNameField.stringValue = albumName;
}

- (void)setDuration:(NSInteger)duration {
  self.durationField.stringValue = [NSString stringWithFormat:@"%ld:%02ld", duration / 60, duration % 60];
}

- (void)setIndex:(NSInteger)index {
  self.songIndex = index;
  self.indexField.stringValue = [NSString stringWithFormat:@"%ld", index];
}

- (NSInteger)getIndex {
    return self.songIndex;
}

- (void)setMusicImageWithMusicId:(NSInteger)musicId {
    [self.musicImageView setImage:nil];
    [self downloadThumbnail:musicId retryCount:0];
}

- (void)downloadThumbnail:(NSInteger)musicId retryCount:(NSInteger)retryCount {
    if (retryCount == kMaxRetryCount) {
        NSLog(@"Image Error: %ld", musicId);
        return;
    }
    retryCount++;
    [[MusicManager sharedManager] downloadCoverImage:musicId complete:^(int errorCode, NSString *path) {
        if (errorCode == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
                if (image != nil) {
                    [self.musicImageView setImage:image];
                } else {
                    [self downloadThumbnail:musicId retryCount:retryCount];
                }
            });
        } else {
            [self downloadThumbnail:musicId retryCount:retryCount];
            NSLog(@"Download Error: %d", errorCode);
        }
    }];
}

- (void)setMusicImage:(NSImage *)image {
  [self.musicImageView setImage:image];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (self.delegate) {
        [self.delegate didClick:self];
    }
    self.clickCount++;
    if (self.clickCount == 2) {
        self.clickCount = 0;
        if ([self.delegate respondsToSelector:@selector(didDClick:)]) {
            [self.delegate didDClick:self];
        }
    }
}

@end
