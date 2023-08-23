##[
  Master Module
]##

import
  zoominvitr/[
    meta,
    configurator,
    database,
    mail,
    timecode
  ],
  zoominvitr/model/[
    zoom,
    configuration
  ],
  std/[
    algorithm,
    base64,
    segfaults,
    strutils,
    sequtils,
    os,
    json,
    tables,
    times,
    strformat,
    logging,
    sugar,
    options
  ],
  pkg/[
    puppy,
    zero_functional
  ]

const
  root_url = "https://api.zoom.us/v2/"
  headerKey_authorization = "Authorization"
  headerKey_contentType = "Content-Type"
  headerVal_contentType = "application/json"
  headerKey_host = "Host"
  headerVal_host = "zoom.us"

func matchKeywords(topic: string, keywords: seq[ConfigZoomPatternKeyword]): bool =
  for words in keywords:
    let state = words.statement
    for word in words.keywords:
      if not topic.contains(word):
        if state == AND:
          return false
      elif state == OR:
        return true


when isMainModule:

  let logger = getLogger("zoominvitr")
  logger.log(lvlNotice, "appVersion: " & appVersion)
  logger.log(lvlNotice, "appRevision: " & appRevision)
  logger.log(lvlNotice, "appDate: " & appDate)

  if not initConf():
    logger.log(lvlFatal, """Failed to initialise configuration file!""")
    logger.log(lvlFatal, """Reason: """ & getCurrentExceptionMsg())
    quit 1

  if not validateConf():
    logger.log(lvlFatal, """Configuration file may not have the same `patternKeywordsYes` or `patternKeywordsNo` in multiple contexts!""")
    quit 1

  initDb(config.getSettings.hostRedis.get(hostRedis), config.getSettings.portRedis.get(portRedis))

  while true:
    for ctx in config.contexts:
      if meta.debugResetNotify or config.getSettingsDebug.resetNotify.get(false): ctx.zoom.deleteNotified
      let
        notifiedLast = block:
          ctx.zoom.initNotifiedIfNotExists
          ctx.zoom.loadNotifiedTimestamp
        preMeetingsMatchedYes = collect:
          for auth in ctx.zoom.authentication:
            let
              respondedLast = block:
                auth.initZoomResponseIfNotExists
                auth.loadZoomResponseTimestamp.toDateTime
              timeAmount = config.getSettings.zoomApiPullInterval.get(ConfigPushSchedule(amount: 24)).amount
              duration = case config.getSettings.zoomApiPullInterval.get(ConfigPushSchedule(tType: ConfigPushScheduleTimeType.DAYS)).tType:
                of ConfigPushScheduleTimeType.DAYS:
                  initDuration(days = timeAmount)
                of ConfigPushScheduleTimeType.HOURS:
                  initDuration(hours = timeAmount)
                of ConfigPushScheduleTimeType.MINUTES:
                  initDuration(minutes = timeAmount)
              dateOfHoursBeforeNow = respondedLast - duration
              databaseZoomResponseMeetings = auth.loadZoomResponse.meetings
              jMeetingsBody = if dateOfHoursBeforeNow < respondedLast and databaseZoomResponseMeetings != string.default:
                logger.log(lvlInfo, &"""Loading Zoom response for "E-Mail: {auth.mail}; User ID: {auth.userID}" from database, because last response was received at "{respondedLast.formatWithTimezone(ctx.timeZone)}"!""")
                databaseZoomResponseMeetings.parseJson
              else:
                logger.log(lvlInfo, &"""Loading Zoom response for ""E-Mail: {auth.mail}; User ID: {auth.userID}" from Zoom API, because last response was received at "{respondedLast.formatWithTimezone(ctx.timeZone)}"!""")
                let
                  userMail = auth.mail
                  mailToID = {
                    userMail: auth.userID
                  }.toTable
                  account_id = auth.accountID
                  client_id = auth.clientID
                  client_secret = auth.clientSecret
                  base_bearer_token = encode(&"""{client_id}:{client_secret}""")
                  bearer_token = "Basic " & base_bearer_token
                  access_token = post(
                    &"https://{headerVal_host}/oauth/token?grant_type=account_credentials&account_id={account_id}",
                    @[
                      (headerKey_authorization, bearer_token),
                      (headerKey_contentType, headerVal_contentType),
                      (headerKey_host, headerVal_host)
                    ].HttpHeaders
                  ).body.parseJson{"access_token"}.getStr
                  bearer_access_token = &"Bearer {access_token}"
                  urlZoomMeetings = parseUrl(&"{root_url}users/{mailToID[userMail]}/meetings").edit:
                    it.query = @[
                      (key: "type", value: "upcoming_meetings"),
                      (key: "page_size", value: "100")
                    ].QueryParams
                  meetingsBody = Request(
                    url: urlZoomMeetings,
                    headers: @[
                      (headerKey_authorization, bearer_access_token),
                      (headerKey_contentType, headerVal_contentType),
                      (headerKey_host, headerVal_host)
                    ].HttpHeaders,
                    verb: "GET"
                  ).fetch().body
                  jMeetingsBody = try:
                      meetingsBody.parseJson
                    except CatchableError:
                      logger.log(lvlError, "Failed to parse the following body:\p" & meetingsBody)
                      logger.log(lvlError, getCurrentException().getStackTrace)
                      logger.log(lvlError, getCurrentExceptionMsg())
                      continue
                if jMeetingsBody{"code"}.getInt(0) == 124:
                  logger.log(lvlError, """Authentication to Zoom API failed! Check your configuration file! Did you configure this server via its configuration file, yet?""")
                  continue
                else:
                  auth.saveZoomResponse(meetingsBody)
                jMeetingsBody
              meetings = block:
                try:
                  jMeetingsBody.toZoomMeetings.toSeq
                except CatchableError:
                  logger.log(lvlError, "Failed to parse the following body:\p" & pretty jMeetingsBody)
                  logger.log(lvlError, getCurrentException().getStackTrace)
                  logger.log(lvlError, getCurrentExceptionMsg())
                  continue
            meetings --> partition(
              it.topic.matchKeywords(ctx.zoom.patternKeywordsYes) and not it.topic.matchKeywords(ctx.zoom.patternKeywordsNo)
            ).yes
        meetingsMatchedYes = preMeetingsMatchedYes --> flatten()
        nextMeeting = if meetingsMatchedYes.len == 0:
            logger.log(lvlDebug, &"""No meetings matched. Skip!""")
            continue
          else:
            meetingsMatchedYes[meetingsMatchedYes.low]
        nextMeetingStartTimeTimestamp = nextMeeting.startTime
        nextMeetingStartTime = nextMeetingStartTimeTimestamp.toDateTime
        nextMeetingStartTimeStr = nextMeetingStartTimeTimestamp.formatWithTimezone("""yyyy-MM-dd HH:mm zzz""", ctx.timeZone)
        schedulesSorted = ctx.mail.schedule.sorted do (x, y: ConfigPushSchedule) -> int:
          if x.tType.ord < y.tType.ord: -1 else: 1

      if meta.debugTrace or config.getSettingsDebug.trace.get(false):
        logger.log lvlDebug, "===================meetingsMatchedYes==================="
        logger.log lvlDebug, pretty %meetingsMatchedYes

      if ctx.mail.enable:
        proc processSendMail(topic: string, timeType: ConfigPushScheduleTimeType, timeAmount: int, dryRun = (dryRunMail or config.getSettingsDebug.dryRunMail.get(false))) =
          let
            timeTypeStr = $timeType
            tplStrBefore = &"{timeAmount} {timeTypeStr} before the meeting"
            duration = case timeType:
              of ConfigPushScheduleTimeType.DAYS:
                initDuration(days = timeAmount)
              of ConfigPushScheduleTimeType.HOURS:
                initDuration(hours = timeAmount)
              of ConfigPushScheduleTimeType.MINUTES:
                initDuration(minutes = timeAmount)
            timeUnitsBefore = nextMeetingStartTime - duration
          if timeUnitsBefore < now():
            if timeUnitsBefore < notifiedLast.toDateTime:
              logger.log(lvlInfo, &"""Meeting "{topic}" at "{nextMeetingStartTimeStr}" for the notification at "{tplStrBefore}" was already notified about!""")
              return
            else:
              let debugEchoMail = config.getSettingsDebug.echoMail.get(false)
              if dryRun: ctx.sendMailDryRun(nextMeeting, debugEchoMail)
              else: ctx.sendMail(nextMeeting, debugEchoMail)
              ctx.zoom.saveNotified
          else:
            logger.log(lvlInfo, &"""Meeting "{topic}" at "{nextMeetingStartTimeStr}" for the notification at "{tplStrBefore}" will not be notified about, yet, because the time has not yet arrived!""")

        for sched in schedulesSorted:
          processSendMail(nextMeeting.topic, sched.tType, sched.amount)
      sleep 10000
    sleep 60_000