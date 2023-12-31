##[
  Redis Database

  For storing which meetings were already notified about & at what interval state.


  For information on Redis commands visit the following website.

  https://redis.io/commands/
]##

import
  meta,
  model/[
    database,
    configuration
  ],
  std/[
    segfaults,
    sequtils,
    strutils,
    options,
    net
  ],
  pkg/[
    zero_functional,
    ready,
    timestamp
  ]

export DatabaseNotified
export timestamp

var
  redis:RedisConn

proc initDb*(hostRedis = hostRedis, portRedis = portRedis) =
  redis = block:
    let socket = newSocket()
    try:
      ## Check if connections exist,
      ## because we cannot catch the LibraryError,
      ## when the connection fails on `newRedisConn`.
      socket.connect(hostRedis, portRedis.Port)
    except OSError:
      raise DatabaseConnectionDefect.newException "Failed to connect to Redis database! Is your database server running?"
    finally:
      socket.close
    newRedisConn(hostRedis, portRedis.Port)

proc exec(cmd: openArray[(string, seq[string])]): RedisReply {.discardable.} =
  redis.send cmd
  for e in cmd:
    result = redis.receive

proc keyExists(key: varargs[string]): bool =
  ## https://redis.io/commands/exists/
  [("EXISTS", key.toSeq)].exec.to(int) == key.len

proc saveNotified(n: DatabaseNotified): RedisReply {.discardable.} =
  ## https://redis.io/commands/multi/
  ## https://redis.io/commands/hmset/
  ## https://redis.io/commands/exec/
  [
    ("MULTI", @[]),
    ("HMSET", @[n.keywordSignature, "timestamp", n.timestamp]),
    ("EXEC", @[])
  ].exec

proc deleteNotified(n: DatabaseNotified): RedisReply {.discardable.} =
  ## https://redis.io/commands/del/
  [
    ("MULTI", @[]),
    ("DEL", @[n.keywordSignature]),
    ("EXEC", @[])
  ].exec

proc saveZoomResponse(r: DatabaseZoomResponse): RedisReply {.discardable.} =
  ## https://redis.io/commands/multi/
  ## https://redis.io/commands/hmset/
  ## https://redis.io/commands/exec/
  [
    ("MULTI", @[]),
    ("HMSET", @[r.zoomUserID, "timestamp", r.timestamp, "meetings", r.meetings]),
    ("EXEC", @[])
  ].exec

proc deleteZoomResponse(r: DatabaseZoomResponse): RedisReply {.discardable.} =
  ## https://redis.io/commands/del/
  [
    ("MULTI", @[]),
    ("DEL", @[r.zoomUserID]),
    ("EXEC", @[])
  ].exec

proc loadZoomResponse(r: DatabaseZoomResponse): seq[string] =
  redis.command("HGETALL", r.zoomUserID).to(seq[string])

proc loadNotified(n: DatabaseNotified): seq[string] =
  redis.command("HGETALL", n.keywordSignature).to(seq[string])

proc saveNotified*(config: ConfigZoom) =
  config.createDatabaseNotified.saveNotified

proc deleteNotified*(config: ConfigZoom) =
  config.createDatabaseNotified.deleteNotified

proc saveZoomResponse*(auth: ConfigZoomAuthentication, meetingsBody: string) =
  auth.createDatabaseZoomResponse(meetingsBody.some).saveZoomResponse

proc deleteZoomResponse*(auth: ConfigZoomAuthentication, meetingsBody: string) =
  auth.createDatabaseZoomResponse(meetingsBody.some).deleteZoomResponse

proc initNotifiedIfNotExists*(config: ConfigZoom) =
  ## https://redis.io/commands/hset/
  let
    n = config.createDatabaseNotified
    key = n.keywordSignature
  if not key.keyExists:
    n.saveNotified
    [("HSET", @[key, "timestamp", rootTimestampStr])].exec

proc initZoomResponseIfNotExists*(auth: ConfigZoomAuthentication) =
  ## https://redis.io/commands/hset/
  let
    r = auth.createDatabaseZoomResponse
    key = auth.userID
  if not key.keyExists:
    r.saveZoomResponse
    [("HSET", @[key, "timestamp", rootTimestampStr])].exec

proc loadNotified*(config: ConfigZoom): DatabaseNotified =
  config.createDatabaseNotified.loadNotified.deserialiseDatabaseNotified

proc loadZoomResponse*(auth: ConfigZoomAuthentication): DatabaseZoomResponse =
  auth.createDatabaseZoomResponse.loadZoomResponse.deserialiseDatabaseZoomResponse

proc loadNotifiedTimestamp*(config: ConfigZoom): Timestamp =
  config.createDatabaseNotified.loadNotified.deserialiseDatabaseNotifiedTimestamp

proc loadZoomResponseTimestamp*(auth: ConfigZoomAuthentication): Timestamp =
  auth.createDatabaseZoomResponse.loadZoomResponse.deserialiseDatabaseZoomResponseTimestamp


when isMainModule:
  const redisTestList = [
    ("MULTI", @[]),
    ("DEL", @["test1"]),
    ("RPUSH", @["test1", "item1"]),
    ("RPUSH", @["test1", "item1"]),
    ("RPUSH", @["test1", "item1"]),
    ("EXEC", @[])
  ]

  redis.send(redisTestList)

  for e in redisTestList:
    echo redis.receive()

  echo redis.command("LRANGE", "test1", "0", "-1")

  let cfg = ConfigZoom(patternKeywordsYes: @[ConfigZoomPatternKeyword(keywords: @["yes"])].some, patternKeywordsNo: @[ConfigZoomPatternKeyword(keywords: @["no"])].some)

  saveNotified(cfg)

  echo redis.command("HGETALL", cfg.createDatabaseNotified.keywordSignature).to(seq[string])