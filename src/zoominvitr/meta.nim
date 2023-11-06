from logging import Level, ConsoleLogger, newConsoleLogger, RollingFileLogger, newRollingFileLogger
from timestamp import initTimestamp, `$`

when NimMajor >= 2:
  from std/os import DirSep
  from std/paths import `/`, Path
  from std/files import fileExists
else:
  from std/os import DirSep, `/`, existsFile

const
  debug             * {.booldefine.} = false
  debugMail         * {.booldefine.} = false ## Whether debug messages should be echoed during SMTP connections.
  debugResetNotify  * {.booldefine.} = false ## Whether `notifiedLast` should be reset on each loop iteration. Useful for repeatedly pretending, no notification was ever sent.
  debugTrace        * {.booldefine.} = false ## Whether trace level HTML & JSON responses should be shown at each step of the process.
  dryRunMail        * {.booldefine.} = false ## Whether mail sending should be done in dry run mode, i.e. no mail is ever sent.
  lineEnd           * {.strdefine.}  = "\p"
  defaultDateFormat * {.strdefine.}  = "yyyy-MM-dd'T'HH:mm:ss'.'fffffffff'Z'"
  logMsgPrefix      * {.strdefine.}  = "[$levelname]:[$datetime]"
  logMsgInter       * {.strdefine.}  = " ~ "
  logMsgSuffix      * {.strdefine.}  = " -> "
  hostRedis         * {.strdefine.}  = "redis"
  portRedis         * {.intdefine.}  = 6379
  appVersion        * {.strdefine.}  = "0.3.1"
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

proc getFileLogger*(moduleName: string): RollingFileLogger =
  when NimMajor >= 2:
    let filename = DirSep & cast[string](DirSep & string("logs".Path / moduleName.Path)) & ".log"
    if not filename.Path.fileExists: filename.writeFile("")
    newRollingFileLogger(filename, mode = fmReadWriteExisting, levelThreshold = defineLogLevel(), fmtStr = "", maxLines = 1000, flushThreshold = lvlAll)
  else:
    let filename = DirSep & "logs" / moduleName & ".log"
    if not filename.existsFile: filename.writeFile("")
    newRollingFileLogger(filename, mode = fmReadWriteExisting, levelThreshold = defineLogLevel(), fmtStr = "", maxLines = 1000)