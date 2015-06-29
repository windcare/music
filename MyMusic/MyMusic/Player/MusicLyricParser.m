//
//  MusicLyricParser.m
//  MyMusic
//
//  Created by sjjwind on 6/26/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MusicLyricParser.h"

@implementation LyricElement

@end

@interface MusicLyricParser()

@property (nonatomic, strong) NSMutableArray *lyrics;

@end

@implementation MusicLyricParser

- (void)parserFromFile:(NSString *)path {
    NSError *error = nil;
    NSString *fileConetnt = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        return;
    }
    NSArray *lines = [fileConetnt componentsSeparatedByString:@"\r\n"];
    if (lines.count == 1) {
        lines = [fileConetnt componentsSeparatedByString:@"\n"];
    }
    self.lyrics = [NSMutableArray array];
    [lines enumerateObjectsUsingBlock:^(NSString *lyric, NSUInteger idx, BOOL *stop) {
        if (lyric.length == 3) {
            return;
        }
        if ([lyric hasPrefix:@"[ti"] || [lyric hasPrefix:@"[ar"] || [lyric hasPrefix:@"[al"] || [lyric hasPrefix:@"[by"] || [lyric hasPrefix:@"[offset"] ) {
            
        }
        else {
            if (lyric.length) {
                NSString *minuteStr = [lyric substringWithRange:NSMakeRange(1, 2)];
                NSInteger minute = [minuteStr integerValue];
                NSString *secondStr = [lyric substringWithRange:NSMakeRange(4, 2)];
                NSInteger second = [secondStr integerValue];
                NSString *millSecondStr = [lyric substringWithRange:NSMakeRange(7, 2)];
                NSInteger millSecond = [millSecondStr integerValue];
                NSString *showString = [lyric substringFromIndex:10];
                LyricElement *element = [[LyricElement alloc] init];
                element.currentTime = minute * 60 + second + 0.01 * millSecond;
                element.lyric = showString;
                [self.lyrics addObject:element];
            }
        }
    }];
    NSLog(@"lines");
}

- (NSArray *)getLyrics {
    return [self.lyrics copy];
}

@end
