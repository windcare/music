package model

import (
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
)

type Database struct {
	DB  *sql.DB
	ref int
}

var database *Database = nil

func DatabaseInstance() *Database {
	if database == nil {
		database = &Database{}
	}
	return database
}

func (this *Database) Open() error {
	var err error = nil
	this.DB, err = sql.Open("mysql", ConnectString)
	if err != nil {
		fmt.Printf("connect err", err)
		return err
	}
	this.ref++
	return nil
}

func (this *Database) Close() {
	this.ref--
	if this.ref == 0 {
		this.DB.Close()
	}
}
