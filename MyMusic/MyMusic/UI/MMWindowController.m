//
//  MMWindowController.m
//  MyMusic
//
//  Created by sjjwind on 5/27/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMWindowController.h"
#import <QuartzCore/QuartzCore.h>

@interface MMWindowController ()

@property (nonatomic, strong) NSMutableArray *views;

@end

@implementation MMWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)setRootView:(NSView *)rootView {
    if (self.views == nil) {
        self.views = [NSMutableArray array];
    }
    [self.views addObject:rootView];
}

- (void)pushView:(NSView *)view animated:(BOOL)animated {
    view.wantsLayer = YES;
    view.layer.frame = view.frame;
    view.layer.masksToBounds = YES;
    NSView *topView = [self.views lastObject];
    if (animated) {
        NSPoint beginPoint = { self.window.frame.size.width, 0 };
        NSPoint endPoint = { 0, 0 };
        [topView addSubview:view];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"]; 
        animation.fromValue = [NSValue valueWithPoint:beginPoint];
        animation.toValue = [NSValue valueWithPoint:endPoint];
        animation.removedOnCompletion = NO; 
        animation.duration = 0.3;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]; 
        [view.layer addAnimation:animation forKey:nil];
    } else {
        
        [topView addSubview:view];
    }
    [self.views addObject:view];
}

- (void)popViewAnimated:(BOOL)animated {
    NSView *topView = self.views.lastObject;
    if (animated) {
        NSPoint beginPoint = { 0, 0 };
        NSPoint endPoint = { self.window.frame.size.width, 0 };
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"]; 
        animation.fromValue = [NSValue valueWithPoint:beginPoint];
        animation.toValue = [NSValue valueWithPoint:endPoint];
        animation.removedOnCompletion = NO; 
        animation.duration = 0.3;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]; 
        animation.delegate = self;
        [animation setValue:@"popViewAnimated" forKey:[kAnimationId copy]];
        [topView.layer addAnimation:animation forKey:nil];
    } else {
        [topView removeFromSuperview];
        [self.views removeLastObject];
    }
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    NSView *topView = self.views.lastObject;
    [topView removeFromSuperview];
    [self.views removeLastObject];
}

- (void)popToRootViewAnimated:(BOOL)animated {
    
}

- (void)pushSmallView:(NSView *)pushView fromView:(NSView *)fromView type:(PushType)type {
//    pushView.wantsLayer = YES;
//    pushView.layer.masksToBounds = YES;
    switch (type) {
        case PushTypeFromLeft:
        {
            pushView.wantsLayer = YES;
            pushView.layer.masksToBounds = YES;
            NSPoint beginPoint = { fromView.frame.origin.x - fromView.frame.size.width, fromView.frame.origin.y };
            NSPoint endPoint = { fromView.frame.origin.x, fromView.frame.origin.y };
            NSRect viewRect = pushView.frame;
            viewRect.origin = beginPoint;
            viewRect.size.height = fromView.frame.size.height;
            pushView.frame = viewRect;
            pushView.layer.frame = pushView.frame;
            [fromView addSubview:pushView];
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"]; 
            animation.fromValue = [NSValue valueWithPoint:beginPoint];
            animation.toValue = [NSValue valueWithPoint:endPoint];
            animation.removedOnCompletion = NO; 
            animation.duration = 1.2;
            animation.fillMode = kCAFillModeForwards;
            animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]; 
            [pushView.layer addAnimation:animation forKey:nil];
            break;
        }
        case PushTypeFromRight:
            break;
        default:
            break;
    }
}

@end
