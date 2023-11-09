import
  meta,
  identificator,
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
    options
  ],
  pkg/[
    yaml
  ]

import std/logging except debug ## https://github.com/flyx/NimYAML/issues/136#issuecomment-1693576125

from unicode import validateUtf8

type
  NoNotificationTargetEnabledDefect = object of Defect
  KeywordsNotUTF8Defect = object of Defect

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
          ].some,
          patternKeywordsNo: @[
            ConfigZoomPatternKeyword(
              statement: AND,
              keywords: @[
                "NotAllowedKeyword",
                "Nonsense",
                "Test"
              ]
            )
          ].some,
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
            headerFrom: "Zoomer <zoomer@zoom.cf>",
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

proc getConfig*: ConfigMaster = config

proc genDefaultConfigJSON(path = configPath, name = configNameJSON): JsonNode =
  let
    pathFull = path.genPathFull(name)
    conf = %* config
  pathFull.writeFile(conf.pretty())
  conf

proc genDefaultConfig(path = configPath, name = configNameYAML) =
  let
    pathFull = path.genPathFull(name)
    fStream = pathFull.newFileStream fmWrite
  defer: fStream.close
  if fStream == nil:
    logger.log(lvlFatal, pathFull)
    raise NilAccessDefect.newException "Trying to generate default configuration not possible, because destination is nil!"
  var dumper = Dumper()
  # https://github.com/flyx/NimYAML/blob/854d33378e2b31ada7e54716439a4d6990460268/yaml/presenter.nim#L69-L80
  discard dumper.edit: ## https://github.com/flyx/NimYAML/issues/140
    it.presentation.containers = cBlock
    it.presentation.outputVersion = ovNone
    it.presentation.newlines = nlLF
    it.presentation.indentationStep = 2
    # it.presentation.condenseFlow = false
    it.presentation.suppressAttrs = true
    it.presentation.directivesEnd = deNever
    it.presentation.quoting = sqUnset
    it.serialization.tagStyle = tsNone
    it.serialization.handles = @[]
    it.dump(config, fStream)

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
    let fStream = pathFull.newFileStream fmRead
    defer: fStream.close
    fStream.load config
    return true
  try:
    genDefaultConfig(path, name)
    logger.log(lvlWarn, &"""Generated new config file at "{pathFull}"!""")
    logger.log(lvlWarn, &"""Please, fill out the needed configuration in that file & restart the application, afterwards!""")
    quit 0
  except:
    return false
  true

proc validateConf*: bool =
  ## Validate, if a parsed configuration file has valid data in it.
  ## Supposed to run only once at application start or
  ## whenver a new configuration file is read & parsed.
  if not config.contexts.anyIt(it.mail.enable):
    raise NoNotificationTargetEnabledDefect.newException """No notification target enabled! You must at least enable a notification target, like, for example, E-Mail!"""
  if not config.contexts.allIt((if it.zoom.patternKeywordsYes.isSome: it.zoom.patternKeywordsYes.get.allIt(it.keywords.allIt(it.validateUtf8 == -1)) else: true) and (if it.zoom.patternKeywordsNo.isSome: it.zoom.patternKeywordsNo.get.allIt(it.keywords.allIt(it.validateUtf8 == -1)) else: true)):
    raise KeywordsNotUTF8Defect.newException """There is at least one word in `patternKeywordsYes` or `patternKeywordsNo`, which is not valid UTF-8 data! Please, only use valid UTF-8 strings."""
  let hashes = genHashes(config)
  hashes.allIt(hashes.count(it) == 1)