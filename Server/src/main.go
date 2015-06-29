package main

import (
	"controller"
	"fmt"
)

func main() {
	server := controller.NewServiceManager()
	server.InitService()
	server.StartService()
	fmt.Println("=============")
}
