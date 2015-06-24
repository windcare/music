//
//  MMTableView.h
//  MyMusic
//
//  Created by sjjwind on 6/23/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//NS_ENUM(UInt8, MMDragType) {
//    MMDragTypeLeft = 0x0,
//    MMDragTypeRight = 0x01,
//};

@protocol MMTableViewDelegate <NSObject>

@optional
- (void)didDragView;

@end

@interface MMTableView : NSTableView

@end
