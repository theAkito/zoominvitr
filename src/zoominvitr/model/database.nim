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

proc createDatabaseNotified*(config: ConfigZoom): DatabaseNotified =
  DatabaseNotified(
    keywordSignature: $config.patternKeywordsYes & $config.patternKeywordsYes, #TODO Use some smarter hash-alike.
    timestamp: $initTimestamp()
  )

proc deserialiseDatabaseNotified*(fields: seq[string]): DatabaseNotified =
  DatabaseNotified(
    timestamp: fields[fields.find("timestamp").succ]
  )

proc deserialiseDatabaseNotifiedTimestamp*(fields: seq[string]): Timestamp =
  fields[fields.find("timestamp").succ].parseZulu