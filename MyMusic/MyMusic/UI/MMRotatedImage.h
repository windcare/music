//
//  MMRotatedImage.h
//  MyMusic
//
//  Created by sjjwind on 6/24/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

typedef enum {
    XMCircularProgressIndicatorStyleSemiCircle,
    XMCircularProgressIndicatorStyleCircle
} XMCircularProgressIndicatorStyle;


@class XMSong;

@interface MMRotatedImage : NSControl

@property (nonatomic, strong) NSImage *songCover;
@property (nonatomic, assign) XMCircularProgressIndicatorStyle style;
@property (nonatomic, assign) CGFloat currentAngel;
@property (nonatomic, assign) BOOL shouldLoadOriginCover;

- (void)startRotating;
- (void)stopRotating;

- (void)quickRotate:(BOOL)forward;

- (void)startSpin:(BOOL)forward;
- (void)stopSpin;

- (void)changeSong:(XMSong *)song;

@end