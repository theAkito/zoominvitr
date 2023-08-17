FROM nimlang/nim:1.6.14-alpine AS build

ARG nimble_task_build=docker_build_prod

WORKDIR /app

COPY . .

RUN \
  apk --no-cache add \
    libcurl \
    openssl-dev && \
  rm -rf /var/cache/apk/* && \
  nimble install -dy && \
  nimble "${nimble_task_build}"

FROM alpine
COPY --from=build /app/app /
RUN apk --no-cache add libcurl && rm -rf /var/cache/apk/*
ENTRYPOINT ["/app"]
