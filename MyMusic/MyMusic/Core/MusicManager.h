//
//  MusicManager.h
//  MyMusic
//
//  Created by sjjwind on 5/15/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicManager : NSObject

+ (instancetype) sharedManager;

- (void)fetchRandomListWithCompletion:(void (^)(int errorCode, NSArray *musicList))completion;

- (void)fetchLoveMusicListWithCompletion:(void (^)(int errorCode, NSArray *musicList))completion;

- (void)fetchListenedMusicListWithCompletion:(void (^)(int errorCode, NSArray *musicList))completion;

- (void)loginByUserName:(NSString *)userName 
               password:(NSString *)password 
             completion:(void (^)(int errorCode))completion;

- (void)downloadMusic:(NSInteger)musicId targetPath:(NSString *)path;

- (void)downloadCoverImage:(NSInteger)musicId targetPath:(NSString *)path;

- (void)downloadLyric:(NSInteger)musicId targetPath:(NSString *)path;

- (void)loveMusic:(NSInteger)musicId loveDegree:(NSInteger)degree;

@end
