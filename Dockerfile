# Step 1: Build stage
FROM golang:1.22-alpine AS builder
RUN apk add --no-cache git
WORKDIR /app

# Source code အားလုံးကို အရင် copy ကူးယူခြင်း
COPY . .

# dependency တွေကို တစ်ခါတည်း download ဆွဲပြီး build လုပ်ခြင်း
RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Step 2: Final stage (Debian-slim ကို သုံးပြီး တည်ငြိမ်အောင်လုပ်ခြင်း)
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /root/
COPY --from=builder /app/main .

EXPOSE 8080
CMD ["./main"]
