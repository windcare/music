//
//  MMLyricTableCellView.h
//  MyMusic
//
//  Created by sjjwind on 6/26/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MMLyricTableCellView : NSTableCellView

- (void)select;
- (void)unSelect;

- (void)setLyric:(NSString *)lyric;

@end
