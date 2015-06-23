package model

import (
	"errors"
	"fmt"
	"time"
)

type accountModel struct {
}

var model *accountModel = nil

func AccountModelInstance() *accountModel {
	if model == nil {
		model = &accountModel{}
	}

	return model
}

func (this *accountModel) Register(username string, password string, sex string, age int) error {
	var registerTime int64 = time.Now().Unix()
	if DatabaseInstance().Open() != nil {
		return errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	stmt, err := DatabaseInstance().DB.Prepare("insert INTO user(username, password, sex, age, registertime) VALUES(?, ?, ?, ?, ?)")
	if err != nil {
		return err
	}
	stmt.Exec(username, password, sex, age, registerTime)
	return nil
}

func (this *accountModel) CheckUserIsExist(username string) (bool, error) {
	if DatabaseInstance().Open() != nil {
		return false, errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	rows, err := DatabaseInstance().DB.Query("select * from user where username = ?", username)
	if err != nil {
		fmt.Println(err)
		return false, errors.New("查询失败:")
	}
	if rows.Next() {
		return true, nil
	}
	return false, nil
}

func (this *accountModel) CheckUserAndPassword(username string, password string) (int, bool, error) {
	if DatabaseInstance().Open() != nil {
		return 0, false, errors.New("打开数据库失败")
	}
	defer DatabaseInstance().Close()
	rows, err := DatabaseInstance().DB.Query("select userid from user where username = ? and password = ?", username, password)
	if err != nil {
		fmt.Println(err)
		return 0, false, errors.New("查询失败")
	}
	if rows.Next() {
		var userid int
		rows.Scan(&userid)
		return userid, true, nil
	}
	return 0, false, nil
}
