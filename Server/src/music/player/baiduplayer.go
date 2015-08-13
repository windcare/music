package player

import (
	"element"
	"encoding/json"
	"fmt"
	"github.com/bitly/go-simplejson"
	"io/ioutil"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"time"
)

const baiduPlayListURLBase = "http://fm.baidu.com/dev/api/?tn=playlist&id=%s&hascode=&_=%d"
const baiduMusicInfoURLBase = "http://fm.baidu.com/data/music/songinfo"
const baiduMusicLinkURLBase = "http://fm.baidu.com/data/music/songlink"
const baiduMusicSearchURLBase = "http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.search.catalogSug&query=%s&_=%d"
const baiduMusicHost = "http://fm.baidu.com"

const (
	BaiduMusicChannelPersonal    = iota // 私人频道
	BaiduMusicChannleLove               // 我喜欢
	BaiduMusicChannelHot                // 热歌
	BaiduMusicChannelKTV                // KTV 歌曲
	BaiduMusicChannelFamous             // 成名曲
	BaiduMusicChannelRandom             // 随便听听
	BaiduMusicChannelNetwork            // 网络歌曲
	BaiduMusicChannelTV                 // 影视歌曲
	BaiduMusicChannelChinaVioce         // 中国好声音
	BaiduMusicChannelClassic            //经典老歌
	BaiduMusicChannel70Age              // 70后歌曲
	BaiduMusicChannel80Age              // 80后歌曲
	BaiduMusicChannel90Age              // 90后歌曲
	BaiduMusicChannelChildren           // 儿童歌曲
	BaiduMusicChannelNew                // 新歌
	BaiduMusicChannelPopular            // 流行
	BaiduMusicChannelLightMusic         //轻音乐
	BaiduMusicChannelFresh              // 小清新
	BaiduMusicChannelChineseWind        //中国风
	BaiduMusicChannelRock               // 摇滚
	BaiduMusicChannelVideo              // 电影
	BaiduMusicChannelFolk               // 民谣
	BaiduMusicChannelChinese            // 华语
	BaiduMusicChannelEurope             // 欧美
	BaiduMusicChannelJanpan             // 小鬼子
	BaiduMusicChannelKorea              // 韩语
	BaiduMusicChannelCantonese          // 粤语
	BaiduMusicChannelHappy              // 欢快
	BaiduMusicChannelSlow               // 舒缓
	BaiduMusicChannelSad                // 伤感
	BaiduMusicChannelReleax             // 轻松
	BaiduMusicChannelAlone              // 寂寞
)

type baiduMusicPlayer struct {
}

var baiduPlayer *baiduMusicPlayer = nil
var baiduPlayerInstanceOnce sync.Once

func getMusicType(musicType int) string {
	switch musicType {
	case BaiduMusicChannelHot:
		return "public_tuijian_rege"
	case BaiduMusicChannelKTV:
		return "public_tuijian_ktv"
	case BaiduMusicChannelFamous:
		return "public_tuijian_chengmingqu"
	case BaiduMusicChannelRandom:
		return "public_tuijian_suibiantingting"
	case BaiduMusicChannelNetwork:
		return "public_tuijian_wangluo"
	case BaiduMusicChannelTV:
		return "public_tuijian_yingshi"
	case BaiduMusicChannelChinaVioce:
		return "public_tuijian_zhongguohaoshengyin"

	case BaiduMusicChannelClassic:
		return "public_shiguang_jingdianlaoge"
	case BaiduMusicChannel70Age:
		return "public_shiguang_70hou"
	case BaiduMusicChannel80Age:
		return "public_shiguang_80hou"
	case BaiduMusicChannel90Age:
		return "public_shiguang_90hou"
	case BaiduMusicChannelChildren:
		return "public_shiguang_erge"
	case BaiduMusicChannelNew:
		return "public_shiguang_xinge"

	case BaiduMusicChannelPopular:
		return "public_fengge_liuxing"
	case BaiduMusicChannelLightMusic:
		return "public_fengge_qingyinyue"
	case BaiduMusicChannelFresh:
		return "public_fengge_xiaoqingxin"
	case BaiduMusicChannelChineseWind:
		return "public_fengge_zhongguofeng"
	case BaiduMusicChannelRock:
		return "public_fengge_yaogun"
	case BaiduMusicChannelVideo:
		return "public_fengge_dianyingyuansheng"
	case BaiduMusicChannelFolk:
		return "public_fengge_minyao"

	case BaiduMusicChannelChinese:
		return "public_yuzhong_huayu"
	case BaiduMusicChannelEurope:
		return "public_yuzhong_oumei"
	case BaiduMusicChannelJanpan:
		return "public_yuzhong_riyu"
	case BaiduMusicChannelKorea:
		return "public_yuzhong_hanyu"
	case BaiduMusicChannelCantonese:
		return "public_yuzhong_yueyu"

	case BaiduMusicChannelHappy:
		return "public_xinqing_huankuai"
	case BaiduMusicChannelSlow:
		return "public_xinqing_shuhuan"
	case BaiduMusicChannelSad:
		return "public_xinqing_shanggan"
	case BaiduMusicChannelReleax:
		return "public_xinqing_qingsongjiari"
	case BaiduMusicChannelAlone:
		return "public_xinqing_jimo"
	default:
		return ""
	}
}

func BaiduMusicPlayerInstance() *baiduMusicPlayer {
	baiduPlayerInstanceOnce.Do(func() {
		baiduPlayer = &baiduMusicPlayer{}
	})

	return baiduPlayer
}

func (this *baiduMusicPlayer) FetchMusicList(musicType int) []*element.MusicInfo {
	currentTime := time.Now().Unix()
	var musicURL string = fmt.Sprintf(baiduPlayListURLBase, getMusicType(musicType), currentTime)
	resp, err := http.Get(musicURL)
	if err != nil {
		fmt.Println("FetchMusicList Error: ", err)
		return nil
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("FetchMusicList Read Body Error: ", err)
		return nil
	}
	js, err := simplejson.NewJson(body)
	if err != nil {
		fmt.Println("FetchMusicList parser json Error: ", err)
		return nil
	}
	musicIdList := this.parserMusicList(js)
	musicList := make(map[string]*element.MusicInfo)
	this.fetchMusicInfoList(musicIdList, &musicList)
	this.fetchMusicLinkList(musicIdList, &musicList)

	var retMusicList []*element.MusicInfo = nil
	for _, music := range musicList {
		if this.checkMusicIsValid(music) {
			retMusicList = append(retMusicList, music)
		}
	}
	return retMusicList
}

func (this *baiduMusicPlayer) FetchMusicById(musicId int) *element.MusicInfo {
	musicIdList := []string{strconv.Itoa(musicId)}
	musicList := make(map[string]*element.MusicInfo)
	this.fetchMusicInfoList(musicIdList, &musicList)
	this.fetchMusicLinkList(musicIdList, &musicList)

	var retMusicList []*element.MusicInfo = nil
	for _, music := range musicList {
		retMusicList = append(retMusicList, music)
	}
	return retMusicList[0]
}

func (this *baiduMusicPlayer) SearchMusic(keyword string) ([]*element.MusicInfo, error) {
	searchURL := fmt.Sprintf(baiduMusicSearchURLBase, keyword, time.Now().Unix())
	resp, err := http.Get(searchURL)
	if err != nil {
		fmt.Println("SearchMusic Error: ", err)
		return nil, err
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("SearchMusic Read Body Error: ", err)
		return nil, err
	}
	js, err := simplejson.NewJson(body)
	if err != nil {
		fmt.Println("SearchMusic parser json Error: ", err)
		return nil, err
	}
	songList := js.Get("song").MustArray()
	musicIdList := make([]string, len(songList))
	for index, music := range songList {
		info := music.(map[string]interface{})
		id, _ := strconv.Atoi(info["songid"].(string))
		musicIdList[index] = fmt.Sprintf("%d", id)
	}

	musicList := make(map[string]*element.MusicInfo)
	this.fetchMusicInfoList(musicIdList, &musicList)
	this.fetchMusicLinkList(musicIdList, &musicList)

	var retMusicList []*element.MusicInfo = nil
	for _, music := range musicList {
		if this.checkMusicIsValid(music) {
			retMusicList = append(retMusicList, music)
		}
	}
	return retMusicList, nil
}

func (this *baiduMusicPlayer) parserMusicList(js *simplejson.Json) []string {
	musicList := js.Get("list").MustArray()
	musicIdList := make([]string, len(musicList))
	for index, node := range musicList {
		info := node.(map[string]interface{})
		id, _ := info["id"].(json.Number).Int64()
		musicIdList[index] = fmt.Sprintf("%d", id)
	}
	return musicIdList
}

func (this *baiduMusicPlayer) fetchMusicInfoList(musicIdList []string, musicList *map[string]*element.MusicInfo) {
	resp, err := http.PostForm(baiduMusicInfoURLBase, url.Values{"songIds": {strings.Join(musicIdList, ",")}})
	if err != nil {
		fmt.Println("FetchMusicInfoList Error: ", err)
		return
	}

	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("FetchMusicInfoList Read Error: ", err)
		return
	}
	js, err := simplejson.NewJson(body)
	if err != nil {
		fmt.Println("FetchMusicInfoList parser json Error: ", err)
		return
	}
	this.parserMusicInfoList(js, musicList)
}

func (this *baiduMusicPlayer) parserMusicInfoList(js *simplejson.Json, musicList *map[string]*element.MusicInfo) {
	data := js.Get("data").MustMap()
	if songList, ok := data["songList"].([]interface{}); ok {
		for _, info := range songList {
			musicInfo := info.(map[string]interface{})
			id := musicInfo["songId"].(string)
			var music *element.MusicInfo = &element.MusicInfo{}
			var err error
			music.NetMusicId, err = strconv.Atoi(id)
			if err != nil {
				continue
			}
			music.MusicName = musicInfo["songName"].(string)
			music.MusicAuthor = musicInfo["artistName"].(string)
			music.SmallCoverImagePath = musicInfo["songPicSmall"].(string)
			music.BigCoverImagePath = musicInfo["songPicBig"].(string)
			music.AlbumName = musicInfo["albumName"].(string)
			music.SourceType = element.BaiduMusicSourceType
			(*musicList)[id] = music
		}
	}
}

func (this *baiduMusicPlayer) fetchMusicLinkList(musicIdList []string, musicList *map[string]*element.MusicInfo) {
	resp, err := http.PostForm(baiduMusicLinkURLBase, url.Values{"songIds": {strings.Join(musicIdList, ",")}, "type": {"mp3"}})
	if err != nil {
		fmt.Println("FetchMusicLink Error: ", err)
		return
	}

	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("FetchMusicLink Read Error: ", err)
		return
	}
	js, err := simplejson.NewJson(body)
	if err != nil {
		fmt.Println("FetchMusicInfoList parser json Error: ", err)
		return
	}
	this.parserMusicLinkList(js, musicList)
}

func (this *baiduMusicPlayer) parserMusicLinkList(js *simplejson.Json, musicList *map[string]*element.MusicInfo) {
	data := js.Get("data").MustMap()
	if songList, ok := data["songList"].([]interface{}); ok {
		for _, info := range songList {
			musicInfo := info.(map[string]interface{})
			id := musicInfo["songId"].(json.Number).String()
			if _, ok := (*musicList)[id]; !ok {
				fmt.Println("Key Not Found")
				continue
			}

			var music *element.MusicInfo = (*musicList)[id]
			if musicInfo["songLink"] == nil {
				delete(*musicList, id)
				continue
			}
			music.MusicPath = musicInfo["songLink"].(string)
			if musicInfo["lrcLink"] == nil {
				delete(*musicList, id)
				continue
			}
			music.LyricPath = baiduMusicHost + musicInfo["lrcLink"].(string)
			if musicInfo["time"] == nil {
				delete(*musicList, id)
				continue
			}
			musicTime, _ := musicInfo["time"].(json.Number).Int64()
			music.MusicTime = int(musicTime)
			music.MusicFormat = "mp3"
		}
	} else {
		musicList = nil
	}
}

func (this *baiduMusicPlayer) checkMusicIsValid(musicInfo *element.MusicInfo) bool {
	// http://pan.baidu.com/share/link歌曲屏蔽
	if strings.HasPrefix(musicInfo.MusicPath, "http://pan.baidu.com/share/link") == false {
		if musicInfo.LyricPath == "http://fm.baidu.com" {
			// 将歌词不对的，直接将歌词赋值空
			musicInfo.LyricPath = ""
		}
		return true
	}
	return false
}
