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

const (
	BaiduMusicChannelHot     = iota // 热歌
	BaiduMusicChannelClassic        //经典老歌
)

const baiduPlayListURLBase = "http://fm.baidu.com/dev/api/?tn=playlist&id=%s&hascode=&_=%d"
const baiduMusicInfoURLBase = "http://fm.baidu.com/data/music/songinfo"
const baiduMusicLinkURLBase = "http://fm.baidu.com/data/music/songlink"
const baiduMusicSearchURLBase = "http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.search.catalogSug&query=%s&_=%d"
const baiduMusicHost = "http://fm.baidu.com"

type baiduMusicPlayer struct {
}

var baiduPlayer *baiduMusicPlayer = nil
var baiduPlayerInstanceOnce sync.Once

func getMusicType(musicType int) string {
	switch musicType {
	case BaiduMusicChannelHot:
		return "public_tuijian_rege"
	case BaiduMusicChannelClassic:
		return "public_shiguang_jingdianlaoge"
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

func (this *baiduMusicPlayer) SearchMusic(keyword string) []*element.MusicInfo {
	searchURL := fmt.Sprintf(baiduMusicSearchURLBase, keyword, time.Now().Unix())
	resp, err := http.Get(searchURL)
	if err != nil {
		fmt.Println("SearchMusic Error: ", err)
		return nil
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("SearchMusic Read Body Error: ", err)
		return nil
	}
	js, err := simplejson.NewJson(body)
	if err != nil {
		fmt.Println("SearchMusic parser json Error: ", err)
		return nil
	}
	songList := js.Get("song").MustArray()
	musicIdList := make([]string, len(songList))
	for index, music := range songList {
		info := music.(map[string]interface{})
		id, _ := info["songid"].(json.Number).Int64()
		musicIdList[index] = fmt.Sprintf("%d", id)
	}

	musicList := make(map[string]*element.MusicInfo)
	this.fetchMusicInfoList(musicIdList, &musicList)
	this.fetchMusicLinkList(musicIdList, &musicList)

	var retMusicList []*element.MusicInfo = nil
	for _, music := range musicList {
		retMusicList = append(retMusicList, music)
	}
	return retMusicList
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
			if musicInfo["showLink"] == nil {
				delete(*musicList, id)
				continue
			}
			music.MusicPath = musicInfo["showLink"].(string)
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
	// 非http://yinyueshiting.baidu.com个歌曲屏蔽
	if strings.HasPrefix(musicInfo.MusicPath, "http://yinyueshiting.baidu.com") {
		if musicInfo.LyricPath == "http://fm.baidu.com" {
			// 将歌词不对的，直接将歌词赋值空
			musicInfo.LyricPath = ""
		}
		return true
	}
	return false
}
