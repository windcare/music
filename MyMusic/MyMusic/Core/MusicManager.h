//
//  MusicManager.h
//  MyMusic
//
//  Created by sjjwind on 5/15/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    MMMusicPersonalChannel = 0x01,
    MMMusicHotChannel = 0x02,
} MMMusicChannel;

@interface MusicManager : NSObject

+ (instancetype) sharedManager;

- (void)fetchRandomListWithChannel:(MMMusicChannel) channel 
                          complete:(void (^)(int errorCode, NSArray *musicList))completion;

- (void)fetchLoveMusicListWithCompletion:(void (^)(int errorCode, NSArray *musicList))completion;

- (void)fetchListenedMusicListWithCompletion:(void (^)(int errorCode, NSArray *musicList))completion;

- (void)loginByUserName:(NSString *)userName 
               password:(NSString *)password 
             completion:(void (^)(int errorCode))completion;

- (void)downloadMusic:(NSInteger)musicId complete:(void (^)(int errorCode, NSString *path))completion;

- (void)downloadCoverImage:(NSInteger)musicId complete:(void (^)(int errorCode, NSString *path))completion;

- (void)downloadLyric:(NSInteger)musicId complete:(void (^)(int errorCode, NSString *path))completion;

- (void)loveMusic:(NSInteger)musicId loveDegree:(NSInteger)degree;

@end
