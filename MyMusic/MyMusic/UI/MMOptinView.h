//
//  MMOptinView.h
//  MyMusic
//
//  Created by sjjwind on 8/10/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MMOptionCellView.h"

@protocol MMOptionViewDelegate <NSObject>

- (void)didClickOption:(MMOptionCellView *)cell;

@end

@protocol MMOptionDelegate <NSObject>

- (void)didOptionChange:(NSInteger)index;

@end

@interface MMOptinView : NSView

@property (nonatomic, assign) id<MMOptionDelegate> delegate;

- (void)setOptions:(NSArray *)options;

@end
