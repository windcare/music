package controller

import (
	"config"
	"fmt"
	"html/template"
	"log"
	"net/http"
)

type NetInfo struct {
	Host string
	Port int
}

type TestController struct {
}

func NewTestController() *TestController {
	return &TestController{}
}

func (this *TestController) TestAction(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	var info NetInfo
	info.Host = "http://" + config.ConfigManagerInstance().ReadIPAddress()
	info.Port = config.ConfigManagerInstance().ReadPort()
	t, err := template.ParseFiles("./src/view/test.html")
	if err != nil {
		log.Println(err)
	}
	t.Execute(w, &info)
}
