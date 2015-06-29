package controller

import (
	"fmt"
	"net/http"
)

type StatisticsController struct {
}

func NewStatisticsController() *StatisticsController {
	return &StatisticsController{}
}

func (this *StatisticsController) StatisticsAction(w http.ResponseWriter, r *http.Request) {
	fmt.Println("statistics: ", r.Form)
}
