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
    base64,
    segfaults,
    strutils,
    sequtils,
    os,
    json,
    tables,
    times,
    strformat,
    logging
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
    sleep 60_000
    for ctx in config.contexts:
      defer: sleep 10000
      let
        userMail = ctx.zoom.authentication.mail
        mailToID = {
          userMail: ctx.zoom.authentication.userID
        }.toTable
        account_id = ctx.zoom.authentication.accountID
        client_id = ctx.zoom.authentication.clientID
        client_secret = ctx.zoom.authentication.clientSecret
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
        meetings = get(
          &"{root_url}users/{mailToID[userMail]}/meetings",
          @[
            (headerKey_authorization, bearer_access_token),
            (headerKey_contentType, headerVal_contentType),
            (headerKey_host, headerVal_host)
          ].HttpHeaders
        ).body.parseJson.toZoomMeetings.toSeq
        meetingsMatched = meetings --> partition(
          it.topic.matchKeywords(ctx.zoom.patternKeywordsYes) and not it.topic.matchKeywords(ctx.zoom.patternKeywordsNo)
        )
        notifiedLast = ctx.zoom.loadNotified.timestamp.parseZulu

      if ctx.mail.enable:
        for meeting in meetingsMatched.yes:
          ctx.sendMailDryRun(meeting)
