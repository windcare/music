//
//  MMChannelView.m
//  MyMusic
//
//  Created by sjjwind on 7/2/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "MMFMPageView.h"
#import "MMFMPageViewCell.h"
#import "MusicManager.h"
#import "PlayManager.h"

const static NSInteger kRankItemRowCount = 5;
const static NSInteger kWidthSeprator = 24;
const static NSInteger kHeightSperator = 20;
const static NSInteger kCellLeftMargin = 16;
const static NSInteger kCellTopMargin = 20;
const static NSInteger kTextHeight = 40;
const static NSInteger kCellHeight = 130;
const static NSInteger kDocumentHeight = 1600;

@interface MMChannelElement : NSObject

@property (nonatomic, strong) NSString *sortName;
@property (nonatomic, strong) NSArray *channels;

@end

@interface MMFMPageView() <MMFMPageViewCellDelegate>

@property (nonatomic, strong) NSScrollView *channelScrollView;
@property (nonatomic, strong) MMView *contentView;

@end


@implementation MMFMPageView

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self.channelScrollView = [[NSScrollView alloc] initWithFrame:self.frame];
        self.channelScrollView.drawsBackground = NO;
        [self addSubview:self.channelScrollView];
        
        NSRect contentViewRect = { 0, 0, self.frame.size.width, kDocumentHeight };
        NSView *contentView = [[NSView alloc] initWithFrame:contentViewRect];
        [self.channelScrollView setDocumentView:contentView];
        
        self.contentView = [[MMView alloc] initWithFrame:contentViewRect];
        [self.channelScrollView setDocumentView:self.contentView];
        [self layoutChannelView];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self setBackgroundImage:[NSImage imageNamed:@"background"]];
        [self layoutChannelView];
    }
    
    return self;
}

- (void)layoutChannelView {
    NSDictionary *allChannel = @{
                                 @"热门": @[
                                         @[@"热歌", @(MMMusicChannelHot), @"fm_hot"],
                                         @[@"歌曲", @(MMMusicChannelKTV), @"fm_ktv"],
                                         @[@"成名曲", @(MMMusicChannelFamous), @"fm_famous"],
                                         @[@"随便听听", @(MMMusicChannelRandom), @"fm_random"],
                                         @[@"网络歌曲", @(MMMusicChannelNetwork), @"fm_net"],
                                         @[@"影视歌曲", @(MMMusicChannelTV), @"fm_tv"],
                                         @[@"中国好声音", @(MMMusicChannelChinaVioce), @"fm_voice"],
                                         ],
                                 @"时间轴": @[
                                         @[@"经典老歌", @(MMMusicChannelClassic), @"fm_old"],
                                         @[@"70后歌曲", @(MMMusicChannel70Age), @"fm_70age"],
                                         @[@"80后歌曲", @(MMMusicChannel80Age), @"fm_80age"],
                                         @[@"90后歌曲", @(MMMusicChannel90Age), @"fm_90age"],
                                         @[@"儿童歌曲", @(MMMusicChannelChildren), @"fm_child"],
                                         ],
                                 @"风格": @[
                                         @[@"新歌", @(MMMusicChannelNew), @"fm_new"],
                                         @[@"流行", @(MMMusicChannelPopular), @"fm_population"],
                                         @[@"轻音乐", @(MMMusicChannelLightMusic), @"fm_soft"],
                                         @[@"小清新", @(MMMusicChannelFresh), @"fm_fresh"],
                                         @[@"中国风", @(MMMusicChannelChineseWind), @"fm_chinawind"],
                                         @[@"摇滚", @(MMMusicChannelRock), @"fm_rock"],
                                         @[@"电影", @(MMMusicChannelVideo), @"fm_movie"],
                                         @[@"民谣", @(MMMusicChannelFolk), @"fm_national"],
                                         ],
                                 @"语种": @[
                                         @[@"华语", @(MMMusicChannelChinese), @"fm_chinese"],
                                         @[@"欧美", @(MMMusicChannelEurope), @"fm_english"],
                                         @[@"小鬼子", @(MMMusicChannelJanpan), @"fm_japan"],
                                         @[@"韩语", @(MMMusicChannelKorea), @"fm_korea"],
                                         @[@"粤语", @(MMMusicChannelCantonese), @"fm_cantonese"],
                                         ],
                                 @"心情": @[
                                         @[@"欢快", @(MMMusicChannelHappy), @"fm_happy"],
                                         @[@"舒缓", @(MMMusicChannelSlow), @"fm_slow"],
                                         @[@"伤感", @(MMMusicChannelSad), @"fm_sad"],
                                         @[@"轻松", @(MMMusicChannelReleax), @"fm_release"],
                                         @[@"寂寞", @(MMMusicChannelAlone), @"fm_alone"],
                                         ],
                                 };
    NSArray *channels = @[@"热门", @"时间轴", @"风格", @"语种", @"心情"];
    __block NSInteger paintHeight = kDocumentHeight - kCellTopMargin;
    [channels enumerateObjectsUsingBlock:^(NSString *channel, NSUInteger idx, BOOL *stop) {
        NSArray *subChannels = allChannel[channel];
        NSInteger subChannelsCount = [subChannels count];
        // 绘制名字
        NSRect textRect = NSMakeRect(10, paintHeight - 90, 400, 70);
        NSTextField *channelTextField = [[NSTextField alloc] initWithFrame:textRect];
        
        channelTextField.bezeled = NO;
        channelTextField.drawsBackground = NO;
        channelTextField.editable = NO;
        channelTextField.selectable = NO;
        channelTextField.alignment = NSLeftTextAlignment;
        channelTextField.textColor = [NSColor colorWithCalibratedRed:0.129 green:0.129 blue:0.129 alpha:1.0];
        channelTextField.font = [NSFont fontWithName:@"MicrosoftYaHei" size:22.0f];
        channelTextField.stringValue = channel;
        
        paintHeight -= 40;
        [self.contentView addSubview:channelTextField];
        [subChannels enumerateObjectsUsingBlock:^(NSArray *info, NSUInteger idx, BOOL *stop) {
            NSString *fmName = info[0];
            NSInteger fmType = [info[1] integerValue];
            NSString *imageName = info[2];
            NSInteger row = idx / kRankItemRowCount;
            NSInteger col = idx % kRankItemRowCount;
            NSInteger xPoint = kCellLeftMargin + col * (kCellHeight + kWidthSeprator);
            NSInteger yPoint = paintHeight - (row + 1) * (kCellHeight + kTextHeight + kHeightSperator);
            NSRect cellRect = NSMakeRect(xPoint, yPoint, kCellHeight, kCellHeight + kTextHeight);
            MMFMPageViewCell *cell = [[MMFMPageViewCell alloc]initWithFrame:cellRect];
            [cell setCellName:fmName];
            [cell setCellImage:imageName];
            [cell setDelegate:self];
            [cell setChannelId:fmType];
            [self.contentView addSubview:cell];
        }];
        paintHeight -= ((subChannelsCount - 1) / kRankItemRowCount + 1) * (kCellHeight + kTextHeight + kHeightSperator);
    }];
    [self.contentView scrollPoint:NSMakePoint(0, kDocumentHeight)];
}

- (void)onClick:(MMFMPageViewCell *)cell {
    [[MusicManager sharedManager] fetchFmListWithChannel:cell.channelId complete:^(int errorCode, NSArray *musicList) {
        if (errorCode == 0) {
            if (musicList.count == 0) {
                return;
            }
            [[PlayManager sharedManager] setPlayMusicList:musicList];
            [[PlayManager sharedManager] playMusic:musicList[0]];
        }
    }];
}

- (IBAction)selectChannel:(id)sender {
//    [self.controller popViewAnimated:YES];
}

- (MMMusicChannel)getCurrentChannel {
    return MMMusicChannelReleax;
//    return self.channelId;
}

@end
