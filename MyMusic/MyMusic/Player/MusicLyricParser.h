//
//  MusicLyricParser.h
//  MyMusic
//
//  Created by sjjwind on 6/26/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LyricElement : NSObject

@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, strong) NSString *lyric;

@end


@interface MusicLyricParser : NSObject

- (void)parserFromFile:(NSString *)path;
- (NSArray *)getLyrics;

@end
