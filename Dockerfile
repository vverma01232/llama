# First stage: Build the Go application
FROM registry.opensuse.org/opensuse/bci/golang:latest as builder

RUN curl -sSfL https://ollama.com/install.sh | sh 

ENV OLLAMA_ORIGINS=*
ENV OLLAMA_LOAD_TIMEOUT=-1
ENV OLLAMA_KEEP_ALIVE=-1

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

FROM cgr.dev/chainguard/glibc-dynamic:latest-dev

# Copy the Go binary from the previous stage
COPY --from=builder /app/aisvc .
# COPY --from=builder /usr/local/.ollama /root/.ollama
COPY --from=builder /usr/local/bin/ollama /usr/local/bin/ollama

# Expose the port the app runs on
EXPOSE 8080

CMD ["./aisvc"]
