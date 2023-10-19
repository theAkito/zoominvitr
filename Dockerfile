FROM nimlang/nim:1.6.14-alpine AS build

ARG nimble_task_build=docker_build_prod
ARG app_version=0.2.0

WORKDIR /app

COPY . .

RUN \
  nimble install --depsOnly --accept --verbose && \
  nimble "${nimble_task_build}" "${app_version}"


FROM alpine:3.18.4

COPY --from=build /app/app /

RUN \
  apk --no-cache add libcurl && \
  rm -fr /var/cache/apk/* && \
  mkdir -p /logs && \
  chmod -cvR 777 /logs

ENTRYPOINT ["/app"]
