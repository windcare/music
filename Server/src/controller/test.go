package controller

import (
	"fmt"
	// "github.com/bitly/go-simplejson"
	// "errors"
	"html/template"
	"log"
	"net/http"
)

type TestController struct {
}

func NewTestController() *TestController {
	return &TestController{}
}

func (this *TestController) TestAction(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	fmt.Println(r.URL.Path)
	t, err := template.ParseFiles("./src/view/test.html")
	if err != nil {
		log.Println(err)
	}
	t.Execute(w, nil)
}
