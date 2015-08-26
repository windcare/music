//
//  MMRankItemCell.m
//  MyMusic
//
//  Created by sjjwind on 7/2/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMRankItemCell.h"
#import <Foundation/Foundation.h>

const static NSInteger kPlayImageWidth = 40;

@interface MMRankItemCell()

@property (nonatomic, assign) MMMusicRankType musicRankType;
@property (nonatomic, strong) NSImageView *imageView;
@property (nonatomic, strong) NSTextField *nameView;
@property (nonatomic, strong) NSView *backgroundView;
@property (nonatomic, strong) CALayer *cornerLayer;
@property (nonatomic, strong) NSImageView *playImageView;

@end

@implementation MMRankItemCell

- (instancetype)initWithFrame:(NSRect)frameRect {
    NSInteger imageHeight = frameRect.size.width;
    NSInteger textHeight = frameRect.size.height - frameRect.size.width;
    if (self = [super initWithFrame:frameRect]) {        
        self.nameView = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, 33)];
        self.nameView.bezeled = NO;
        self.nameView.drawsBackground = NO;
        self.nameView.editable = NO;
        self.nameView.selectable = NO;
        self.nameView.alignment = NSCenterTextAlignment;
        self.nameView.textColor = [NSColor blackColor];
        self.nameView.font = [NSFont fontWithName:@"MicrosoftYaHei" size:13.0f];
        
        [self addSubview:self.backgroundView];
        [self addSubview:self.nameView];
        
        self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, textHeight, imageHeight, imageHeight)];
        [self addSubview:self.imageView];
        
        NSRect trackRect = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
        NSTrackingArea *area = [[NSTrackingArea alloc]initWithRect:trackRect options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp owner:self userInfo:nil];
        [self addTrackingArea:area];
    }
    return self;
}

- (void)mouseEntered:(NSEvent *)theEvent {
//    self.backgroundView.layer.opacity = 0.2;
}

- (void)mouseExited:(NSEvent *)theEvent {
//    self.backgroundView.layer.opacity = 0.1;
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (self.delegate) {
        [self.delegate onClickItem:self];
    }
}

- (void)setCellImage:(NSString *)imageName {
    [self.imageView setImage:[NSImage imageNamed:imageName]];
}

- (void)setCellName:(NSString *)cellName {
    self.nameView.stringValue = cellName;
}

- (void)setMusicType:(MMMusicRankType)rankType {
  self.musicRankType = rankType;
}

- (MMMusicRankType)getMusicType {
  return self.musicRankType;
}

@end
