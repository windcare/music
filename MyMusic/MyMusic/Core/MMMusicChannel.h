//
//  MMMusicChannel.h
//  MyMusic
//
//  Created by sjjwind on 7/2/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

typedef enum : NSInteger {
    MMMusicChannelPersonal = 0x0,     // 私人频道
    MMMusicChannelLove,               // 我喜欢
    MMMusicChannelHot,                // 热歌
    MMMusicChannelKTV,                // KTV 歌曲
    MMMusicChannelFamous,             // 成名曲
    MMMusicChannelRandom,             // 随便听听
    MMMusicChannelNetwork,            // 网络歌曲
    MMMusicChannelTV,                 // 影视歌曲
    MMMusicChannelChinaVioce,         // 中国好声音
    MMMusicChannelClassic,            // 经典老歌
    MMMusicChannel70Age,              // 70后歌曲
    MMMusicChannel80Age,              // 80后歌曲
    MMMusicChannel90Age,              // 90后歌曲
    MMMusicChannelChildren,           // 儿童歌曲
    MMMusicChannelNew,                // 新歌
    MMMusicChannelPopular,            // 流行
    MMMusicChannelLightMusic,         // 轻音乐
    MMMusicChannelFresh,              // 小清新
    MMMusicChannelChineseWind,        // 中国风
    MMMusicChannelRock,               // 摇滚
    MMMusicChannelVideo,              // 电影
    MMMusicChannelFolk,               // 民谣
    MMMusicChannelChinese,            // 华语
    MMMusicChannelEurope,             // 欧美
    MMMusicChannelJanpan,             // 小鬼子
    MMMusicChannelKorea,              // 韩语
    MMMusicChannelCantonese,          // 粤语
    MMMusicChannelHappy,              // 欢快
    MMMusicChannelSlow,               // 舒缓
    MMMusicChannelSad,                // 伤感
    MMMusicChannelReleax,             // 轻松
    MMMusicChannelAlone,              // 寂寞
} MMMusicChannel;

typedef enum : NSInteger {
  MMMusicRankTypePopulation = 0x0,        // 流行指数
  MMMusicRankTypeInner,                   // 内地
  MMMusicRankTypeHK,                      // 港台
  MMMusicRankTypeEurope,                  // 欧美
  MMMusicRankTypeJapan,                   // 日本
  MMMusicRankTypeNational,                // 民谣
  MMMusicRankTypeRock,                    // 摇滚
  MMMusicRankTypeTop,                     // 中国top
  MMMusicRankTypeiTunes,                  // iTunes
  MMMusicRankTypeHKBusiness,              // 香港商业榜
  MMMusicRankTypeBillboard,               // 美国Billboard公告牌
  MMMusicRankTypeUK,                      // 英国UK榜
  MMMusicRankTypeChannelV,                // Channel[V]
  MMMusicRankTypeHKNew,                   // 香港新城榜
  MMMusicRankTypeDarkDisk,                // 幽浮劲碟榜
  MMMusicRankTypeJapanPub,                // 日本公信榜
  MMMusicRankTypeKTV,                     // KTV榜
} MMMusicRankType;
