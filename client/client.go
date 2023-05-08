package main

import (
	"flag"
	"fmt"
	"net/http"
	"sync"
)

func main() {
	remoteHost := flag.String("remote_host", "", "enter the ip or fqdn of the remote host")
	numberOfGoRoutines := flag.Int("go_routines", 100, "number of go routines to spawn.")
	flag.Parse()
	var wg sync.WaitGroup
	for i := 0; i < *numberOfGoRoutines; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			host := "http://" + *remoteHost + ":80/"
			resp, err := http.Get(host)
			if err != nil {
				fmt.Println("Error:", err)
				return
			}
			defer resp.Body.Close()
			fmt.Println("Response status:", resp.Status)
		}()
	}
	wg.Wait()
}
