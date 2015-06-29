//
//  MMSearchCellView.h
//  MyMusic
//
//  Created by sjjwind on 6/26/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MMSearchActionDelegate;
@interface MMSearchCellView : NSTableCellView

@property (nonatomic, weak) id<MMSearchActionDelegate> delegate;
@property (nonatomic, assign) NSInteger index;
- (void)setTitle:(NSString *)title;

@end

@protocol MMSearchActionDelegate <NSObject>
- (void)click:(MMSearchCellView *)cell;

@end

