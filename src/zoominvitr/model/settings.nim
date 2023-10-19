import json, timestamp, logging

type
  LogMessage* = object
    timestamp*: string ## From initTimestamp().zulu
    level*: string     ## lvlError, etc.
    msg*: string       ## Message content.
    module*: string    ## Module name.

func logLevelString(level: Level): string =
  case level
    of lvlNone: "none"
    of lvlFatal: "fatal"
    of lvlError: "error"
    of lvlWarn: "warn"
    of lvlNotice: "notice"
    of lvlInfo: "info"
    of lvlDebug: "debug"
    of lvlAll: "all"

proc createLogMessage*(level: Level, msg: string, module: string): string =
  $ %LogMessage(
    timestamp: initTimestamp().zulu,
    level: level.logLevelString,
    msg: msg,
    module: module
  )