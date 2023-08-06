import
  configuration,
  pkg/[
    timestamp
  ]

type
  DatabaseNotified* = object
    keywordSignature*: string ## Hash-like thing of `patternKeywordsYes` & `patternKeywordsNo`.
    timestamp*: string        ## Timestamp Library

proc createDatabaseNotified*(patternKeywordsYes, patternKeywordsNo: seq[ConfigZoomPatternKeyword]): DatabaseNotified =
  DatabaseNotified(
    keywordSignature: $patternKeywordsYes & $patternKeywordsYes, #TODO Use some smarter hash-alike.
    timestamp: $initTimestamp()
  )