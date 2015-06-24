package controller

import (
	"crypto/md5"
	"encoding/hex"
	"fmt"
	"music"
	"net/http"
	"strconv"
)

type downloadFunc func(musicId int, information music.FetchInformationCallback, progress music.DownloadProgressCallback)

func getMd5String(s string) string {
	h := md5.New()
	h.Write([]byte(s))
	return hex.EncodeToString(h.Sum(nil))
}

type MessageController struct {
}

func NewMessageController() *MessageController {
	return &MessageController{}
}

func (this *MessageController) writeStream(musicId int, function downloadFunc, w http.ResponseWriter) {
	w.Header().Set("Accept", "*/*")
	w.Header().Set("Connection", "keep-alive")
	function(musicId, func(contentLength int) {
		w.Header().Set("Content-Length", strconv.Itoa(contentLength))
	}, func(content []byte, err error, stop *bool) {
		if err != nil {
			fmt.Println("download error: ", err)
		} else {
			if size, err := w.Write(content); err != nil || size == 0 {
				*stop = true
			}
			w.(http.Flusher).Flush()
		}
	})
}

func (this *MessageController) handleGetRequest(w http.ResponseWriter, r *http.Request) {
	action := r.Form.Get("action")
	switch action {
	case "downloadMusic":
		musicId, err := strconv.Atoi(r.Form.Get("musicId"))
		if err != nil {
			NormalResponse(w, InvalidParam)
		} else {
			fmt.Println("downloadMusic: ", musicId)
			w.Header().Set("Content-Type", "audio/mpeg")
			this.writeStream(musicId, music.MusicManagerInstance().DownloadMusic, w)
		}
	case "downloadBigCover":
		musicId, err := strconv.Atoi(r.Form.Get("musicId"))
		if err != nil {
			NormalResponse(w, InvalidParam)
		} else {
			fmt.Println("downloadBigCover: ", musicId)
			this.writeStream(musicId, music.MusicManagerInstance().DownloadBigCoverImage, w)
		}
	case "downloadSmallCover":
		musicId, err := strconv.Atoi(r.Form.Get("musicId"))
		if err != nil {
			NormalResponse(w, InvalidParam)
		} else {
			fmt.Println("downloadSmallCover: ", musicId)
			this.writeStream(musicId, music.MusicManagerInstance().DownloadSmallCoverImage, w)
		}
	case "downloadLyric":
		musicId, err := strconv.Atoi(r.Form.Get("musicId"))
		if err != nil {
			NormalResponse(w, InvalidParam)
		} else {
			fmt.Println("downloadLyric: ", musicId)
			this.writeStream(musicId, music.MusicManagerInstance().DownloadLyric, w)
		}
	}
}

func (this *MessageController) MessageAction(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	if r.Method == "GET" {
		this.handleGetRequest(w, r)
	}
}
