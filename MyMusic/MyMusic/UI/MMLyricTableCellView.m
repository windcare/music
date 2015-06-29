//
//  MMLyricTableCellView.m
//  MyMusic
//
//  Created by sjjwind on 6/26/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMLyricTableCellView.h"

@interface MMLyricTableCellView()

@property (nonatomic, weak) IBOutlet NSTextField *lyricField;

@end

@implementation MMLyricTableCellView

- (void)select {
    self.lyricField.textColor = [NSColor colorWithCalibratedRed:0.227 green:0.757 blue:0.494 alpha:1.0];
}

- (void)unSelect {
    self.lyricField.textColor = [NSColor whiteColor];
}

- (void)setLyric:(NSString *)lyric {
    self.lyricField.stringValue = lyric;
}

@end
