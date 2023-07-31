import
  meta,
  model/[
    configuration
  ],
  std/[
    segfaults,
    sequtils,
    strutils,
    json,
    os,
    htmlparser,
    xmltree,
    # threadpool,
    tables,
    times,
    asyncdispatch,
    random,
    strformat,
    streams,
    logging
  ],
  pkg/[
    yaml
  ]

let
  logger = newConsoleLogger(defineLogLevel(), logMsgPrefix & logMsgInter & "configurator" & logMsgSuffix)
var
  config* = ConfigMaster(
    version: "appVersion",
    contexts: @[
      ConfigContext(
        authentication: ConfigAuthentication(
          mail: "mail@example.com",
          userID: "ZoomUserID"
        ),
        mailSender: ConfigMailSender(
          mail: "sender@example.com",
          serverSMTP: "smtps.example.com",
          portSMTP: 465, ## 465: TLS; 587 STARTTLS
          user: "username",
          password: "password"
        ),
        mailAddressList: ConfigMailAddressList(
          topic: "MeetupTopicKeyword",
          mails: @[
            "friend1@example.com",
            "friend2@example.com",
            "friend3@example.com",
            "friend4@example.com",
            "friend5@example.com"
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
    #anchorStyle = asNOne,
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
    genDefaultConfig(path, name)
  except:
    return false
  true