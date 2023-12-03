# Package

version       = "0.5.1"
author        = "Akito <the@akito.ooo>"
description   = "Automatically send invitations about planned Zoom meetings."
license       = "AGPL-3.0-or-later"
srcDir        = "src"
bin           = @["zoominvitr"]
skipFiles     = @["README.md"]
skipExt       = @["nim"]
backend       = "c"


# Dependencies

requires "nim             >= 2.0.0"
requires "schedules       >= 0.2.0" ## https://github.com/soasme/nim-schedules
requires "puppy           >= 2.1.0" # https://github.com/treeform/puppy
requires "ready           >= 0.1.4" ## https://github.com/guzba/ready
requires "timestamp       >= 0.4.2"
requires "timezones       >= 0.5.4"
requires "zero_functional >= 1.3.0" ## https://github.com/zero-functional/zero-functional
requires "smtp#8013aa199dedd04905d46acf3484a232378de518" ## https://github.com/nim-lang/smtp/issues/9
requires "yaml#854d33378e2b31ada7e54716439a4d6990460268" ## https://github.com/flyx/NimYAML/issues/101


# Tasks
import os, strformat, strutils

const defaultVersion = "unreleased"

let
  buildParams   = if paramCount() > 8: commandLineParams()[8..^1] else: @[]    ## Actual arguments passed to task. Previous arguments are only for internal use.
  buildVersion  = if buildParams.len > 0: buildParams[^1] else: defaultVersion ## Semver compliant App Version
  buildRevision = gorge """git log -1 --format="%H""""                         ## Build revision, i.e. Git Commit Hash
  buildDate     = gorge """date"""                                             ## Build date; Example: Sun 10 Apr 2022 01:13:09 AM CEST

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
            --excessiveStackTrace:off \
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
            --excessiveStackTrace:off \
            --debugger:native \
            --debuginfo:on \
            --opt:none \
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
            --define:logDirPath:/data/logs \
            --define:danger \
            --excessiveStackTrace:off \
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
            --define:logDirPath:/data/logs \
            --excessiveStackTrace:off \
            --debugger:native \
            --debuginfo:on \
            --opt:none \
            --out:app \
            src/zoominvitr
       """