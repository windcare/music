package element

import (
// "fmt"
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
	IsLoveMusic         bool
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
