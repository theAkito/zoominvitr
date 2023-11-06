import
  meta,
  timecode,
  model/[
    configuration,
    zoom
  ],
  std/[
    segfaults,
    strutils
  ],
  pkg/[
    smtp
  ]

proc fillPlaceholders(tpl: string, meeting: ZoomMeeting, dateFormat, timeFormat, timeZone: string): string =
  tpl.multiReplace(
    ("{zoom.TOPIC}", meeting.topic),
    ("{zoom.URL}", meeting.joinUrl),
    ("{zoom.START_DATE}", meeting.startTime.formatWithTimezone(dateFormat, timeZone)),
    ("{zoom.START_TIME}", meeting.startTime.formatWithTimezone(timeFormat, timeZone))
  )

proc sendMail*(ctx: ConfigContext, meeting: ZoomMeeting, debugEchoMail = meta.debugMail) =
  let mail = newSmtp(useSsl = true, debug = debugEchoMail)
  defer: mail.close
  mail.connect(ctx.mail.mailSender.serverSMTP, ctx.mail.mailSender.portSMTP.Port)
  if ctx.mail.mailSender.startTLS: mail.startTls()
  mail.auth(ctx.mail.mailSender.user, ctx.mail.mailSender.password)
  for recv in ctx.mail.mailReceiver.mails:
    mail.sendMail(ctx.mail.mailSender.mail, @[recv],
      $createMessage(
        ctx.mail.mailReceiver.subjectTpl.fillPlaceholders(meeting, ctx.dateFormat, ctx.timeFormat, ctx.timeZone),
        ctx.mail.mailReceiver.bodyTpl.fillPlaceholders(meeting, ctx.dateFormat, ctx.timeFormat, ctx.timeZone),
        @[recv],
        @[],
        [("FROM", ctx.mail.mailReceiver.headerFrom)]
      )
    )

proc sendMailDryRun*(ctx: ConfigContext, meeting: ZoomMeeting, debugEchoMail = meta.debugMail) =
  let mail = newSmtp(useSsl = true, debug = debugEchoMail)
  defer: mail.close
  mail.connect(ctx.mail.mailSender.serverSMTP, ctx.mail.mailSender.portSMTP.Port)
  if ctx.mail.mailSender.startTLS: mail.startTls()
  mail.auth(ctx.mail.mailSender.user, ctx.mail.mailSender.password)
  echo createMessage(
    ctx.mail.mailReceiver.subjectTpl.fillPlaceholders(meeting, ctx.dateFormat, ctx.timeFormat, ctx.timeZone),
    ctx.mail.mailReceiver.bodyTpl.fillPlaceholders(meeting, ctx.dateFormat, ctx.timeFormat, ctx.timeZone),
    ctx.mail.mailReceiver.mails
  )