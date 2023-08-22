# Package

version       = "0.1.0"
author        = "Akito <the@akito.ooo>"
description   = "Automatically send invitations to planned Zoom meetings."
license       = "GPL-3.0-or-later"
srcDir        = "src"
bin           = @["zoominvitr"]
skipDirs      = @["helpers"]
skipFiles     = @["README.md"]
skipExt       = @["nim"]
backend       = "c"


# Dependencies

requires "nim             >= 1.6.14"
requires "smtp#8013aa199dedd04905d46acf3484a232378de518" ## https://github.com/nim-lang/smtp/issues/9
requires "schedules       >= 0.2.0"
requires "puppy           >= 1.0.3"
requires "ready           >= 0.1.4" # https://github.com/guzba/ready
requires "timestamp       >= 0.4.2"
requires "timezones       >= 0.5.4"
requires "zero_functional >= 1.3.0"
requires "yaml#189844a72b90ba7ade864f997280809efcb21d0a"


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
            --define:hostRedis:127.0.0.1 \
            --define:configPath:"" \
            --define:danger \
            --opt:speed \
            --out:zoominvitr \
            src/zoominvitr && \
          strip zoominvitr \
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
            --define:dryRunMail:true \
            --define:debugResetNotify:true \
            --define:hostRedis:127.0.0.1 \
            --define:configPath:"" \
            --debuginfo:on \
            --out:zoominvitr_debug \
            src/zoominvitr
       """
task docker_build_prod, "Build Production Docker.":
  exec &"""nim c \
            --define:appVersion:"{buildVersion}" \
            --define:appRevision:"{buildRevision}" \
            --define:appDate:"{buildDate}" \
            --define:hostRedis:redis \
            --define:configPath:/data \
            --define:danger \
            --opt:speed \
            --out:app \
            src/zoominvitr && \
          strip app \
            --strip-all \
            --remove-section=.comment \
            --remove-section=.note.gnu.gold-version \
            --remove-section=.note \
            --remove-section=.note.gnu.build-id \
            --remove-section=.note.ABI-tag
       """
task docker_build_debug, "Build Debug Docker.":
  exec &"""nim c \
            --define:appVersion:"{buildVersion}" \
            --define:appRevision:"{buildRevision}" \
            --define:appDate:"{buildDate}" \
            --define:debug:true \
            --define:dryRunMail:true \
            --define:debugResetNotify:true \
            --define:hostRedis:redis \
            --define:configPath:/data \
            --debuginfo:on \
            --out:app \
            src/zoominvitr
       """
task makecfg, "Create nim.cfg for optimized builds.":
  exec "nim tasks/cfg_optimized.nims"
task clean, "Removes nim.cfg.":
  exec "nim tasks/cfg_clean.nims"
