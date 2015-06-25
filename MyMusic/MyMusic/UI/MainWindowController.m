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
#import "PlayManager.h"

static const CGFloat kWindowOriginYMargin = 30.0f;

static const CGFloat kWindowOriginHeight = 120.0f;
static const CGFloat kWindowFullHeight = 500.0f;

@interface MainWindowController () <MMSliderDelegate>

@property (nonatomic, weak) IBOutlet NSView *view1;
@property (nonatomic, weak) IBOutlet NSView *view2;
@property (nonatomic, weak) IBOutlet MMSlider *slider;
@property (nonatomic, weak) IBOutlet MMTableView *tableView;
@property (nonatomic, weak) IBOutlet MMRotatedImage *coverImage;
@property (nonatomic, weak) IBOutlet NSTextField *musicName;
@property (nonatomic, weak) IBOutlet NSTextField *timeField;
@property (nonatomic, weak) IBOutlet NSView *playListView;
@property (nonatomic, weak) IBOutlet NSView *leftPanelView;
@property (nonatomic, weak) IBOutlet NSButton *playBtn;

@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, strong) NSArray *musicList;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isPaused;

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
    [PlayManager sharedManager].controller = self;
    [self fetchMusic:MMMusicChannelChildren];
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
    [[PlayManager sharedManager] playMusic:selectMusic];
}

- (IBAction)changeList:(id)sender {
//    [self pushSmallView:self.leftPanelView fromView:self.playListView type:PushTypeFromLeft];
}

- (IBAction)play:(id)sender {
    if (self.isPaused) {
        self.isPaused = NO;
        [self.playBtn setImage:[NSImage imageNamed:@"player_btn_play_normal"]];
        [[PlayManager sharedManager] play];
    }
    else {
        self.isPaused = YES;
        [self.playBtn setImage:[NSImage imageNamed:@"player_btn_pause_normal"]];
        [[PlayManager sharedManager] pause];
    }
}

- (IBAction)playNext:(id)sender {
    [[PlayManager sharedManager] playNext];
}

- (IBAction)playPrevious:(id)sender {
    [[PlayManager sharedManager] playPrevious];
}

- (void)setMusicName:(NSString *)musicName authorName:(NSString *)artist {
    NSString *showName = nil;
    if (artist != nil ) {
        showName = [NSString stringWithFormat:@"%@ - %@", musicName, artist];
    }
    else {
        showName = musicName;
    }
    
    self.musicName.stringValue = showName;
}

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
}

- (void)setProgress:(NSTimeInterval)progress {
    self.slider.currentTime = progress;
    NSString *showTime = [NSString stringWithFormat:@"%ld:%ld/%ld:%ld", (NSInteger)progress / 60,  (NSInteger)progress % 60, (NSInteger)self.duration / 60, (NSInteger)self.duration % 60];
    self.timeField.stringValue = showTime;
}

- (void)setCover:(NSImage *)coverImage {
    [self.coverImage setSongCover:coverImage];
}

- (void)startAnimation {
    [self.coverImage startRotating];
}

- (void)stopAnimation {
    [self.coverImage stopRotating];
}

- (void)setVolumn:(CGFloat)volumn {
    
}

- (void)fetchMusic:(MMMusicChannel)channel {
    [[MusicManager sharedManager] fetchRandomListWithChannel:channel complete:^(int errorCode, NSArray *musicList) {
        if (errorCode == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.musicList = musicList;
                [[PlayManager sharedManager] setPlayMusicList:musicList];
                [self.tableView reloadData];
            });
        }
    }];
}

- (IBAction)hotMusic:(id)sender {
    [self fetchMusic:MMMusicChannelHot];
}

- (IBAction)classicMusic:(id)sender {
    [self fetchMusic:MMMusicChannelClassic];
}

- (IBAction)chineseVoice:(id)sender {
    [self fetchMusic:MMMusicChannelChinaVioce];
}

@end
