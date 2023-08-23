import
  ../meta,
  configuration,
  std/[
    logging,
    options
  ],
  pkg/[
    timestamp
  ]

let logger = getLogger("model/database")

type
  DatabaseConnectionDefect* = object of Defect
  DatabaseNotified* = object
    keywordSignature*: string ## Hash-like thing of `patternKeywordsYes` & `patternKeywordsNo`.
    timestamp*: string        ## Timestamp Library
  DatabaseZoomResponse* = object
    zoomUserID*: string       ## `ctx.zoom.authentication.userID`
    timestamp*: string        ## Timestamp Library
    meetings*: string         ## Original Zoom Response Body, as if we just got it from the Zoom API.

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

proc createDatabaseZoomResponse*(auth: ConfigZoomAuthentication, meetingsBody: Option[string] = string.none): DatabaseZoomResponse =
  DatabaseZoomResponse(
    zoomUserID: auth.userID,
    timestamp: initTimestamp().zulu,
    meetings: meetingsBody.get(string.default)
  )

proc deserialiseDatabaseNotified*(fields: seq[string]): DatabaseNotified =
  DatabaseNotified(
    timestamp: fields[fields.find("timestamp").succ]
  )

proc deserialiseDatabaseZoomResponse*(fields: seq[string]): DatabaseZoomResponse =
  DatabaseZoomResponse(
    timestamp: fields[fields.find("timestamp").succ],
    meetings: fields[fields.find("meetings").succ]
  )

proc deserialiseDatabaseNotifiedTimestamp*(fields: seq[string]): Timestamp =
  try:
    fields[fields.find("timestamp").succ].parseZulu
  except:
    logger.log(lvlError, "[model/database.deserialiseDatabaseZoomResponseTimestamp] Unable to deserialise this Redis Query result:\p" & fields[fields.find("timestamp").succ])
    raise getCurrentException()

proc deserialiseDatabaseZoomResponseTimestamp*(fields: seq[string]): Timestamp =
  try:
    fields[fields.find("timestamp").succ].parseZulu
  except:
    logger.log(lvlError, "[model/database.deserialiseDatabaseZoomResponseTimestamp] Unable to deserialise this Redis Query result:\p" & fields[fields.find("timestamp").succ])
    raise getCurrentException()