import options, pkg/yaml

## {.sparse.} --> https://nimyaml.org/api/annotations.html#sparse.t

type
  ConfigZoomFilterStatement* = enum
    OR, AND
  ConfigPushScheduleTimeType* = enum
    DAYS, HOURS, MINUTES
  ConfigZoomAuthentication* = object
    ## https://developers.zoom.us/docs/api/rest/using-zoom-apis/#client-credentials
    ## https://devforum.zoom.us/t/userid-where-to-get-it/14125
    ## https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/meetings
    ## https://developers.zoom.us/docs/integrations/oauth/#using-an-access-token
    mail*: string      ## E-Mail address used to log into this particular Zoom account.
    userID*: string    ## User ID provided by Zoom.
    accountID*: string ## User ID provided by Zoom.
    clientID*: string  ## User ID provided by Zoom.
    clientSecret*: string ## User ID provided by Zoom.
  ConfigMailSender* = object
    mail*: string       ## E-Mail address used to SEND invitations to sendees in the same context.
    serverSMTP*: string ## SMTP server.
    portSMTP*: int      ## SMTP Port.
    user*: string       ## Login username.
    password*: string   ## Login password.
    startTLS*: bool     ## Whether to use STARTTLS.
  ConfigMailReceiver* = object
    mails*: seq[string] ## E-Mail Addresses associated with this object's Meeting topic.
    subjectTpl*: string ## E-Mail Subject with placeholders.
    bodyTpl*: string    ## E-Mail body with placeholders.\
                        ## {zoom.URL} will be replaced with the Zoom URL.\
                        ## {zoom.TOPIC} will be replaced with the FOUND Meeting topic, according to how it is saved in Zoom.
  ConfigPushSchedule* = object
    tType*: ConfigPushScheduleTimeType ## Whether the amount applies to days, hours or minutes.
    amount*: int        ## How many days|hours|minutes before the Meeting, recipients should get a notification.
  ConfigPushMail* = object
    enable*: bool
    mailSender*: ConfigMailSender
    mailReceiver*: ConfigMailReceiver
    schedule*: seq[ConfigPushSchedule]
  ConfigPushMattermost* = object
    enable*: bool
  ConfigZoomPatternKeyword* = object
    statement*: ConfigZoomFilterStatement ## If `OR`, any of the keywords should match. Not all have to match.\
                                          ## If `AND`, all keywords must match. If only one does not match, the match fails.
    keywords*: seq[string] ## Keywords, which will be searched as a\
                           ## substring in the Meeting topics,\
                           ## to able to associate the E-Mail addresses\
                           ## from this object to the Meetings matching these keywords.
  ConfigZoom* {.sparse.} = object
    authentication*: seq[ConfigZoomAuthentication]
    patternKeywordsYes*: Option[seq[ConfigZoomPatternKeyword]] ## Gets Meetings, which match what is in here.
    patternKeywordsNo*: Option[seq[ConfigZoomPatternKeyword]]  ## Ignores Meetings, which match what is in here.
  ConfigContext* = object
    dateFormat*: string
    timeFormat*: string
    timeZone*: string
    zoom*: ConfigZoom
    mail*: ConfigPushMail
  ConfigDebug* {.sparse.} = object
    echoMail*: Option[bool]
    resetNotify*: Option[bool]
    trace*: Option[bool]
    dryRunMail*: Option[bool]
  ConfigSettings* {.sparse.} = object
    debug*: Option[ConfigDebug]
    zoomApiPullInterval*: Option[ConfigPushSchedule]
    hostRedis*: Option[string]
    portRedis*: Option[int]
    log*: Option[bool]
  ConfigMaster* {.sparse.} = object
    version*: string
    settings*: Option[ConfigSettings]
    contexts*: seq[ConfigContext]


proc getSettings*(config: ConfigMaster): ConfigSettings =
  config.settings.get(ConfigSettings())

proc getSettingsDebug*(config: ConfigMaster): ConfigDebug =
  config.getSettings.debug.get(ConfigDebug())