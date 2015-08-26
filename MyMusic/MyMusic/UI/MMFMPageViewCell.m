//
//  MMChannelCell.m
//  MyMusic
//
//  Created by sjjwind on 7/2/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMFMPageViewCell.h"
#import <Foundation/Foundation.h>
#import "MMView.h"
#import "MMButton.h"

static const NSInteger kPlayButtonHeight = 32;

@interface MMFMPageViewCell() <MMButtonDelegate>

@property (nonatomic, strong) NSImageView *imageView;
@property (nonatomic, strong) NSTextField *nameView;
@property (nonatomic, strong) CALayer *cornerLayer;
@property (nonatomic, strong) NSImageView *playImageView;
@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, strong) MMButton *playButton;
@property (nonatomic, assign) NSInteger enterCount;

@end

@implementation MMFMPageViewCell

- (instancetype)initWithFrame:(NSRect)frameRect {
    NSInteger imageHeight = frameRect.size.width;
    NSInteger textHeight = frameRect.size.height - frameRect.size.width;
    if (self = [super initWithFrame:frameRect]) {        
        self.nameView = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, 33)];
        self.nameView.bezeled = NO;
        self.nameView.drawsBackground = NO;
        self.nameView.editable = NO;
        self.nameView.selectable = NO;
        self.nameView.alignment = NSLeftTextAlignment;
        self.nameView.textColor = [NSColor colorWithCalibratedRed:0.051 green:0.678 blue:0.318 alpha:1.0];
        self.nameView.font = [NSFont fontWithName:@"MicrosoftYaHei" size:13.0f];
        
        [self addSubview:self.nameView];
        
        NSRect imageViewRect = NSMakeRect(0, textHeight, imageHeight, imageHeight);
        self.imageView = [[NSImageView alloc] initWithFrame:imageViewRect];
        [self addSubview:self.imageView];
        NSRect trackRect = NSMakeRect(0, textHeight, self.frame.size.height, self.frame.size.height);
        NSTrackingArea *area = [[NSTrackingArea alloc]initWithRect:trackRect options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp owner:self userInfo:nil];
        [self addTrackingArea:area];
    }
    return self;
}

- (void)mouseEntered:(NSEvent *)theEvent {
    self.enterCount++;
    self.imageView.wantsLayer = YES;
    if (self.maskLayer == nil) {
        self.maskLayer = [CALayer layer];
        self.maskLayer.frame = NSMakeRect(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
        [self.imageView.layer addSublayer:self.maskLayer];
    }
    self.maskLayer.backgroundColor = [[NSColor colorWithCalibratedRed:0.300 green:0.300 blue:0.300 alpha:0.7] CGColor];
    if (self.playButton == nil) {
        NSInteger imageHeight = self.frame.size.width;
        NSInteger textHeight = self.frame.size.height - self.frame.size.width;
        NSInteger btnLeft = (imageHeight - kPlayButtonHeight) / 2;
        NSRect playButtonRect = NSMakeRect(btnLeft, btnLeft + textHeight, kPlayButtonHeight, kPlayButtonHeight);
        self.playButton = [[MMButton alloc] initWithFrame:playButtonRect];
        [self.playButton setNormalImage:[NSImage imageNamed:@"play_normal"]];
        [self.playButton setHoverImage:[NSImage imageNamed:@"play_hover"]];
        [self.playButton setDelegate:self];
        [self addSubview:self.playButton];
    }
    [self.playButton setHidden:NO];
}

- (void)mouseExited:(NSEvent *)theEvent {
    self.enterCount--;
    if (self.enterCount == 0) {
        self.maskLayer.backgroundColor = [[NSColor clearColor] CGColor];
        [self.playButton setHidden:YES];
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (self.delegate) {
        [self.delegate onClick:self];
    }
}

- (void)showPlayImage:(BOOL)show {
//    if (self.playImageView == nil) {
//        NSInteger imageWidth = self.frame.size.width;
//        
//        NSRect playImageRect = { (imageWidth - kPlayImageWidth) / 2, self.frame.size.height - self.frame.size.width + (imageWidth - kPlayImageWidth) / 2, kPlayImageWidth, kPlayImageWidth };
//        self.playImageView = [[NSImageView alloc] initWithFrame:playImageRect];
//        [self.playImageView setImage:[NSImage imageNamed:@"btn_channel_play"]];
//        [self.playImageView setHidden:YES];
//        [self addSubview:self.playImageView];
//    }
//    
//    if (show) {
//        [self.playImageView setHidden:NO];
//    } else {
//        [self.playImageView setHidden:YES];
//    }
}

- (void)didClick:(MMButton *)button {
    if (self.delegate) {
        [self.delegate onClick:self];
    }
}

- (void)setCellImage:(NSString *)imageName {
    [self.imageView setImage:[NSImage imageNamed:imageName]];
}

- (void)setCellName:(NSString *)cellName {
    self.nameView.stringValue = cellName;
}

@end
