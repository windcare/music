package main

import (
	"controller"
	"fmt"
)

func main() {
            fmt.Println("StartService")
	server := controller.NewServiceManager()
	server.InitService()
	server.StartService()
	fmt.Println("=============")
}
