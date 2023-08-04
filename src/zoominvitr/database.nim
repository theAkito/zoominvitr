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

redis.send("MULTI")
redis.send("DEL", "test1")
redis.send("RPUSH", "test1", "item1")
redis.send("RPUSH", "test1", "item2")
redis.send("RPUSH", "test1", "item3")
redis.send("EXEC")
# echo redis.receive().to(seq[string])
echo redis.receive()
echo redis.receive()
echo redis.receive()
echo redis.receive()
echo redis.receive()
echo redis.receive()#.to(seq[string])
echo redis.command("LRANGE", "test1", "0", "-1")#.to(seq[string])