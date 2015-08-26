package download

import (
	"encoding/xml"
	"fmt"
	"github.com/guotie/gogb2312"
	"os"
	"strings"
)

type xmlInfo struct {
	Lyric string `xml:",chardata"`
}

type qqMusicDownloader struct {
	info *DownloadInfo
}

func NewQQMusicDownloader(info *DownloadInfo) *qqMusicDownloader {
	instance := &qqMusicDownloader{}
	instance.info = info
	return instance
}

func (this *qqMusicDownloader) handleLyric(lyric []byte) []byte {
	output, err, _, _ := gogb2312.ConvertGB2312String(string(lyric))
	output = strings.Replace(output, "encoding=\"GB2312\"", "encoding=\"UTF-8\"", 1)
	fmt.Println(output)
	info := &xmlInfo{}
	err = xml.Unmarshal([]byte(output), info)
	if err == nil {
		fmt.Println("%q", info)
		return []byte(info.Lyric)
	} else {
		fmt.Println("handleLyric Error: ", err)
		return lyric
	}
}

func (this *qqMusicDownloader) downloadURL(url string) {
	if err := DownloadHelper().downloadNetworkFileToBufferUsingCallback(url, func(contentLength int) {
		this.info.Information(contentLength)
	}, func(content []byte, err error, stop *bool) {
		this.info.Progress(content, err, stop)
	}); err != nil {
		var stop bool
		this.info.Progress(nil, err, &stop)
	}
	this.info.CompleteSignal <- true
}

func (this *qqMusicDownloader) downloadURLWithHandle(url string) {
	var stop bool
	if body, err := DownloadHelper().downloadNetworkFileToBuffer(url); err == nil {
		// 处理body
		body = this.handleLyric(body)
		this.info.Progress(body, err, &stop)
	} else {
		this.info.Progress(nil, err, &stop)
	}
	this.info.CompleteSignal <- true
}

func (this *qqMusicDownloader) DownloadLyric() {
	lyricPath := this.info.DownloadPath
	this.downloadURL(lyricPath)
}

func (this *qqMusicDownloader) DownloadBigCover() {
	coverPath := this.info.DownloadPath
	fmt.Println("download Big Cover Image: ", coverPath)
	this.downloadURL(coverPath)
}

func (this *qqMusicDownloader) DownloadSmallCover() {
	coverPath := this.info.DownloadPath
	this.downloadURL(coverPath)
}

func (this *qqMusicDownloader) DownloadAllToNativeFile() {
	downloadMusic := this.info.MusicInfo
	os.Mkdir(this.info.DownloadPath, os.ModeType|os.ModePerm)
	musicPath := this.info.DownloadPath + "/music.mp3"
	fmt.Println(downloadMusic.MusicPath)
	if err := DownloadHelper().downloadNetworkFileToNativeFileUsingCallback(
		downloadMusic.MusicPath, musicPath, func(contentLength int) {
			this.info.Information(contentLength)
		}, func(content []byte, err error, stop *bool) {
			this.info.Progress(content, err, stop)
		}); err != nil {
		this.info.CompleteSignal <- true
		var stop bool
		this.info.Progress(nil, err, &stop)
		this.info.Failed(downloadMusic, err)
		return
	}
	this.info.CompleteSignal <- true
	// download Lyric
	lyricPath := this.info.DownloadPath + "/lyric.lrc"
	if err := DownloadHelper().downloadNetworkFileToNativeFileByHandle(
		downloadMusic.LyricPath, lyricPath, func(body []byte) []byte {
			return this.handleLyric(body)
		}); err == nil {
		// download lyric success
	} else {
		fmt.Println("download lyric failed: ", err)
		this.info.Failed(downloadMusic, err)
		return
	}

	// download big cover
	bigCoverImagePath := this.info.DownloadPath + "/big_cover.jpg"
	if err := DownloadHelper().downloadNetworkFileToNativeFile(downloadMusic.BigCoverImagePath, bigCoverImagePath); err == nil {
		// download big cover success
	} else {
		fmt.Println("download big cover failed: ", err)
		this.info.Failed(downloadMusic, err)
		return
	}

	// download small cover
	smallCoverImagePath := this.info.DownloadPath + "/small_cover.jpg"
	if err := DownloadHelper().downloadNetworkFileToNativeFile(downloadMusic.SmallCoverImagePath, smallCoverImagePath); err == nil {
		// download small cover success
	} else {
		fmt.Println("download small cover failed: ", err)
		this.info.Failed(downloadMusic, err)
		return
	}

	// download compete, callback
	this.info.Complete(downloadMusic)
}
