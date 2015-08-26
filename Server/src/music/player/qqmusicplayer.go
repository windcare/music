package player

import (
	"element"
	"fmt"
	"github.com/bitly/go-simplejson"
	"io/ioutil"
	"math/rand"
	"net/http"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"time"
)

const (
	RankTypePopulation = "top_7"
	RankTypeInner      = "top_2"
	RankTypeHK         = "top_1"
	RankTypeEurope     = "top_6"
	RankTypeKorea      = "top_9"
	RankTypeJapan      = "top_10"
	RankTypeNational   = "top_11"
	RankTypeRock       = "top_12"
	RankTypeChinaTop   = "global_14"
	RankTypeiTunes     = "global_12"
	RankTypeHKBusiness = "global_13"
	RankTypeBillboard  = "global_7"
	RankTypeUK         = "global_6"
	RankTypeChannelV   = "global_2"
	RankTypeHKNew      = "global_3"
	RankTypeDarkDisk   = "global_9"
	RankTypeJapanPub   = "global_4"
	RankTypeKTV        = "global_1"
)

const rankListBaseURL = "http://music.qq.com/musicmac/toplist/index/%s.js?_=%d"
const musicBaseURL = "http://stream1%d.qqmusic.qq.com/%d.mp3"
const lyricBaseURL = "http://music.qq.com/miniportal/static/lyric/%d/%d.xml"
const smallCoverIamgeBaseURL = "http://imgcache.qq.com/music/photo/album/%d/180_albumpic_%d_0.jpg"
const bigCoverIamgeBaseURL = "http://imgcache.qq.com/music/photo/album_500/%d/500_albumpic_%d_0.jpg"
const searchBaseURL = "http://soso.music.qq.com/fcgi-bin/music_search_new_platform_mac.fcg?format=jsonp&p=%d&n=%d&w=%s&_=%d"

const fetchKeyBaseURL = "http://base.music.qq.com/fcgi-bin/fcg_musicexpress.fcg?json=3&guid=%d&g_tk=938407465"

const cdnMusicBaseURL = "http://cc.stream.qqmusic.qq.com/C200%s.m4a?vkey=%s&guid=%d&fromtag=0"

const kKeyAvaiableTime = 3 // 有效期-3个小时

type qqMusicPlayer struct {
	key        string
	id         int64
	createTime int64
}

var qqPlayer *qqMusicPlayer = nil
var qqMusicPlayerOnce sync.Once

var rankType []string = []string{RankTypePopulation, RankTypeHK, RankTypeEurope, RankTypeKorea, RankTypeJapan, RankTypeNational, RankTypeRock, RankTypeChinaTop, RankTypeiTunes, RankTypeHKBusiness, RankTypeBillboard, RankTypeUK, RankTypeChannelV, RankTypeHKNew, RankTypeDarkDisk, RankTypeJapanPub, RankTypeKTV}

func QQMusicPlayerInstance() *qqMusicPlayer {
	qqMusicPlayerOnce.Do(func() {
		qqPlayer = &qqMusicPlayer{}
	})
	return qqPlayer
}

func (this *qqMusicPlayer) translateRandId() {

}

func (this *qqMusicPlayer) fetchMusicURLWithMusicId() {

}

func (this *qqMusicPlayer) FetchMusicList(channel int) []*element.MusicInfo {
	fmt.Println("channel = ", channel)
	if len(rankType) <= channel || channel < 0 {
		return nil
	}
	url := fmt.Sprintf(rankListBaseURL, rankType[channel], time.Now().Unix())
	fmt.Println("url = ", url)
	resp, err := http.Get(url)
	if err != nil {
		fmt.Println("QQMusic FetchMusicList Error: ", err)
		return nil
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	jsonStr := string(body)
	reg := regexp.MustCompile(`{s : (\'.*?\',)f`)
	songList := reg.FindAllString(jsonStr, -1)
	var musicList []*element.MusicInfo = nil
	for _, song := range songList {
		info := this.parseString(song[6:])
		if info != nil {
			musicList = append(musicList, info)
		}
	}
	return musicList
}

func (this *qqMusicPlayer) FetchMusicById(musicId int) *element.MusicInfo {
	return nil
}

func (this *qqMusicPlayer) FetchMusicLinkInfoById(musicInfo *element.MusicInfo) {
	index := strings.Index(musicInfo.MusicPath, "|")
	fmt.Println("path = ", musicInfo.MusicPath)
	fmt.Println("index = ", index)
	if index != -1 {
		musicInfo.MusicPath = musicInfo.MusicPath[index+1 : len(musicInfo.MusicPath)]
		fmt.Println("path = ", musicInfo.MusicPath)
		musicInfo.MusicPath = fmt.Sprintf(cdnMusicBaseURL, musicInfo.MusicPath, this.fetchKey(), this.fetchId())
	}
}

func (this *qqMusicPlayer) FetchNormalMusicLinkInfoById(musicInfo *element.MusicInfo) {

}

func (this *qqMusicPlayer) fetchId() int64 {
	if this.id == 0 {
		this.forceFetchId()
	}
	return this.id
}

func (this *qqMusicPlayer) forceFetchId() {
	this.id = int64(rand.Int31()*2147483647) * time.Now().UTC().Unix() % 1E10
}

func (this *qqMusicPlayer) fetchKey() string {
	nowTime := time.Now().Unix()
	if nowTime-this.createTime >= int64(kKeyAvaiableTime*time.Hour.Seconds()) {
		this.key = ""
		this.createTime = nowTime
		this.forceFetchId()
	}
	if this.key != "" {
		return this.key
	}
	searchURL := fmt.Sprintf(fetchKeyBaseURL, this.fetchId())
	resp, err := http.Get(searchURL)
	if err != nil {
		fmt.Println("QQMusic fetchKey Error: ", err)
		return ""
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("QQMusic fetchKey Read Body Error: ", err)
		return ""
	}
	js, err := simplejson.NewJson(body[13 : len(body)-2])
	if err != nil {
		fmt.Println("QQMusic fetchKey Parse Json Error: ", err)
		return ""
	}
	code := js.Get("code").MustInt()
	if code == 0 {
		this.key = js.Get("key").MustString()
	}
	return this.key
}

func (this *qqMusicPlayer) parseString(info string) *element.MusicInfo {
	arr := strings.Split(info, "|")
	if len(arr) >= 8 {
		info := &element.MusicInfo{}
		info.NetMusicId, _ = strconv.Atoi(arr[0])
		info.NetMusicId += 3E7
		info.MusicName = arr[1]
		info.MusicAuthor = arr[3]
		albumId, _ := strconv.Atoi(arr[4])
		info.AlbumName = arr[5]
		info.MusicTime, _ = strconv.Atoi(arr[7])
		stream, _ := strconv.Atoi(arr[8])
		info.MusicPath = fmt.Sprintf(musicBaseURL, stream, info.NetMusicId)
		info.SmallCoverImagePath = fmt.Sprintf(smallCoverIamgeBaseURL, albumId%100, albumId)
		info.BigCoverImagePath = fmt.Sprintf(bigCoverIamgeBaseURL, albumId%100, albumId)
		fmt.Println("big cover: ", info.BigCoverImagePath)
		info.LyricPath = fmt.Sprintf(lyricBaseURL, info.NetMusicId%100, info.NetMusicId-3E7)
		info.SourceType = element.QQMusicSourceType
		if len(arr) >= 20 {
			// 保存mid
			if len(arr[20]) > 1 {
				info.MusicPath = info.MusicPath + "|" + arr[20]
			}
		}
		return info
	}
	return nil
}

func (this *qqMusicPlayer) SearchMusic(keyword string, page int, count int) ([]*element.MusicInfo, error) {
	this.fetchKey()
	searchURL := fmt.Sprintf(searchBaseURL, page, count, keyword, time.Now().Unix())
	resp, err := http.Get(searchURL)
	if err != nil {
		fmt.Println("QQMusic SearchMusic Error: ", err)
		return nil, err
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("QQMusic SearchMusic Read Body Error: ", err)
		return nil, err
	}
	js, err := simplejson.NewJson(body[9 : len(body)-1])
	if err != nil {
		fmt.Println("QQMusic Parse Json Error: ", err)
		return nil, err
	}

	var musicList []*element.MusicInfo = nil
	code := js.Get("code").MustInt()
	if code == 0 {
		song := js.Get("data").MustMap()["song"].(map[string]interface{})
		if song != nil {
			songList := song["list"].([]interface{})
			for _, t := range songList {
				songInfo := t.(map[string]interface{})
				info := this.parseString(songInfo["f"].(string))
				if info != nil {
					musicList = append(musicList, info)
					fmt.Println("%q", info)
				}
			}
		}
	}
	return musicList, nil
}
