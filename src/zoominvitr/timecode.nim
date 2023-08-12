import
  std/[
    times
  ],
  pkg/[
    timestamp,
    timezones
  ]

proc formatWithTimezone*(timestamp: Timestamp, dateFormat, timeFormat, timeZone: string): string =
  timestamp.toDateTime.inZone(timeZone.tzInfo.timezone).format(dateFormat)