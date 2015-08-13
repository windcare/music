package download

type Downloader interface {
	DownloadAllToNativeFile()
	DownloadLyric()
	DownloadBigCover()
	DownloadSmallCover()
}
