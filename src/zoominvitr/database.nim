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
    json,
    os,
    options,
    tables,
    asyncdispatch,
    times,
    strformat,
    strtabs,
    logging,
    random,
    sugar,
    threadpool
  ],
  pkg/[
    puppy,
    zero_functional,
    ready,
    timestamp
  ]

export DatabaseNotified
export timestamp

let
  # redis = newRedisConn("redis")
  redis = newRedisConn()

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

proc loadNotified(n: DatabaseNotified): seq[string] =
  redis.command("HGETALL", n.keywordSignature).to(seq[string])

proc saveNotified*(config: ConfigZoom) =
  config.createDatabaseNotified.saveNotified

proc deleteNotified*(config: ConfigZoom) =
  config.createDatabaseNotified.deleteNotified

proc initNotifiedIfNotExists*(config: ConfigZoom) =
  ## https://redis.io/commands/hset/
  let
    n = config.createDatabaseNotified
    key = n.keywordSignature
  if not key.keyExists:
    n.saveNotified
    [("HSET", @[key, "timestamp", rootTimestampStr])].exec

proc loadNotified*(config: ConfigZoom): DatabaseNotified =
  config.createDatabaseNotified.loadNotified.deserialiseDatabaseNotified

proc loadNotifiedTimestamp*(config: ConfigZoom): Timestamp =
  config.createDatabaseNotified.loadNotified.deserialiseDatabaseNotifiedTimestamp


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

  let cfg = ConfigZoom(patternKeywordsYes: @[ConfigZoomPatternKeyword(keywords: @["yes"])], patternKeywordsNo: @[ConfigZoomPatternKeyword(keywords: @["no"])])

  saveNotified(cfg)

  echo redis.command("HGETALL", createDatabaseNotified(cfg.patternKeywordsYes, cfg.patternKeywordsNo).keywordSignature).to(seq[string])