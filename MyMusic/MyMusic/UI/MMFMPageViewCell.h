//
//  MMChannelCell.h
//  MyMusic
//
//  Created by sjjwind on 7/2/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MMMusicChannel.h"

@protocol MMFMPageViewCellDelegate;
@interface MMFMPageViewCell : NSControl

@property (nonatomic, assign) MMMusicChannel channelId;

@property (nonatomic, strong) id<MMFMPageViewCellDelegate> delegate;

- (void)setCellImage:(NSString *)imageName;
- (void)setCellName:(NSString *)cellName;

@end

@protocol MMFMPageViewCellDelegate <NSObject>

- (void)onClick:(MMFMPageViewCell *)cell;

@end
