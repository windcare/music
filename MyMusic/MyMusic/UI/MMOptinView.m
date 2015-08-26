//
//  MMOptinView.m
//  MyMusic
//
//  Created by sjjwind on 8/10/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMOptinView.h"
#import "MMOptionCellView.h"
#import "MMOptionSepratorCellView.h"
#import "MMTableView.h"

@interface MMOptinView() <MMOptionViewDelegate>

@property (nonatomic, strong) NSArray *options;

@property (nonatomic, weak) IBOutlet MMTableView *tableView;

@property (nonatomic, weak) MMOptionCellView *focusCellView;

@end

@implementation MMOptinView

- (void)setOptions:(NSArray *)options {
    _options = options;
    [self.tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.options.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    NSDictionary *dic = self.options[row];
    if ([dic[@"type"] integerValue] != 0) {
        return 30.0f;
    }
    return 45.0f;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSDictionary *dic = self.options[row];
    if ([dic[@"type"] integerValue] != 0) {
        MMOptionCellView *cellView = [tableView makeViewWithIdentifier:@"optionViewCell" owner:self];    
        [cellView setTitle:dic[@"title"]];
        cellView.delegate = self;
        [cellView setFocus:NO];
        NSImage *iconImage = [NSImage imageNamed:dic[@"image"]];
        [cellView setIconImage:iconImage];
        [cellView setIndex:row];
        return cellView;
    } else {
        MMOptionSepratorCellView *cellView = [tableView makeViewWithIdentifier:@"optionViewSeprator" owner:self];
        [cellView setTitle:dic[@"title"]];
        [cellView setIndex:row];
        return cellView;
    }
}

- (void)didClickOption:(MMOptionCellView *)cell {
    if (self.focusCellView) {
        [self.focusCellView setFocus:NO];
    }
    [cell setFocus:YES];
    self.focusCellView = cell;
    if (self.delegate) {
        [self.delegate didOptionChange:[cell getIndex]];
    }
}

@end
