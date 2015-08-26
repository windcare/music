//
//  MMOptionSepratorCellView.h
//  MyMusic
//
//  Created by sjjwind on 8/10/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MMOptionSepratorCellView : NSTableCellView

- (void)setTitle:(NSString *)title;

- (void)setIndex:(NSInteger)index;
- (NSInteger)getIndex;

@end
