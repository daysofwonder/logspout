FROM golang:1.12 AS build

ENV GO111MODULE=on
WORKDIR /go/src/github.com/gliderlabs/logspout/

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .

RUN \
  GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -a -installsuffix nocgo -o /bin/logspout -ldflags "-X main.Version=$1"

FROM alpine:3.11

RUN apk --update upgrade \
  && apk add curl ca-certificates \
  && update-ca-certificates \
  && rm -rf /var/cache/apk/*

COPY --from=build /bin/logspout /bin/logspout

ENTRYPOINT ["/bin/logspout"]
VOLUME /mnt/routes
EXPOSE 80

