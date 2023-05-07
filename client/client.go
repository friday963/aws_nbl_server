package main

import (
	"fmt"
	"net/http"
	"sync"

)

func main() {
    var wg sync.WaitGroup
    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
			// "TODO: Change from localhost to LB"
            resp, err := http.Get("http://localhost:80/")
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