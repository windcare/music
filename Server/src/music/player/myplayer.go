package player

import (
	"element"
	"model"
	"sync"
)

const fetchCount = 100

const (
	NormalMusicPersonal = iota // 私人频道
	NormalMusicLove            // 我喜欢
)

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

func (this *myMusicPlayer) fetchLoveList(userId int) ([]*element.MusicInfo, error) {
	musicList, err := model.MusicModelInstance().FetchLoveList(userId)
	if err != nil {
		return nil, err
	}
	var retMusicList []*element.MusicInfo = nil
	for _, music := range musicList {
		switch music.LoveDegree {
		case element.LoveDegreeNone:
			retMusicList = append(retMusicList, music.MusicInfo)
		case element.LoveDegreeHate:
		case element.LoveDegreeLike:
			music.IsLoveMusic = true
			retMusicList = append(retMusicList, music.MusicInfo)
		}
	}
	return retMusicList, nil
}

func (this *myMusicPlayer) fetchRandomList() ([]*element.MusicInfo, error) {
	musicList, err := model.MusicModelInstance().FetchRandomList(fetchCount)
	if err == nil {
		return musicList, nil
	}

	return nil, err
}

func (this *myMusicPlayer) FetchMusicList(musicType int, userId int) []*element.MusicInfo {
	switch musicType {
	case NormalMusicPersonal:
		musicList, _ := this.fetchRandomList()
		return musicList
	case NormalMusicLove:
		musicList, _ := this.fetchLoveList(userId)
		return musicList
	default:
		return nil
	}
}

func (this *myMusicPlayer) FetchMusicById(musicId int) *element.MusicInfo {
	musicInfo, err := model.MusicModelInstance().QueryMusicById(musicId)
	if err == nil {
		return musicInfo
	}

	return nil
}

func (this *myMusicPlayer) SearchMusic(keyword string) ([]*element.MusicInfo, error) {
	musicList, err := model.MusicModelInstance().SearchMusic(keyword)
	if err == nil {
		return musicList, nil
	}

	return nil, err
}
