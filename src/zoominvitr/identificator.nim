import std/options
from std/sugar import collect
from model/configuration import ConfigMaster, ConfigZoomPatternKeyword
from std/strutils import join, toLowerAscii
from std/hashes import hash
from std/sequtils import mapIt, concat, map
from std/algorithm import sorted

type NoKeywordsFoundDefect* = object of Defect

template raiseNoKeywordsFoundDefect* =
  raise NoKeywordsFoundDefect.newException("No `patternKeywordsYes` and `patternKeywordsNo` found!")

func genHash*(configs: varargs[seq[ConfigZoomPatternKeyword]]): int =
  # Alphabetically sort keywords, so it does not generate a new hash,
  # simply by changing the keyword order.
  # Lower all characters, for the same reason.
  @configs.concat.mapIt(it.keywords.mapIt(it.toLowerAscii).sorted.join).mapIt(it.toLowerAscii).sorted.join.hash

proc genHash*(yesOpt, noOpt: Option[seq[ConfigZoomPatternKeyword]]): int =
  let
    yesThere = yesOpt.isSome
    noThere = noOpt.isSome
  if yesThere and noThere:
    genHash(yesOpt.get, noOpt.get)
  elif yesThere:
    genHash(yesOpt.get)
  elif noThere:
    genHash(noOpt.get)
  else:
    raiseNoKeywordsFoundDefect()

proc genHashStr*(yesOpt, noOpt: Option[seq[ConfigZoomPatternKeyword]]): string =
  $genHash(yesOpt, noOpt)

proc genHashes*(config: ConfigMaster): seq[int] =
  let yesesNos: seq[(Option[seq[ConfigZoomPatternKeyword]], Option[seq[ConfigZoomPatternKeyword]])] = collect:
    for ctx in config.contexts:
      (ctx.zoom.patternKeywordsYes, ctx.zoom.patternKeywordsNo)
  yesesNos.map do (yesNo: (Option[seq[ConfigZoomPatternKeyword]], Option[seq[ConfigZoomPatternKeyword]])) -> int:
    genHash(yesNo[0], yesNo[1])