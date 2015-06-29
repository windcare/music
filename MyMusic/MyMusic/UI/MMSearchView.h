//
//  MMSearchView.h
//  MyMusic
//
//  Created by sjjwind on 6/25/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MusicInfo.h"

@protocol MMSearchViewDelegate;
@interface MMSearchView : NSView

@property (nonatomic, weak) id<MMSearchViewDelegate> delegate;

- (void)setSearchContent:(NSArray *)content;
- (void)appendToView:(NSView *)view;

- (void)showAtPoint:(NSPoint)pt;
- (void)reloadTableView;
- (void)hidden;

@end

@protocol MMSearchViewDelegate <NSObject>

- (void)didClickMusic:(MusicInfo *)music;

@end
