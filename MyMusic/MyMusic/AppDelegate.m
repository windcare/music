//
//  AppDelegate.m
//  MyMusic
//
//  Created by sjjwind on 5/14/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "AppDelegate.h"
#import "MainMenuController.h"
#import "LoginMananger.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [[MainMenuController sharedController] setMenuImage:@"logo"];
    [[LoginMananger sharedManager] autoLoginWithComplete:^(BOOL success) {
        if (!success) {
            NSWindowController *windwoController = [[NSStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateControllerWithIdentifier:@"LoginWindow"];
            [windwoController showWindow:nil];
        }
    }];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}

@end
