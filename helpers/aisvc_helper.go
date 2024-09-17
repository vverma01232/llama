package helpers

import (
	"bufio"
	"bytes"
	"encoding/json"
	"net/http"

	"github.com/gin-gonic/gin"
)

type ModelConfig struct {
	Model    string    `json:"model"`
	Messages []Message `json:"messages"`
	Options  struct {
		Temperature float32 `json:"temperature,omitempty"`
		TopP        float64 `json:"top_p,omitempty"`
		NumPredict  int     `json:"num_predict,omitempty"`
		MaxTokens   int     `json:"max_tokens,omitempty"`
	} `json:"options"`
}

type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

func HandleAiSvcRequest(c *gin.Context) {
	var modelConfig ModelConfig
	err := c.BindJSON(&modelConfig)
	if err != nil {
		c.String(http.StatusBadRequest, "Error occured while mapping the body")
		return
	}

	modelConfig.Options.NumPredict = modelConfig.Options.MaxTokens
	body, _ := json.Marshal(modelConfig)
	ollamaUrl := "http://localhost:11434"
	req, err := http.NewRequest("POST", ollamaUrl+"/api/chat", bytes.NewBuffer(body))
	if err != nil {
		c.JSON(http.StatusBadRequest, "Error occured while calling the api")
		return
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		c.JSON(http.StatusBadRequest, err.Error())
		return
	}
	defer resp.Body.Close()

	c.Header("Content-Type", "text/event-stream")

	// Stream the response from OLLAMA API to the client
	scanner := bufio.NewScanner(resp.Body)
	for scanner.Scan() {
		chunk := scanner.Text()
		c.Writer.WriteString("data: " + chunk + "\n\n")
		c.Writer.Flush()
	}
}
