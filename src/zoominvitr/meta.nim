from timestamp import initTimestamp, `$`

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
  appName           * {.strdefine.}  = "zoominvitr"
  appVersion        * {.strdefine.}  = "0.5.1"
  appRevision       * {.strdefine.}  = appVersion
  appDate           * {.strdefine.}  = appVersion
  configNameJSON    * {.strdefine.}  = appName & ".json"
  configNameYAML    * {.strdefine.}  = appName & ".yaml"
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