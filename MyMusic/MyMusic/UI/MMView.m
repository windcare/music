//
//  MMView.m
//  MyMusic
//
//  Created by sjjwind on 5/28/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMView.h"

@interface MMView()

@property (nonatomic, strong) NSImage *backgroundImage;
@property (nonatomic, assign) BOOL needDrawBackgroundImage;

@end

@implementation MMView

- (void)setBackgroundImage:(NSImage *)image {
    if (image == nil) {
        _backgroundImage = nil;
        self.needDrawBackgroundImage = NO;
    }
    else {
        _backgroundImage = image;
        self.needDrawBackgroundImage = YES;
    }
}

- (void)setBackgroundColor:(NSColor *)color {
    self.wantsLayer = YES;
    self.layer.backgroundColor = [color CGColor];
}

- (void)drawRect:(NSRect)dirtyRect {
    if (self.needDrawBackgroundImage) {
        [self.backgroundImage drawInRect:self.bounds
                 fromRect:NSZeroRect
                operation:NSCompositeSourceOver
                 fraction:1.0];
        self.wantsLayer = YES;
    }
    
    [super drawRect:dirtyRect];
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSLog(@"View Down!");
}

@end
