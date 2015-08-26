package music

import (
	"element"
	"fmt"
	"music/download"
	"sync"
	"time"
)

// go的条件变量太搓了，所以暂时自己简单实现

const (
	DownloadTypeMusic = iota // 下载音乐全部
	DownloadTypeBigCover
	DownloadTypeSmallCover
	DownloadTypeLyric
)

const DownloadRetryCount = 3 // 下载失败可重试3次
const MaxDownloadQueue = 3   // 最多可以支持3个携程同时下载

type downloadManager struct {
	downloadList  []*download.DownloadInfo
	downloading   bool
	mutex         *sync.Mutex
	downloadMutex *sync.Mutex
	ref           int
	downloadRef   int
}

var manager *downloadManager = nil

func DownloadManagerInstance() *downloadManager {
	if manager == nil {
		manager = &downloadManager{}
		manager.mutex = &sync.Mutex{}
		manager.downloadMutex = &sync.Mutex{}
		manager.ref = 0
		manager.StartDownload()
	}

	return manager
}

func (this *downloadManager) AddDownloadInfoIntoQueue(downloadInfo *download.DownloadInfo) {
	fmt.Println("AddDownloadInfoIntoQueue")
	this.mutex.Lock()
	this.downloadList = append(this.downloadList, downloadInfo)
	this.ref++
	this.mutex.Unlock()
}

func (this *downloadManager) IsExistInDownloadList(downloadType int, downloadInfo download.DownloadInfo) bool {
	this.mutex.Lock()
	defer this.mutex.Unlock()
	for _, item := range this.downloadList {
		if item.DownloadType == downloadType {
			downloadMusic := item.MusicInfo
			compareMusic := downloadInfo.MusicInfo
			if downloadMusic.NetMusicId == compareMusic.NetMusicId && item.DownloadType == downloadInfo.DownloadType {
				return true
			}
		}
	}
	return false
}

func (this *downloadManager) releaseDownloadRef() {
	this.downloadMutex.Lock()
	defer this.downloadMutex.Unlock()
	this.downloadRef--
}

func (this *downloadManager) StartDownload() {
	if this.downloading == true {
		return
	}
	this.downloading = true
	go func(this *downloadManager) {
		for true {
			if this.downloading == false {
				break
			}
			this.mutex.Lock()
			if this.ref > 0 {
				downloadInfo := this.downloadList[0]
				this.downloadList = this.downloadList[1:len(this.downloadList)]
				this.ref--
				this.mutex.Unlock()
				this.downloadMutex.Lock()
				if this.downloadRef < MaxDownloadQueue {
					this.downloadRef++
					this.downloadMutex.Unlock()
					go func(downloadInfo *download.DownloadInfo, this *downloadManager) {
						var downloadInterface download.Downloader = nil
						if downloadInfo.MusicInfo.SourceType == element.BaiduMusicSourceType {
							downloadInterface = download.NewMusicDownloader(downloadInfo)
						} else {
							downloadInterface = download.NewQQMusicDownloader(downloadInfo)
						}
						switch downloadInfo.DownloadType {
						case DownloadTypeMusic:
							downloadInterface.DownloadAllToNativeFile()
						case DownloadTypeBigCover:
							downloadInterface.DownloadBigCover()
						case DownloadTypeLyric:
							downloadInterface.DownloadLyric()
						case DownloadTypeSmallCover:
							downloadInterface.DownloadSmallCover()
						default:
							fmt.Println("Download Type Error!")
						}
						this.releaseDownloadRef()
					}(downloadInfo, this)
				} else {
					this.downloadMutex.Unlock()
				}
			} else {
				this.mutex.Unlock()
				// 暂停100毫秒
				time.Sleep(time.Millisecond * 100)
			}
		}
	}(this)
}

func (this *downloadManager) StopDownload() {
	this.downloading = false
}
