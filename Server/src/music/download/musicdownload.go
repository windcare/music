package download

import (
	"fmt"
	"os"
)

type musicDownloader struct {
	info *DownloadInfo
}

func NewMusicDownloader(info *DownloadInfo) *musicDownloader {
	instance := &musicDownloader{}
	instance.info = info
	return instance
}

func (this *musicDownloader) downloadURL(url string) {
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

func (this *musicDownloader) DownloadLyric() {
	lyricPath := this.info.DownloadPath + "/lyric.lrc"
	this.downloadURL(lyricPath)
}

func (this *musicDownloader) DownloadBigCover() {
	coverPath := this.info.DownloadPath + "/big_cover.jpg"
	this.downloadURL(coverPath)
}

func (this *musicDownloader) DownloadSmallCover() {
	coverPath := this.info.DownloadPath + "/small_cover.jpg"
	this.downloadURL(coverPath)
}

func (this *musicDownloader) DownloadAllToNativeFile() {
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
	if err := DownloadHelper().downloadNetworkFileToNativeFile(downloadMusic.LyricPath, lyricPath); err == nil {
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
