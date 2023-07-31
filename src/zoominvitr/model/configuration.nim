import
  std/[
    streams
  ],
  pkg/[
    ## https://nimyaml.org/index.html
    yaml
  ]

type
  ConfigAuthentication* = object
    mail*: string   ## E-Mail address used to log into this particular Zoom account.
    userID*: string ## User ID provided by Zoom.
  ConfigMailSender* = object
    mail*: string       ## E-Mail address used to SEND invitations to sendees in the same context.
    serverSMTP*: string ## SMTP server.
    portSMTP*: int      ## SMTP Port.
    user*: string       ## Login username.
    password*: string   ## Login password.
  ConfigMailAddressList* = object
    topic*: string ## A keyword, which will be searched as a\
                   ## substring in the Meeting topics,\
                   ## to able to associate the E-Mail addresses\
                   ## from this object to the Meetings matching this keyword.
    mails*: seq[string] ## E-Mail Addresses associated with this object's Meeting topic.
  ConfigContext* = object
    authentication*: ConfigAuthentication
    mailSender*: ConfigMailSender
    mailAddressList*: ConfigMailAddressList
  ConfigMaster* = object
    version*: string
    contexts*: seq[ConfigContext]