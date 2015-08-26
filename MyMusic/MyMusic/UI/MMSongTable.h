//
//  MMSongTable.h
//  MyMusic
//
//  Created by sjjwind on 8/12/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MMSongTable : NSView

- (void)setParentView:(NSView *)parentView;

- (void)setFrame:(NSRect)frame;

- (void)setTitle:(NSString *)title;

- (void)setMusicList:(NSArray *)musicList;

@end
