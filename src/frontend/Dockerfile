FROM node:22-bookworm-slim AS builder

WORKDIR /app

COPY src/frontend/package*.json ./

RUN npm ci

COPY src/frontend/ .

RUN NODE_OPTIONS=--openssl-legacy-provider npm run build


FROM node:22-bookworm-slim AS runtime

WORKDIR /app

RUN npm install --global http-server

COPY --from=builder /app/dist ./dist

EXPOSE 8080

CMD ["http-server", "dist", "-p", "8080", "--proxy", "http://backend:8081"]