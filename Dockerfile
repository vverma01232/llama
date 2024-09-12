FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt .

COPY . .


RUN pip install --no-cache-dir -r requirements.txt
# ENV CMAKE_ARGS="-DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS"
# RUN pip install llama-cpp-python


ENV CMAKE_ARGS="-DLLAMA_CUBLAS=on -DCUDA_PATH=/usr/local/cuda-12.2 -DCUDAToolkit_ROOT=/usr/local/cuda-12.2 -DCUDAToolkit_INCLUDE_DIR=/usr/local/cuda-12/include -DCUDAToolkit_LIBRARY_DIR=/usr/local/cuda-12.2/lib64" 
ENV FORCE_CMAKE=1 
RUN pip install llama-cpp-python

RUN wget -q https://huggingface.co/bartowski/Meta-Llama-3-8B-Instruct-GGUF/resolve/main/Meta-Llama-3-8B-Instruct-IQ2_S.gguf -O llama

# EXPOSE 8080

CMD ["python", "./app.py"]
