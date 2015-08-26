//
//  MMSongTable.m
//  MyMusic
//
//  Created by sjjwind on 8/12/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMSongTable.h"
#import "MMTableView.h"
#import "MusicInfo.h"
#import "PlayManager.h"
#import "MMSongTableCellView.h"

@interface MMSongTable() <MMSongTableDelegate>

@property (nonatomic, weak) IBOutlet MMTableView *tableView;
@property (nonatomic, weak) IBOutlet NSTextField *titleField;
@property (nonatomic, weak) NSView *parentView;

@property (nonatomic, strong) NSMutableArray *allMusicList;
@property (nonatomic, weak) MMSongTableCellView *previousCellView;

@end

@implementation MMSongTable

- (void)setParentView:(NSView *)parentView {
    _parentView = parentView;
    [self removeFromSuperview];
    [_parentView addSubview:self];
    [self.tableView reloadData];
}

- (void)setFrame:(NSRect)frame {
    _frame = frame;
}

- (void)setMusicList:(NSArray *)musicList {
    self.allMusicList = [NSMutableArray arrayWithArray:musicList];
    [self.tableView reloadData];
}

- (void)setTitle:(NSString *)title {
  self.titleField.stringValue = title;
}

- (void)didClick:(MMSongTableCellView *)cell {
    [cell setIsHighlight:YES];
    if (self.previousCellView != cell) {
        [self.previousCellView setIsHighlight:NO];
    }
    self.previousCellView = cell;
}

- (void)didDClick:(MMSongTableCellView *)cell {
    [[PlayManager sharedManager] setPlayMusicList:[self.allMusicList copy]];
    MusicInfo *clickMusic = self.allMusicList[[cell getIndex]];
    [[PlayManager sharedManager] playMusic:clickMusic];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.allMusicList.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    MMSongTableCellView *cellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];    
    [cellView setIndex:row];
    [cellView setIsHighlight:NO];
    [cellView setDelegate:self];
    MusicInfo *musicInfo = self.allMusicList[row];
    [cellView setMusicName:musicInfo.musicName artistName:musicInfo.musicAuthor];
    [cellView setAlbumName:musicInfo.albumName];
    [cellView setDuration:musicInfo.duration];
    [cellView setMusicImageWithMusicId:musicInfo.musicId];
//    cellView setMusicImage:
    return cellView;
}

@end
