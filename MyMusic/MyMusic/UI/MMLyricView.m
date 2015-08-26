//
//  MMLyricView.m
//  MyMusic
//
//  Created by sjjwind on 6/26/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMLyricView.h"
#import "MMTableView.h"
#import "MMLyricTableCellView.h"
#import "MusicManager.h"
#import "MusicLyricParser.h"

@interface MMLyricView()

@property (nonatomic, weak) IBOutlet MMTableView *lyricView;
@property (nonatomic, assign) BOOL hasError;
@property (nonatomic, strong) MMLyric *lyric;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger retryCount;
@property (nonatomic, weak) IBOutlet NSTextField *informationField;

@end

@implementation MMLyricView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
    }
    return self;
}

- (void)startPlayLyric:(MusicInfo *)music {
    [[MusicManager sharedManager] downloadLyric:music.musicId complete:^(int errorCode, NSString *path) {
        if (errorCode == 0) {
            self.retryCount = 0;
            MusicLyricParser *parser = [[MusicLyricParser alloc] init];
            [parser parserFromFile:path];
            self.lyric = [parser getLyrics];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.lyric.hasLyric) {
                    [self.informationField setHidden:YES];
                } else {
                    [self.informationField setHidden:NO];
                }
                self.currentIndex = 0;
                [self.lyricView reloadData];
            });
        }
        else {
            if (errorCode < 0 && self.retryCount < 3) {
                self.retryCount++;
                NSLog(@"拉取歌曲，网络错误");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSelector:@selector(startPlayLyric:) withObject:music afterDelay:1];
                });
            } else {
                [self.informationField setHidden:YES];
                self.retryCount = 0;
                self.lyric.hasLyric = YES;
                self.lyric.lyrics = [NSArray array];
                self.hasError = YES;
                NSLog(@"无歌词");
            }
        }
    }];
}

- (void)setProgress:(NSTimeInterval)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.lyric.hasLyric && !self.lyric.isStaticLyric) {
            NSInteger nowIndex = 0;
            while (nowIndex + 1 < self.lyric.lyrics.count) {
                LyricElement *lyric = self.lyric.lyrics[nowIndex+ 1];
                NSTimeInterval nextTime = lyric.currentTime;
                if (progress < nextTime) {
                    if (nowIndex != self.currentIndex) {
                        [self scrollToIndex:nowIndex];
                    }
                    break;
                }
                nowIndex++;
            }
        }
    });
}

- (void)scrollToIndex:(NSInteger)index {
    [self scrollRowToCenter:index];
    MMLyricTableCellView *previousCell = [self.lyricView viewAtColumn:0 row:self.currentIndex makeIfNecessary:NO];
    [previousCell unSelect];
    self.currentIndex = index;
    MMLyricTableCellView *cell = [self.lyricView viewAtColumn:0 row:index makeIfNecessary:NO];
    [cell select];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.lyric.lyrics.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    MMLyricTableCellView *cellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];    
    [cellView unSelect];
    LyricElement *element = self.lyric.lyrics[row];
    [cellView setLyric:element.lyric];
    return cellView;
}

- (void)scrollRowToCenter:(NSUInteger)index {
    NSRect rowRect       = [self.lyricView rectOfRow:index];
    NSRect viewRect      = self.lyricView.enclosingScrollView.contentView.bounds;
    NSPoint scrollOrigin = rowRect.origin;
    
    scrollOrigin.y = round(scrollOrigin.y + (rowRect.size.height - viewRect.size.height) / 2);
    if (scrollOrigin.y < 0) {
        scrollOrigin.y = 0;
    }
    
    [self.lyricView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSet]];
            
    [self.lyricView.enclosingScrollView.contentView.animator setBoundsOrigin:scrollOrigin];
    [self.lyricView setNeedsDisplay:YES];
}

@end
