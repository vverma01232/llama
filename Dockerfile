# Use a more complete base image like Alpine since BusyBox has limited package support
FROM alpine:latest

# Install required dependencies (git, git-lfs, wget, python3, pip, and bash)
RUN apk add --no-cache git git-lfs bash python3 py3-pip && \
    git lfs install

# Create a virtual environment for Python packages
RUN python3 -m venv /opt/venv

# Activate the virtual environment and install Hugging Face CLI
RUN . /opt/venv/bin/activate && pip install -U "huggingface_hub[cli]"

# Ensure all future commands use the virtual environment
ENV PATH="/opt/venv/bin:$PATH"

# Create the /models directory and set appropriate permissions
RUN mkdir /models && chmod 775 /models


# Authenticate using the Hugging Face CLI
RUN huggingface-cli login --token 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 --add-to-git-credential

# Optionally skip downloading large files by setting this env variable
RUN git-lfs install

# Clone the repository after logging in
RUN git clone https://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@huggingface.co/meta-llama/Meta-Llama-3-8B-Instruct 

WORKDIR /Meta-Llama-3-8B-Instruct

COPY . /models/

# Set file permissions for the cloned files
RUN chmod -R 775 /models
