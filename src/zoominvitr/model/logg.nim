from json import `$`, `%`
from timestamp import initTimestamp, zulu
from logging import Level

type
  LogMessage* = object
    timestamp*: string ## From initTimestamp().zulu
    level*: string     ## lvlError, etc.
    msg*: string       ## Message content.
    module*: string    ## Module name.

func toString(level: Level): string =
  case level
    of lvlNone: "none"
    of lvlFatal: "fatal"
    of lvlError: "error"
    of lvlWarn: "warn"
    of lvlNotice: "notice"
    of lvlInfo: "info"
    of lvlDebug: "debug"
    of lvlAll: "all"

when NimMajor >= 2:
  func toLevel*(level: string): Level =
    case level
      of "none": lvlNone
      of "fatal": lvlFatal
      of "error": lvlError
      of "warn": lvlWarn
      of "notice": lvlNotice
      of "info": lvlInfo
      of "debug": lvlDebug
      of "all": lvlAll
      else: lvlAll

proc createLogMessage*(level: Level, msg: string, module: string): string =
  $ %LogMessage(
    timestamp: initTimestamp().zulu,
    level: level.toString,
    msg: msg,
    module: module
  )