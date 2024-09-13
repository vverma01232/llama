# Use a more complete base image like Alpine since BusyBox has limited package support
FROM alpine:latest

# Install required dependencies (git, git-lfs, wget, python3, pip, and bash)
RUN apk add --no-cache git git-lfs bash python3 py3-pip && \
    git lfs install

# Install Hugging Face CLI
RUN  pip install -U "huggingface_hub[cli]"

# Create the /models directory and set appropriate permissions
RUN mkdir /models && chmod 775 /models

# Set the working directory to /models
WORKDIR /models

# Authenticate using the Hugging Face CLI
RUN huggingface-cli login --token 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

# Optionally skip downloading large files by setting this env variable
RUN git-lfs install

# Clone the repository after logging in
RUN git clone https://huggingface.co/meta-llama/Meta-Llama-3-8B-Instruct.git .

# Set file permissions for the cloned files
RUN chmod -R 775 /models
