# Package

version       = "0.1.0"
author        = "Akito <the@akito.ooo>"
description   = "An awesome Nimble package."
license       = "GPL-3.0-or-later"
srcDir        = "src"
bin           = @["nimpackage"]
skipDirs      = @["helpers"]
skipFiles     = @["README.md"]
skipExt       = @["nim"]
backend       = "c"


# Dependencies

requires "nim >= 1.6.4"


# Tasks
import os, strformat, strutils

const defaultVersion = "unreleased"

let
  buildParams   = if paramCount() > 8: commandLineParams()[8..^1] else: @[]    ## Actual arguments passed to task. Previous arguments are only for internal use.
  buildVersion  = if buildParams.len > 0: buildParams[^1] else: defaultVersion ## Semver compliant App Version
  buildRevision = gorge """git log -1 --format="%H""""                         ## Build revision, i.e. Git Commit Hash
  buildDate     = gorge """date"""                                             ## Build date; Example: Sun 10 Apr 2022 01:13:09 AM CEST

task intro, "Initialize project. Run only once at first pull.":
  exec "git submodule add https://github.com/theAkito/nim-tools.git helpers || true"
  exec "git submodule update --init --recursive"
  exec "git submodule update --recursive --remote"
  exec "nimble configure"
task configure, "Configure project. Run whenever you continue contributing to this project.":
  exec "git fetch --all"
  exec "nimble check"
  exec "nimble --silent refresh"
  exec "nimble install --accept --depsOnly"
  exec "git status"
task fbuild, "Build project.":
  exec &"""nim c \
            --define:appVersion:"{buildVersion}" \
            --define:appRevision:"{buildRevision}" \
            --define:appDate:"{buildDate}" \
            --define:danger \
            --opt:speed \
            --out:nimpackage \
            src/nimpackage && \
          strip nimpackage \
            --strip-all \
            --remove-section=.comment \
            --remove-section=.note.gnu.gold-version \
            --remove-section=.note \
            --remove-section=.note.gnu.build-id \
            --remove-section=.note.ABI-tag
       """
task dbuild, "Debug Build project.":
  exec &"""nim c \
            --define:appVersion:"{buildVersion}" \
            --define:appRevision:"{buildRevision}" \
            --define:appDate:"{buildDate}" \
            --define:debug:true \
            --debuginfo:on \
            --out:nimpackage_debug \
            src/nimpackage
       """
task makecfg, "Create nim.cfg for optimized builds.":
  exec "nim tasks/cfg_optimized.nims"
task clean, "Removes nim.cfg.":
  exec "nim tasks/cfg_clean.nims"
