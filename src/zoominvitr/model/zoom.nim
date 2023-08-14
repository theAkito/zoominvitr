import ../meta, json, options, timestamp

type
  ExceptionAuthenticationFailed* = object of ValueError ## When authentication to Zoom failed. First error that appears, when configuration file has not been edited, yet.
  ExceptionNoMeetingFound* = object of ValueError ## When invalid JSON is provided, no meeting are found.
  RawZoomMeeting = object ## 1:1 representation of raw JSON
    uuid: string
    id: int
    host_id: string
    topic: string
    `type`: int
    start_time: Option[string]
    duration: int
    timezone: string
    created_at: string
    join_url: string
  ZoomMeeting* = object ## Object we actually wanna deal with inside Nim.
    uuid*: string
    id*: int
    hostID*: string
    topic*: string
    mType*: int
    startTime*: Timestamp
    duration*: int
    timezone*: string
    createdAt*: string
    joinUrl*: string

iterator toZoomMeetings*(payload: JsonNode): ZoomMeeting {.gcsafe, raises: [ExceptionNoMeetingFound, KeyError, ValueError].} =
  ## Takes entire response payload from Zoom API's
  ## `https://api.zoom.us/v2/users/<accountId>/meetings`
  let rawMeetings = if payload.hasKey("meetings"): payload["meetings"].getElems else: raise ExceptionNoMeetingFound.newException("No meetings were found in the provided JSON!")
  for jMeeting in rawMeetings:
    let raw = jMeeting.to(RawZoomMeeting)
    yield ZoomMeeting(
      uuid: raw.uuid,
      id: raw.id,
      hostID: raw.host_id,
      topic: raw.topic,
      mType: raw.`type`,
      startTime: try: raw.start_time.get.parseZulu except UnpackDefect, TimestampOutOfRangeError, TimestampInvalidFormatError: rootTimestamp,
      duration: raw.duration,
      timezone: raw.timezone,
      createdAt: raw.created_at,
      joinUrl: raw.join_url
    )