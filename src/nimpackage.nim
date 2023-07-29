##[
  Master Module
]##

when isMainModule:
  import
    nimpackage/meta,
    logging

  let logger = getLogger("nimpackage")
  logger.log(lvlNotice, "appVersion: " & appVersion)
  logger.log(lvlNotice, "appRevision: " & appRevision)
  logger.log(lvlNotice, "appDate: " & appDate)
