# Compile stage
FROM golang:1.17.2-alpine AS build-env

RUN apk add --no-cache g++ git

# Build Delve
RUN go get github.com/go-delve/delve/cmd/dlv

ADD . /dockerdev

WORKDIR /dockerdev

RUN go mod tidy

# Compile the application with the optimizations turned off
# This is important for the debugger to correctly work with the binary
RUN go build -gcflags "all=-N -l" -o /server

# Final stage
FROM alpine:3.14

RUN apk add --no-cache

EXPOSE 8000 40000

WORKDIR /
COPY --from=build-env /go/bin/dlv /
COPY --from=build-env /server /

CMD ["/dlv", "--listen=:40000", "--headless=true", "--api-version=2", "--accept-multiclient", "exec", "/server"]
