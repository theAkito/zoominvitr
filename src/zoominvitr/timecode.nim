import
  std/[
    times
  ],
  pkg/[
    timestamp,
    timezones
  ]

proc formatWithTimezone*(timestamp: Timestamp, format, timeZone: string): string =
  timestamp.toDateTime.inZone(timeZone.tzInfo.timezone).format(format)

proc formatWithTimezone*(timestamp: Timestamp, timeZone: string): string =
  $timestamp.toDateTime.inZone(timeZone.tzInfo.timezone)