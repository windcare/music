//
//  MyPlayer.h
//  MyMusic
//
//  Created by sjjwind on 5/14/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyPlayer : NSObject

- (void)setMusicList:(NSArray *)musicList;
- (void)play;
- (void)pause;
- (void)stop;
- (void)playNext;
- (void)playPrevious;


@end
