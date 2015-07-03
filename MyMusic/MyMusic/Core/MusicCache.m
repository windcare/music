//
//  MusicCache.m
//  MyMusic
//
//  Created by sjjwind on 6/24/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MusicCache.h"

@implementation MusicCache

+ (instancetype) sharedCache {
    static dispatch_once_t onceToken;
    static MusicCache *cache;
    dispatch_once(&onceToken, ^{
        cache = [[MusicCache alloc] init];
    });
    
    return cache;
}

- (void)setCacheMaxSize:(NSInteger)maxSize {
    
}

- (NSString *)getCachePathWithMusicId:(NSInteger)musicId resourceType:(CacheResourceType)type {
    NSString *appendingPath = [NSString stringWithFormat:@"/Library/Containers/%@/Data/Library/Application Support", [[NSBundle mainBundle] bundleIdentifier]];
    
    NSString *applicationSupportPath = [NSHomeDirectory() stringByAppendingPathComponent:appendingPath];
    applicationSupportPath = [applicationSupportPath stringByAppendingPathComponent:@"MyMusic"];
    NSString *path = [applicationSupportPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld", musicId]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error = nil;
        if(![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Failed to create cache directory at %@", path);
        }
        return nil;
    }
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld", type]];
}

- (NSString *)getResourcePathWithMusicId:(NSInteger)musicId resourceType:(CacheResourceType)type {
    NSString *path = [self getCachePathWithMusicId:musicId resourceType:type];
    if (path != nil) {
        NSError *error;
        NSURL *url = [NSURL fileURLWithPath:path];
        NSDictionary *fileAttributes = [url resourceValuesForKeys:@[NSURLFileSizeKey, NSURLContentModificationDateKey, NSURLIsDirectoryKey, NSURLIsHiddenKey]
                                                            error:&error];
        BOOL fileIsNotExist = error.code == NSFileReadNoSuchFileError;
        NSInteger fileSize = [fileAttributes[NSURLFileSizeKey] longLongValue];
        if (fileIsNotExist || fileSize == 0) {
            return @"";
        }
        return path;
    }
    return @"";
}

- (NSString *)cacheResourceWithMusicId:(NSInteger)musicId resourceType:(CacheResourceType)type {
    NSString *path = [self getCachePathWithMusicId:musicId resourceType:type];
    return path;
}

@end
