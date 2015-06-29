//
//  MMTableCellView.m
//  MyMusic
//
//  Created by sjjwind on 6/23/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMTableCellView.h"
#import "MusicManager.h"

@interface MMTableCellView()

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, weak) IBOutlet NSTextField *musicName;
@property (nonatomic, weak) IBOutlet NSTextField *musicAuthor;
@property (nonatomic, weak) IBOutlet NSTextField *time;
@property (nonatomic, weak) IBOutlet NSImageView *musicCover;

@end

@implementation MMTableCellView

- (void)reloadView {
    [[MusicManager sharedManager] downloadCoverImage:self.musicInfo.musicId complete:^(int errorCode, NSString *path) {
        if (errorCode == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.musicCover setImage:[[NSImage alloc] initWithContentsOfFile:path]];
            });
        }
    }];
    self.musicName.stringValue = self.musicInfo.musicName;
    self.musicAuthor.stringValue = self.musicInfo.musicAuthor;
    self.time.stringValue = [NSString stringWithFormat:@"%ld:%02ld", self.musicInfo.duration / 60, self.musicInfo.duration % 60];
    [self setNeedsDisplay:YES];
}

- (void)setMusicInfo:(MusicInfo *)info {
    _musicInfo = info;
    [self reloadView];
}

@end
