import
  meta,
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

let mail = newSmtp(useSsl = true, debug = meta.debug)

func fillPlaceholders(tpl: string, meeting: ZoomMeeting): string =
  tpl.multiReplace(
    ("{zoom.TOPIC}", meeting.topic),
    ("{zoom.URL}", meeting.joinUrl)
  )

proc sendMail*(ctx: ConfigContext, meeting: ZoomMeeting) =
  mail.connect(ctx.mail.mailSender.serverSMTP, ctx.mail.mailSender.portSMTP.Port)
  defer: mail.close
  if ctx.mail.mailSender.startTLS: mail.startTls()
  mail.auth(ctx.mail.mailSender.user, ctx.mail.mailSender.password)
  mail.sendMail(ctx.mail.mailSender.mail, ctx.mail.mailReceiver.mails,
    $createMessage(
      ctx.mail.mailReceiver.subjectTpl.fillPlaceholders(meeting),
      ctx.mail.mailReceiver.bodyTpl.fillPlaceholders(meeting),
      ctx.mail.mailReceiver.mails
    )
  )

proc sendMailDryRun*(ctx: ConfigContext, meeting: ZoomMeeting) =
  mail.connect(ctx.mail.mailSender.serverSMTP, ctx.mail.mailSender.portSMTP.Port)
  defer: mail.close
  if ctx.mail.mailSender.startTLS: mail.startTls()
  mail.auth(ctx.mail.mailSender.user, ctx.mail.mailSender.password)
  echo createMessage(
    ctx.mail.mailReceiver.subjectTpl.fillPlaceholders(meeting),
    ctx.mail.mailReceiver.bodyTpl.fillPlaceholders(meeting),
    ctx.mail.mailReceiver.mails
  )