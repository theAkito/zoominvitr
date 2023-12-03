from meta import debug, appName
from logging import Level, ConsoleLogger, newConsoleLogger, RollingFileLogger, newRollingFileLogger

when NimMajor >= 2:
  from std/os import createDir
  from std/paths import `/`, Path
  from std/files import fileExists
  from model/logg import toLevel
else:
  from std/os import `/`, fileExists, createDir


const
  logMsgPrefix* {.strdefine.}  = "[$levelname]:[$datetime]"
  logMsgInter * {.strdefine.}  = " ~ "
  logMsgSuffix* {.strdefine.}  = " -> "
  logDirPath  * {.strdefine.}  = "logs"

when NimMajor >= 2:
  const logLevelFlush* {.strdefine.}  = "all"

func defineLogLevel(): Level =
  if debug: lvlDebug else: lvlInfo

proc getLogger*(moduleName: string): ConsoleLogger =
  when NimMajor >= 2:
    newConsoleLogger(defineLogLevel(), logMsgPrefix & logMsgInter & moduleName & logMsgSuffix, flushThreshold = logLevelFlush.toLevel)
  else:
    newConsoleLogger(defineLogLevel(), logMsgPrefix & logMsgInter & moduleName & logMsgSuffix)

proc getFileLogger*(moduleName: string = appName): RollingFileLogger =
  when NimMajor >= 2:
    let logFilePath = string(logDirPath.Path / moduleName.Path) & ".log"
    if not logFilePath.Path.fileExists:
      logDirPath.createDir
      logFilePath.writeFile("")
    newRollingFileLogger(logFilePath, mode = fmReadWriteExisting, levelThreshold = defineLogLevel(), fmtStr = "", maxLines = 1000, flushThreshold = logLevelFlush.toLevel)
  else:
    let logFilePath = logDirPath / moduleName & ".log"
    if not logFilePath.fileExists:
      logDirPath.createDir
      logFilePath.writeFile("")
    newRollingFileLogger(logFilePath, mode = fmReadWriteExisting, levelThreshold = defineLogLevel(), fmtStr = "", maxLines = 1000)