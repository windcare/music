package model

import (
	"element"
	"errors"
	"sync"
)

type myMusicModel struct {
}

var myModel *myMusicModel = nil
var myMusicModelOnce sync.Once

func MyMusicModelInstance() *myMusicModel {
	myMusicModelOnce.Do(func() {
		myModel = &myMusicModel{}
	})

	return myModel
}

func (this *myMusicModel) InsertMusic(musicInfo *element.MusicInfo) (int, error) {
	stmt, err := DatabaseInstance().DB.Prepare("insert into localmusic(musicid, path) VALUES(?, ?)")
	defer stmt.Close()
	_, err = stmt.Exec(musicInfo.MusicId, musicInfo.MusicUUID)
	return musicInfo.MusicId, err
}

func (this *myMusicModel) FetchMusicInfo(musicInfo *element.MusicInfo) error {
	rows, err := DatabaseInstance().DB.Query("select path from localmusic where musicid = ?", musicInfo.MusicId)
	if err != nil {
		return err
	}
	defer rows.Close()
	if rows.Next() {
		err := rows.Scan(&musicInfo.MusicUUID)
		if err != nil {
			return err
		}
		musicInfo.MusicPath = musicInfo.MusicUUID + "/music.mp3"
		musicInfo.LyricPath = musicInfo.MusicUUID + "/lyric.lrc"
		musicInfo.BigCoverImagePath = musicInfo.MusicUUID + "/big_cover.jpg"
		musicInfo.SmallCoverImagePath = musicInfo.MusicUUID + "/small_cover.jpg"
		return nil
	} else {
		return errors.New("No Data")
	}
}

func (this *myMusicModel) DeleteMusic(musicId int) error {
	stmt, err := DatabaseInstance().DB.Prepare("delete from localmusic where musicid = ?")
	defer stmt.Close()
	_, err = stmt.Exec(musicId)
	return err
}
