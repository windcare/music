//
//  MusicManager.m
//  MyMusic
//
//  Created by sjjwind on 5/15/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MusicManager.h"
#import "AFNetworking.h"
#import "NSString+Encode.h"
#import "MusicInfo.h"
#import "MusicCache.h"

static NSString * kHost = @"localhost:34321";
static NSString * kAPIURLBase = @"http://localhost:34321/music";
static NSString * kLoginURLBase = @"http://localhost:34321/account";
static NSString * kDownloadURLBase = @"http://localhost:34321/message";

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

- (void)sendRequest:(NSMutableURLRequest *)request success:(void (^)(NSDictionary *response))success failed:(void (^)(NSError *error))failed {
    if (self.token.length) {
        NSDictionary *cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                          kHost, NSHTTPCookieDomain,
                                          @"\\", NSHTTPCookiePath,  
                                          @"token", NSHTTPCookieName,
                                          self.token, NSHTTPCookieValue,
                                          nil];
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        NSArray* cookieArray = [NSArray arrayWithObject:cookie];
        NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieArray];
        [request setAllHTTPHeaderFields:headers];
    }
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSDictionary *response) {
        success(response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failed(error);
    }];
    
    [requestOperation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
        return [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response data:cachedResponse.data userInfo:cachedResponse.userInfo storagePolicy:NSURLCacheStorageAllowed];
    }];
    
    [[[self class] sharedRequestOperationQueue] addOperation:requestOperation];
}

- (void)fetchRandomListWithChannel:(MMMusicChannel)channel 
                          complete:(void (^)(int, NSArray *))completion {
    NSString *url = [NSString stringWithFormat:@"?action=fetchRandomList&channel=%ld", channel];
    NSURL *fetchRadomListURL = [NSURL URLWithString:[kAPIURLBase stringByAppendingString:url]];
    
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:fetchRadomListURL];
    [self sendRequest:mutableRequest success:^(NSDictionary *response) {
        NSLog(@"response: %@", response);
        int errorCode = [response[@"code"] intValue];
        if (errorCode == 0) {
            NSArray *musicArr = response[@"param"][@"musicList"];
            NSMutableArray *musicList = [NSMutableArray array];
            if (musicArr) {
                [musicArr enumerateObjectsUsingBlock:^(NSDictionary *musicElement, NSUInteger idx, BOOL *stop) {
                    MusicInfo *info = [[MusicInfo alloc] init];
                    info.musicId = [musicElement[@"id"] integerValue];
                    info.musicName = musicElement[@"musicname"];
                    info.musicAuthor = musicElement[@"artist"];
                    info.albumName = musicElement[@"albumname"];
                    info.duration = [musicElement[@"time"] integerValue];
                    [musicList addObject:info];
                }];
            }
            completion(0, [musicList copy]);
        }
        else {
            completion(errorCode, nil);
        }
    } failed:^(NSError *error) {
        int errorCode = (int)error.code;
        completion(errorCode, nil);
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
    NSString *code = [[NSString stringWithFormat:@"%@%@", [password MD5], userName] MD5];
    NSDictionary *jsonParam = @{@"action": @"login", @"param": @{@"username": userName, @"password": code}};
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

- (void)searchMusic:(NSString *)keyword 
         completion:(void (^)(int errorCode, NSArray *musicList))completion {
    NSString *url = [kAPIURLBase stringByAppendingString:[NSString stringWithFormat:@"?action=searchMusic&key=%@", keyword]];
    NSURL *fetchRadomListURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:fetchRadomListURL];
    [self sendRequest:mutableRequest success:^(NSDictionary *response) {
        NSLog(@"response: %@", response);
        int errorCode = [response[@"code"] intValue];
        if (errorCode == 0 && [response[@"param"][@"musicList"] isKindOfClass:[NSArray class]]) {
            NSArray *musicArr = response[@"param"][@"musicList"];
            NSMutableArray *musicList = [NSMutableArray array];
            if (musicArr.count) {
                [musicArr enumerateObjectsUsingBlock:^(NSDictionary *musicElement, NSUInteger idx, BOOL *stop) {
                    MusicInfo *info = [[MusicInfo alloc] init];
                    info.musicId = [musicElement[@"id"] integerValue];
                    info.musicName = musicElement[@"musicname"];
                    info.musicAuthor = musicElement[@"artist"];
                    info.albumName = musicElement[@"albumname"];
                    info.duration = [musicElement[@"time"] integerValue];
                    [musicList addObject:info];
                }];
            }
            completion(0, [musicList copy]);
        }
        else {
            completion(errorCode, nil);
        }
    } failed:^(NSError *error) {
        int errorCode = (int)error.code;
        completion(errorCode, nil);
    }];
}

- (void)downloadNetworkFile:(NSURL *)url targetPath:(NSString *)path complete:(void (^)(int errorCode))completion {
    //下载附件   
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];  
    operation.inputStream   = [NSInputStream inputStreamWithURL:url];  
    operation.outputStream  = [NSOutputStream outputStreamToFileAtPath:path append:NO];  
    
    //已完成下载  
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {  
        completion(0); 
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {  
        completion((int)error.code);
    }];  
    
    [operation start]; 
}

- (void)downloadMusic:(NSInteger)musicId complete:(void (^)(int errorCode, NSString *path))completion {
    // stream方式
    NSString *path = [[MusicCache sharedCache] getResourcePathWithMusicId:musicId resourceType:CacheResourceType_Music];
    if (path.length == 0) {
        NSString *urlBase = [NSString stringWithFormat:@"%@?action=downloadMusic&musicId=%ld", kDownloadURLBase, musicId];
        completion(-1, urlBase);
    }
    else {
        completion(0, path);
    }
}

- (void)downloadCoverImage:(NSInteger)musicId complete:(void (^)(int errorCode, NSString *path))completion {
    NSLog(@"cover: %ld", musicId);
    NSString *path = [[MusicCache sharedCache] getResourcePathWithMusicId:musicId resourceType:CacheResourceType_BigCover];
    if (path.length == 0) {
        NSString *urlBase = [NSString stringWithFormat:@"%@?action=downloadBigCover&musicId=%ld", kDownloadURLBase, musicId];
        path = [[MusicCache sharedCache] cacheResourceWithMusicId:musicId resourceType:CacheResourceType_BigCover];
        [self downloadNetworkFile:[NSURL URLWithString:urlBase] targetPath:path complete:^(int errorCode) {
            completion(errorCode, path);
        }];
    }
    else {
        completion(0, path);
    }
}

- (void)downloadLyric:(NSInteger)musicId complete:(void (^)(int errorCode, NSString *path))completion {
    NSString *path = [[MusicCache sharedCache] getResourcePathWithMusicId:musicId resourceType:CacheResourceType_Lyric];
    if (path.length == 0) {
        path = [[MusicCache sharedCache] cacheResourceWithMusicId:musicId resourceType:CacheResourceType_Lyric];
        NSString *urlBase = [NSString stringWithFormat:@"%@?action=downloadLyric&musicId=%ld", kDownloadURLBase, musicId];
        [self downloadNetworkFile:[NSURL URLWithString:urlBase] targetPath:path complete:^(int errorCode) {
            completion(errorCode, path);
        }];
    }
    else {
        completion(0, path);
    }
}

- (void)loveMusic:(NSInteger)musicId loveDegree:(NSInteger)degree {
  
}

@end
