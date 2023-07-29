import
  std/[
    streams
  ],
  pkg/[
    ## https://nimyaml.org/index.html
    yaml
  ]

type
  ConfigMailAddressList* = object
    topic*: string ## A keyword, which will be searched as a\
                   ## substring in the Meeting topics,\
                   ## to able to associate the E-Mail addresses\
                   ## from this object to the Meetings matching this keyword.
    mails*: seq[string] ## E-Mail Addresses associated with this object's Meeting topic.
  ConfigMaster* = object
    version*: int
    mailAddressList*: ConfigMailAddressList