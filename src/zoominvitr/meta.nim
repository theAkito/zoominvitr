from logging import Level, ConsoleLogger, newConsoleLogger
from timestamp import initTimestamp

const
  debug             * {.booldefine.} = false
  lineEnd           * {.strdefine.}  = "\n"
  defaultDateFormat * {.strdefine.}  = "yyyy-MM-dd'T'HH:mm:ss'.'fffffffff'Z'"
  logMsgPrefix      * {.strdefine.}  = "[$levelname]:[$datetime]"
  logMsgInter       * {.strdefine.}  = " ~ "
  logMsgSuffix      * {.strdefine.}  = " -> "
  appVersion        * {.strdefine.}  = "0.1.0"
  appRevision       * {.strdefine.}  = appVersion
  appDate           * {.strdefine.}  = appVersion
  configNameJSON    * {.strdefine.}  = "zoominvitr.json"
  configNameYAML    * {.strdefine.}  = "zoominvitr.yaml"
  configPath        * {.strdefine.}  = ""
  configIndentation * {.intdefine.}  = 2
  sourcepage        * {.strdefine.}  = "https://github.com/theAkito/zoominvitr"
  homepage          * {.strdefine.}  = sourcepage
  wikipage          * {.strdefine.}  = sourcepage
  rootTimestamp     *                = initTimestamp(0)
  rootTimestampStr  *                = $rootTimestamp


template edit*(o, body: untyped): untyped =
  block:
    var it {.inject.} = `o`
    `body`
    it

func defineLogLevel*(): Level =
  if debug: lvlDebug else: lvlInfo

proc getLogger*(moduleName: string): ConsoleLogger =
  newConsoleLogger(defineLogLevel(), logMsgPrefix & logMsgInter & moduleName & logMsgSuffix)