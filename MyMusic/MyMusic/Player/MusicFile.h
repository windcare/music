//
//  MusicFile.h
//  MyMusic
//
//  Created by sjjwind on 5/14/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioFile.h"

@interface MusicFile : NSObject <DOUAudioFile>

@property (nonatomic, assign) NSUInteger musicId;
@property (nonatomic, strong) NSString *musicName;
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) NSString *coverImageURL;
@property (nonatomic, strong) NSURL *audioFileURL;

@end
