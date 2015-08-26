//
//  MusicManager.h
//  MyMusic
//
//  Created by sjjwind on 5/15/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMMusicChannel.h"

typedef enum : NSInteger {
    MMLoveMusicDegreeNormal = 0x0,
    MMLoveMusicDegreeHate,
    MMLoveMusicDegreeLove,
} MMLoveMusicDegree;

@interface MusicManager : NSObject

+ (instancetype) sharedManager;

- (void)fetchRankListWithType:(MMMusicRankType)type 
                     complete:(void (^)(int errorCode, NSArray *musicList))completion;

- (void)fetchFmListWithChannel:(MMMusicChannel) channel 
                      complete:(void (^)(int errorCode, NSArray *musicList))completion;

- (void)fetchLoveMusicListWithCompletion:(void (^)(int errorCode, NSArray *musicList))completion;

- (void)fetchListenedMusicListWithCompletion:(void (^)(int errorCode, NSArray *musicList))completion;

- (void)loginByUserName:(NSString *)userName 
               password:(NSString *)password 
             completion:(void (^)(int errorCode))completion;

- (void)searchMusic:(NSString *)keyword 
         completion:(void (^)(int errorCode, NSArray *musicList))completion;

- (void)downloadMusic:(NSInteger)musicId 
             complete:(void (^)(int errorCode, NSString *path))completion;

- (void)downloadCoverImage:(NSInteger)musicId 
                  complete:(void (^)(int errorCode, NSString *path))completion;

- (void)downloadLyric:(NSInteger)musicId 
             complete:(void (^)(int errorCode, NSString *path))completion;

- (void)loveMusic:(NSInteger)musicId 
       loveDegree:(MMLoveMusicDegree)degree 
         complete:(void (^)(BOOL success))completion;

@end
