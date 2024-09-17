# Second stage: Use Ollama base image
FROM ollama/ollama:latest

# Set environment variables for Ollama
ENV OLLAMA_ORIGINS=*
ENV OLLAMA_LOAD_TIMEOUT=-1
ENV OLLAMA_KEEP_ALIVE=-1

# First stage: Build the Go application
FROM registry.opensuse.org/opensuse/bci/golang:latest as builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the Go Modules manifests
COPY go.mod go.sum ./

# Download Go Modules dependencies
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go application
RUN go build -o aisvc .

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the Go binary from the previous stage
COPY --from=builder /app/aisvc .

# Expose the port the app runs on
EXPOSE 8080

# Run the Ollama command and the Go application
CMD ["/bin/sh", "-c", "ollama serve & ./aisvc"]
