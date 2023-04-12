# Dockerfile
FROM crystallang/crystal:latest
#FROM crystallang/crystal:latest-alpine

ADD . /app
WORKDIR /app

# Staticly compiled builds only work on Alpine
#RUN crystal build --release --static --no-debug ./web.cr
RUN crystal build --release --no-debug src/web.cr -o web

RUN ldd ./web | tr -s '[:blank:]' '\n' | grep '^/' | xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;'

FROM scratch
#FROM alpine:latest
#FROM busybox
COPY --from=0 /app/deps /
COPY --from=0 /app/web /web

EXPOSE 8080

ENTRYPOINT ["/web"]
