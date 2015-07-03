//
//  LoginMananger.m
//  MyMusic
//
//  Created by sjjwind on 7/2/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "LoginMananger.h"
#import "MusicManager.h"
#import "NSString+Encode.h"
#import "MusicDefaults.h"

@implementation LoginMananger

+ (instancetype) sharedManager {
    static dispatch_once_t onceToken;
    static LoginMananger *manager;
    dispatch_once(&onceToken, ^{
        manager = [[LoginMananger alloc] init];
    });
    
    return manager;
}

- (void)loginWithUsername:(NSString *)username 
                 password:(NSString *)password 
                 complete:(void (^)(BOOL success))completion {
    NSString *code = [[NSString stringWithFormat:@"%@%@", [password MD5], username] MD5];
    [[MusicManager sharedManager] loginByUserName:username password:code completion:^(int errorCode) {
        if (errorCode == 0) {
            [[MusicDefaults sharedInstance] setLastLoginCode:code];
            [[MusicDefaults sharedInstance] setLastLoginUser:username];
            completion(YES);
        } else {
            completion(NO);
        }
    }];
}

- (void)autoLoginWithComplete:(void (^)(BOOL success))completion {
    NSString *username = [[MusicDefaults sharedInstance] getLastLoginUser];
    NSString *code = [[MusicDefaults sharedInstance] getLastLoginCode];
    if (username.length == 0 || code.length == 0) {
        completion(NO);
        return;
    }
    [[MusicManager sharedManager] loginByUserName:username password:code completion:^(int errorCode) {
        if (errorCode == 0) {
            completion(YES);
        } else {
            completion(NO);
        }
    }];
}

@end
