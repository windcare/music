//
//  MMOptionCellView.m
//  MyMusic
//
//  Created by sjjwind on 8/10/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMOptionCellView.h"
#import "MMOptinView.h"

@interface MMOptionCellView()

@property (nonatomic, weak) IBOutlet NSImageView *iconImageView;
@property (nonatomic, weak) IBOutlet NSTextField *titleField;
@property (nonatomic, weak) IBOutlet NSTextField *background;
@property (nonatomic, assign) BOOL isFocus;
@property (nonatomic, assign) NSInteger optionIndex;

@end

@implementation MMOptionCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setIndex:(NSInteger)index {
    self.optionIndex = index;
}

- (NSInteger)getIndex {
    return self.optionIndex;
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self.delegate didClickOption:self];
    NSLog(@"enter: %@", theEvent);
}

- (void)setTitle:(NSString *)title {
    self.titleField.stringValue = title;
}

- (void)setIconImage:(NSImage *)iconImage {
    [self.iconImageView setImage:iconImage];
}

- (void)setFocus:(BOOL)isFocus {
    self.isFocus = isFocus;
    if (isFocus) {
        [self.background setBackgroundColor:[NSColor colorWithCalibratedRed:0.867 green:0.871 blue:0.890 alpha:1.0]];
    } else {
        [self.background setBackgroundColor:[NSColor clearColor]];
    }
}

@end
