//
//  MusicLyricParser.h
//  MyMusic
//
//  Created by sjjwind on 6/26/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMLyric : NSObject

@property (nonatomic, assign) BOOL isStaticLyric;
@property (nonatomic, assign) BOOL hasLyric;

@property (nonatomic, strong) NSArray *lyrics;

@end

@interface LyricElement : NSObject

@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, strong) NSString *lyric;

@end


@interface MusicLyricParser : NSObject

- (void)parserFromFile:(NSString *)path;
- (MMLyric *)getLyrics;

@end
