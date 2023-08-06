##[
  Redis Database

  For storing which meetings were already notified about & at what interval state.
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
    ready
  ]

let
  # redis = newRedisConn("redis")
  redis = newRedisConn()

proc exec(cmd: openArray[(string, seq[string])]): RedisReply {.discardable.} =
  redis.send cmd
  for e in cmd:
    result = redis.receive

proc saveNotified(n: DatabaseNotified): RedisReply {.discardable.} =
  [
    ("MULTI", @[]),
    ("HMSET", @[n.keywordSignature, "timestamp", n.timestamp]),
    ("EXEC", @[])
  ].exec

proc loadNotified(n: DatabaseNotified): RedisReply {.discardable.} =
  [
    ("MULTI", @[]),
    ("HMSET", @[n.keywordSignature, "timestamp", n.timestamp]),
    ("EXEC", @[])
  ].exec

proc saveNotified*(config: ConfigZoom) =
  createDatabaseNotified(config.patternKeywordsYes, config.patternKeywordsNo).saveNotified

proc loadNotified*(config: ConfigZoom) =
  createDatabaseNotified(config.patternKeywordsYes, config.patternKeywordsNo).saveNotified


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

  echo redis.command("HGETALL", createDatabaseNotified(cfg.patternKeywordsYes, cfg.patternKeywordsNo).keywordSignature)