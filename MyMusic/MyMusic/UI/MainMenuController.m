//
//  MainMenuController.m
//  MyMusic
//
//  Created by sjjwind on 5/28/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MainMenuController.h"
#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"

static const CGFloat kStatusItemWidth = 28.0;

@interface MainMenuController ()<NSMenuDelegate>

@property (nonatomic, strong) NSStatusItem *statusItem;

@end

@implementation MainMenuController

+ (instancetype)sharedController {
    static MainMenuController *_controller;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _controller = [[MainMenuController alloc] init]; 
    });
    
    return _controller;
}

- (instancetype)init {
    if (self = [super init]) {
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:kStatusItemWidth];
        self.statusItem.target = self;
        self.statusItem.action = @selector(statusItemClicked:);
        self.statusItem.highlightMode = NO;
    }
    
    return self;
}

- (void)statusItemClicked:(id)sender {
    [self _bringAllToFront];
    [[MainWindowController sharedMainWindowController] toggleWindow];
}

- (void)setMenuImage:(NSString *)imageName {
    self.statusItem.image = [NSImage imageNamed:imageName];
}

- (void)_bringAllToFront {
    [[NSApp windows] enumerateObjectsUsingBlock:^(NSWindow *window, NSUInteger idx, BOOL *stop) {
        if (window.isVisible) {
            [window orderFrontRegardless];
        }
    }];
}

@end
