##[
  Redis Database

  For storing which meetings were already notified about & at what interval state.
]##

import
  meta,
  model/[
    database
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
  redisTestList = [
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