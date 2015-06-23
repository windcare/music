package controller

import (
	"encoding/json"
	"fmt"
	"net/http"
)

type NormalPacket struct {
	ErrorCode int `json:"code"`
}

func NormalResponse(w http.ResponseWriter, errorCode int) {
	packet := &NormalPacket{}
	packet.ErrorCode = errorCode
	body, err := json.Marshal(packet)
	if err != nil {
		panic(err.Error())
	}
	w.Header().Set("Content-Type", "application/json")
	fmt.Fprint(w, string(body))
}
