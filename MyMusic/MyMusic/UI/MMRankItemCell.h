//
//  MMRankItemCell.h
//  MyMusic
//
//  Created by sjjwind on 8/12/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MMRankDelegate.h"
#import "MMMusicChannel.h"

@interface MMRankItemCell : NSControl

@property (nonatomic, assign) id<MMRangDelegate> delegate;

- (void)setCellImage:(NSString *)imageName;
- (void)setCellName:(NSString *)cellName;
- (void)setMusicType:(MMMusicRankType)rankType;
- (MMMusicRankType)getMusicType;

@end

