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
@property (nonatomic, assign) NSInteger retryCount; 
@end

@implementation MMTableCellView

- (void)reloadView {
    [[MusicManager sharedManager] downloadCoverImage:self.musicInfo.musicId complete:^(int errorCode, NSString *path) {
        if (errorCode == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
                if (image == nil) {
                    self.retryCount++;
                    if (self.retryCount >= 3) {
                        
                    }
                    else {
                        [self performSelector:@selector(reloadView) withObject:nil afterDelay:1];
                        NSLog(@"图片下载失败");
                    }
                } else {
                    self.retryCount = 0;
                    [self.musicCover setImage:[[NSImage alloc] initWithContentsOfFile:path]];
                }
            });
        }
        else {
            if (errorCode < 0 && self.retryCount < 3) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.retryCount++;
                    [self performSelector:@selector(reloadView) withObject:nil afterDelay:1];
                });
            } else {
                [self.musicCover setImage:[NSImage imageNamed:@"disk"]];
                self.retryCount = 0;
                NSLog(@"图片下载失败");
            }
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
