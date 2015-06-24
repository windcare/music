//
//  MainWindowController.m
//  MyMusic
//
//  Created by sjjwind on 5/26/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MainWindowController.h"
#import "MMWindow.h"
#import "MMView.h"
#import "MMSlider.h"
#import "MMTableView.h"
#import "MMTableCellView.h"
#import "MusicManager.h"
#import "MusicFile.h"
#import "MyPlayer.h"
#import "MMRotatedImage.h"

static const CGFloat kWindowOriginYMargin = 30.0f;

static const CGFloat kWindowOriginHeight = 120.0f;
static const CGFloat kWindowFullHeight = 500.0f;

@interface MainWindowController () <MMSliderDelegate>

@property (nonatomic, weak) IBOutlet NSView *view1;
@property (nonatomic, weak) IBOutlet NSView *view2;
@property (nonatomic, weak) IBOutlet MMSlider *slider;
@property (nonatomic, weak) IBOutlet MMTableView *tableView;
@property (nonatomic, weak) IBOutlet MMRotatedImage *coverImage;

@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, strong) NSArray *musicList;

@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [(MMWindow *)self.window setClearBackground];
    [(MMView *)self.window.contentView setBackgroundImage:[NSImage imageNamed:@"background"]];
    [self setRootView:self.window.contentView];
    
    NSRect originRect = self.window.frame;
    originRect.size.height = kWindowOriginHeight;
    [self.window setFrame:originRect display:YES];
    [self.slider setDelegate:self];
    self.slider.duration = 400.0;
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(didDoubleClickFolderRow:)];
    [[MusicManager sharedManager] fetchRandomListWithChannel:0 complete:^(int errorCode, NSArray *musicList) {
        if (errorCode == 0) {
            self.musicList = musicList;
            [self.tableView reloadData];
        }
    }]; 
}

+ (MainWindowController *)sharedMainWindowController{
    static MainWindowController *_sharedMainWindowController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMainWindowController = [[self alloc] initWithWindowNibName:[self className]];
    });
    
    return _sharedMainWindowController;
}

- (IBAction)test:(id)sender {
    [(MMView *)self.view1 setBackgroundImage:[NSImage imageNamed:@"background"]];
    [self pushView:self.view1 animated:YES];
}

- (IBAction)test1:(id)sender {
    [self popViewAnimated:YES];
}

- (void)toggleWindow {
    if (!self.window.isVisible) {
        [self _showWindow];
    } else {
        [self _hideWindow];
    }
}

- (void)_showWindow {
    NSRect itemFrame = [[[NSApp currentEvent] window] frame];
    NSRect windowFrame = self.window.frame;
    windowFrame.origin.x = NSMidX(itemFrame) - ceil(NSWidth(windowFrame)/2);
    windowFrame.origin.y = NSMaxY(itemFrame) - NSHeight(windowFrame) - kWindowOriginYMargin;
    [self.window setFrame:windowFrame display:YES];
    
    [(MMWindow *)self.window showWindowAndMakeItKeyWindow];
}


- (void)_hideWindow {
    [self.window orderOut:nil];
}

- (void)sliderDidBeginDragging:(BOOL)forward {
  NSLog(@"Begin Dragging");
}

- (void)sliderDidEndDragging {
  NSLog(@"End Dragging");
}

- (IBAction)progressBarClickedOrDragged:(id)sender {
}

- (IBAction)togglerFullScreen:(id)sender {
    NSRect windowFrame = self.window.frame;
    if (self.isFullScreen == NO) {
        self.isFullScreen = YES;
        windowFrame.origin.y -= (kWindowFullHeight - kWindowOriginHeight);
        windowFrame.size.height = kWindowFullHeight;
        [self.window setFrame:windowFrame display:YES animate:YES];
    } else {
        self.isFullScreen = NO;
        windowFrame.origin.y += (kWindowFullHeight - kWindowOriginHeight);
        windowFrame.size.height = kWindowOriginHeight;
        [self.window setFrame:windowFrame display:YES animate:YES];
    }
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.musicList.count;
}

- (void)tableView:(NSTableView *)tableView
  willDisplayCell:(id)cell
   forTableColumn:(NSTableColumn *)tableColumn
              row:(NSInteger)row {
    [cell setBackgroundColor:[NSColor whiteColor]];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    MMTableCellView *cellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];    
    [cellView setMusicInfo:self.musicList[row]];
    return cellView;
}

- (IBAction)didDoubleClickFolderRow:(id)sender {
    NSUInteger row = self.tableView.clickedRow;
    MusicInfo *selectMusic = self.musicList[row];
    MusicFile *file = [[MusicFile alloc] init];
    file.musicName = selectMusic.musicName;
    [[MusicManager sharedManager] downloadMusic:selectMusic.musicId complete:^(int errorCode, NSString *path) {
        if (errorCode == -1) {
            file.audioFileURL = [NSURL URLWithString:path];
            MyPlayer *player = [[MyPlayer alloc] init];
            [player setMusicList:@[file]];
            [player play];
        }
    }];
    [[MusicManager sharedManager] downloadCoverImage:selectMusic.musicId complete:^(int errorCode, NSString *path) {
        self.coverImage.songCover = [[NSImage alloc] initWithContentsOfFile:path];
        [self.coverImage startRotating];
    }];
}
@end
