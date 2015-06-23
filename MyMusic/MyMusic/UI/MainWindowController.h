//
//  MainWindowController.h
//  MyMusic
//
//  Created by sjjwind on 5/26/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MMWindowController.h"

@interface MainWindowController : MMWindowController

+ (MainWindowController *)sharedMainWindowController;

- (void)toggleWindow;

@end
