import
  configuration,
  ../[
    logg,
    identificator
  ],
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
    keywordSignature*: string ## Hash of keywords containing in `patternKeywordsYes` & `patternKeywordsNo` by https://nim-lang.org/docs/hashes.html#hash%2Cstring.
    timestamp*: string        ## Timestamp Library
  DatabaseZoomResponse* = object
    zoomUserID*: string       ## `ctx.zoom.authentication.userID`
    timestamp*: string        ## Timestamp Library
    meetings*: string         ## Original Zoom Response Body, as if we just got it from the Zoom API.

func findValue(fields: openArray[string], key: string): string =
  fields[fields.find(key).succ]

func findValueTimestamp(fields: openArray[string]): string =
  fields[fields.find("timestamp").succ]

proc createDatabaseNotified*(config: ConfigZoom): DatabaseNotified =
  DatabaseNotified(
    keywordSignature: genHashStr(config.patternKeywordsYes, config.patternKeywordsNo),
    timestamp: initTimestamp().zulu
  )

proc createDatabaseZoomResponse*(auth: ConfigZoomAuthentication, meetingsBody: Option[string] = string.none): DatabaseZoomResponse =
  DatabaseZoomResponse(
    zoomUserID: auth.userID,
    timestamp: initTimestamp().zulu,
    meetings: meetingsBody.get(string.default)
  )

func deserialiseDatabaseNotified*(fields: seq[string]): DatabaseNotified =
  DatabaseNotified(
    timestamp: fields.findValueTimestamp
  )

func deserialiseDatabaseZoomResponse*(fields: seq[string]): DatabaseZoomResponse =
  DatabaseZoomResponse(
    timestamp: fields.findValueTimestamp,
    meetings: fields.findValue("meetings")
  )

proc deserialiseDatabaseNotifiedTimestamp*(fields: seq[string]): Timestamp =
  try:
    fields.findValueTimestamp.parseZulu
  except:
    logger.log(lvlError, "[model/database.deserialiseDatabaseZoomResponseTimestamp] Unable to deserialise this Redis Query result:\p" & fields.findValueTimestamp)
    raise getCurrentException()

proc deserialiseDatabaseZoomResponseTimestamp*(fields: seq[string]): Timestamp =
  try:
    fields.findValueTimestamp.parseZulu
  except:
    logger.log(lvlError, "[model/database.deserialiseDatabaseZoomResponseTimestamp] Unable to deserialise this Redis Query result:\p" & fields.findValueTimestamp)
    raise getCurrentException()