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
#import "MMOptinView.h"

// options
#import "MMHomePageView.h"
#import "MMRankPageView.h"
#import "MMFMPageView.h"
#import "MMGuessPageView.h"
#import "MMDevicePageView.h"
#import "MMLovePageView.h"
#import "MMSongPageView.h"
#import "MMiTunesPageView.h"

#import "MMSongTable.h"

#import <QuartzCore/QuartzCore.h>

static const CGFloat kWindowOriginYMargin = 30.0f;

static const CGFloat kWindowOriginHeight = 120.0f;
static const CGFloat kWindowFullHeight = 660.0f;

@interface MainWindowController () <MMSliderDelegate, 
                                    NSControlTextEditingDelegate, 
                                    MMSearchViewDelegate, MMOptionDelegate>

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

// layout view
@property (nonatomic, weak) IBOutlet MMView *layoutView;

// top view
@property (nonatomic, weak) IBOutlet MMView *topView;

// bottom view
@property (nonatomic, weak) IBOutlet MMView *bottomView;

// center view
@property (nonatomic, weak) NSView *currentOptionView;
@property (nonatomic, weak) IBOutlet MMView *centerView;
@property (nonatomic, weak) IBOutlet MMHomePageView *homePageView;
@property (nonatomic, weak) IBOutlet MMRankPageView *rankPageView;
@property (nonatomic, weak) IBOutlet MMFMPageView *fmPageView;
@property (nonatomic, weak) IBOutlet MMGuessPageView *guessPageView;
@property (nonatomic, weak) IBOutlet MMDevicePageView *devicePageView;
@property (nonatomic, weak) IBOutlet MMLovePageView *lovePageView;
@property (nonatomic, weak) IBOutlet MMSongPageView *songPageView;
@property (nonatomic, weak) IBOutlet MMiTunesPageView *iTunesPageView;

// left view
@property (nonatomic, weak) IBOutlet MMView *leftView;
@property (nonatomic, weak) IBOutlet MMOptinView *optionView;

// songView
@property (nonatomic, weak) IBOutlet MMSongTable *songListView;


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
    
    [self initLayoutView];
    [self initTopView];
    [self initCenterView];
    [self initBottomView];
    [self initLeftView];
    
    [self setRootView:self.window.contentView];
    
    [self.slider setDelegate:self];
    self.slider.duration = 400.0;
    
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(didDoubleClickFolderRow:)];
    
    [PlayManager sharedManager].controller = self;
    
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

- (void)initLayoutView {
    [(MMWindow *)self.window setClearBackground];
    [(MMWindow *)self.window setContentView:self.layoutView];
    [self.layoutView setBackgroundColor:[NSColor whiteColor]];
}

- (void)initTopView {
    [self.topView setBackgroundColor:[NSColor colorWithCalibratedRed:0.125 green:0.643 blue:0.325 alpha:1.0]];
    
    // 显示右上角button
    NSButton *closeButton = [NSWindow standardWindowButton:NSWindowCloseButton forStyleMask:NSTitledWindowMask];
    NSRect closeButtonRect = [closeButton frame];
    [closeButton setFrame:NSMakeRect(6, self.window.frame.size.height - 3 - closeButtonRect.size.height, closeButtonRect.size.width, closeButtonRect.size.height)];
    [closeButton setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
    
    [self.layoutView addSubview:closeButton];
}

- (void)initCenterView {
    NSArray *options = @[@{
                         @"type": @(0),
                         @"title": @"精选",
                         },
                     @{
                         @"type": @(1),
                         @"title": @"首页",
                         @"image": @"home_recommend",
                         },
                     @{
                         @"type": @(1),
                         @"title": @"排行榜",
                         @"image": @"home_ranking",
                         },
                     @{
                         @"type": @(1),
                         @"title": @"电台",
                         @"image": @"home_radio",
                         },
                     @{
                         @"type": @(1),
                         @"title": @"猜你喜欢",
                         @"image": @"home_gessyoulike",
                         },
                     @{
                         @"type": @(1),
                         @"title": @"我的设备",
                         @"image": @"home_choiceness",
                         },
                     @{
                         @"type": @(0),
                         @"title": @"我的歌曲",
                         },
                     @{
                         @"type": @(1),
                         @"title": @"我喜欢",
                         @"image": @"home_love",
                         },
                     @{
                         @"type": @(1),
                         @"title": @"我的歌单",
                         @"image": @"home_custom",
                         },
                     @{
                         @"type": @(1),
                         @"title": @"iTunes音乐",
                         @"image": @"home_custom",
                         }];
    [self.optionView setOptions:options];
    [self.optionView setDelegate:self];
}

- (void)initBottomView {
    [self.bottomView setBackgroundColor:[NSColor colorWithCalibratedRed:0.067 green:0.247 blue:0.239 alpha:1.0]];
}

- (void)initLeftView {
    [self.leftView setBackgroundColor:[NSColor colorWithCalibratedRed:0.941 green:0.945 blue:0.969 alpha:1.0]];
    [self.leftView addSubview:self.optionView];
}

+ (MainWindowController *)sharedMainWindowController{
    static MainWindowController *_sharedMainWindowController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMainWindowController = [[self alloc] initWithWindowNibName:[self className]];
    });
    
    return _sharedMainWindowController;
}

- (MMSongTable *)getSongTable {
    return self.songListView;
}

- (MMView *)getCenterView {
    return self.centerView;
}

- (MMRankPageView *)getRankPageView {
    return self.rankPageView;
}

- (void)setCurrentView:(NSView *)view {
    if (self.currentOptionView) {
        [self.currentOptionView removeFromSuperview];
    }
    self.currentOptionView = view;
}

- (void)didOptionChange:(NSInteger)index {
    if (self.currentOptionView) {
        [self.currentOptionView removeFromSuperview];
    }
    MMView *selectPageView = nil;
    switch (index) {
        case 1:
            selectPageView = self.homePageView;
            break;
        case 2: {
            selectPageView = self.rankPageView;
            NSArray *rankInfos = @[@{
                                       @"image": @"pop",
                                       @"title": @"巅峰榜·流行指数",
                                       },
                                   @{
                                       @"image": @"inner",
                                       @"title": @"巅峰榜·内地",
                                       },
                                   @{
                                       @"image": @"hk",
                                       @"title": @"巅峰榜·港台榜",
                                       },
                                   @{
                                       @"image": @"us",
                                       @"title": @"巅峰榜·欧美",
                                       },
                                   @{
                                       @"image": @"jp",
                                       @"title": @"巅峰榜·日本",
                                       },
                                   @{
                                       @"image": @"national",
                                       @"title": @"巅峰榜·民谣",
                                       },
                                   @{
                                       @"image": @"rock",
                                       @"title": @"巅峰榜·摇滚",
                                       },
                                   @{
                                       @"image": @"china-top",
                                       @"title": @"中国top排行榜",
                                       },
                                   @{
                                       @"image": @"iTunes",
                                       @"title": @"iTunes榜",
                                       },
                                   @{
                                       @"image": @"bk-bussiness",
                                       @"title": @"香港商业电台榜",
                                       },
                                   @{
                                       @"image": @"billboard",
                                       @"title": @"Billboard美国公告牌榜",
                                       },
                                   @{
                                       @"image": @"uk",
                                       @"title": @"英国UK榜",
                                       },
                                   @{
                                       @"image": @"channel-v",
                                       @"title": @"Channel[V]榜",
                                       },
                                   @{
                                       @"image": @"hk_new",
                                       @"title": @"香港新城榜",
                                       },
                                   @{
                                       @"image": @"dark-disk",
                                       @"title": @"幽浮劲碟榜",
                                       },
                                   @{
                                       @"image": @"jp_pub",
                                       @"title": @"日本公信榜",
                                       },
                                   @{
                                       @"image": @"ktv",
                                       @"title": @"KTV榜",
                                       }];
            [self.rankPageView setRankInfos:rankInfos];
            break;
        }
        case 3:
            selectPageView = self.fmPageView;
            break;
        case 4:
            selectPageView = self.guessPageView;
            break;
        case 5:
            selectPageView = self.devicePageView;
            break;
        case 7:
            selectPageView = self.lovePageView;
            break;
        case 8:
            selectPageView = self.songPageView;
            break;
        case 9:
            selectPageView = self.iTunesPageView;
        default:
            break;
    }
    [self.centerView addSubview:selectPageView];
    self.currentOptionView = selectPageView;
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


- (void)fetchMusic:(MMMusicChannel)channel {
//    [[MusicManager sharedManager] fetchRandomListWithChannel:channel complete:^(int errorCode, NSArray *musicList) {
//        if (errorCode == 0) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (musicList.count == 0) {
//                    [self fetchMusic:channel];
//                } else {
//                    self.musicList = musicList;
//                    [[PlayManager sharedManager] setPlayMusicList:musicList];
//                    [self.tableView reloadData];
//                }
//            });
//        }
//    }];
}

@end
