package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
)

type PerplexityResponse struct {
	ID        string   `json:"id"`
	Model     string   `json:"model"`
	Created   int64    `json:"created"`
	Usage     Usage    `json:"usage"`
	Citations []string `json:"citations"`
	Object    string   `json:"object"`
	Choices   []Choice `json:"choices"`
}

type Usage struct {
	PromptTokens     int `json:"prompt_tokens"`
	CompletionTokens int `json:"completion_tokens"`
	TotalTokens      int `json:"total_tokens"`
}

type Choice struct {
	Index        int     `json:"index"`
	FinishReason string  `json:"finish_reason"`
	Message      Message `json:"message"`
	Delta        Message `json:"delta"`
}

type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

func main() {
	modelFlag := flag.String("model", "llama-3.1-sonar-huge-128k-online", "AI model to use")
	flag.Parse()

	perplexityToken := os.Getenv("PREPLEXITY_TOKEN")
	if perplexityToken == "" {
		fmt.Println("Error: PREPLEXITY_TOKEN environment variable not set.")
		return
	}

	args := flag.Args()
	if len(args) < 1 {
		fmt.Println("Error: Please provide a question as arguments.")
		return
	}
	prompt := strings.Join(args, " ")

	payload := strings.NewReader(`{
   "model": "` + *modelFlag + `",
   "messages": [
     {
       "role": "system",
       "content": "Be precise and concise."
     },
     {
       "role": "user",
       "content": "` + prompt + `"
     }
   ],
   "max_tokens": 500,
   "temperature": 0.2,
   "top_p": 0.9,
   "search_domain_filter": [
     "perplexity.ai"
   ],
   "return_images": false,
   "return_related_questions": false,
   "search_recency_filter": "month",
   "top_k": 0,
   "stream": false,
   "presence_penalty": 0,
   "frequency_penalty": 1
 }`)

	url := "https://api.perplexity.ai/chat/completions"
	req, err := http.NewRequest("POST", url, payload)
	if err != nil {
		fmt.Println("Error creating request:", err)
		return
	}

	req.Header.Add("Authorization", "Bearer "+perplexityToken)
	req.Header.Add("Content-Type", "application/json")

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		fmt.Println("Error sending request:", err)
		return
	}

	defer res.Body.Close()
	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		fmt.Println("Error reading response:", err)
		return
	}

	var response PerplexityResponse
	if err := json.Unmarshal(body, &response); err != nil {
		fmt.Println("Error parsing response:", err)
		return
	}

	fmt.Println("Status:", res.Status)
	if len(response.Choices) > 0 {
		fmt.Println("Answer:", response.Choices[0].Message.Content)
		fmt.Println("\nCitations:")
		for _, citation := range response.Citations {
			fmt.Println("-", citation)
		}
	}
}
