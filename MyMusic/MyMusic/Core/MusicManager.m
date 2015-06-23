//
//  MusicManager.m
//  MyMusic
//
//  Created by sjjwind on 5/15/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MusicManager.h"
#import "AFNetworking.h"

static NSString * kAPIURLBase = @"http://localhost:34321/message";
static NSString * kLoginURLBase = @"http://localhost:34321/account";

@interface MusicManager()

@property (nonatomic, strong) NSString *token;
@property (nonatomic, assign) NSInteger createTime;
@property (nonatomic, assign) NSInteger expireTime;
@property (nonatomic, assign) BOOL isLogin;

@end

@implementation MusicManager

- (instancetype) init {
  if (self = [super init]) {
    self.isLogin = NO;
  }
  return self;
}

+ (instancetype) sharedManager {
    static dispatch_once_t onceToken;
    static MusicManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[MusicManager alloc] init];
    });
    
    return manager;
}

+ (NSOperationQueue *)sharedRequestOperationQueue {
    static NSOperationQueue *_sharedRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_sharedRequestOperationQueue setMaxConcurrentOperationCount:8];
    });
    
    return _sharedRequestOperationQueue;
}

- (void)setToken:(NSString *)token createTime:(NSInteger)createTime expireTime:(NSInteger)expireTime {
    self.token = token;
    self.createTime = createTime;
    self.expireTime = expireTime;
}

- (BOOL)checkTokenIsValid {
    NSDate *currentTime = [NSDate date];
    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:self.expireTime];
    if ([currentTime compare:expireDate] == NSOrderedDescending) {
        return NO;
    }
    return YES;
}

- (void)sendRequest:(NSURLRequest *)request success:(void (^)(NSDictionary *response))success failed:(void (^)(NSError *error))failed {
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSDictionary *response) {
        NSLog(@"%@", response);
        success(response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        failed(error);
    }];
    
    [requestOperation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
        return [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response data:cachedResponse.data userInfo:cachedResponse.userInfo storagePolicy:NSURLCacheStorageAllowed];
    }];
    
    [[[self class] sharedRequestOperationQueue] addOperation:requestOperation];
}

- (void)fetchRandomListWithCompletion:(void (^)(int errorCode, NSArray *musicList))completion {
    NSURL *fetchRadomListURL = [NSURL URLWithString:[kAPIURLBase stringByAppendingString:@"?action=getMusicList"]];
    
    NSURLRequest *mutableRequest = [NSURLRequest requestWithURL:fetchRadomListURL];
    [self sendRequest:mutableRequest success:^(NSDictionary *response) {
        
    } failed:^(NSError *error) {
        
    }];
}

- (void)fetchLoveMusicListWithCompletion:(void (^)(int errorCode, NSArray *musicList))completion {
    
}

- (void)fetchListenedMusicListWithCompletion:(void (^)(int errorCode, NSArray *musicList))completion {
    
}

- (void)loginByUserName:(NSString *)userName 
               password:(NSString *)password 
             completion:(void (^)(int errorCode))completion {
    NSURL *loginURL = [NSURL URLWithString:kLoginURLBase];
    
    NSDictionary *jsonParam = @{@"action": @"login", @"param": @{@"username": userName, @"password": password}};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonParam
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:loginURL];
    mutableRequest.HTTPMethod = @"POST";
    mutableRequest.HTTPBody = jsonData;
    [self sendRequest:mutableRequest success:^(NSDictionary *response) {
        NSInteger errorCode = [response[@"code"] integerValue];
        if (errorCode == 0) {
            NSLog(@"LoginSuccess: %@", response[@"token"]);
            self.token = response[@"token"];
            self.createTime = [response[@"createTime"] unsignedLongLongValue];
            // 过期时间是创建时间的5小时
            self.expireTime = self.createTime + 5 * 60 * 60 * 1000;
            self.isLogin = YES;
        } else {
            self.isLogin = NO;
            NSLog(@"LoginFailed: %ld", (long)errorCode);
        }
    } failed:^(NSError *error) {
        
    }];
}

- (void)downloadMusic:(NSInteger)musicId targetPath:(NSString *)path {
  
}

- (void)downloadCoverImage:(NSInteger)musicId targetPath:(NSString *)path {
  
}

- (void)downloadLyric:(NSInteger)musicId targetPath:(NSString *)path {
  
}

- (void)loveMusic:(NSInteger)musicId loveDegree:(NSInteger)degree {
  
}

@end
