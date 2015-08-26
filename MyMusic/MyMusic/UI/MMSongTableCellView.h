//
//  MMSongTableCellView.h
//  MyMusic
//
//  Created by sjjwind on 8/12/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MMSongTableDelegate;
@interface MMSongTableCellView : NSTableCellView

@property (nonatomic, assign) id<MMSongTableDelegate> delegate;

- (void)setIsHighlight:(BOOL)isHightLight;

- (BOOL)getIsHighlight;

- (void)setMusicName:(NSString *)musicName artistName:(NSString *)artistName;

- (void)setAlbumName:(NSString *)albumName;

- (void)setDuration:(NSInteger)duration;

- (void)setIndex:(NSInteger)index;

- (NSInteger)getIndex;

- (void)setMusicImageWithMusicId:(NSInteger)musicId;

- (void)setMusicImage:(NSImage *)image;

@end

@protocol MMSongTableDelegate <NSObject>

- (void)didClick:(MMSongTableCellView *)cell;

@optional
- (void)didDClick:(MMSongTableCellView *)cell;

@end
