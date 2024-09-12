# Use a base image with CUDA support
FROM nvidia/cuda:11.8.0-base-ubuntu20.04

WORKDIR /app

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y wget build-essential cmake ninja-build libopenblas-dev pkg-config python3-pip && \
    rm -rf /var/lib/apt/lists/*

ENV TZ=America/New_York
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata
# Copy requirements file and install Python packages
COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

# Set environment variables for CMake
ENV CMAKE_ARGS="-DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS"
ENV FORCE_CMAKE=1

# Install llama-cpp-python package
RUN pip3 install llama-cpp-python

# Copy the rest of the application code
COPY . .

# Download the model file
RUN wget -q https://huggingface.co/bartowski/Meta-Llama-3-8B-Instruct-GGUF/resolve/main/Meta-Llama-3-8B-Instruct-IQ2_S.gguf -O llama

# Expose port if needed (optional)
# EXPOSE 8080

# Command to run the application
CMD ["python3", "./app.py"]
