package element

import (
// "fmt"
)

const (
	BaiduMusicSourceType = iota
	LocalMusicSourceType
)

type MusicInfo struct {
	MusicName           string
	MusicAuthor         string
	AlbumName           string
	SmallCoverImagePath string
	BigCoverImagePath   string
	MusicPath           string
	LyricPath           string
	SourceType          int
	MusicFormat         string
	MusicTime           int
	MusicUUID           string
	MusicId             int
	NetMusicId          int
}

type LoveMusicInfo struct {
	*MusicInfo
	LoveTime   int
	LoveDegree int
}

type ListenMusicInfo struct {
	*MusicInfo
	ListenTimes int
}
