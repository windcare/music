package music

import (
	"cache"
	"config"
	"crypto/md5"
	"crypto/rand"
	"element"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"model"
	"music/player"
	"os"
	"strings"
	"time"
)

const (
	BaiduPlayer = iota
	MyPlayer
)

type musicManager struct {
	palyer Player
}

var instance *musicManager = nil

func MusicManagerInstance() *musicManager {
	if instance == nil {
		instance = &musicManager{}
		DownloadManagerInstance()
		time.Sleep(100 * time.Millisecond)
	}
	return instance
}

func (this *musicManager) SetPlayer(playerType int) {
	switch playerType {
	case BaiduPlayer:
		this.palyer = player.BaiduMusicPlayerInstance()
	}
}

func (this *musicManager) FetchMusicList(channel int) []*element.MusicInfo {
	musicList := this.palyer.FetchMusicList(channel)
	this.SaveMusicList(musicList)
	return musicList
}

func (this *musicManager) DownloadMusicList(musicList []*element.MusicInfo) {
	// for _, info := range musicList {
	// 	ret, _, err := model.MusicModelInstance().CheckMusicIsExistByNameAndAuthor(info.MusicName, info.MusicAuthor)
	// 	if err != nil {
	// 		fmt.Println("Database Is Error: ", err)
	// 		continue
	// 	}

	// 	if ret == true || DownloadManagerInstance().IsExistInDownloadList(info.MusicName, info.MusicAuthor) {
	// 		continue
	// 	}
	// 	downloadInfo := &DownloadElement{}
	// 	downloadInfo.MusicPath = info.MusicPath
	// 	downloadInfo.MusicBigCoverPath = info.BigCoverImagePath
	// 	downloadInfo.MusicSmallCoverPath = info.SmallCoverImagePath
	// 	downloadInfo.MusicLyrciPath = info.LyricPath
	// 	info.MusicUUID = this.createUUID()
	// 	downloadInfo.MusicLocalPath = fmt.Sprintf("./resource/%s/", info.MusicUUID)
	// 	downloadInfo.ElementInfo = info
	// 	downloadInfo.CompleteCallback = func(success bool, musicInfo *element.MusicInfo) {
	// 		if success {
	// 			model.MusicModelInstance().SaveMusic(musicInfo)
	// 		}
	// 	}
	// 	DownloadManagerInstance().AddDownloadInfoIntoQueue(downloadInfo)
	// }
}

func (this *musicManager) SaveMusicList(musicList []*element.MusicInfo) error {
	for _, info := range musicList {
		ret, musicId, err := model.MusicModelInstance().CheckMusicIsExistByNameAndAuthor(info.MusicName, info.MusicAuthor)
		// 已经存在本地数据库了
		if ret == true {
			info.MusicId = musicId
		} else if err != nil {
			return err
		} else {
			musicId, err = model.MusicModelInstance().SaveMusic(info)
			info.MusicId = musicId
		}
	}
	return nil
}

func (this *musicManager) createUUID() string {
	b := make([]byte, 48)
	if _, err := io.ReadFull(rand.Reader, b); err != nil {
		return ""
	}

	h := md5.New()
	h.Write([]byte(base64.URLEncoding.EncodeToString(b)))
	str := strings.ToUpper(hex.EncodeToString(h.Sum(nil)))
	return str[0:8] + "-" + str[8:12] + "-" + str[12:16] + "-" + str[16:20] + "-" + str[20:32]
}

func (this *musicManager) DownloadMusic(musicId int, informationCallback FetchInformationCallback, callback DownloadProgressCallback) {
	musicInfo, err := model.MusicModelInstance().QueryMusicById(musicId)
	if musicInfo == nil {
		var stop bool
		callback(nil, errors.New("对应的musicID无音乐"), &stop)
		return
	} else if err != nil {
		var stop bool
		callback(nil, err, &stop)
		return
	}
	fmt.Println("Download Music: " + musicInfo.MusicName)
	switch musicInfo.SourceType {
	case element.BaiduMusicSourceType:
		downloadInfo := &DownloadElement{}
		downloadInfo.Complete = func(musicInfo *element.MusicInfo) {
			fmt.Println("Download Success!")
			// 下载完成，将文件拷贝到本地目录，然后删除缓存目录
			// musicInfo.MusicPath = musicInfo.DownloadPath
			localPath := fmt.Sprintf("%s/resource/%s/", config.ConfigManagerInstance().ReadLocalResourcePath(), musicInfo.MusicUUID)
			err := cache.CacheManagerInstance().MoveCacheFile(downloadInfo.DownloadPath, localPath)
			if err != nil {
				fmt.Println("Save Error: ", err)
			} else {
				this.WriteMusicInfoIntoDB(musicInfo)
			}
		}
		downloadInfo.Information = func(contentLength int) {
			informationCallback(contentLength)
		}
		downloadInfo.Failed = func(musicInfo *element.MusicInfo, err error) {
			cache.CacheManagerInstance().DeleteCacheFile(downloadInfo.DownloadPath)
		}
		musicInfo.MusicUUID = this.createUUID()
		downloadInfo.DownloadPath = fmt.Sprintf("/tmp/%s", musicInfo.MusicUUID)
		downloadInfo.DownloadType = DownloadTypeMusic
		downloadInfo.DownloadContent = musicInfo
		downloadInfo.Progress = func(content []byte, err error, stop *bool) {
			callback(content, err, stop)
		}
		downloadInfo.CompleteSignal = make(chan bool)
		DownloadManagerInstance().AddDownloadInfoIntoQueue(downloadInfo)
		<-downloadInfo.CompleteSignal
	case element.LocalMusicSourceType:
		musicInfo.MusicPath = fmt.Sprintf("%s/resource/%s", config.ConfigManagerInstance().ReadLocalResourcePath(), musicInfo.MusicPath)
		fmt.Println(musicInfo.MusicPath)
		content, err := this.readLocalFile(musicInfo.MusicPath)
		informationCallback(len(content))
		var stop bool
		callback(content, err, &stop)
	}
}

func (this *musicManager) DownloadLyric(musicId int, informationCallback FetchInformationCallback, callback DownloadProgressCallback) {
	musicInfo, err := model.MusicModelInstance().QueryMusicById(musicId)
	if musicInfo == nil {
		var stop bool
		callback(nil, errors.New("对应的musicID无音乐"), &stop)
		return
	} else if err != nil {
		var stop bool
		callback(nil, err, &stop)
		return
	}
	fmt.Println("Download Lyric: " + musicInfo.MusicName)
	switch musicInfo.SourceType {
	case element.BaiduMusicSourceType:
		downloadInfo := &DownloadElement{}
		downloadInfo.DownloadType = DownloadTypeSingle
		downloadInfo.DownloadContent = musicInfo.LyricPath
		downloadInfo.DownloadPath = cache.CacheManagerInstance().GenerateCacheFile()
		downloadInfo.Progress = func(content []byte, err error, stop *bool) {
			callback(content, err, stop)
		}
		downloadInfo.Information = func(contentLength int) {
			informationCallback(contentLength)
		}
		downloadInfo.CompleteSignal = make(chan bool)
		DownloadManagerInstance().AddDownloadInfoIntoQueue(downloadInfo)
		<-downloadInfo.CompleteSignal
		cache.CacheManagerInstance().DeleteCacheFile(downloadInfo.DownloadPath)
	case element.LocalMusicSourceType:
		musicInfo.LyricPath = fmt.Sprintf("%s/resource/%s", config.ConfigManagerInstance().ReadLocalResourcePath(), musicInfo.LyricPath)
		content, err := this.readLocalFile(musicInfo.LyricPath)
		informationCallback(len(content))
		var stop bool
		callback(content, err, &stop)
	}
}

func (this *musicManager) DownloadBigCoverImage(musicId int, informationCallback FetchInformationCallback, callback DownloadProgressCallback) {
	musicInfo, err := model.MusicModelInstance().QueryMusicById(musicId)
	if musicInfo == nil {
		var stop bool
		callback(nil, errors.New("对应的musicID无音乐"), &stop)
		return
	} else if err != nil {
		var stop bool
		callback(nil, err, &stop)
		return
	}
	fmt.Println("Download big cover image: " + musicInfo.MusicName)
	switch musicInfo.SourceType {
	case element.BaiduMusicSourceType:
		downloadInfo := &DownloadElement{}
		downloadInfo.DownloadType = DownloadTypeSingle
		downloadInfo.DownloadContent = musicInfo.BigCoverImagePath
		downloadInfo.DownloadPath = cache.CacheManagerInstance().GenerateCacheFile()
		downloadInfo.Progress = func(content []byte, err error, stop *bool) {
			callback(content, err, stop)
		}
		downloadInfo.Information = func(contentLength int) {
			informationCallback(contentLength)
		}
		downloadInfo.CompleteSignal = make(chan bool)
		DownloadManagerInstance().AddDownloadInfoIntoQueue(downloadInfo)
		<-downloadInfo.CompleteSignal
		cache.CacheManagerInstance().DeleteCacheFile(downloadInfo.DownloadPath)
	case element.LocalMusicSourceType:
		musicInfo.BigCoverImagePath = fmt.Sprintf("%s/resource/%s", config.ConfigManagerInstance().ReadLocalResourcePath(), musicInfo.BigCoverImagePath)
		content, err := this.readLocalFile(musicInfo.BigCoverImagePath)
		informationCallback(len(content))
		var stop bool
		callback(content, err, &stop)
	}
}

func (this *musicManager) DownloadSmallCoverImage(musicId int, informationCallback FetchInformationCallback, callback DownloadProgressCallback) {
	musicInfo, err := model.MusicModelInstance().QueryMusicById(musicId)
	if musicInfo == nil {
		var stop bool
		callback(nil, errors.New("对应的musicID无音乐"), &stop)
		return
	} else if err != nil {
		var stop bool
		callback(nil, err, &stop)
		return
	}
	fmt.Println("Download small cover image: " + musicInfo.MusicName)
	switch musicInfo.SourceType {
	case element.BaiduMusicSourceType:
		downloadInfo := &DownloadElement{}
		downloadInfo.DownloadType = DownloadTypeSingle
		downloadInfo.DownloadContent = musicInfo.SmallCoverImagePath
		downloadInfo.DownloadPath = cache.CacheManagerInstance().GenerateCacheFile()
		downloadInfo.Progress = func(content []byte, err error, stop *bool) {
			callback(content, err, stop)
		}
		downloadInfo.Information = func(contentLength int) {
			informationCallback(contentLength)
		}
		downloadInfo.CompleteSignal = make(chan bool)
		DownloadManagerInstance().AddDownloadInfoIntoQueue(downloadInfo)
		<-downloadInfo.CompleteSignal
		cache.CacheManagerInstance().DeleteCacheFile(downloadInfo.DownloadPath)
	case element.LocalMusicSourceType:
		musicInfo.SmallCoverImagePath = fmt.Sprintf("%s/resource/%s", config.ConfigManagerInstance().ReadLocalResourcePath(), musicInfo.SmallCoverImagePath)
		content, err := this.readLocalFile(musicInfo.SmallCoverImagePath)
		informationCallback(len(content))
		var stop bool
		callback(content, err, &stop)
	}
}

func (this *musicManager) readLocalFile(filePath string) ([]byte, error) {
	info, err := os.Stat(filePath)
	if err != nil {
		return nil, errors.New("获取文件属性失败")
	}
	file, err := os.Open(filePath)
	defer file.Close()
	if err != nil {
		return nil, errors.New("打开文件失败")
	}
	var content []byte = make([]byte, info.Size())
	file.Read(content)
	return content, nil
}

func (this *musicManager) WriteMusicInfoIntoDB(musicInfo *element.MusicInfo) {
	model.MusicModelInstance().ChangeSourceType(element.BaiduMusicSourceType, element.LocalMusicSourceType, musicInfo)
}
