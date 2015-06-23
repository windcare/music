package player

import (
	"element"
	"model"
	"sync"
)

const fetchCount = 10

type myMusicPlayer struct {
}

var myMusicInstanceOnce sync.Once
var myPlayer *myMusicPlayer

func MyMusicPlayerInstance() *myMusicPlayer {
	myMusicInstanceOnce.Do(func() {
		myPlayer = &myMusicPlayer{}
	})

	return myPlayer
}

func (this *myMusicPlayer) FetchMusicList(musicType int) []*element.MusicInfo {
	musicList, err := model.MusicModelInstance().FetchRandomList(fetchCount)
	if err == nil {
		return musicList
	}

	return nil
}

func (this *myMusicPlayer) FetchMusicById(musicId int) *element.MusicInfo {
	musicInfo, err := model.MusicModelInstance().QueryMusicById(musicId)
	if err == nil {
		return musicInfo
	}

	return nil
}

func (this *myMusicPlayer) SearchMusic(keyword string) []*element.MusicInfo {
	musicList, err := model.MusicModelInstance().SearchMusic(keyword)
	if err == nil {
		return musicList
	}

	return nil
}
