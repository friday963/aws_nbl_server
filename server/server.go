package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

func main() {
	// create a log file to store requests
	f, err := os.Create("request.log")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	logger := log.New(f, "", log.LstdFlags)
	// Create a handler function to handle incoming HTTP requests
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Log the request details to the file
		logger.Printf("%s - [%s] \"%s %s %s\" \"%s\"\n", r.RemoteAddr, time.Now().Format("02/Jan/2006:15:04:05 -0700"), r.Method, r.URL.Path, r.Proto, r.UserAgent())

		// Return a response to the client
		fmt.Fprintf(w, "Successful Query to port 80")
	})
	log.Println("Server listening on port 80...")
    log.Fatal(http.ListenAndServe(":80", handler))
}
