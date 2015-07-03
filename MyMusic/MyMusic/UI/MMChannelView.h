//
//  MMChannelView.h
//  MyMusic
//
//  Created by sjjwind on 7/2/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MMView.h"
#import "MMMusicChannel.h"
#import "MainWindowController.h"


@interface MMChannelView : MMView

@property (nonatomic, weak) MainWindowController *controller;
- (MMMusicChannel)getCurrentChannel;
@end
