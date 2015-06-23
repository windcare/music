package controller

import (
	"encoding/json"
	"fmt"
	"github.com/bitly/go-simplejson"
	"io/ioutil"
	"model"
	"net/http"
	"token"
)

type LoginPacket struct {
	ErrorCode  int    `json:"code"`
	Param      string `json:"token"`
	CreateTime int64  `json:"createTime"`
}

func LoginSuccessResponse(w http.ResponseWriter, token token.Token) {
	packet := &LoginPacket{OK, token.Value, token.CreateTime}
	body, err := json.Marshal(packet)
	if err != nil {
		panic(err.Error())
	}
	w.Header().Set("Content-Type", "application/json")
	fmt.Fprint(w, string(body))
}

type AccountController struct {
}

func NewAccountController() *AccountController {
	return &AccountController{}
}

func (this *AccountController) AccountAction(w http.ResponseWriter, r *http.Request) {
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		NormalResponse(w, InvalidParam)
		return
	}
	js, err := simplejson.NewJson(body)
	if err != nil {
		NormalResponse(w, InvalidParam)
		return
	}
	action, err := js.Get("action").String()
	if err != nil {
		NormalResponse(w, InvalidParam)
		return
	}
	param := js.Get("param").MustMap()
	if param == nil {
		NormalResponse(w, InvalidParam)
		return
	}
	fmt.Println("action = ", action)
	switch action {
	case "register":
		username := param["username"].(string)
		password := param["password"].(string)
		sex := param["sex"].(string)
		age, err := param["age"].(json.Number).Int64()
		if len(username) == 0 || len(password) == 0 || len(sex) == 0 || err != nil {
			NormalResponse(w, InvalidParam)
			return
		}
		ret, err := model.AccountModelInstance().CheckUserIsExist(username)
		if err != nil {
			fmt.Println("register Error: ", err)
			NormalResponse(w, RegisterDatabaseError)
		} else if ret == true {
			fmt.Println("register ", username, " is exist")
			NormalResponse(w, RegisterInvalidUserName)
		} else {
			code := getMd5String(getMd5String(password) + username)
			model.AccountModelInstance().Register(username, code, sex, int(age))
			NormalResponse(w, OK)
		}
	case "login":
		username := param["username"].(string)
		password := param["password"].(string)
		if len(username) == 0 || len(password) == 0 {
			NormalResponse(w, InvalidParam)
			return
		}
		userid, ret, err := model.AccountModelInstance().CheckUserAndPassword(username, password)
		if err != nil {
			fmt.Println("login Error: ", err)
			NormalResponse(w, LoginDatabaseError)
		} else if ret == true {
			token := token.TokenManagerInstance().AddToken(userid)
			LoginSuccessResponse(w, token)
		} else {
			NormalResponse(w, LoginPasswordError)
		}
	}
}
