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
RUN CGO_ENABLED=0 GOOS=linux go build -o aisvc .

# Final stage: Prepare the runtime environment
# FROM cgr.dev/chainguard/glibc-dynamic:latest-dev

# Set environment variables for Ollama
ENV OLLAMA_ORIGINS=*
ENV OLLAMA_LOAD_TIMEOUT=-1
ENV OLLAMA_KEEP_ALIVE=-1

# Install Ollama
RUN curl -sSfL https://ollama.com/install.sh | sh

# Copy the Go binary from the builder stage
COPY --from=builder /app/aisvc /usr/local/bin/aisvc

# Copy Ollama configuration and binaries if needed (uncomment if used)
# COPY --from=builder /root/.ollama /root/.ollama
COPY --from=builder /usr/local/bin/ollama /usr/local/bin/ollama

# Expose the port the app runs on
EXPOSE 8080

# Set the command to run the Go application and Ollama server
CMD ["aisvc"]
