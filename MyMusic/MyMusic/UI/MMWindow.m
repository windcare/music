//
//  MMWindow.m
//  MyMusic
//
//  Created by sjjwind on 5/15/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMWindow.h"

@implementation MMWindow

- (void)awakeFromNib {
    [super awakeFromNib];
    self.movableByWindowBackground = YES;
    self.titlebarAppearsTransparent = YES;
    [[self standardWindowButton:NSWindowDocumentIconButton] setImage:nil];
}

- (void)setContentView:(NSView *)aView {
    aView.wantsLayer = YES;
    aView.layer.frame = aView.frame;
    aView.layer.cornerRadius = 5.0f;
    aView.layer.masksToBounds = YES;
    [super setContentView:aView];
}

- (void)setClearBackground {
    [self setStyleMask:NSBorderlessWindowMask];
    [self setOpaque:NO];
    [self setBackgroundColor:[NSColor clearColor]];
}

- (void)showWindowAndMakeItKeyWindow {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [self makeKeyAndOrderFront:nil];
}

- (BOOL) canBecomeKeyWindow { 
    return YES; 
}

- (BOOL) canBecomeMainWindow { 
    return YES; 
}

- (BOOL) acceptsFirstResponder { 
    return YES; 
}

- (BOOL) becomeFirstResponder { 
    return YES; 
}

- (BOOL) resignFirstResponder { 
    return YES; 
}

@end
