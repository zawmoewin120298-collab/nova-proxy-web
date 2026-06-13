# Step 1: Build stage
FROM golang:1.22-alpine AS builder

# Build လုပ်ရာတွင် လိုအပ်သော git ကဲ့သို့ tool များ ထည့်သွင်းခြင်း
RUN apk add --no-cache git

WORKDIR /app

# Go modules configuration ဖိုင်များကို အရင် copy ကူးယူခြင်း (Cache ရစေရန်)
COPY go.mod go.sum ./
RUN go mod download

# Source code အားလုံးကို copy ကူးခြင်း
COPY . .

# Static binary အဖြစ် build လုပ်ခြင်း
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Step 2: Final lightweight image stage
FROM alpine:latest

RUN apk add --no-cache ca-certificates

WORKDIR /root/

# Builder stage မှ ထွက်လာသော binary ဖိုင်ကိုသာ သန့်သန့်ရှင်းရှင်း copy ကူးယူခြင်း
COPY --from=builder /app/main .

# Railway အတွက် Port ဖွင့်ပေးခြင်း (သင့် app က သုံးမည့် port ပြောင်းပေးပါ)
EXPOSE 8080

# Application ကို Run ရန်
CMD ["./main"]
