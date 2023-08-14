##[
  Master Module
]##

import
  zoominvitr/[
    meta,
    configurator,
    database,
    mail
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
    sugar
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
    quit 1

  if not validateConf():
    logger.log(lvlFatal, """Configuration file may not have the same `patternKeywordsYes` or `patternKeywordsNo` in multiple contexts!""")
    quit 1

  while true:
    defer: sleep 60_000
    for ctx in config.contexts:
      defer: sleep 10000
      when meta.debug: ctx.zoom.deleteNotified
      let
        notifiedLast = block:
          ctx.zoom.initNotifiedIfNotExists
          ctx.zoom.loadNotifiedTimestamp
        preMeetingsMatchedYes = collect:
          for auth in ctx.zoom.authentication:
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
              meetings = try:
                  meetingsBody.parseJson.toZoomMeetings.toSeq
                except CatchableError:
                  logger.log(lvlError, "Failed to parse the following body:\p" & meetingsBody)
                  logger.log(lvlError, getCurrentException().getStackTrace)
                  logger.log(lvlError, getCurrentExceptionMsg())
                  continue
            meetings --> partition(
              it.topic.matchKeywords(ctx.zoom.patternKeywordsYes) and not it.topic.matchKeywords(ctx.zoom.patternKeywordsNo)
            ).yes
        meetingsMatchedYes = preMeetingsMatchedYes --> flatten()
      when meta.debug: echo "===================meetingsMatchedYes==================="
      logger.log lvlDebug, pretty %meetingsMatchedYes
      #let
        # meetingsMatchedYesSorted = meetingsMatchedYes.sorted do (x, y: ZoomMeeting) -> int:
        #   if x.startTime.parseZulu < y.startTime.parseZulu: -1 else: 1
        #meetingsMatchedYesSortedPlanned = meetingsMatchedYes.filterIt(initTimestamp() < it.startTime)

      # echo "===================meetingsMatchedYesSortedPlanned==================="
      # echo pretty %meetingsMatchedYesSortedPlanned

      # if ctx.mail.enable:
      #   # for meeting in meetingsMatchedYesSortedPlanned:
      #   for meeting in meetingsMatchedYes:
      #     ctx.sendMailDryRun(meeting)

      let
        schedulesSorted = ctx.mail.schedule.sorted do (x, y: ConfigPushSchedule) -> int:
          if x.tType.ord < y.tType.ord: -1 else: 1

      for sched in schedulesSorted:
        let now = now()
        case sched.tType:
          of ConfigPushScheduleTimeType.DAYS:
            let daysBefore = (meetingsMatchedYes[0].startTime.toDateTime - initDuration(days = sched.amount))
            if daysBefore < now:
              if daysBefore < notifiedLast.toDateTime:
                logger.log(lvlDebug, &"[ConfigPushScheduleTimeType.DAYS] Meeting at {meetingsMatchedYes[0].startTime.toDateTime} was already notified about!")
                continue
              else:
                ctx.sendMailDryRun(meetingsMatchedYes[0])
                ctx.zoom.saveNotified
            else:
              logger.log(lvlDebug, &"[ConfigPushScheduleTimeType.DAYS] Meeting at {meetingsMatchedYes[0].startTime.toDateTime} will not be notified about, yet, because the time has not yet arrived!")
          of ConfigPushScheduleTimeType.HOURS:
            let hoursBefore = (meetingsMatchedYes[0].startTime.toDateTime - initDuration(hours = sched.amount))
            if hoursBefore < now:
              if hoursBefore < notifiedLast.toDateTime:
                logger.log(lvlDebug, &"[ConfigPushScheduleTimeType.HOURS] Meeting at {meetingsMatchedYes[0].startTime.toDateTime} was already notified about!")
                continue
              else:
                ctx.sendMailDryRun(meetingsMatchedYes[0])
                ctx.zoom.saveNotified
            else:
              logger.log(lvlDebug, &"[ConfigPushScheduleTimeType.HOURS] Meeting at {meetingsMatchedYes[0].startTime.toDateTime} will not be notified about, yet, because the time has not yet arrived!")
          of ConfigPushScheduleTimeType.MINUTES:
            let minutesBefore = (meetingsMatchedYes[0].startTime.toDateTime - initDuration(minutes = sched.amount))
            if minutesBefore < now:
              if minutesBefore < notifiedLast.toDateTime:
                logger.log(lvlDebug, &"[ConfigPushScheduleTimeType.MINUTES] Meeting at {meetingsMatchedYes[0].startTime.toDateTime} was already notified about!")
                continue
              else:
                ctx.sendMailDryRun(meetingsMatchedYes[0])
                ctx.zoom.saveNotified
            else:
              logger.log(lvlDebug, &"[ConfigPushScheduleTimeType.MINUTES] Meeting at {meetingsMatchedYes[0].startTime.toDateTime} will not be notified about, yet, because the time has not yet arrived!")