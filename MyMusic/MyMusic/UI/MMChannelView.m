//
//  MMChannelView.m
//  MyMusic
//
//  Created by sjjwind on 7/2/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMChannelView.h"
#import "MMChannelCell.h"
#import "MusicManager.h"

const static NSInteger kLabelHeight = 20;
const static NSInteger kBlockHeight = 25;
const static NSInteger kSeparateHeight = 35;
const static NSInteger kDocumentHeight = 1600;
@interface MMChannelElement : NSObject

@property (nonatomic, strong) NSString *sortName;
@property (nonatomic, strong) NSArray *channels;

@end

@interface MMChannelView() <MMChannelCellDelegate>

@property (nonatomic, assign) MMMusicChannel channelId;
@property (nonatomic, strong) NSScrollView *channelScrollView;

@end


@implementation MMChannelView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self setBackgroundImage:[NSImage imageNamed:@"background"]];
        [self layoutChannelView];
    }
    
    return self;
}

- (void)layoutChannelView {
    NSRect channelRect = self.frame;
    channelRect.origin.y = 35;
    channelRect.size.height = 430;
    self.channelScrollView = [[NSScrollView alloc] initWithFrame:channelRect];
    self.channelScrollView.drawsBackground = NO;
    [self addSubview:self.channelScrollView];
    
    NSRect contentViewRect = { 0, 0, self.frame.size.width, kDocumentHeight };
    NSView *contentView = [[NSView alloc] initWithFrame:contentViewRect];
    [self.channelScrollView setDocumentView:contentView];
    
    NSDictionary *allChannel = @{
                            @"推荐": @[
                                @[@"私人频道", @(MMMusicChannelPersonal)],
                                @[@"我喜欢", @(MMMusicChannelLove)],
                                ],
                            @"热门": @[
                                @[@"热歌", @(MMMusicChannelHot)],
                                @[@"歌曲", @(MMMusicChannelKTV)],
                                @[@"成名曲", @(MMMusicChannelFamous)],
                                @[@"随便听听", @(MMMusicChannelRandom)],
                                @[@"网络歌曲", @(MMMusicChannelNetwork)],
                                @[@"影视歌曲", @(MMMusicChannelTV)],
                                @[@"中国好声音", @(MMMusicChannelChinaVioce)],
                                ],
                            @"时间轴": @[
                                @[@"经典老歌", @(MMMusicChannelClassic)],
                                @[@"70后歌曲", @(MMMusicChannel70Age)],
                                @[@"80后歌曲", @(MMMusicChannel80Age)],
                                @[@"90后歌曲", @(MMMusicChannel90Age)],
                                @[@"儿童歌曲", @(MMMusicChannelChildren)],
                                ],
                            @"风格": @[
                                @[@"新歌", @(MMMusicChannelNew)],
                                @[@"流行", @(MMMusicChannelPopular)],
                                @[@"轻音乐", @(MMMusicChannelLightMusic)],
                                @[@"小清新", @(MMMusicChannelFresh)],
                                @[@"中国风", @(MMMusicChannelChineseWind)],
                                @[@"摇滚", @(MMMusicChannelRock)],
                                @[@"电影", @(MMMusicChannelVideo)],
                                @[@"民谣", @(MMMusicChannelFolk)],
                                ],
                            @"语种": @[
                                @[@"华语", @(MMMusicChannelChinese)],
                                @[@"欧美", @(MMMusicChannelEurope)],
                                @[@"小鬼子", @(MMMusicChannelJanpan)],
                                @[@"韩语", @(MMMusicChannelKorea)],
                                @[@"粤语", @(MMMusicChannelCantonese)],
                                ],
                            @"心情": @[
                                @[@"欢快", @(MMMusicChannelHappy)],
                                @[@"舒缓", @(MMMusicChannelSlow)],
                                @[@"伤感", @(MMMusicChannelSad)],
                                @[@"轻松", @(MMMusicChannelReleax)],
                                @[@"寂寞", @(MMMusicChannelAlone)],
                                ],
                            };
    int originX = 20;
    __block int originY = 0;
    NSArray *labelList = @[@"风格", @"语种", @"心情", @"时间轴", @"热门", @"推荐"];
    [labelList enumerateObjectsUsingBlock:^(NSString *label, NSUInteger idx, BOOL *stop) {
        NSArray *allSonChannel = allChannel[label];
        NSInteger sonChannelRowCount = (allSonChannel.count + 3) / 4;
        NSInteger channelOrginY = originY + (sonChannelRowCount - 1) * kSeparateHeight;
        for (int j = 0; j < sonChannelRowCount; j++) {
            for (int i = 0; j * 4 + i < allSonChannel.count && i < 4; i++) {
                NSArray *channelInfo = allSonChannel[j * 4 + i];
                NSRect channelRect = { originX + i * 95, channelOrginY, 75, kBlockHeight };
                MMChannelCell *cell = [[MMChannelCell alloc] initWithFrame:channelRect];
                cell.channelId = [channelInfo[1] integerValue];
                [cell setCellName:channelInfo[0]];
                cell.delegate = self;
                [contentView addSubview:cell];
            }
            channelOrginY -= kSeparateHeight;
            originY += kSeparateHeight;
        }
        
        NSRect labelRect = { 5, originY, 200, kLabelHeight };
        NSTextField *labelField = [[NSTextField alloc] initWithFrame:labelRect];
        labelField.bezeled = NO;
        labelField.drawsBackground = NO;
        labelField.editable = NO;
        labelField.selectable = NO;
        labelField.stringValue = label;
        labelField.textColor = [NSColor whiteColor];
        [contentView addSubview:labelField];
        
        originY += kLabelHeight;
        originY += 10;
    }];
    contentViewRect.size.height = originY;
    contentView.frame = contentViewRect;
}

- (void)onClick:(MMChannelCell *)cell {
    if (self.channelId != cell.channelId) {
        self.channelId = cell.channelId;
        [[MusicManager sharedManager] fetchRandomListWithChannel:cell.channelId complete:^(int errorCode, NSArray *musicList) {
            if (errorCode == 0) {
                if (musicList.count == 0) {
                    [self onClick:cell];
                    return;
                }
                [self.controller setMusicList:musicList];
            }
        }];
    }
}

- (IBAction)selectChannel:(id)sender {
    [self.controller popViewAnimated:YES];
}

- (MMMusicChannel)getCurrentChannel {
    return self.channelId;
}

@end
