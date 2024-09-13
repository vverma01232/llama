# Use a more complete base image like Alpine since BusyBox has limited package support
FROM alpine:latest

# Install required dependencies (git, git-lfs, and wget)
RUN apk add --no-cache git git-lfs bash && \
    git lfs install

# Create the /models directory and set appropriate permissions
RUN mkdir /models && chmod 775 /models

# Accept Hugging Face token as a build argument
ARG HF_TOKEN

# Set the working directory to /models
WORKDIR /models

# Clone the Hugging Face repository using the token
RUN git clone https://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:x-oauth-basic@huggingface.co/meta-llama/Meta-Llama-3-8B-Instruct.git .

# Set file permissions for the cloned files
RUN chmod -R 775 /models
