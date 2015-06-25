package music

import (
	"bufio"
	"element"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"
	"sync"
	"time"
)

// go的条件变量太搓了，所以暂时自己简单实现
type CompleteCallback func(musicInfo *element.MusicInfo)
type FailedCallback func(musicInfo *element.MusicInfo, err error)
type DownloadProgressCallback func(content []byte, err error, stop *bool)
type FetchInformationCallback func(fileSize int)

const (
	DownloadTypeMusic = iota
	DownloadTypeSingle
)

const MaxDownloadQueue = 3 // 最多可以支持3个携程同时下载
const HttpReadSize = 4 * 1024 * 1024

type DownloadElement struct {
	DownloadType    int
	DownloadContent interface{}
	DownloadPath    string
	Progress        DownloadProgressCallback
	CompleteSignal  chan bool
	Information     FetchInformationCallback
	Complete        CompleteCallback
	Failed          FailedCallback
}

type downloadManager struct {
	downloadList  []*DownloadElement
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

func (this *downloadManager) AddDownloadInfoIntoQueue(downloadInfo *DownloadElement) {
	fmt.Println("AddDownloadInfoIntoQueue")
	this.mutex.Lock()
	this.downloadList = append(this.downloadList, downloadInfo)
	this.ref++
	this.mutex.Unlock()
}

func (this *downloadManager) readNetworkFile(url string, filePath string) error {
	out, err := os.Create(filePath)
	if err != nil {
		fmt.Println("download create error: ", err)
		return err
	}
	defer out.Close()
	resp, err := http.Get(url)
	if err != nil {
		fmt.Println("download get error: ", err)
		return err
	}
	defer resp.Body.Close()
	pix, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("download readall error: ", err)
		return err
	}
	size, err := out.Write(pix)
	if err != nil || size == 0 {
		fmt.Println("download copy error: ", err)
		return err
	}
	return nil
}

func (this *downloadManager) readNetworkFileUsingCallback(url string, downloadPath string, fetchCallback FetchInformationCallback, callback DownloadProgressCallback) error {
	out, err := os.Create(downloadPath)
	if err != nil {
		fmt.Println("download create error: ", err)
		return err
	}
	defer out.Close()
	var stopDownload bool = false
	resp, err := http.Get(url)
	if err != nil {
		callback(nil, err, &stopDownload)
		return err
	}
	contentLength, err := strconv.Atoi(resp.Header.Get("Content-Length"))
	if err == nil {
		fetchCallback(contentLength)
	}
	reader := bufio.NewReader(resp.Body)
	content := make([]byte, HttpReadSize)
	offset := 0
	var hasError bool = false
	for {
		if stopDownload == true {
			fmt.Println("Stop Download!")
			return errors.New("Stop Download!")
		}
		size, err := reader.Read(content)
		if size != 0 {
			out.WriteAt(content[:size], int64(offset))
			offset += size
			callback(content[:size], nil, &stopDownload)
			if err != nil {
				callback(nil, nil, &stopDownload)
				return nil
			}
		} else if err != nil || size == 0 {
			callback(nil, err, &stopDownload)
			if err != nil {
				hasError = true
			}
			break
		}
	}
	if hasError == true {
		return err
	}
	return nil
}

func (this *downloadManager) IsExistInDownloadList(downloadType int, downloadContent interface{}) bool {
	this.mutex.Lock()
	defer this.mutex.Unlock()
	for _, item := range this.downloadList {
		if item.DownloadType == downloadType {
			switch item.DownloadType {
			case DownloadTypeMusic:
				downloadMusic := item.DownloadContent.(*element.MusicInfo)
				compareMusic := downloadContent.(*element.MusicInfo)
				if downloadMusic.MusicName == compareMusic.MusicName && downloadMusic.MusicAuthor == compareMusic.MusicAuthor {
					return true
				}
			case DownloadTypeSingle:
				downloadURL := item.DownloadContent.(string)
				compareURL := downloadContent.(string)
				if downloadURL == compareURL {
					return true
				}
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
				var stop bool
				downloadInfo := this.downloadList[0]
				this.downloadList = this.downloadList[1:len(this.downloadList)]
				this.ref--
				this.mutex.Unlock()
				this.downloadMutex.Lock()
				if this.downloadRef < MaxDownloadQueue {
					this.downloadRef++
					this.downloadMutex.Unlock()
					go func(downloadInfo *DownloadElement, this *downloadManager) {
						switch downloadInfo.DownloadType {
						case DownloadTypeMusic:
							downloadMusic := downloadInfo.DownloadContent.(*element.MusicInfo)
							fmt.Println("StartDownload Music: ", downloadMusic.MusicName)
							os.Mkdir(downloadInfo.DownloadPath, os.ModeType|os.ModePerm)
							// download Music
							musicPath := downloadInfo.DownloadPath + "/music.mp3"
							fmt.Println(downloadMusic.MusicPath)
							if err := this.readNetworkFileUsingCallback(downloadMusic.MusicPath, musicPath, func(contentLength int) {
								downloadInfo.Information(contentLength)
							}, func(content []byte, err error, stop *bool) {
								downloadInfo.Progress(content, err, stop)
							}); err != nil {
								downloadInfo.CompleteSignal <- true
								downloadInfo.Progress(nil, err, &stop)
								downloadInfo.Failed(downloadMusic, err)
								this.releaseDownloadRef()
								return
							}
							downloadInfo.CompleteSignal <- true
							// download Lyric
							lyricPath := downloadInfo.DownloadPath + "/lyric.lrc"
							if err := this.readNetworkFile(downloadMusic.LyricPath, lyricPath); err == nil {
								// download lyric success
							} else {
								fmt.Println("download lyric failed: ", err)
								downloadInfo.Failed(downloadMusic, err)
								this.releaseDownloadRef()
								return
							}

							// download big cover
							bigCoverImagePath := downloadInfo.DownloadPath + "/big_cover.jpg"
							if err := this.readNetworkFile(downloadMusic.BigCoverImagePath, bigCoverImagePath); err == nil {
								// download big cover success
							} else {
								fmt.Println("download big cover failed: ", err)
								downloadInfo.Failed(downloadMusic, err)
								this.releaseDownloadRef()
								return
							}

							// download small cover
							smallCoverImagePath := downloadInfo.DownloadPath + "/small_cover.jpg"
							if err := this.readNetworkFile(downloadMusic.SmallCoverImagePath, smallCoverImagePath); err == nil {
								// download small cover success
							} else {
								fmt.Println("download small cover failed: ", err)
								downloadInfo.Failed(downloadMusic, err)
								this.releaseDownloadRef()
								return
							}

							// download compete, callback
							downloadInfo.Complete(downloadMusic)
							this.releaseDownloadRef()
						case DownloadTypeSingle:
							downloadURL := downloadInfo.DownloadContent.(string)
							fmt.Println("StartDownload URL: ", downloadURL)
							if err := this.readNetworkFileUsingCallback(downloadURL, downloadInfo.DownloadPath, func(contentLength int) {
								downloadInfo.Information(contentLength)
							}, func(content []byte, err error, stop *bool) {
								downloadInfo.Progress(content, err, stop)
							}); err != nil {
								var stop bool
								downloadInfo.Progress(nil, err, &stop)
							}
							this.releaseDownloadRef()
							downloadInfo.CompleteSignal <- true
						default:
							fmt.Println("Download Type Error!")
						}
					}(downloadInfo, this)
				} else {
					this.downloadMutex.Unlock()
				}
			} else {
				this.mutex.Unlock()
				// 暂停500毫秒
				time.Sleep(time.Millisecond * 100)
			}
		}
	}(this)
}

func (this *downloadManager) StopDownload() {
	this.downloading = false
}
