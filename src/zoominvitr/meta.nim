from logging import Level, ConsoleLogger, newConsoleLogger
from timestamp import initTimestamp, `$`

const
  debug             * {.booldefine.} = false
  debugMail         * {.booldefine.} = false ## Whether debug messages should be echoed during SMTP connections.
  dryRunMail        * {.booldefine.} = false ## Whether mail sending should be done in dry run mode, i.e. no mail is ever sent.
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
  rootTimestamp     *                = initTimestamp(2001, 11, 22) ## Zero raises a parsing exception, so a random later date is used.
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