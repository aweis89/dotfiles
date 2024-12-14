package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
)

func main() {
	perplexityToken := os.Getenv("PREPLEXITY_TOKEN")
	if perplexityToken == "" {
		fmt.Println("Error: PREPLEXITY_TOKEN environment variable not set.")
		return
	}

	url := "https://api.perplexity.ai/chat/completions"

	payload := strings.NewReader(`{
   "model": "llama-3.1-sonar-small-128k-online",
   "messages": [
     {
       "role": "system",
       "content": "Be precise and concise."
     },
     {
       "role": "user",
       "content": "How many stars are there in our galaxy?"
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

	// parse the resposne from this format ai!
	// Response: {"id": "f2b95836-b457-4e20-8637-4f5301c8f9fa", "model": "llama-3.1-sonar-small-128k-online", "created": 1734134338, "usage": {"prompt_tokens": 14, "completion_tokens": 26, "total_tokens": 40}, "citations": ["https://dev.schoolsobservatory.org/learn/space/galaxies", "https://en.wikipedia.org/wiki/Galaxy", "https://science.nasa.gov/missions/hubble/hubble-uncovers-thousands-of-globular-star-clusters-scattered-among-galaxies/", "https://www.youtube.com/watch?v=vtv7Ok-19eU", "https://www.sciencenews.org/article/first-close-image-star-beyond-galaxy"], "object": "chat.completion", "choices": [{"index": 0, "finish_reason": "stop", "message": {"role": "assistant", "content": "Our galaxy, the Milky Way, contains approximately 200 billion (2\u00d710^11) stars[2][4]."}, "delta": {"role": "assistant", "content": ""}}]}
	defer res.Body.Close()
	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		fmt.Println("Error reading response:", err)
		return
	}

	fmt.Println("Status:", res.Status)
	fmt.Println("Response:", string(body))
}
