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
    algorithm,
    segfaults,
    sequtils,
    strutils,
    json,
    os,
    htmlparser,
    xmltree,
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
    zero_functional
  ]

## https://github.com/guzba/ready