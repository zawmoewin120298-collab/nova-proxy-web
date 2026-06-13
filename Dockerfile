# Step 1: Build stage (ဒီအတိုင်းပဲ ထားပါ)
FROM golang:1.22-alpine AS builder
RUN apk add --no-cache git
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# ==========================================
# Step 2: Final stage (ဒါလေးကို အစားထိုးပေးပါ)
# ==========================================
FROM debian:bookworm-slim

# ca-certificates အလိုအလျောက် ပါပြီးသားဖြစ်သော်လည်း update လုပ်ရန်
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /root/

# Builder ထဲက binary ဖိုင်ကို လှမ်းယူမယ်
COPY --from=builder /app/main .

EXPOSE 8080

CMD ["./main"]
