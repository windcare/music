package controller

import (
	// "code.google.com/p/go.net/websocket"
	"net/http"
)

type ServiceManager struct {
	testController        *TestController
	messageController     *MessageController
	musicController       *MusicController
	accountController     *AccountController
	pushMessageController *PushMessageController
}

func NewServiceManager() *ServiceManager {
	service := &ServiceManager{}
	service.testController = NewTestController()
	service.messageController = NewMessageController()
	service.musicController = NewMusicController()
	service.accountController = NewAccountController()
	service.pushMessageController = NewPushMessageController()
	return service
}

func (this *ServiceManager) InitService() {
	http.HandleFunc("/test", this.testController.TestAction)
	http.HandleFunc("/message", this.messageController.MessageAction)
	http.HandleFunc("/music", this.musicController.MusicAction)
	http.HandleFunc("/account", this.accountController.AccountAction)

	http.HandleFunc("/longconnect", this.pushMessageController.AccountAction)
	http.Handle("/js/", http.FileServer(http.Dir("/Users/sjjwind/Desktop/Project/Music/Server/src/view")))
}

func (this *ServiceManager) UninitService() {

}

func (this *ServiceManager) StartService() {
	http.ListenAndServe(":34321", nil)
}
