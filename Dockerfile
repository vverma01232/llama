FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt .

COPY . .

CMAKE_ARGS="-DLLAMA_CUBLAS=on -DCUDA_PATH=/usr/local/cuda-12.2 -DCUDAToolkit_ROOT=/usr/local/cuda-12.2 -DCUDAToolkit_INCLUDE_DIR=/usr/local/cuda-12/include -DCUDAToolkit_LIBRARY_DIR=/usr/local/cuda-12.2/lib64" FORCE_CMAKE=1 pip install llama-cpp-python - no-cache-dir
    
RUN pip install -r requirements.txt

RUN wget -q https://huggingface.co/bartowski/Meta-Llama-3-8B-Instruct-GGUF/resolve/main/Meta-Llama-3-8B-Instruct-IQ2_S.gguf -O llama3.gguf

# EXPOSE 8080

CMD ["python", "./app.py"]
