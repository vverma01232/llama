FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt ./
COPY . ./

# RUN apt-get update && \
#     apt-get install -y wget build-essential cmake ninja-build libopenblas-dev pkg-config && \
#     rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir -r requirements.txt
# ENV CMAKE_ARGS="-DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS"
# ENV FORCE_CMAKE=1
# RUN pip install llama-cpp-python
RUN apt-get update && apt-get install -y software-properties-common && \
    wget https://developer.download.nvidia.com/compute/cuda/12.3.1/local_installers/cuda-repo-debian12-12-3-local_12.3.1-545.23.08-1_amd64.deb && \
    dpkg -i cuda-repo-debian12-12-3-local_12.3.1-545.23.08-1_amd64.deb && \
    cp /var/cuda-repo-debian12-12-3-local/cuda-*-keyring.gpg /usr/share/keyrings/ && \
    add-apt-repository contrib && \
    apt-get update && \
    apt-get -y install cuda-toolkit-12-3 

#Install llama-cpp-python with CUDA Support (and jupyterlab)
RUN CUDACXX=/usr/local/cuda-12/bin/nvcc CMAKE_ARGS="-DLLAMA_CUBLAS=on -DCMAKE_CUDA_ARCHITECTURES=all-major" FORCE_CMAKE=1 \
    pip install llama-cpp-python --no-cache-dir --force-reinstall --upgrade
RUN pip install -r requirements.txt

RUN wget -q https://huggingface.co/bartowski/Meta-Llama-3-8B-Instruct-GGUF/resolve/main/Meta-Llama-3-8B-Instruct-IQ2_S.gguf -O llama

# EXPOSE 8080

CMD ["python", "./app.py"]
