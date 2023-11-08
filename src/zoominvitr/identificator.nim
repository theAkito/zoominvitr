from model/configuration import ConfigMaster, ConfigZoomPatternKeyword
from std/options import Option, get, isSome
from std/strutils import join
from std/unicode import toLower
from std/sequtils import mapIt, concat, map
from std/hashes import hash
from std/algorithm import sorted
from std/sugar import collect

type NoKeywordsFoundDefect* = object of Defect

template raiseNoKeywordsFoundDefect* =
  raise NoKeywordsFoundDefect.newException("No `patternKeywordsYes` and `patternKeywordsNo` found!")

func withPrefix(prefix: string, configs: seq[ConfigZoomPatternKeyword]): tuple[prefix: string, keywords: seq[ConfigZoomPatternKeyword]] =
  (prefix, configs)

func withPrefixYes(configs: seq[ConfigZoomPatternKeyword]): tuple[prefix: string, keywords: seq[ConfigZoomPatternKeyword]] =
  withPrefix("y", configs)

func withPrefixNo(configs: seq[ConfigZoomPatternKeyword]): tuple[prefix: string, keywords: seq[ConfigZoomPatternKeyword]] =
  withPrefix("n", configs)

func genHash(configs: varargs[tuple[prefix: string, keywords: seq[ConfigZoomPatternKeyword]]]): int =
  # Alphabetically sort keywords, so it does not generate a new hash,
  # simply by changing the keyword order.
  # Lower all characters, for the same reason.
  #
  # Differentiates between YES and NO,
  # so changing YES or NO keywords
  # will make a difference in hashes,
  # when different contexts are
  # using different YES & NO constellations,
  # while still using the same keywords themselves.
  #
  # Example:
  #   Context 1: Yes: Hello, World No: I, Hate, You
  #   Context 2: Yes: Hello No: World, I, Hate, You
  #   Both contexts must be considered different.
  @configs.mapIt(it.prefix & it.keywords.concat.mapIt(it.keywords.mapIt(it.toLower).sorted.join).mapIt(it.toLower).sorted.join).hash

proc genHash*(yesOpt, noOpt: Option[seq[ConfigZoomPatternKeyword]]): int =
  let
    yesThere = yesOpt.isSome
    noThere = noOpt.isSome
  if yesThere and noThere:
    genHash(yesOpt.get.withPrefixYes, noOpt.get.withPrefixNo)
  elif yesThere:
    genHash(yesOpt.get.withPrefixYes)
  elif noThere:
    genHash(noOpt.get.withPrefixNo)
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