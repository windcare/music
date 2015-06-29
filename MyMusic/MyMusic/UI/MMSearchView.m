//
//  MMSearchView.m
//  MyMusic
//
//  Created by sjjwind on 6/25/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMSearchView.h"
#import "MMSearchCellView.h"
#import "MusicInfo.h"
#import <QuartzCore/QuartzCore.h>

@interface MMSearchView() <MMSearchActionDelegate>

@property (nonatomic, weak) IBOutlet NSView *innerView;

@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@property (nonatomic, strong) NSArray *musicList;

@end

@implementation MMSearchView

- (void)setSearchContent:(NSArray *)content {
    self.musicList = content;
}

- (void)appendToView:(NSView *)view {
    [self setWantsLayer:YES];
    [self.innerView setWantsLayer:YES];
    [self.innerView.layer setBackgroundColor:[[NSColor colorWithCalibratedRed:0.945 green:0.957 blue:0.953 alpha:1.0] CGColor]];
    [self.innerView.layer setCornerRadius:4];
    
    [self.layer setOpacity:0.8];
    [self.layer setShadowColor:[[NSColor blackColor] CGColor]];
    [self.layer setShadowOpacity:0.4];
    [self.layer setShadowRadius:2];
    [self.layer setShadowOffset:NSMakeSize(0, -1)];
    [self.layer setMasksToBounds:NO];
    
    [view addSubview:self.self];
    [self setHidden:YES];
}

- (void)showAtPoint:(NSPoint)pt {
    NSInteger musicCount = self.musicList.count < 5 ? self.musicList.count : 5;
    NSRect showRect;
    showRect.origin.x = pt.x;
    showRect.origin.y = pt.y - musicCount * 44;
    showRect.size.width = 300;
    showRect.size.height = musicCount * 44;
    self.tableView.frame = self.frame;
    [self setFrame:showRect];
    [self.tableView reloadData];
    [self setHidden:NO];
}

- (void)reloadTableView {
}

- (void)hidden {
    [self setHidden:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.musicList.count;
}

- (void)click:(MMSearchCellView *)cell {
    [self hidden];
    MusicInfo *info = self.musicList[cell.index];
    if (self.delegate) {
        [self.delegate didClickMusic:info];
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    MMSearchCellView *cellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];    
    cellView.delegate = self;
    cellView.index = row;
    MusicInfo *info = self.musicList[row];
    NSString *showString = [NSString stringWithFormat:@"%@ - %@", info.musicName, info.musicAuthor];
    [cellView setTitle:showString];
    return cellView;
}


@end
