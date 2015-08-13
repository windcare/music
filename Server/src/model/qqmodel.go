package model

import (
	"element"
	"errors"
	"sync"
)

type qqMusicModel struct {
}

var qqModel *qqMusicModel = nil
var qqMusicModelOnce sync.Once

func QQMusicModelInstance() *qqMusicModel {
	qqMusicModelOnce.Do(func() {
		qqModel = &qqMusicModel{}
	})

	return qqModel
}

func (this *qqMusicModel) InsertMusic(musicInfo *element.MusicInfo) (int, error) {
	stmt, err := DatabaseInstance().DB.Prepare("insert into qqmusic(qqmusicid, musicid, songlink, lyriclink, smallcoverlink, bigcoverlink) VALUES(?, ?, ?, ?, ?, ?)")
	defer stmt.Close()
	_, err = stmt.Exec(musicInfo.NetMusicId, musicInfo.MusicId, musicInfo.MusicPath, musicInfo.LyricPath,
		musicInfo.SmallCoverImagePath, musicInfo.BigCoverImagePath)
	return musicInfo.MusicId, err
}

func (this *qqMusicModel) UpdateMusic(musicInfo *element.MusicInfo) error {
	stmt, err := DatabaseInstance().DB.Prepare("update qqmusic set songlink = ? and lyriclink, smallcoverlink, bigcoverlink where qqmusicid = ?")
	defer stmt.Close()
	_, err = stmt.Exec(musicInfo.MusicPath, musicInfo.LyricPath, musicInfo.SmallCoverImagePath, musicInfo.BigCoverImagePath, musicInfo.NetMusicId)
	return err
}

func (this *qqMusicModel) FetchMusicInfo(musicInfo *element.MusicInfo) error {
	rows, err := DatabaseInstance().DB.Query("select qqmusicid, songlink, lyriclink, smallcoverlink, bigcoverlink from qqmusic where musicid = ?", musicInfo.MusicId)
	if err != nil {
		return err
	}
	defer rows.Close()
	if rows.Next() {
		err := rows.Scan(&musicInfo.NetMusicId, &musicInfo.MusicPath, &musicInfo.LyricPath, &musicInfo.SmallCoverImagePath, &musicInfo.BigCoverImagePath)
		if err != nil {
			return err
		}
	} else {
		return errors.New("No Data")
	}
	return nil
}

func (this *qqMusicModel) DeleteMusic(musicId int) error {
	stmt, err := DatabaseInstance().DB.Prepare("delete from qqmusic where musicid = ?")
	defer stmt.Close()
	_, err = stmt.Exec(musicId)
	return err
}
