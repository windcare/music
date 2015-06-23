package controller

import (
	"encoding/json"
	"fmt"
	"net/http"
	"sync"
	"time"
)

type ConnectionElement struct {
	Message    chan string
	CloseTimer chan bool
}

type PushMessageController struct {
	currentIndex  int
	lock          *sync.Mutex
	allConnection map[int]*ConnectionElement
}

func NewPushMessageController() *PushMessageController {
	controller := &PushMessageController{}
	controller.lock = &sync.Mutex{}
	controller.allConnection = make(map[int]*ConnectionElement)
	return controller
}

func (this *PushMessageController) AddNewConnection() int {
	this.lock.Lock()
	defer this.lock.Unlock()
	this.currentIndex++
	connection := &ConnectionElement{
		Message:    make(chan string),
		CloseTimer: make(chan bool),
	}
	this.allConnection[this.currentIndex] = connection
	return this.currentIndex
}

func (this *PushMessageController) CloseConnection(index int) {
	this.allConnection[index].CloseTimer <- true
	delete(this.allConnection, index)
}

func (this *PushMessageController) PushMessage(index int, message string) {
	go func(this *PushMessageController, index int, message string) {
		if v, ok := this.allConnection[index]; ok {
			v.Message <- message
		}
	}(this, index, message)
}

func (this *PushMessageController) Run(w http.ResponseWriter, r *http.Request, index int) {
	go func(this *PushMessageController) {
		timer := time.NewTicker(1 * time.Second)
		var lastCount int = 10
		for {
			select {
			case <-timer.C:
				lastCount--
				if lastCount == 0 {

				}
				var heatbeatPackage = &NormalPacket{HeatBeatSingal}
				content, err := json.Marshal(heatbeatPackage)
				if err == nil {
					this.allConnection[index].Message <- string(content) + "\r\n"
				}
			case <-this.allConnection[index].CloseTimer:
				fmt.Println("CloseTimer: ", index)
				return
			}
		}
	}(this)
	for {
		select {
		case message, ok := <-this.allConnection[index].Message:
			if ok == true {
				n, err := w.Write([]byte(message))
				if n == 0 || err != nil {
					fmt.Println(n, err)
					fmt.Println("Connection Closed!")
					this.CloseConnection(index)
					return
				} else {
					if flush, ok := w.(http.Flusher); ok {
						flush.Flush()
					} else {
						fmt.Println("err")
					}
				}
			}
		}
	}
}

func (this *PushMessageController) AccountAction(w http.ResponseWriter, r *http.Request) {
	index := this.AddNewConnection()
	w.Header().Set("Connection", "keep-alive")
	this.Run(w, r, index)
}
