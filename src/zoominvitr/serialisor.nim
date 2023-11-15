import
  meta,
  std/[
    streams
  ],
  pkg/[
    yaml
  ]

from model/configuration import ConfigMaster

export Dumper

func defaultDumper*: Dumper =
  var dumper = Dumper()
  # https://github.com/flyx/NimYAML/blob/854d33378e2b31ada7e54716439a4d6990460268/yaml/presenter.nim#L69-L80
  dumper.edit: ## https://github.com/flyx/NimYAML/issues/140
    it.presentation.containers = cBlock
    it.presentation.outputVersion = ovNone
    it.presentation.newlines = nlLF
    it.presentation.indentationStep = 2
    # it.presentation.condenseFlow = false
    it.presentation.suppressAttrs = true
    it.presentation.directivesEnd = deNever
    it.presentation.quoting = sqUnset
    it.serialization.tagStyle = tsNone
    it.serialization.handles = @[]

proc dump*(dumper: Dumper, fStream: Stream, obj: ConfigMaster) =
  dumper.dump(obj, fStream)

proc load*(input: Stream, target: var ConfigMaster) =
  yaml.load(input, target)