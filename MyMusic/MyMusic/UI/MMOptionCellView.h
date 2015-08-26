//
//  MMOptionCellView.h
//  MyMusic
//
//  Created by sjjwind on 8/10/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MMOptionViewDelegate;
@interface MMOptionCellView : NSTableCellView

@property (nonatomic, weak) id<MMOptionViewDelegate> delegate;

- (void)setTitle:(NSString *)title;
- (void)setIconImage:(NSImage *)iconImage;
- (void)setIndex:(NSInteger)index;
- (NSInteger)getIndex;
- (void)setFocus:(BOOL)isFocus;

@end
