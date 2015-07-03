//
//  MusicDefaults.h
//  MyMusic
//
//  Created by sjjwind on 7/2/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicDefaults : NSObject

+ (instancetype)sharedInstance;

- (void)setLastLoginCode:(NSString *)code;
- (void)setLastLoginUser:(NSString *)user;

- (NSString *)getLastLoginCode;
- (NSString *)getLastLoginUser;

@end
