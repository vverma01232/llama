# Use the Ollama base image
FROM ollama/ollama:latest

# Set environment variables for Ollama
ENV OLLAMA_ORIGINS=*
ENV OLLAMA_LOAD_TIMEOUT=-1
ENV OLLAMA_KEEP_ALIVE=-1

RUN ollama serve
# Install Go
RUN apt-get update && \
    apt-get install -y golang && \
    mkdir -p /app

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the Go Modules manifests
COPY go.mod go.sum ./

# Download Go Modules dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go application
RUN go build -o main .

# Expose the port the app runs on
EXPOSE 8080

# Run the Ollama command and the Go application
CMD ["./aisvc"]
