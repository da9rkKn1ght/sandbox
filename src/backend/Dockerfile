FROM golang:alpine AS builder

WORKDIR /app

COPY src/backend/go.mod src/backend/go.sum ./
RUN go mod download

COPY src/backend/ .

RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-w -s" \
    -o app \
    ./cmd/api


FROM golang:alpine AS runtime

WORKDIR /app

COPY --from=builder /app/app ./app

EXPOSE 8081

CMD ["./app"]