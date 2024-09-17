package main

import (
	"aisvc/config"
	"aisvc/helpers"
	"net/http"
	"os"
	"os/exec"
	"time"

	"github.com/gin-gonic/gin"
	cors "github.com/itsjamie/gin-cors"
	log "github.com/sirupsen/logrus"
)

func main() {
	log.SetFormatter(&log.TextFormatter{
		FullTimestamp: true,
	})
	config.LoadEnv()
	//initiate db connection
	model := os.Getenv("Model")

	cmd := exec.Command("ollama", "serve")
	err := cmd.Start()
	if err != nil {
		log.Error("Error while downloading the model..........")
		return
	}

	ollamaUp := waitForOllamaToBeReady(15 * time.Minute) // Wait for up to 60 seconds
	if !ollamaUp {
		log.Error("Error occured while running the model......")
		return
	}

	cmd = exec.Command("ollama", "pull "+model)
	output, err := cmd.CombinedOutput()
	if err != nil {
		log.Error("Error while downloading the model")
		return
	}
	log.Infof("Model downloaded successfully. Output: %s", output)
	corsConfig := cors.Config{
		Origins:         "*",
		RequestHeaders:  "Origin, Authorization, Content-Type,App-User, Org_id, User-Agent",
		Methods:         "GET, POST, PUT, DELETE",
		Credentials:     false,
		ValidateHeaders: false,
		MaxAge:          1 * time.Minute,
	}
	router := gin.Default()
	router.Use(cors.Middleware(corsConfig))

	router.POST("/initializ/v1/ai/chat", helpers.HandleAiSvcRequest)

	log.Infof("Server listening on http://localhost:8080/")
	if err := http.ListenAndServe("0.0.0.0:8080", router); err != nil {
		log.Fatalf("There was an error with the http server: %v", err)
	}
}

func waitForOllamaToBeReady(timeout time.Duration) bool {
	client := http.Client{
		Timeout: 5 * time.Second, // Set a small timeout for the health check request
	}
	start := time.Now()

	for time.Since(start) < timeout {
		resp, err := client.Get("http://localhost:11434") // Adjust this URL if ollama runs on a different port
		if err == nil && resp.StatusCode == http.StatusOK {
			log.Info("Model is up and running.....")
			return true
		}
		time.Sleep(2 * time.Second) // Wait for 2 seconds before retrying
	}

	return false
}
