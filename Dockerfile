FROM nimlang/nim:1.6.14-alpine AS build

WORKDIR /app

COPY . .

RUN \
  nimble install -dy && \
  nimble docker_build_prod

FROM alpine
COPY --from=build /app/app /
RUN apk --no-cache add libcurl && rm -rf /var/cache/apk/*
ENTRYPOINT ["/app"]
