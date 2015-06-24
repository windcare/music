//
//  MMRotatedImage.m
//  MyMusic
//
//  Created by sjjwind on 6/24/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMRotatedImage.h"
#import <QuartzCore/QuartzCore.h>

#define kDefaultCoverWidth      96.0f
#define kDefaultY               ceil(NSHeight(self.diskContainer.bounds) - kDefaultCoverWidth/2)
#define kCentralMaskWidth       ceil(self.coverWidth * 16/100)

#define kTextureWidthLarge      ceil(self.coverWidth * 3/100)
#define kTextureWidthSmall      ceil(self.coverWidth * 2.5/100)
#define kTextureOpacity         0.85f
#define kTextureOpacityDark     0.6f

#define kRotationAngle          (-2*M_PI/300*self.speedFactor)
#define kQuickRotationSpeed     8.0f

static NSImage *defaultDisk;


@interface MMRotatedImage () {
    CVDisplayLinkRef displayLinkRef;
}

@property (nonatomic, strong) XMSong *song;

@property (nonatomic, assign) CGFloat coverWidth;
@property (nonatomic, strong) CALayer *cropContainer;
@property (nonatomic, strong) CALayer *diskContainer;
@property (nonatomic, strong) CALayer *coverImageLayer;
@property (nonatomic, strong) CALayer *texture;

@property (nonatomic, strong) NSURL *logoURL;

@property (nonatomic, assign) BOOL    iscontinuous;
@property (nonatomic, assign) CGFloat speedFactor;

@end


@implementation MMRotatedImage

#pragma mark - Designated Initializer

- (id)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.cell = [[NSActionCell alloc] init];
        
        _coverWidth  = kDefaultCoverWidth;
        _speedFactor = 1.0;
        
        defaultDisk  = [NSImage imageNamed:@"default_disk"];
        
        [self layoutLayers];
    }
    
    return self;
}


- (void)setStyle:(XMCircularProgressIndicatorStyle)style {
    _style = style;
    
    for (CALayer *sublayer in self.layer.sublayers) {
        [sublayer removeFromSuperlayer];
    }
    
    [self layoutLayers];
}


- (void)layoutLayers {
    self.layer = [CALayer layer];
    [self setWantsLayer:YES];
    
    // 绘制裁切容器
    self.cropContainer = [CALayer layer];
    self.cropContainer.anchorPoint   = CGPointZero;
    self.cropContainer.position      = CGPointZero;
    self.cropContainer.bounds        = self.bounds;
    self.cropContainer.masksToBounds = YES;
    [self.layer addSublayer:self.cropContainer];
    
    // 绘制光盘容器
    self.diskContainer = [CALayer layer];
    self.diskContainer.anchorPoint   = CGPointZero;
    self.diskContainer.position      = CGPointZero;
    self.diskContainer.bounds        = self.bounds;
    [self.cropContainer addSublayer:self.diskContainer];
    
    // 设置容器的动画属性
    CAAnimation *positionAnimation   = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    positionAnimation.duration       = 0.5f;
    self.diskContainer.actions       = @{@"position":positionAnimation};
    
    // 设置各 Layer 的位置和大小
    CGPoint position = CGPointMake(NSWidth(self.diskContainer.bounds)/2, NSHeight(self.diskContainer.bounds)/2);
    switch (self.style) {
        case XMCircularProgressIndicatorStyleSemiCircle:
            position.y = kDefaultY;
            break;
        case XMCircularProgressIndicatorStyleCircle:
            self.coverWidth = MIN(NSWidth(self.diskContainer.bounds), NSHeight(self.diskContainer.bounds));
            break;
    }
    
    // 绘制阴影
    self.layer.shadowOpacity = 0.6f;
    self.layer.shadowOffset  = CGSizeMake(0, 0);
    self.layer.shadowRadius  = self.coverWidth * 0.06;
    
    // 绘制光盘
    self.coverImageLayer = [CALayer layer];
    self.coverImageLayer.contentsGravity = kCAGravityResizeAspectFill;
    self.coverImageLayer.position        = position;
    self.coverImageLayer.bounds          = CGRectMake(0, 0, self.coverWidth, self.coverWidth);
    self.coverImageLayer.cornerRadius    = self.coverWidth/2;
    self.coverImageLayer.masksToBounds   = YES;
    [self.diskContainer addSublayer:self.coverImageLayer];
    
    // 设置光盘的动画属性
    self.coverImageLayer.actions = @{@"transform":[NSNull null]};
    
    // 绘制光盘纹理
    self.texture = [CALayer layer];
    self.texture.position = CGPointMake(self.coverWidth/2, self.coverWidth/2);
    self.texture.bounds   = CGRectMake(0, 0, self.coverWidth, self.coverWidth);
    [self drawTexture];
    [self.coverImageLayer addSublayer:self.texture];
    
    // 设置默认封面
    [self setDefaultSongCover];
}


- (void)drawTexture {
    CALayer *blackCircle = [self drawCircleWithRadius:(kCentralMaskWidth + kTextureWidthSmall + kTextureWidthLarge)/2
                                          borderWidth:0.0f
                                          borderColor:CGColorGetConstantColor(kCGColorBlack)];
    blackCircle.backgroundColor = CGColorGetConstantColor(kCGColorBlack);
    blackCircle.opacity         = kTextureOpacityDark;
    [self.texture addSublayer:blackCircle];
    
    CALayer *smallWhiteRing = [self drawCircleWithRadius:(kCentralMaskWidth + kTextureWidthSmall)/2
                                             borderWidth:kTextureWidthSmall/2
                                             borderColor:CGColorGetConstantColor(kCGColorWhite)];
    [self.texture addSublayer:smallWhiteRing];
    
    CALayer *largeWhiteRing = [self drawCircleWithRadius:self.coverWidth/2
                                             borderWidth:kTextureWidthSmall/2
                                             borderColor:CGColorGetConstantColor(kCGColorWhite)];
    [self.texture addSublayer:largeWhiteRing];
}


- (CALayer *)drawCircleWithRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(CGColorRef)color {
    CALayer *circle        = [CALayer layer];
    circle.position        = CGPointMake(self.coverWidth/2, self.coverWidth/2);
    circle.bounds          = CGRectMake(0, 0, radius*2, radius*2);
    circle.cornerRadius    = radius;
    circle.borderColor     = color;
    circle.borderWidth     = width;
    circle.backgroundColor = CGColorGetConstantColor(kCGColorClear);
    circle.opacity         = kTextureOpacity;
    
    return circle;
}

#pragma mark - Handle Mouse Event

- (void)mouseDown:(NSEvent *)theEvent {
    if ([self isValidClick:theEvent] && self.target && self.action) {
        [NSApp sendAction:self.action to:self.target from:self];
        return;
    }
    
    [[self nextResponder] mouseDown:theEvent];
}


- (BOOL)isValidClick:(NSEvent *)theEvent {
    NSPoint clickPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    
    BOOL result = NO;
    CGFloat clickDistance = [self distanceBetween:self.coverImageLayer.position andPoint:clickPoint];
    
    if (clickDistance <= self.coverWidth/2) {
        result = YES;
    }
    
    return result;
}


- (CGFloat)distanceBetween:(NSPoint)point1 andPoint:(NSPoint)point2 {
    CGFloat deltaX = point1.x - point2.x;
    CGFloat deltaY = point1.y - point2.y;
    CGFloat distance = sqrt(deltaX * deltaX + deltaY * deltaY);
    
    return distance;
}


#pragma mark - Hide/Show Disk

//- (void)changeSong:(XMSong *)song {
//    if (self.song.Id == song.Id) {
//        return;
//    }
//    
//    [self stopRotating];
//    
//    self.song = song;
//    
//    if (self.style == XMCircularProgressIndicatorStyleCircle) {
//        [self setSongCoverWithSong:song];
//        return;
//    }
//    
//    if (![song.logoUrl.largeURL isEqual:self.logoURL]) {
//        [CATransaction setCompletionBlock:nil];
//        [CATransaction begin];
//        [CATransaction setCompletionBlock:^{
//            [self setDefaultSongCover];
//            [self setSongCoverWithSong:song];
//            [self showDisk];
//        }];
//        [self hideDisk];
//        [CATransaction commit];
//    }
//}


- (void)hideDisk {
    self.diskContainer.position = CGPointMake(
                                              0,
                                              -NSHeight(self.diskContainer.bounds));
}


- (void)showDisk {
    self.diskContainer.position = CGPointZero;
}


- (void)setDefaultSongCover {
    [self setSongCover:defaultDisk];
}

//
//- (void)setSongCoverWithSong:(XMSong *)song {
//    if (song.logoUrl) {
//        self.logoURL = song.logoUrl.largeURL;
//        [self loadHTTPCoverWithSong:song];
//    } else {
//        [self loadiTunesCoverWithSong:song];
//    }
//}
//
//
//- (void)loadiTunesCoverWithSong:(XMSong *)song {
//    [self setSongCover:defaultDisk];
//    [[NSImageView alloc] setiTunesImageWithSong:song defaultImage:defaultDisk success:^(NSImage *image) {
//        [self setSongCover:image];
//    } failure:^(NSError *error) {
//        //
//    }];
//}
//
//
//- (void)loadHTTPCoverWithSong:(XMSong *)song {
//    [self setSongCover:defaultDisk];
//    NSURL *imageURL = (self.shouldLoadOriginCover && XMUserConfig.isUseHighQuality) ? song.logoUrl.originURL : song.logoUrl.largeURL;
//    [NSImageView fetchImageWithURL:imageURL defaultImage:defaultDisk completion:^(NSImage *image, NSError *error) {
//        if (image) {
//            [self setSongCover:image];
//        }
//    }];
//}


- (void)setSongCover:(NSImage *)songCover {
    if (!songCover) {
        return;
    }
    
    _songCover = songCover;
    self.coverImageLayer.contents = _songCover;
    self.texture.hidden = [songCover isEqual:defaultDisk];
}


#pragma mark ======== Rotating =========

- (void)startRotating {
    self.iscontinuous  = YES;
    
    [self setNormalSpeed];
}


- (void)stopRotating {
    self.iscontinuous = NO;
}


#pragma mark - Quick Rotating

- (void)quickRotate:(BOOL)forward {
    [self startSpin:forward];
    [self stopSpin];
}


#pragma mark - Spin Methods

- (void)startSpin:(BOOL)forward {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setNormalSpeed) object:nil];
    self.speedFactor = forward ? kQuickRotationSpeed : -kQuickRotationSpeed;
}


- (void)stopSpin {
    [self performSelector:@selector(setNormalSpeed) withObject:nil afterDelay:0.25];
}


#pragma mark - Rotation Helper Methods

- (void)setNormalSpeed {
    self.speedFactor = 1.0;
}


#pragma mark - CVDisplayLink

CVReturn displayLinkOutputCallback(
                                   CVDisplayLinkRef displayLink,
                                   const CVTimeStamp *inNow,
                                   const CVTimeStamp *inOutputTime,
                                   CVOptionFlags flagsIn,
                                   CVOptionFlags *flagsOut,
                                   void *displayLinkContext)
{
    @autoreleasepool {
        __unsafe_unretained MMRotatedImage *self = (__bridge MMRotatedImage *)displayLinkContext;
        [self rotateIfNeeded];
    }
    
    return kCVReturnSuccess;
}


- (void)rotateIfNeeded {
    if (self.iscontinuous) {
        [self performSelectorOnMainThread:@selector(performRotate)
                               withObject:nil
                            waitUntilDone:NO];
    }
}


- (void)performRotate {
    self.currentAngel += kRotationAngle;
    self.coverImageLayer.transform = CATransform3DMakeRotation(self.currentAngel, 0, 0, 1);
}


#pragma mark - CVDisplayLink Lifecycle

- (void)awakeFromNib {
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLinkRef);
    CVDisplayLinkSetOutputCallback(displayLinkRef, displayLinkOutputCallback, (__bridge void *)self);
    CVDisplayLinkStart(displayLinkRef);
}

- (void)dealloc {
    CVDisplayLinkStop(displayLinkRef);
    CVDisplayLinkRelease(displayLinkRef);
}

@end
