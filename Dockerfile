FROM golang:alpine as go
WORKDIR /app
COPY ./wasm .
RUN go mod tidy && GOOS=js GOARCH=wasm go build -ldflags="-w -s" -o main.wasm

FROM node:alpine as web
RUN npm install -g pnpm
WORKDIR /app
COPY package.json .
COPY package-lock.json .
RUN pnpm install
COPY . .
RUN pnpm build:ts

FROM nginx:latest
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=web /app/build .
COPY --from=go /app/main.wasm .
ENTRYPOINT ["nginx", "-g", "daemon off;"]