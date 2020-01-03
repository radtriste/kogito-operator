// Copyright 2019 Red Hat, Inc. and/or its affiliates
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"fmt"
	"io"
	"io/ioutil"
	"math/rand"
	"net/http"
	"strings"
	"time"
)

func randSeq(n int) string {
	randomLetters := []rune("abcdefghijklmnopqrstuvwxyz0123456789")
	b := make([]rune, n)
	for i := range b {
		b[i] = randomLetters[rand.Intn(len(randomLetters))]
	}
	return string(b)
}

func readFromUri(uri string) (string, error) {
	var data []byte
	var err error
	if strings.HasPrefix(uri, "http") {
		resp, err := http.Get(uri)
		if err != nil {
			return "", err
		}
		defer resp.Body.Close()
		data, err = ioutil.ReadAll(resp.Body)
	} else {
		data, err = ioutil.ReadFile(uri)
		if err != nil {
			return "", err
		}
	}
	return string(data), nil
}

func waitFor(display string, timeout time.Duration, condition func() (bool,error)) error {
	log.Infof("Wait %s for %s", timeout.String(), display)
	interval := timeout / 60
	
	running := false 
	var err error
	for i := 1; i <= 60; i++ {
		running, err = condition()
		if err != nil {
			return err
		}
		if running {
			break
		}
		time.Sleep(interval)
	}
	if !running {
		return fmt.Errorf("Timeout waiting for %s", display)
	}
	log.Infof("All is happening according to plan... %s succeeded", display)
	return nil
}

func waitForHttpRequest(httpMethod, uri, path string, body io.Reader, timeoutInMin int) error {
	return waitFor("request to be successful", time.Duration(timeoutInMin)*time.Minute, func() (bool, error) {
		request, err := http.NewRequest(httpMethod, uri+"/"+path, body)
		if err != nil {
			return false, err
		}

		client := &http.Client{}
		resp, err := client.Do(request)
		if err != nil {
			return false, err
		}
		if resp.StatusCode < 200 && resp.StatusCode >= 300 {
			return false, nil
		}
		return true, nil
	})
}