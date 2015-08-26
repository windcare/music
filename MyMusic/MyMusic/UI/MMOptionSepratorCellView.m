//
//  MMOptionSepratorCellView.m
//  MyMusic
//
//  Created by sjjwind on 8/10/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMOptionSepratorCellView.h"

@interface MMOptionSepratorCellView()

@property (nonatomic, weak) IBOutlet NSTextField *titleField;
@property (nonatomic, assign) NSInteger optionIndex;

@end

@implementation MMOptionSepratorCellView

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

- (void)setTitle:(NSString *)title {
    self.titleField.stringValue = title;
}

@end
