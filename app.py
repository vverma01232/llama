from flask import Flask, request, Response, jsonify
from llama_cpp import Llama
from gevent.pywsgi import WSGIServer
import json

app = Flask(__name__)

# Initialize the model globally before using it in the predict function
llm = None

@app.route("/v1/models/chat", methods=["POST"])
def chat():
    global llm
    data = request.json
    
    prompt = data.get("prompt", "")
    max_tokens = data.get("max_tokens", 2048)
    temperature = data.get("temperature", 0.7)
    top_p = data.get("top_p", 1.0)
    frequency_penalty = data.get("frequency_penalty", 0.0)
    presence_penalty = data.get("presence_penalty", 0.0)
    stop = data.get("stop", None)
    stream = data.get("stream", True)

    if stream: 
        def generate():
            for output in llm.create_completion(
                prompt=prompt,
                max_tokens=max_tokens,
                temperature=temperature,
                top_p=top_p,
                frequency_penalty=frequency_penalty,
                presence_penalty=presence_penalty,
                stop=stop,
                stream=stream  
            ):
                choices = output.get('choices', [])
                if choices and 'delta' in choices[0]:
                    delta = choices[0]['delta']
                    if delta:
                        text_chunk = delta.get('content', '')
                        if text_chunk:
                            yield f"data: {json.dumps(output)}\n\n"
                if choices[0].get('finish_reason') in ['stop', 'length']:
                    yield f"data: [DONE]\n\n"
        return Response(generate(), content_type='text/event-stream')
    
    else:
        output = llm.create_completion(
             prompt=prompt,
            max_tokens=max_tokens,
            temperature=temperature,
            top_p=top_p,
            frequency_penalty=frequency_penalty,
            presence_penalty=presence_penalty,
            stream=stream
        )
        return jsonify(output)

@app.route("/v1/models/chatcompletion", methods=["POST"])
def chat_completion():
    global llm
    data = request.json
    
    messages = data.get("messages", [])
    max_tokens = data.get("max_tokens", 2048)
    temperature = data.get("temperature", 0.7)
    top_p = data.get("top_p", 1.0)
    frequency_penalty = data.get("frequency_penalty", 0.0)
    presence_penalty = data.get("presence_penalty", 0.0)
    stream = data.get("stream", True)

    if stream:
        # Handle streaming case
        def generate():
            for output in llm.create_chat_completion(
                messages=messages,
                max_tokens=max_tokens,
                temperature=temperature,
                top_p=top_p,
                frequency_penalty=frequency_penalty,
                presence_penalty=presence_penalty,
                stream=stream
            ):
                choices = output.get('choices', [])
                if choices and 'delta' in choices[0]:
                    delta = choices[0]['delta']
                    if delta:
                        text_chunk = delta.get('content', '')
                        if text_chunk:
                            yield f"data: {json.dumps(output)}\n\n"
                if choices[0].get('finish_reason') in ['stop', 'length']:
                    yield f"data: [DONE]\n\n"
        return Response(generate(), content_type='text/event-stream')

    else:
        # Handle non-streaming case
        output = llm.create_chat_completion(
            messages=messages,
            max_tokens=max_tokens,
            temperature=temperature,
            top_p=top_p,
            frequency_penalty=frequency_penalty,
            presence_penalty=presence_penalty,
            stream=stream
        )
        return jsonify(output)


if __name__ == "__main__":
    llm = Llama(
        model_path="llama",
        n_ctx=2048,
        n_gpu_layers=33,
        # n_threads=6,
        # n_batch=521,
        verbose=True,
    )
    http_server = WSGIServer(("", 8080), app)
    http_server.serve_forever()
