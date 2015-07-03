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
#import "MMSearchView.h"
#import "MMLyricView.h"
#import "MMChannelView.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kWindowOriginYMargin = 30.0f;

static const CGFloat kWindowOriginHeight = 120.0f;
static const CGFloat kWindowFullHeight = 500.0f;

@interface MainWindowController () <MMSliderDelegate, NSControlTextEditingDelegate, MMSearchViewDelegate>

@property (nonatomic, weak) IBOutlet MMChannelView *channelView;
@property (nonatomic, weak) IBOutlet NSView *view2;
@property (nonatomic, weak) IBOutlet MMSlider *slider;
@property (nonatomic, weak) IBOutlet MMTableView *tableView;
@property (nonatomic, weak) IBOutlet MMRotatedImage *coverImage;
@property (nonatomic, weak) IBOutlet NSTextField *musicName;
@property (nonatomic, weak) IBOutlet NSTextField *timeField;
@property (nonatomic, weak) IBOutlet NSView *playListView;
@property (nonatomic, weak) IBOutlet NSTextField *searchField;
@property (nonatomic, weak) IBOutlet NSButton *playBtn;
@property (nonatomic, weak) IBOutlet NSView *listView;
@property (nonatomic, weak) IBOutlet MMLyricView *lyricView;
@property (nonatomic, weak) IBOutlet NSButton *loveBtn;


@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, strong) NSArray *musicList;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isPaused;
@property (nonatomic, assign) BOOL enableSetProgress;
@property (nonatomic, assign) BOOL enableSetVolumn;
@property (nonatomic, assign) BOOL lyricViewIsHide;
@property (nonatomic, assign) BOOL isShowingLyricView;
@property (nonatomic, assign) BOOL isshowTypeLyricShow;
@property (nonatomic, assign) NSRect listOriginRect;
@property (nonatomic, weak) IBOutlet MMSearchView *searchView;

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
    self.channelView.controller = self;
    
    [self fetchMusic:MMMusicChannelChildren];
    
    [self.searchView appendToView:self.window.contentView];
    self.searchView.delegate = self;
    
    self.enableSetProgress = YES;
    self.lyricViewIsHide = YES;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationWillResignActiveNotification 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification *note) {
         [self _hideWindow];
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
    [(MMView *)self.channelView setBackgroundImage:[NSImage imageNamed:@"background"]];
    [self pushView:self.channelView animated:YES];
}

- (IBAction)showLyric:(id)sender {
    if (self.lyricViewIsHide) {
        [self showLyricView];
    }
    else {
        [self hideLyricView];
    }
    self.lyricViewIsHide = !self.lyricViewIsHide;
}


- (IBAction)loveMusic:(id)sender {
    MusicInfo *playingMusic = [[PlayManager sharedManager] getCurrentMusic];
    MMLoveMusicDegree degree = playingMusic.isMyLove ? MMLoveMusicDegreeNormal : MMLoveMusicDegreeLove;
    [[MusicManager sharedManager] loveMusic:playingMusic.musicId loveDegree:degree complete:^(BOOL success) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                playingMusic.isMyLove = !playingMusic.isMyLove;
                [self setLoveMusic:playingMusic.isMyLove];
            });
        }
    }];
}

- (IBAction)deleteMusic:(id)sender {
    MusicInfo *playingMusic = [[PlayManager sharedManager] getCurrentMusic];
    [[MusicManager sharedManager] loveMusic:playingMusic.musicId loveDegree:MMLoveMusicDegreeHate complete:^(BOOL success) {
        if (success) {
            [[PlayManager sharedManager] playNext];
            [[PlayManager sharedManager] deleteMusic:playingMusic];
        }
    }];

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
    if ([[PlayManager sharedManager] isPlaying]) {
        [self.coverImage startRotating];
    }
    [self setProgress:[[PlayManager sharedManager] getProgress]];
}

- (void)showSmallSearchView {
}


- (void)_hideWindow {
    [self.window orderOut:nil];
    [self.coverImage stopRotating];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        
    }
    return NO;
}

- (void)controlTextDidChange:(NSNotification *)obj {
    NSResponder *firstResponder = [self.window firstResponder];
    if ([firstResponder isKindOfClass:[NSText class]] && [[(NSText *)firstResponder delegate] isEqual:self.searchField]) {
        NSString *keyword = self.searchField.stringValue;
        [[MusicManager sharedManager] searchMusic:keyword completion:^(int errorCode, NSArray *musicList) {
            if (errorCode == 0 && musicList.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.searchView setSearchContent:musicList];
                    [self.searchView showAtPoint:NSMakePoint(10, 350)];
                });
            }
            else {
                [self.searchView hidden];
                NSLog(@"errorCode: %d", errorCode);
            }
        }];
    }
}

- (void)sliderDidBeginDragging:(BOOL)forward slider:(MMSlider *)slider {
    if (slider == self.slider) {
        self.enableSetProgress = NO;
    }
}

- (void)sliderDidEndDragging:(MMSlider *)slider {
    if (slider == self.slider) {
        self.enableSetProgress = YES;
        [[PlayManager sharedManager] setProgress:self.slider.currentTime];
    }
}

- (IBAction)progressBarClickedOrDragged:(id)sender {
    self.enableSetProgress = NO;
}

- (IBAction)togglerFullScreen:(id)sender {
    NSRect windowFrame = self.window.frame;
    if (self.isFullScreen == NO) {
        self.isFullScreen = YES;
        windowFrame.origin.y -= (kWindowFullHeight - kWindowOriginHeight);
        windowFrame.size.height = kWindowFullHeight;
        [self.window setFrame:windowFrame display:YES animate:YES];
        static BOOL isFirst = YES;
        if (isFirst) {
            NSRect listViewRect = self.listView.frame;
            self.listOriginRect = listViewRect;
            listViewRect.origin.x = -listViewRect.size.width;
            self.lyricView.frame = listViewRect;
            [self.window.contentView addSubview:self.lyricView];
        }
        isFirst = NO;
        [self.lyricView setHidden:NO];
        [self.listView setHidden:NO];
    } else {
        self.isFullScreen = NO;
        [self.lyricView setHidden:YES];
        [self.listView setHidden:YES];
        windowFrame.origin.y += (kWindowFullHeight - kWindowOriginHeight);
        windowFrame.size.height = kWindowOriginHeight;
        [self.window setFrame:windowFrame display:YES animate:YES];
    }
}

- (void)showLyricView {
    if (self.isShowingLyricView) {
        return;
    }
    self.isshowTypeLyricShow = YES;
    self.isShowingLyricView = YES;
    self.lyricView.wantsLayer = YES;
    self.listView.wantsLayer = YES;
    
    NSPoint lyricBeginPoint = { -self.listView.layer.frame.size.width, self.listView.layer.frame.origin.y };
    NSPoint lyricEndPoint = { 0, self.listView.layer.frame.origin.y };
    CABasicAnimation *lyricAnimation = [CABasicAnimation animationWithKeyPath:@"position"]; 
    lyricAnimation.fromValue = [NSValue valueWithPoint:lyricBeginPoint];
    lyricAnimation.toValue = [NSValue valueWithPoint:lyricEndPoint];
    lyricAnimation.removedOnCompletion = NO; 
    lyricAnimation.duration = 0.8;
    lyricAnimation.fillMode = kCAFillModeForwards;
    [lyricAnimation setValue:@"showLyricView" forKey:[kAnimationId copy]];
    lyricAnimation.delegate = self;
    lyricAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]; 
    
    NSPoint listBeginPoint = { 0, self.listView.layer.frame.origin.y };
    NSPoint listEndPoint = { self.listView.layer.frame.size.width, self.listView.layer.frame.origin.y };
    CABasicAnimation *listAnimation = [CABasicAnimation animationWithKeyPath:@"position"]; 
    listAnimation.fromValue = [NSValue valueWithPoint:listBeginPoint];
    listAnimation.toValue = [NSValue valueWithPoint:listEndPoint];
    listAnimation.removedOnCompletion = NO; 
    listAnimation.duration = 0.8;
    listAnimation.fillMode = kCAFillModeForwards;
    listAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    [self.lyricView.layer addAnimation:lyricAnimation forKey:nil];
    [self.listView.layer addAnimation:listAnimation forKey:nil];
    [self.lyricView setProgress:[[PlayManager sharedManager] getProgress]];
}

- (void)hideLyricView {
    if (self.isShowingLyricView) {
        return;
    }
    self.isshowTypeLyricShow = NO;
    self.isShowingLyricView = YES;
    self.lyricView.wantsLayer = YES;
    self.listView.wantsLayer = YES;
    
    NSPoint lyricBeginPoint = { 0, self.listView.layer.frame.origin.y };
    NSPoint lyricEndPoint = { -self.listView.layer.frame.size.width, self.listView.layer.frame.origin.y };
    CABasicAnimation *lyricAnimation = [CABasicAnimation animationWithKeyPath:@"position"]; 
    lyricAnimation.fromValue = [NSValue valueWithPoint:lyricBeginPoint];
    lyricAnimation.toValue = [NSValue valueWithPoint:lyricEndPoint];
    lyricAnimation.removedOnCompletion = NO; 
    lyricAnimation.duration = 0.8;
    lyricAnimation.fillMode = kCAFillModeForwards;
    lyricAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]; 
    
    NSPoint listBeginPoint = { self.listView.layer.frame.size.width, self.listView.layer.frame.origin.y };
    NSPoint listEndPoint = { 0, self.listView.layer.frame.origin.y };
    CABasicAnimation *listAnimation = [CABasicAnimation animationWithKeyPath:@"position"]; 
    listAnimation.fromValue = [NSValue valueWithPoint:listBeginPoint];
    listAnimation.toValue = [NSValue valueWithPoint:listEndPoint];
    listAnimation.removedOnCompletion = NO; 
    listAnimation.duration = 0.8;
    listAnimation.fillMode = kCAFillModeForwards;
    [listAnimation setValue:@"hideLyricView" forKey:[kAnimationId copy]];
    listAnimation.delegate = self;
    listAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]; 
    [self.lyricView.layer addAnimation:lyricAnimation forKey:nil];
    [self.listView.layer addAnimation:listAnimation forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    NSString *key = [animation valueForKey:[kAnimationId copy]];
    if ([key isEqualToString:@"showLyricView"] || [key isEqualToString:@"hideLyricView"]) {
        self.isShowingLyricView = NO;
        if (!self.isshowTypeLyricShow) {
            self.listView.frame = self.listOriginRect;
            NSRect tmpRect = self.listOriginRect;
            tmpRect.origin.x = -tmpRect.size.width;
            self.lyricView.frame = tmpRect;
        } else {
            self.lyricView.frame = self.listOriginRect;
            NSRect tmpRect = self.listOriginRect;
            tmpRect.origin.x = tmpRect.size.width;
            self.listView.frame = tmpRect;
        }
    }
    else {
        [super animationDidStop:animation finished:flag];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.musicList.count;
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

- (void)startParserLyric:(MusicInfo *)music {
    [self.lyricView startPlayLyric:music];
}

- (void)didClickMusic:(MusicInfo *)music {
    [[PlayManager sharedManager] playMusic:music];
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
    self.slider.currentTime = 0.0f;
    self.slider.duration = duration;
}

- (void)setProgress:(NSTimeInterval)progress {
    if (self.window.isVisible) {
        if (self.enableSetProgress) {
            self.slider.currentTime = progress;
        }
        NSString *showTime = [NSString stringWithFormat:@"%ld:%02ld/%ld:%02ld", (NSInteger)progress / 60,  (NSInteger)progress % 60, (NSInteger)self.duration / 60, (NSInteger)self.duration % 60];
        self.timeField.stringValue = showTime;
        if (self.isshowTypeLyricShow) {
            [self.lyricView setProgress:progress];
        }
    }
}

- (void)setCover:(NSImage *)coverImage {
    [self.coverImage setSongCover:coverImage];
}

- (void)startAnimation {
    if (self.window.isVisible) {
        [self.coverImage startRotating];
    }
}

- (void)stopAnimation {
    [self.coverImage stopRotating];
}

- (void)setVolumn:(CGFloat)volumn {
    [[PlayManager sharedManager] setVolumn:volumn];
}

- (void)setLoveMusic:(BOOL)isMyLove {
    if (isMyLove) {
        [self.loveBtn setImage:[NSImage imageNamed:@"player_btn_favorited_normal"]];
    } else {
        [self.loveBtn setImage:[NSImage imageNamed:@"player_btn_not_favorite_normal"]];
    }
}

- (void)setMusicList:(NSArray *)musicList {
    _musicList = musicList;
    [[PlayManager sharedManager] setPlayMusicList:musicList];
    [self.tableView reloadData];
}

- (void)refreshMusicList {
    MMMusicChannel currentChannel = [self.channelView getCurrentChannel];
    [self fetchMusic:currentChannel];
}

- (void)fetchMusic:(MMMusicChannel)channel {
    [[MusicManager sharedManager] fetchRandomListWithChannel:channel complete:^(int errorCode, NSArray *musicList) {
        if (errorCode == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (musicList.count == 0) {
                    [self fetchMusic:channel];
                } else {
                    self.musicList = musicList;
                    [[PlayManager sharedManager] setPlayMusicList:musicList];
                    [self.tableView reloadData];
                }
            });
        }
    }];
}

@end
