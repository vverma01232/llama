from flask import Flask, request, Response, jsonify
from gevent.pywsgi import WSGIServer
import transformers
import torch

app = Flask(__name__)

# Initialize the transformers pipeline globally
pipeline = None

@app.route("/v1/models/chat", methods=["POST"])
def chat():
    global pipeline
    data = request.json
    
    prompt = data.get("prompt", "")
    max_tokens = data.get("max_tokens", 2048)
    temperature = data.get("temperature", 0.7)
    top_p = data.get("top_p", 1.0)
    stream = data.get("stream", True)

    # Prepare generation arguments for Hugging Face pipeline
    generate_args = {
        "max_new_tokens": max_tokens,
        "do_sample": True,
        "temperature": temperature,
        "top_p": top_p,
    }

    if stream:
        def generate():
            for output in pipeline(prompt, **generate_args, return_full_text=False):
                text_chunk = output.get('generated_text', '')
                if text_chunk:
                    yield f"data: {json.dumps({'text': text_chunk})}\n\n"
            yield f"data: [DONE]\n\n"
        return Response(generate(), content_type='text/event-stream')
    
    else:
        output = pipeline(prompt, **generate_args, return_full_text=False)
        return jsonify(output)


@app.route("/v1/models/chatcompletion", methods=["POST"])
def chat_completion():
    global pipeline
    data = request.json
    
    messages = data.get("messages", [])
    max_tokens = data.get("max_tokens", 2048)
    temperature = data.get("temperature", 0.7)
    top_p = data.get("top_p", 1.0)
    frequency_penalty = data.get("frequency_penalty", 0.0)
    presence_penalty = data.get("presence_penalty", 0.0)
    stream = data.get("stream", True)

    # Join all messages into a single prompt for the pipeline
    prompt = " ".join([msg.get("content", "") for msg in messages])

    # Prepare generation arguments for Hugging Face pipeline
    generate_args = {
        "max_new_tokens": max_tokens,
        "do_sample": True,
        "temperature": temperature,
        "top_p": top_p,
        "repetition_penalty": frequency_penalty + presence_penalty,
    }

    if stream:
        def generate():
            for output in pipeline(prompt, **generate_args, return_full_text=False):
                text_chunk = output.get('generated_text', '')
                if text_chunk:
                    yield f"data: {json.dumps({'text': text_chunk})}\n\n"
            yield f"data: [DONE]\n\n"
        return Response(generate(), content_type='text/event-stream')

    else:
        output = pipeline(prompt, **generate_args, return_full_text=False)
        return jsonify(output)


if __name__ == "__main__":
    model_id = "meta-llama/Meta-Llama-3.1-8B"
    pipeline = transformers.pipeline(
        "text-generation",
        model=model_id,
        token="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",
        model_kwargs={"torch_dtype": torch.bfloat16},
        device_map="auto"
    )
    
    http_server = WSGIServer(("", 8080), app)
    http_server.serve_forever()
