package download

import (
	"bufio"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"
	"sync"
)

const HttpReadSize = 4 * 1024 * 1024 // 每次读取4KB的数据

type HandleCallback func(downloadContent []byte) []byte
type DownloadProgressCallback func(content []byte, err error, stop *bool)
type FetchInformationCallback func(fileSize int)

type downloadHelper struct {
}

var downloadHelperOnce sync.Once
var helper *downloadHelper = nil

func DownloadHelper() *downloadHelper {
	downloadHelperOnce.Do(func() {
		helper = &downloadHelper{}
	})
	return helper
}

func (this *downloadHelper) downloadNetworkFileToNativeFile(url string, filePath string) error {
	out, err := os.Create(filePath)
	if err != nil {
		fmt.Println("download create error: ", err)
		return err
	}
	defer out.Close()
	resp, err := http.Get(url)
	if err != nil {
		fmt.Println("download get error: ", err)
		return err
	}
	defer resp.Body.Close()
	pix, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("download readall error: ", err)
		return err
	}
	size, err := out.Write(pix)
	if err != nil || size == 0 {
		fmt.Println("download copy error: ", err)
		return err
	}
	return err
}

func (this *downloadHelper) downloadNetworkFileToBuffer(url string) ([]byte, error) {
	resp, err := http.Get(url)
	if err != nil {
		fmt.Println("download get error: ", err)
		return nil, err
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("download readall error: ", err)
		return nil, err
	}
	return body, err
}

func (this *downloadHelper) downloadNetworkFileToNativeFileByHandle(url string, filePath string,
	handler HandleCallback) error {
	out, err := os.Create(filePath)
	if err != nil {
		fmt.Println("download create error: ", err)
		return err
	}
	defer out.Close()
	resp, err := http.Get(url)
	if err != nil {
		fmt.Println("download get error: ", err)
		return err
	}
	defer resp.Body.Close()
	pix, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("download readall error: ", err)
		return err
	}
	size, err := out.Write(handler(pix))
	if err != nil || size == 0 {
		fmt.Println("download copy error: ", err)
		return err
	}
	return err
}

func (this *downloadHelper) downloadNetworkFileToNativeFileUsingCallback(url string, downloadPath string, fetchCallback FetchInformationCallback, callback DownloadProgressCallback) error {
	out, err := os.Create(downloadPath)
	if err != nil {
		fmt.Println("download create error: ", err)
		return err
	}
	defer out.Close()
	var stopDownload bool = false
	resp, err := http.Get(url)
	if err != nil {
		callback(nil, err, &stopDownload)
		return err
	}
	if resp.StatusCode >= 400 {
		err = errors.New(fmt.Sprintf("download with http code: %d", resp.StatusCode))
		return err
	}
	contentLength, err := strconv.Atoi(resp.Header.Get("Content-Length"))
	if err == nil {
		fetchCallback(contentLength)
	}
	reader := bufio.NewReader(resp.Body)
	content := make([]byte, HttpReadSize)
	offset := 0
	var hasError bool = false
	for {
		if stopDownload == true {
			fmt.Println("Stop Download!")
			return errors.New("Stop Download!")
		}
		size, err := reader.Read(content)
		if size != 0 {
			out.WriteAt(content[:size], int64(offset))
			offset += size
			callback(content[:size], nil, &stopDownload)
			if err != nil {
				callback(nil, nil, &stopDownload)
				return nil
			}
		} else if err != nil || size == 0 {
			callback(nil, err, &stopDownload)
			if err != nil {
				fmt.Println("downloadNetworkFileToNativeFileUsingCallback Error: ", err)
				hasError = true
			}
			break
		}
	}
	if hasError == true {
		return err
	}
	return nil
}

func (this *downloadHelper) downloadNetworkFileToBufferUsingCallback(url string, fetchCallback FetchInformationCallback, callback DownloadProgressCallback) error {
	var stopDownload bool = false
	resp, err := http.Get(url)
	if err != nil {
		callback(nil, err, &stopDownload)
		return err
	}
	if resp.StatusCode >= 400 {
		err = errors.New(fmt.Sprintf("download with http code: %d", resp.StatusCode))
		return err
	}
	contentLength, err := strconv.Atoi(resp.Header.Get("Content-Length"))
	if err == nil {
		fetchCallback(contentLength)
	}
	reader := bufio.NewReader(resp.Body)
	content := make([]byte, HttpReadSize)
	offset := 0
	var hasError bool = false
	for {
		if stopDownload == true {
			fmt.Println("Stop Download!")
			return errors.New("Stop Download!")
		}
		size, err := reader.Read(content)
		if size != 0 {
			offset += size
			callback(content[:size], nil, &stopDownload)
			if err != nil {
				callback(nil, nil, &stopDownload)
				return nil
			}
		} else if err != nil || size == 0 {
			callback(nil, err, &stopDownload)
			if err != nil {
				fmt.Println("downloadNetworkFileToBufferUsingCallback Error: ", err)
				hasError = true
			}
			break
		}
	}
	if hasError == true {
		return err
	}
	return nil
}
