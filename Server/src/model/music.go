package model

import (
	"element"
	"errors"
	"fmt"
	"math/rand"
	"time"
)

type musicModel struct {
}

var music *musicModel = nil

func MusicModelInstance() *musicModel {
	if music == nil {
		music = &musicModel{}
	}

	return music
}

func (this *musicModel) SaveMusic(musicInfo *element.MusicInfo) (int, error) {
	if musicInfo == nil && musicInfo.SourceType != element.BaiduMusicSourceType &&
		musicInfo.SourceType != element.LocalMusicSourceType {
		return 0, errors.New("参数错误")
	}
	if DatabaseInstance().Open() != nil {
		return 0, errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	stmt, err := DatabaseInstance().DB.Prepare("insert INTO music(musicname, authorname, albumname, time, type) VALUES(?, ?, ?, ?, ?)")
	if err != nil {
		return 0, err
	}
	result, err := stmt.Exec(musicInfo.MusicName, musicInfo.MusicAuthor, musicInfo.AlbumName, musicInfo.MusicTime, musicInfo.SourceType)
	if err != nil {
		return 0, err
	}
	musicId, err := result.LastInsertId()
	musicInfo.MusicId = int(musicId)
	switch musicInfo.SourceType {
	case element.BaiduMusicSourceType:
		return BaiduMusicModelInstance().InsertMusic(musicInfo)
	case element.LocalMusicSourceType:
		return MyMusicModelInstance().InsertMusic(musicInfo)
	default:
		return 0, errors.New("SourceType Error")
	}
}

func (this *musicModel) UpdateMusic(musicInfo *element.MusicInfo) error {
	if musicInfo == nil && musicInfo.SourceType != element.BaiduMusicSourceType &&
		musicInfo.SourceType != element.LocalMusicSourceType {
		return errors.New("参数错误")
	}
	if DatabaseInstance().Open() != nil {
		return errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	stmt, err := DatabaseInstance().DB.Prepare("update music set musicname = ? and authorname = ? and albumname = ? and time = ? and type = ? where musicid = ?")
	if err != nil {
		return err
	}
	_, err = stmt.Exec(musicInfo.MusicName, musicInfo.MusicAuthor, musicInfo.AlbumName, musicInfo.MusicUUID,
		musicInfo.MusicTime, musicInfo.SourceType, musicInfo.MusicId)
	if err != nil {
		return err
	}
	switch musicInfo.SourceType {
	case element.BaiduMusicSourceType:
		err = BaiduMusicModelInstance().UpdateMusic(musicInfo)
	case element.LocalMusicSourceType:
	}
	return err
}

func (this *musicModel) ChangeSourceType(srcType, dstType int, musicInfo *element.MusicInfo) error {
	if srcType == dstType {
		return this.UpdateMusic(musicInfo)
	} else {
		if DatabaseInstance().Open() != nil {
			return errors.New("打开数据库失败")
		}
		defer DatabaseInstance().Close()
		stmt, err := DatabaseInstance().DB.Prepare("update music set type = ? where musicid = ?")
		if err != nil {
			return err
		}
		_, err = stmt.Exec(dstType, musicInfo.MusicId)
		if err != nil {
			return err
		}
		if srcType == element.BaiduMusicSourceType {
			err := BaiduMusicModelInstance().DeleteMusic(musicInfo.MusicId)
			if err != nil {
				return err
			}
			_, err = MyMusicModelInstance().InsertMusic(musicInfo)
			return err
		} else {
			err := MyMusicModelInstance().DeleteMusic(musicInfo.MusicId)
			if err != nil {
				return err
			}
			_, err = BaiduMusicModelInstance().InsertMusic(musicInfo)
			return err
		}
	}
	return nil
}

func (this *musicModel) FetchRandomList(count int) ([]*element.MusicInfo, error) {
	musicCount, err := this.GetMusicCount()
	if err != nil {
		return nil, err
	}
	if count > musicCount {
		return nil, errors.New("count 大于 musicCount")
	}
	if DatabaseInstance().Open() != nil {
		return nil, errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	// 产生count个1-musicCount的随机数
	var randNumber map[int]bool = make(map[int]bool)
	var randCount int = count
	for randCount > 0 {
		num := int(rand.Int31n(int32(musicCount)))
		if _, ok := randNumber[num]; ok == false {
			randNumber[num] = true
			randCount--
		}
	}
	randCount = count
	var musicList []*element.MusicInfo
	for k, _ := range randNumber {
		var sqlString = fmt.Sprintf("select musicid from music limit %d, 1", k)
		rows, err := DatabaseInstance().DB.Query(sqlString)
		if err != nil {
			fmt.Println("查询失败: ", err)
			return nil, err
		} else {
			if rows.Next() {
				var musicId int
				rows.Scan(&musicId)
				musicInfo, err := this.QueryMusicById(musicId)
				if err != nil {
					return nil, err
				}
				musicList = append(musicList, musicInfo)
			}
		}
	}
	return musicList, nil
}

func (this *musicModel) GetMusicCount() (int, error) {
	if DatabaseInstance().Open() != nil {
		return 0, errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	var sqlString = "select count(*) from music"
	rows, err := DatabaseInstance().DB.Query(sqlString)
	if err != nil {
		fmt.Println(err)
		return 0, errors.New("查询失败")
	}
	if rows.Next() {
		var count int
		rows.Scan(&count)
		return count, nil
	}
	return 0, errors.New("查询失败")
}

func (this *musicModel) FetchLoveList(userid int) ([]*element.LoveMusicInfo, error) {
	if DatabaseInstance().Open() != nil {
		return nil, errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	var loveList []*element.LoveMusicInfo
	rows, err := DatabaseInstance().DB.Query("select musicid, time, degree from lovelist where userid = ?", userid)
	if err != nil {
		fmt.Println(err)
		return nil, errors.New("查询失败")
	}
	for rows.Next() {
		var info *element.LoveMusicInfo = &element.LoveMusicInfo{}
		var musicId, loveTime, degree int
		rows.Scan(&musicId, &loveTime, &degree)
		info.MusicInfo, err = this.QueryMusicById(musicId)
		if err != nil {
			fmt.Println("FetchLoveList Error: ", err)
			return nil, err
		}
		info.MusicId = musicId
		info.LoveTime = loveTime
		info.LoveDegree = degree
		loveList = append(loveList, info)
	}
	return loveList, nil
}

func (this *musicModel) FetchListenList(userid int) ([]*element.ListenMusicInfo, error) {
	if DatabaseInstance().Open() != nil {
		return nil, errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	var listenList []*element.ListenMusicInfo
	rows, err := DatabaseInstance().DB.Query("select musicid, time, times from listenlist where userid = ?", userid)
	if err != nil {
		fmt.Println(err)
		return nil, errors.New("查询失败")
	}
	for rows.Next() {
		var info *element.ListenMusicInfo = &element.ListenMusicInfo{}
		var musicId, listenTimes int
		rows.Scan(&musicId, &listenTimes)
		info.MusicInfo, err = this.QueryMusicById(musicId)
		if err != nil {
			fmt.Println("FetchListenList Error: ", err)
			return nil, err
		}
		info.MusicId = musicId
		info.ListenTimes = listenTimes
		listenList = append(listenList, info)
	}
	return listenList, nil
}

func (this *musicModel) LoveMusic(userId int, musicId int, degree int) error {
	if DatabaseInstance().Open() != nil {
		return errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	var currentTime = time.Now().Unix()
	stmt, err := DatabaseInstance().DB.Prepare("insert INTO lovelist(userid, musicid, time, degree) VALUES(?, ?, ?, ?)")
	if err != nil {
		return err
	}
	stmt.Exec(userId, musicId, currentTime, degree)
	return nil
}

func (this *musicModel) ListenMusic(userId int, musicId int) error {
	if DatabaseInstance().Open() != nil {
		return errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	rows, err := DatabaseInstance().DB.Query("select * from listenlist where userid = ? and musicid = ?", userId, musicId)
	if err != nil {
		fmt.Println(err)
		return err
	}
	if rows.Next() {
		// 数据库中已经存在记录，times增加1
		stmt, err := DatabaseInstance().DB.Prepare("update listenlist set times = times + 1 where userid = ? and musicid = ?")
		if err != nil {
			return err
		}
		stmt.Exec(userId, musicId)
	} else {
		// 数据库中不存在记录，插入
		stmt, err := DatabaseInstance().DB.Prepare("insert INTO listenlist(userid, musicid, times) VALUES(?, ?, ?)")
		if err != nil {
			return err
		}
		stmt.Exec(userId, musicId, 1)
	}
	return nil
}

func (this *musicModel) CheckMusicIsExistByNameAndAuthor(musicName string, authorName string) (bool, int, error) {
	if DatabaseInstance().Open() != nil {
		return false, 0, errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	rows, err := DatabaseInstance().DB.Query("select musicid from music where musicname = ? and authorname = ?", musicName, authorName)
	if err != nil {
		return false, 0, err
	}
	if rows.Next() {
		var musicId int
		rows.Scan(&musicId)
		return true, musicId, nil
	}
	return false, 0, nil
}

func (this *musicModel) CheckMusicIsExist(musicId int) (bool, error) {
	if DatabaseInstance().Open() != nil {
		return false, errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	rows, err := DatabaseInstance().DB.Query("select * from music where musicId = ?", musicId)
	if err != nil {
		return false, err
	}
	if rows.Next() {
		return true, nil
	}
	return false, nil
}

func (this *musicModel) QueryMusicById(musicId int) (*element.MusicInfo, error) {
	if DatabaseInstance().Open() != nil {
		return nil, errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	rows, err := DatabaseInstance().DB.Query("select musicname, authorname, albumname, time, type from music where musicId = ?", musicId)
	if err != nil {
		fmt.Println(err)
		return nil, errors.New("查询失败")
	}
	if rows.Next() {
		var musicInfo *element.MusicInfo = &element.MusicInfo{}
		rows.Scan(&musicInfo.MusicName, &musicInfo.MusicAuthor, &musicInfo.AlbumName, &musicInfo.MusicTime, &musicInfo.SourceType)
		musicInfo.MusicId = musicId
		switch musicInfo.SourceType {
		case element.BaiduMusicSourceType:
			err = BaiduMusicModelInstance().FetchMusicInfo(musicInfo)
		case element.LocalMusicSourceType:
			err = MyMusicModelInstance().FetchMusicInfo(musicInfo)
		default:
			return nil, errors.New("SourceType Error!")
		}
		return musicInfo, err
	}
	return nil, errors.New("查询失败")
}

func (this *musicModel) SearchMusic(searchString string) ([]*element.MusicInfo, error) {
	if DatabaseInstance().Open() != nil {
		return nil, errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	var sqlString = fmt.Sprintf("select musicid from music where musicname like '%%%s%%' or authorname like '%%%s%%' or albumname like '%%%s%%' limit 10",
		searchString, searchString, searchString)
	rows, err := DatabaseInstance().DB.Query(sqlString)
	if err != nil {
		fmt.Println(err)
		return nil, err
	}
	var musicList []*element.MusicInfo
	for rows.Next() {
		var musicInfo *element.MusicInfo = &element.MusicInfo{}
		rows.Scan(&musicInfo.MusicId)
		musicInfo, err = this.QueryMusicById(musicInfo.MusicId)
		if err == nil {
			musicList = append(musicList, musicInfo)
		}
	}
	return musicList, nil
}
