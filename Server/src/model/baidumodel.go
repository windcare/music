package model

import (
	"element"
	"errors"
	"sync"
)

type baiduMusicModel struct {
}

var baiduModel *baiduMusicModel = nil
var baiduMusicModelOnce sync.Once

func BaiduMusicModelInstance() *baiduMusicModel {
	baiduMusicModelOnce.Do(func() {
		baiduModel = &baiduMusicModel{}
	})

	return baiduModel
}

func (this *baiduMusicModel) InsertMusic(musicInfo *element.MusicInfo) (int, error) {
	stmt, err := DatabaseInstance().DB.Prepare("insert into baidumusic(baidumusicid, musicid, songlink, lyriclink, smallcoverlink, bigcoverlink) VALUES(?, ?, ?, ?, ?, ?)")
	defer stmt.Close()
	_, err = stmt.Exec(musicInfo.NetMusicId, musicInfo.MusicId, musicInfo.MusicPath, musicInfo.LyricPath,
		musicInfo.SmallCoverImagePath, musicInfo.BigCoverImagePath)
	return musicInfo.MusicId, err
}

func (this *baiduMusicModel) UpdateMusic(musicInfo *element.MusicInfo) error {
	stmt, err := DatabaseInstance().DB.Prepare("update baidumusic set songlink = ? and lyriclink, smallcoverlink, bigcoverlink where baidumusicid = ?")
	defer stmt.Close()
	_, err = stmt.Exec(musicInfo.MusicPath, musicInfo.LyricPath, musicInfo.SmallCoverImagePath, musicInfo.BigCoverImagePath, musicInfo.NetMusicId)
	return err
}

func (this *baiduMusicModel) FetchMusicInfo(musicInfo *element.MusicInfo) error {
	rows, err := DatabaseInstance().DB.Query("select baidumusicid, songlink, lyriclink, smallcoverlink, bigcoverlink from baidumusic where musicid = ?", musicInfo.MusicId)
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

func (this *baiduMusicModel) DeleteMusic(musicId int) error {
	stmt, err := DatabaseInstance().DB.Prepare("delete from baidumusic where musicid = ?")
	defer stmt.Close()
	_, err = stmt.Exec(musicId)
	return err
}
