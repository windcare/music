package config

import (
	"encoding/json"
	"fmt"
	"github.com/bitly/go-simplejson"
)

type configManager struct {
}

var manager *configManager = nil

func ConfigManagerInstance() *configManager {
	if manager == nil {
		manager = &configManager{}
	}

	return manager
}
