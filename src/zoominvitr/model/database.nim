import
  ../meta,
  configuration,
  std/[
    logging
  ],
  pkg/[
    timestamp
  ]

let logger = getLogger("model/database")

type
  DatabaseDeserialisationDefect* = object
  DatabaseNotified* = object
    keywordSignature*: string ## Hash-like thing of `patternKeywordsYes` & `patternKeywordsNo`.
    timestamp*: string        ## Timestamp Library

proc createDatabaseNotified*(patternKeywordsYes, patternKeywordsNo: seq[ConfigZoomPatternKeyword]): DatabaseNotified =
  DatabaseNotified(
    keywordSignature: $patternKeywordsYes & $patternKeywordsYes, #TODO Use some smarter hash-alike.
    timestamp: initTimestamp().zulu
  )

proc createDatabaseNotified*(config: ConfigZoom): DatabaseNotified =
  DatabaseNotified(
    keywordSignature: $config.patternKeywordsYes & $config.patternKeywordsYes, #TODO Use some smarter hash-alike.
    timestamp: initTimestamp().zulu
  )

proc deserialiseDatabaseNotified*(fields: seq[string]): DatabaseNotified =
  DatabaseNotified(
    timestamp: fields[fields.find("timestamp").succ]
  )

proc deserialiseDatabaseNotifiedTimestamp*(fields: seq[string]): Timestamp =
  try:
    fields[fields.find("timestamp").succ].parseZulu
  except:
    logger.log(lvlError, "[model/database.deserialiseDatabaseNotifiedTimestamp] Unable to deserialise this Redis Query result:\p" & fields[fields.find("timestamp").succ])
    raise getCurrentException()