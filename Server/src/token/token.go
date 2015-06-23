package token

import (
	"crypto/md5"
	"crypto/rand"
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"io"
	"strings"
	"sync"
	"time"
)

var kTokenTime int = 5

type Token struct {
	UserId     int
	CreateTime int64
	Value      string
}

type tokenManager struct {
	tokenList map[int]*Token
	lock      *sync.Mutex
}

var manager *tokenManager = nil

func TokenManagerInstance() *tokenManager {
	if manager == nil {
		manager = &tokenManager{}
		manager.tokenList = make(map[int]*Token)
		manager.lock = &sync.Mutex{}
		manager.startCheckToken()
	}

	return manager
}

func (this *tokenManager) createToken() string {
	b := make([]byte, 48)
	if _, err := io.ReadFull(rand.Reader, b); err != nil {
		return ""
	}

	h := md5.New()
	h.Write([]byte(base64.URLEncoding.EncodeToString(b)))
	return strings.ToUpper(hex.EncodeToString(h.Sum(nil)))
}

func (this *tokenManager) CheckTokenExist(currentToken string) (bool, int) {
	this.lock.Lock()
	defer this.lock.Unlock()
	for _, token := range this.tokenList {
		if token.Value == currentToken {
			return true, token.UserId
		}
	}
	return false, 0
}

func (this *tokenManager) CheckTokenIsValid(userid int, currentToken string) bool {
	this.lock.Lock()
	defer this.lock.Unlock()
	return this.CheckTokenIsValidWithoutLock(userid, currentToken)
}

func (this *tokenManager) CheckTokenIsValidWithoutLock(userid int, currentToken string) bool {
	if _, ret := this.tokenList[userid]; ret {
		tokenInfo := this.tokenList[userid]
		currentTime := time.Now().Unix()
		if tokenInfo.Value != currentToken {
			return false
		}
		if tokenInfo.CreateTime >= currentTime {
			return false
		} else {
			// 5个小时token过期
			if (currentTime-tokenInfo.CreateTime)/int64(time.Hour) > int64(kTokenTime) {
				delete(this.tokenList, userid)
				return false
			}
			return true
		}
	}
	return false
}

func (this *tokenManager) AddToken(userid int) Token {
	this.lock.Lock()
	if _, ok := this.tokenList[userid]; ok {
		// token已经存在
		existToken := this.tokenList[userid]
		if this.CheckTokenIsValidWithoutLock(userid, existToken.Value) {
			return *existToken
		}
	}
	token := this.createToken()
	defer this.lock.Unlock()
	this.tokenList[userid] = &Token{UserId: userid, CreateTime: time.Now().Unix(), Value: token}
	return *this.tokenList[userid]
}

func (this *tokenManager) startCheckToken() {
	// 每隔10分钟扫描一下，去掉过期的token
	go func(*tokenManager) {
		timer := time.NewTicker(10 * time.Minute)
		for {
			select {
			case <-timer.C:
				fmt.Println("Timer Check Token")
				this.lock.Lock()
				for userid, token := range this.tokenList {
					if this.CheckTokenIsValidWithoutLock(userid, token.Value) == false {
						// 过期了
						delete(this.tokenList, userid)
					}
				}
				this.lock.Unlock()
			}
		}
	}(this)
}
