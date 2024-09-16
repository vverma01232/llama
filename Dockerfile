# Base image with Python 3.9 and CUDA for GPU support
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install required system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip python3-dev && \
    rm -rf /var/lib/apt/lists/*

# Install torch with CUDA support
RUN pip install torch==2.0.1+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file and install dependencies, including accelerate
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app code to the container
COPY . /app

# Expose the port the app runs on
EXPOSE 8080

# Run the Flask app with Gunicorn
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8080", "app:app"]
