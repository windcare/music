//
//  MMGuessPageView.m
//  MyMusic
//
//  Created by sjjwind on 8/11/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMGuessPageView.h"
#import "NSImage+MMAddition.h"
#import "MMButton.h"
#import <QuartzCore/QuartzCore.h>

const static NSInteger kPlayButtonHeight = 64;

@interface MMGuessPageView()

@property (nonatomic, strong) CALayer *background;
@property (nonatomic, strong) MMButton *playButton;

@end

@implementation MMGuessPageView

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self initBackground];
        NSImage *testImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://qzonestyle.gtimg.cn/music/photo/radio/track_radio_440_12_1.jpg"]];
        [self setBackgroundImage:testImage];
        [testImage createBlurredCGImage:^(CGImageRef cgImage) {
            [self redrawGradientWithContents:cgImage];
        }];
        NSRect btnRect;
        btnRect.origin.x = (self.frame.size.width - kPlayButtonHeight) / 2;
        btnRect.origin.y = (self.frame.size.height + kPlayButtonHeight) / 2;
        btnRect.size.width = kPlayButtonHeight;
        btnRect.size.height = kPlayButtonHeight;
        self.playButton = [[MMButton alloc] initWithFrame:btnRect];
        [self.playButton setNormalImage:[NSImage imageNamed:@"play_normal"]];
        [self.playButton setHoverImage:[NSImage imageNamed:@"play_hover"]];
        [self addSubview:self.playButton];
        
//        NSTextField *titleField = [NSTextField alloc] initWithFrame:<#(NSRect)#>
    }
    return self;
}

- (void)initBackground {
    self.wantsLayer = YES;
    self.background = [CALayer layer];
    self.background.anchorPoint      = CGPointZero;
    self.background.position         = CGPointZero;
    self.background.bounds           = self.bounds;
    self.background.autoresizingMask = NSViewWidthSizable;
    self.background.contentsGravity  = kCAGravityResizeAspectFill;
    
    [self.layer addSublayer:self.background];
    
//    CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
//    gradient.anchorPoint      = self.background.anchorPoint;
//    gradient.position         = self.background.position;
//    gradient.bounds           = self.background.bounds;
//    gradient.autoresizingMask = self.background.autoresizingMask;
//    
//    gradient.colors = @[
//                        (__bridge id)CGColorGetConstantColor(kCGColorClear),
//                        (__bridge id)CGColorGetConstantColor(kCGColorBlack),
//                        (__bridge id)CGColorGetConstantColor(kCGColorBlack)
//                        ];
//    
//    gradient.locations = @[
//                           @0.2,
//                           @0.5,
//                           @1.0
//                           ];
    
//    [self.background setMask:gradient];
}

- (void)redrawGradientWithContents:(CGImageRef)contents {
  self.background.contents = (__bridge id)contents;
}

@end
