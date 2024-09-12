FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt ./
COPY . ./

RUN apt-get update && \
    apt-get install -y wget build-essential cmake ninja-build libopenblas-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Install CUDA toolkit (this example installs CUDA 12.2)
RUN wget https://developer.download.nvidia.com/compute/cuda/12.2.0/local_installers/cuda_12.2.0_530.41.03_linux.run && \
    chmod +x cuda_12.2.0_530.41.03_linux.run && \
    ./cuda_12.2.0_530.41.03_linux.run --silent --toolkit

# Install NVIDIA drivers and tools (if not already installed)
RUN apt-get install -y nvidia-driver nvidia-cuda-toolkit

RUN pip install --no-cache-dir -r requirements.txt
ENV CMAKE_ARGS="-DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS"
ENV FORCE_CMAKE=1
RUN pip install llama-cpp-python
RUN pip install -r requirements.txt

RUN wget -q https://huggingface.co/bartowski/Meta-Llama-3-8B-Instruct-GGUF/resolve/main/Meta-Llama-3-8B-Instruct-IQ2_S.gguf -O llama

# EXPOSE 8080

CMD ["python", "./app.py"]
