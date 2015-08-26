//
//  MMButton.m
//  MyMusic
//
//  Created by sjjwind on 8/18/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMButton.h"

@interface MMButton()

@property (nonatomic, strong) NSImage *normalImage;
@property (nonatomic, strong) NSImage *hoverImage;
@property (nonatomic, strong) NSImage *pressImage;

@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, strong) NSImage *imageTmp;
@property (nonatomic, strong) NSImageView *imageView;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) SEL clickAction;

@end

@implementation MMButton

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        NSRect imageRect = NSMakeRect(0, 0, frameRect.size.width, frameRect.size.height);
        self.imageView = [[NSImageView alloc] initWithFrame:imageRect];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)setNormalImage:(NSImage *)image {
    _normalImage = image;
    [self updateImage];
}

- (void)setHoverImage:(NSImage *)image {
    _hoverImage = image;
    [self updateImage];
}

- (void)setPressImage:(NSImage *)image {
    _pressImage = image;
    [self updateImage];
}

- (void)setClickAction:(SEL)action {
    _clickAction = action;
}

- (void)updateImage {
    if (self.state == 0) {
        if (self.normalImage) {
            [self.imageView setImage:self.normalImage];
        }
    } else if (self.state == 1) {
        if (self.hoverImage) {
            [self.imageView setImage:self.hoverImage];
        }
    } else {
        if (self.pressImage) {
            [self.imageView setImage:self.pressImage];
        }
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    self.state = 1;
    [self updateImage];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    
    self.state = 0;
    [self updateImage];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    self.state = 2;
    [self updateImage];
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (self.state == 2) {
        if (self.delegate) {
            [self.delegate didClick:self];
        }
    }
    [super mouseUp:theEvent];
}

- (void)updateTrackingAreas {
    if(self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:opts
                                                       owner:self
                                                    userInfo:nil];
    
    [self addTrackingArea:self.trackingArea];
}

@end
