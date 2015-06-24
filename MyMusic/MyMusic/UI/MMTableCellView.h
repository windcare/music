//
//  MMTableCellView.h
//  MyMusic
//
//  Created by sjjwind on 6/23/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MusicInfo.h"

@interface MMTableCellView : NSTableCellView

@property (nonatomic, strong) MusicInfo *musicInfo;

@end
