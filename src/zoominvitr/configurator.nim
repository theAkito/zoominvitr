import
  meta,
  model/[
    configuration
  ],
  std/[
    segfaults,
    strformat,
    sequtils,
    json,
    os,
    streams,
    sugar,
    logging
  ],
  pkg/[
    yaml
  ]

let logger = getLogger("configurator")

var
  config* = ConfigMaster(
    version: "appVersion",
    contexts: @[
      ConfigContext(
        dateFormat: "yyyy-MM-dd",
        timeFormat: "HH:mm",
        timeZone: "Europe/Oslo",
        zoom: ConfigZoom(
          patternKeywordsYes: @[
            ConfigZoomPatternKeyword(
              statement: OR,
              keywords: @[
                "MeetupTopicKeyword",
                "Second Keyword",
                "Juggernaut"
              ]
            )
          ],
          patternKeywordsNo: @[
            ConfigZoomPatternKeyword(
              statement: AND,
              keywords: @[
                "NotAllowedKeyword",
                "Nonsense",
                "Test"
              ]
            )
          ],
          authentication: @[
            ConfigZoomAuthentication(
              mail: "mail@example.com",
              userID: "ZoomUserID",
              accountID: "",
              clientID: "",
              clientSecret: ""
            )
          ]
        ),
        mail: ConfigPushMail(
          enable: false,
          mailSender: ConfigMailSender(
            mail: "sender@example.com",
            serverSMTP: "smtps.example.com",
            portSMTP: 465, ## 465: TLS; 587 STARTTLS
            user: "username",
            password: "password",
            startTLS: false
          ),
          mailReceiver: ConfigMailReceiver(
            subjectTpl: "Invitation to {zoom.TOPIC} on {zoom.START_DATE}",
            bodyTpl: "You are invited to {zoom.TOPIC} at {zoom.START_TIME}!\p\pPlease, join via the following link:\p\p{zoom.URL}\p\p\p\p\pThis E-Mail was automatically generated and sent. Please do not reply.",
            mails: @[
              "friend1@example.com",
              "friend2@example.com",
              "friend3@example.com",
              "friend4@example.com",
              "friend5@example.com"
            ]
          ),
          schedule: @[
            ConfigPushSchedule(
              tType: DAYS,
              amount: 7
            ),
            ConfigPushSchedule(
              tType: DAYS,
              amount: 3
            ),
            ConfigPushSchedule(
              tType: HOURS,
              amount: 1
            ),
            ConfigPushSchedule(
              tType: MINUTES,
              amount: 15
            )
          ]
        )
      )
    ]
  )

func pretty(node: JsonNode): string = node.pretty(configIndentation)

func genPathFullJSON(path, name: string): string =
  if path != "": path.normalizePathEnd() & '/' & name else: name

func genPathFull(path, name: string): string =
  if path != "": path.normalizePathEnd() & '/' & name else: name

proc getConfig*(): ConfigMaster = config

proc genDefaultConfigJSON(path = configPath, name = configNameJSON): JsonNode =
  let
    pathFull = path.genPathFull(name)
    conf = %* config
  pathFull.writeFile(conf.pretty())
  conf

proc genDefaultConfig(path = configPath, name = configNameYAML): string =
  let
    pathFull = path.genPathFull(name)
    fStream = pathFull.newFileStream fmWrite
  defer: fStream.close
  config.dump(
    fStream,
    tagStyle = tsNone,
    options = defineOptions(outputVersion = ovNone),
    handles = @[]
  )
  ""

proc initConfJSON*(path = configPath, name = configNameJSON): bool =
  let
    pathFull = path.genPathFullJSON(name)
    configAlreadyExists = pathFull.fileExists
  if configAlreadyExists:
    logger.log(lvlDebug, "Config already exists! Not generating new one.")
    config = pathFull.parseFile().to(ConfigMaster)
    return true
  try:
    genDefaultConfigJSON(path, name)
  except:
    return false
  true

proc initConf*(path = configPath, name = configNameYAML): bool =
  let
    pathFull = path.genPathFull(name)
    configAlreadyExists = pathFull.fileExists
  if configAlreadyExists:
    logger.log(lvlDebug, "Config already exists! Not generating new one.")
    var conf: ConfigMaster
    let fStream = pathFull.newFileStream fmRead
    defer: fStream.close
    fStream.load conf
    config = conf
    return true
  try:
    discard genDefaultConfig(path, name)
    logger.log(lvlWarn, &"""Generated new config file at "{pathFull}"!""")
    logger.log(lvlWarn, &"""Please, fill out the needed configuration in that file & restart the application, afterwards!""")
    quit 0
  except:
    return false
  true

proc validateConf*(): bool =
  let yesesNos = collect:
    for ctx in config.contexts:
      (ctx.zoom.patternKeywordsYes, ctx.zoom.patternKeywordsNo)
  yesesNos.any do (yesNo: (seq[ConfigZoomPatternKeyword], seq[ConfigZoomPatternKeyword])) -> bool:
    yesesNos.countIt(it[0] == yesNo[0]) == 1 and yesesNos.countIt(it[1] == yesNo[1]) == 1