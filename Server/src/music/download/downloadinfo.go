package download

import (
	"element"
)

type CompleteCallback func(musicInfo *element.MusicInfo)
type FailedCallback func(musicInfo *element.MusicInfo, err error)

type DownloadInfo struct {
	DownloadType   int
	MusicInfo      *element.MusicInfo
	DownloadPath   string
	CompleteSignal chan bool
	Information    FetchInformationCallback
	Complete       CompleteCallback
	Failed         FailedCallback
	Progress       DownloadProgressCallback
	Handle         HandleCallback
}
