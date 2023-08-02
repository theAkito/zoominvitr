##[
  Master Module
]##

import
  zoominvitr/[
    meta,
    configurator,
    mail
  ],
  zoominvitr/model/[
    zoom
  ],
  std/[
    base64,
    segfaults,
    sequtils,
    os,
    json,
    tables,
    strformat,
    logging
  ],
  pkg/[
    puppy,
    zero_functional,
  ]

const
  root_url = "https://api.zoom.us/v2/"
  header_authorization = "Authorization"
  headerKey_content_type = "Content-Type"
  headerVal_content_type = "application/json"
  headerKey_host = "Host"
  headerVal_host = "zoom.us"


when isMainModule:

  let logger = getLogger("zoominvitr")
  logger.log(lvlNotice, "appVersion: " & appVersion)
  logger.log(lvlNotice, "appRevision: " & appRevision)
  logger.log(lvlNotice, "appDate: " & appDate)

  if not initConf():
    logger.log(lvlFatal, """Failed to initialise configuration file!""")
    quit 1

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
      access_token = block:
        post(
          &"https://{headerVal_host}/oauth/token?grant_type=account_credentials&account_id={account_id}",
          @[
            (header_authorization, bearer_token),
            (headerKey_content_type, headerVal_content_type),
            (headerKey_host, headerVal_host)
          ].HttpHeaders
        ).body.parseJson{"access_token"}.getStr
      bearer_access_token = &"Bearer {access_token}"
      meetings = get(
        &"{root_url}users/{mailToID[userMail]}/meetings",
        @[
          (header_authorization, bearer_access_token),
          (headerKey_content_type, headerVal_content_type),
          (headerKey_host, headerVal_host)
        ].HttpHeaders
      ).body.parseJson.toZoomMeetings.toSeq

    # echo pretty get(
    #   &"{root_url}users/{mailToID[userMail]}/meetings",
    #   @[
    #     (header_authorization, bearer_access_token),
    #     (headerKey_content_type, headerVal_content_type),
    #     (headerKey_host, headerVal_host)
    #   ].HttpHeaders
    # ).body.parseJson

    # ctx.sendMailDryRun 
