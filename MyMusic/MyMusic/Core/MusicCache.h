//
//  MusicCache.h
//  MyMusic
//
//  Created by sjjwind on 6/24/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    CacheResourceType_BigCover = 0x01,
    CacheResourceType_SmallCover = 0x02,
    CacheResourceType_Lyric = 0x03,
    CacheResourceType_Music = 0x04,
} CacheResourceType;

@interface MusicCache : NSObject

+ (instancetype) sharedCache;

- (void)setCacheMaxSize:(NSInteger)maxSize;

- (NSString *)getResourcePathWithMusicId:(NSInteger)musicId resourceType:(CacheResourceType)type;

- (NSString *)cacheResourceWithMusicId:(NSInteger)musicId resourceType:(CacheResourceType)type;

@end
