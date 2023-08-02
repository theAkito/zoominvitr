type
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
  ConfigPushMail* = object
    enable*: bool
    mailSender*: ConfigMailSender
    mailReceiver*: ConfigMailReceiver
  ConfigPushMattermost* = object
    enable*: bool
  ConfigZoom* = object
    authentication*: ConfigZoomAuthentication
    topic*: string ## A keyword, which will be searched as a\
                   ## substring in the Meeting topics,\
                   ## to able to associate the E-Mail addresses\
                   ## from this object to the Meetings matching this keyword.
  ConfigContext* = object
    zoom*: ConfigZoom
    mail*: ConfigPushMail
  ConfigMaster* = object
    version*: string
    contexts*: seq[ConfigContext]