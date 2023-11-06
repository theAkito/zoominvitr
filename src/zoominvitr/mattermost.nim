##[
  Mattermost API
]##

import
  http,
  std/[
    algorithm,
    segfaults,
    sequtils,
    strutils,
    json,
    os,
    htmlparser,
    xmltree,
    tables,
    asyncdispatch,
    times,
    strformat,
    strtabs,
    logging,
    random,
    sugar,
    threadpool,
    options
  ],
  pkg/[
    puppy,
    zero_functional,
    nimdbx,
    timestamp,
    schedules,
    jester
  ]

type
  WebhookFromMattermost = object
    token: string
    teamID: string
    channelID: string
    userID: string
    text: string

  WebhookFromMattermostResponse = object
    ## https://developers.mattermost.com/integrate/slash-commands/custom/#response-parameters
    text: string
    username: string ## https://docs.mattermost.com/configure/integrations-configuration-settings.html#enable-integrations-to-override-usernames
    channel_id: string
    icon_url: string
    `type`: Option[string]
    response_type: string
    skip_slack_parsing: bool
    extra_responses: Option[JsonNode]
    props: Option[JsonNode]

proc constructRequest(bearerToken, url, verb, body: string = ""): puppy.Request {.gcsafe.} =
  puppy.Request(
    url: parseUrl(url),
    headers: @[
      Header(key: headerKeyAuth, value: bearerToken),
      Header(key: headerKeyContentType, value: headerValueContentType),
      Header(key: headerKeyAccept, value: headerValueContentType)
    ],
    verb: verb,
    body: body
  )