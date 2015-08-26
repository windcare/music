//
//  MMRankPageView.m
//  MyMusic
//
//  Created by sjjwind on 8/11/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMRankPageView.h"
#import "MMRankItemCell.h"
#import "MMRankDelegate.h"
#import "MMSongTable.h"
#import "MusicManager.h"
#import "MainWindowController.h"

const static NSInteger kRankItemRowCount = 5;
const static NSInteger kWidthSeprator = 28;
const static NSInteger kHeightSperator = 20;
const static NSInteger kCellLeftMargin = 16;
const static NSInteger kCellTopMargin = 20;
const static NSInteger kTextHeight = 40;
const static NSInteger kCellHeight = 130;
const static NSInteger kDocumentHeight = 850;

@interface MMRankPageView() <MMRangDelegate>

@property (nonatomic, strong) NSScrollView *channelScrollView;
@property (nonatomic, strong) MMView *contentView;

@end

@implementation MMRankPageView

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self.channelScrollView = [[NSScrollView alloc] initWithFrame:self.frame];
        self.channelScrollView.drawsBackground = NO;
        [self addSubview:self.channelScrollView];
        
        NSRect contentViewRect = { 0, 0, self.frame.size.width, kDocumentHeight };
        NSView *contentView = [[NSView alloc] initWithFrame:contentViewRect];
        [self.channelScrollView setDocumentView:contentView];
        
        self.contentView = [[MMView alloc] initWithFrame:contentViewRect];
        [self.channelScrollView setDocumentView:self.contentView];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setRankInfos:(NSArray *)infos {
    [infos enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
        NSString *imageName = dic[@"image"];
        NSString *title = dic[@"title"];
        NSInteger row = idx / kRankItemRowCount;
        NSInteger col = idx % kRankItemRowCount;
        NSInteger xPoint = kCellLeftMargin + col * (kCellHeight + kWidthSeprator);
        NSInteger yPoint = -kCellTopMargin + kDocumentHeight - (row + 1) * (kCellHeight + kTextHeight + kHeightSperator);
        NSRect cellRect = NSMakeRect(xPoint, yPoint, kCellHeight, kCellHeight + kTextHeight);
        MMRankItemCell *cell = [[MMRankItemCell alloc]initWithFrame:cellRect];
        [cell setCellName:title];
        [cell setCellImage:imageName];
        [cell setDelegate:self];
        [cell setMusicType:idx];
        [self.contentView addSubview:cell];
    }];
    [self.contentView scrollPoint:NSMakePoint(0, kDocumentHeight)];
}

- (void)onClickItem:(MMRankItemCell *)cell {
    MMSongTable *songView = [[MainWindowController sharedMainWindowController] getSongTable];
    MMView *centerView = [[MainWindowController sharedMainWindowController] getCenterView];
    MMRankPageView *rankPageView = [[MainWindowController sharedMainWindowController] getRankPageView];
    [rankPageView removeFromSuperview];
    [[MainWindowController sharedMainWindowController] setCurrentView:songView];
    [songView setParentView:centerView];
    [[MusicManager sharedManager] fetchRankListWithType:[cell getMusicType] complete:^(int errorCode, NSArray *musicList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [songView setMusicList:musicList];
        });
    }];
}

@end
