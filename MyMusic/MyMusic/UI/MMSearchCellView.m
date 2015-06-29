//
//  MMSearchCellView.m
//  MyMusic
//
//  Created by sjjwind on 6/26/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMSearchCellView.h"

@interface MMSearchCellView()

@property (nonatomic, weak) IBOutlet NSTextField *name;
@property (nonatomic, weak) IBOutlet NSTextField *background;
@property (nonatomic, assign) BOOL isFocus;
@property (nonatomic, strong) NSTrackingArea *trackingArea;

@end

@implementation MMSearchCellView

- (void)setTitle:(NSString *)title {
    self.name.stringValue = title;
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self.delegate click:self];
    NSLog(@"enter: %@", theEvent);
}

- (void)mouseEntered:(NSEvent *)theEvent {
    NSLog(@"enter: %@", theEvent);
}

- (void)mouseExited:(NSEvent *)theEvent {
    NSLog(@"enter: %@", theEvent);
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    
    if (!self.trackingArea) {
        self.trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                                         options:NSTrackingInVisibleRect |
                             NSTrackingActiveAlways |
                             NSTrackingMouseEnteredAndExited
                                                           owner:self
                                                        userInfo:nil];
        [self addTrackingArea:self.trackingArea];
    }
    
}

@end
