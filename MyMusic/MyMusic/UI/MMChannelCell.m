//
//  MMChannelCell.m
//  MyMusic
//
//  Created by sjjwind on 7/2/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMChannelCell.h"
#import <Foundation/Foundation.h>

const static NSInteger kPlayImageWidth = 40;

@interface MMChannelCell()

@property (nonatomic, strong) NSImageView *imageView;
@property (nonatomic, strong) NSTextField *nameView;
@property (nonatomic, strong) NSView *backgroundView;
@property (nonatomic, strong) CALayer *cornerLayer;
@property (nonatomic, strong) NSImageView *playImageView;

@end

@implementation MMChannelCell

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {        
        self.backgroundView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
        
        self.nameView = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, 22)];
        self.nameView.bezeled = NO;
        self.nameView.drawsBackground = NO;
        self.nameView.editable = NO;
        self.nameView.selectable = NO;
        self.nameView.alignment = NSCenterTextAlignment;
        self.nameView.textColor = [NSColor whiteColor];
        
        [self addSubview:self.backgroundView];
        [self addSubview:self.nameView];
        
        [self.backgroundView setWantsLayer:YES];
        self.backgroundView.layer.backgroundColor = [[NSColor whiteColor] CGColor];
        self.backgroundView.layer.opacity = 0.1;
        
        NSRect trackRect = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
        NSTrackingArea *area = [[NSTrackingArea alloc]initWithRect:trackRect options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp owner:self userInfo:nil];
        [self addTrackingArea:area];
    }
    return self;
}

- (void)mouseEntered:(NSEvent *)theEvent {
    self.backgroundView.layer.opacity = 0.2;
}

- (void)mouseExited:(NSEvent *)theEvent {
    self.backgroundView.layer.opacity = 0.1;
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (self.delegate) {
        [self.delegate onClick:self];
    }
}

- (void)showPlayImage:(BOOL)show {
    if (self.playImageView == nil) {
        NSInteger imageWidth = self.frame.size.width;
        
        NSRect playImageRect = { (imageWidth - kPlayImageWidth) / 2, self.frame.size.height - self.frame.size.width + (imageWidth - kPlayImageWidth) / 2, kPlayImageWidth, kPlayImageWidth };
        self.playImageView = [[NSImageView alloc] initWithFrame:playImageRect];
        [self.playImageView setImage:[NSImage imageNamed:@"btn_channel_play"]];
        [self.playImageView setHidden:YES];
        [self addSubview:self.playImageView];
    }
    
    if (show) {
        [self.playImageView setHidden:NO];
    } else {
        [self.playImageView setHidden:YES];
    }
}

- (void)setCellImage:(NSString *)imageName {
    [self.imageView setImage:[NSImage imageNamed:imageName]];
}

- (void)setCellName:(NSString *)cellName {
    self.nameView.stringValue = cellName;
}

@end
