//
//  MMLyricView.h
//  MyMusic
//
//  Created by sjjwind on 6/26/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MMView.h"
#import "MusicInfo.h"

@interface MMLyricView : MMView

- (void)startPlayLyric:(MusicInfo *)music;
- (void)setProgress:(NSTimeInterval)progress;

@end
