package config

import (
	"encoding/json"
	"os"
)

type net struct {
	IP   string `json:"ip"`
	Port int    `json:"port"`
}

type resource struct {
	Webresourcepath   string `json:"webpath"`
	Localresourcepath string `json:"localpath"`
}

type config struct {
	Net      net      `json:"net"`
	Resource resource `json:"resource"`
}

const (
	ConfigFileName           = "default.conf"
	DefaultIPAddress         = "127.0.0.1"
	DefaultPort              = 9020
	DefaultWebResourcePath   = "/"
	DefaultLocalResourcePath = "/"
)

type configManager struct {
	configContent string
}

var manager *configManager = nil

func IsFileExixt(path string) bool {
	_, err := os.Stat(path)
	return err == nil || os.IsExist(err)
}

func ConfigManagerInstance() *configManager {
	if manager == nil {
		manager = &configManager{}
	}

	return manager
}

func (this *configManager) loadConfigFile() {
	if IsFileExixt(ConfigFileName) == false {
		file, _ := os.Create(ConfigFileName)
		defer file.Close()
		var js config
		js.Net.IP = DefaultIPAddress
		js.Net.Port = DefaultPort
		js.Resource.Localresourcepath = DefaultLocalResourcePath
		js.Resource.Webresourcepath = DefaultWebResourcePath
		data, err := json.Marshal(js)
		if err != nil {
			file.Write(data)
			this.configContent = string(data)
		} else {
			this.configContent = ""
		}
	} else {
		fileInfo, err := os.Stat(ConfigFileName)
		if err != nil {
			this.configContent = ""
			return
		}
		file, err := os.Open(ConfigFileName)
		if err != nil {
			this.configContent = ""
			return
		}
		content := make([]byte, fileInfo.Size())
		file.Read(content)
		this.configContent = string(content)
	}

}

func (this *configManager) ReadLocalResourcePath() string {
	this.loadConfigFile()
	if this.configContent == "" {
		return DefaultLocalResourcePath
	}
	var js config
	err := json.Unmarshal([]byte(this.configContent), &js)
	if err != nil {
		return DefaultLocalResourcePath
	}
	return js.Resource.Localresourcepath
}

func (this *configManager) ReadWebResourcePath() string {
	this.loadConfigFile()
	if this.configContent == "" {
		return DefaultWebResourcePath
	}
	var js config
	err := json.Unmarshal([]byte(this.configContent), &js)
	if err != nil {
		return DefaultWebResourcePath
	}
	return js.Resource.Webresourcepath
}

func (this *configManager) ReadIPAddress() string {
	this.loadConfigFile()
	if this.configContent == "" {
		return DefaultIPAddress
	}
	var js config
	err := json.Unmarshal([]byte(this.configContent), &js)
	if err != nil {
		return DefaultIPAddress
	}
	return js.Net.IP
}

func (this *configManager) ReadPort() int {
	this.loadConfigFile()
	if this.configContent == "" {
		return DefaultPort
	}
	var js config
	err := json.Unmarshal([]byte(this.configContent), &js)
	if err != nil {
		return DefaultPort
	}
	return js.Net.Port
}
