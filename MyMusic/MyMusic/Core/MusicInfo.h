//
//  MusicInfo.h
//  MyMusic
//
//  Created by sjjwind on 6/24/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicInfo : NSObject

@property (nonatomic, assign) NSInteger musicId;
@property (nonatomic, strong) NSString *musicName;
@property (nonatomic, strong) NSString *musicAuthor;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, assign) NSInteger duration;

@end
