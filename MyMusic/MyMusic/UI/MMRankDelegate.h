//
//  MMRankDelegate.h
//  MyMusic
//
//  Created by sjjwind on 8/12/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MMRangDelegate <NSObject>

@optional
- (void)onClickItem:(id)cell;

@end
