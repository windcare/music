package model

import (
	"element"
	"fmt"
	"sync"
)

type recordModel struct {
}

var record *recordModel = nil
var recordOnce sync.Once

func RecordModeInstance() *recordModel {
	recordOnce.Do(func() {
		record = &recordModel{}
	})
	return record
}

func (this *recordModel) InsertRecord(userId int, musicId int, degree int) error {
	if DatabaseInstance().Open() != nil {
		return errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	stmt, err := DatabaseInstance().DB.Prepare("insert into record(userid, musicid, degree) VALUES(?, ?, ?)")
	if err != nil {
		return err
	}
	defer stmt.Close()
	stmt.Exec(userId, musicId, degree)
	return nil
}

func (this *recordModel) GetUserRecode(userId int) ([]*element.UserRecord, error) {
	if DatabaseInstance().Open() != nil {
		return nil, errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	row, err := DatabaseInstance().DB.Query("select musicid, degree from record where userid = ?", userId)
	if err != nil {
		return nil, err
	}
	defer row.Close()
	var recordList []*element.UserRecord = nil
	for row.Next() {
		info := &element.UserRecord{}
		row.Scan(&info.MusicId, &info.Degree)
		info.UserId = userId
		recordList = append(recordList, info)
	}
	return recordList, nil
}

func (this *recordModel) RandomTestData() {

}
