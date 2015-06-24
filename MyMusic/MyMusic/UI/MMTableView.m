//
//  MMTableView.m
//  MyMusic
//
//  Created by sjjwind on 6/23/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMTableView.h"

@implementation MMTableView

- (instancetype)init {
    if (self = [super init]) {
        [self setBackgroundColor:[NSColor clearColor]];
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setBackgroundColor:[NSColor clearColor]];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    [self setBackgroundColor:[NSColor clearColor]];
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

@end
