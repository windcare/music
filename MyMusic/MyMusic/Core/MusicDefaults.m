//
//  MusicDefaults.m
//  MyMusic
//
//  Created by sjjwind on 7/2/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MusicDefaults.h"

static NSString * const kLoginCode = @"com.music.login.code";
static NSString * const kLastLoginUserName = @"com.music.login.username";

@implementation MusicDefaults


+ (instancetype)sharedInstance {
    static MusicDefaults *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[MusicDefaults alloc] init];
    });
    
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:[self defaultValues]];
    }
    
    return self;
}


- (NSDictionary *)defaultValues {
    return @{
             kLoginCode     : @"",
             kLastLoginUserName  : @"",
             };
}

- (id)persistenceObjectForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}


- (void)setPersistenceObject:(id)object forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setLastLoginCode:(NSString *)code {
    [self setPersistenceObject:code forKey:kLoginCode];
}

- (void)setLastLoginUser:(NSString *)user {
    [self setPersistenceObject:user forKey:kLastLoginUserName];    
}

- (NSString *)getLastLoginCode {
    return [self persistenceObjectForKey:kLoginCode];
}

- (NSString *)getLastLoginUser {
    return [self persistenceObjectForKey:kLastLoginUserName];
}


@end
