package music

import (
	"element"
)

type Player interface {
	FetchMusicList(channel int) []*element.MusicInfo
	FetchMusicById(musicId int) *element.MusicInfo
	SearchMusic(keyword string) []*element.MusicInfo
}
