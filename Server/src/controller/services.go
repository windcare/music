package controller

import (
	"config"
	"fmt"
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

	webPath := config.ConfigManagerInstance().ReadWebResourcePath()
	jsPath := webPath + "/src/view"
	http.Handle("/js/", http.FileServer(http.Dir(jsPath)))
}

func (this *ServiceManager) UninitService() {

}

func (this *ServiceManager) StartService() {
	port := config.ConfigManagerInstance().ReadPort()
	http.ListenAndServe(fmt.Sprintf(":%d", port), nil)
}
