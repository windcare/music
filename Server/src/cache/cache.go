package cache

import (
	"fmt"
	"os"
	"sync"
	"time"
)

type cacheManager struct {
}

const cacheFilePath = "/tmp/musiccache/"

var manager *cacheManager = nil
var once sync.Once

func IsDirExists(path string) bool {
	fi, err := os.Stat(path)
	if err != nil {
		return os.IsExist(err)
	} else {
		return fi.IsDir()
	}
	return false
}

func CacheManagerInstance() *cacheManager {
	once.Do(func() {
		manager = &cacheManager{}
	})

	return manager
}

func (this *cacheManager) GenerateCacheFile() string {
	currentTime := fmt.Sprintf("%d", time.Now().Unix())
	path := cacheFilePath + currentTime
	if IsDirExists(cacheFilePath) == false {
		os.Mkdir(cacheFilePath, os.ModeType|os.ModePerm)
	}
	return path
}

func (this *cacheManager) MoveCacheFile(srcPath, dstPath string) {
	os.Rename(srcPath, dstPath)
}

func (this *cacheManager) DeleteCacheFile(path string) {
	os.Remove(path)
}
