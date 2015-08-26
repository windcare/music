//
//  MMButton.h
//  MyMusic
//
//  Created by sjjwind on 8/18/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MMButtonDelegate <NSObject>

@optional
- (void)didClick:(id)button;

@end

@interface MMButton : NSControl

@property (nonatomic, assign) id<MMButtonDelegate> delegate;

- (void)setNormalImage:(NSImage *)image;
- (void)setHoverImage:(NSImage *)image;
- (void)setPressImage:(NSImage *)image;

@end
