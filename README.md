[![Nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://nimble.directory/pkg/zoominvitr)

[![Source](https://img.shields.io/badge/project-source-2a2f33?style=plastic)](https://github.com/theAkito/zoominvitr)
[![Language](https://img.shields.io/badge/language-Nim-orange.svg?style=plastic)](https://nim-lang.org/)

![Last Commit](https://img.shields.io/github/last-commit/theAkito/zoominvitr?style=plastic)

[![Licence](https://img.shields.io/badge/license-AGPL--3.0-informational?style=plastic)](https://www.gnu.org/licenses/agpl-3.0.txt)
[![Liberapay patrons](https://img.shields.io/liberapay/patrons/Akito?style=plastic)](https://liberapay.com/Akito/)

## What
Automatically invite peers to scheduled Zoom Meetings.

## Why
No need for manual invitations.

## How
First, check out [how to get access to Zoom's API](HOW-TO-ZOOM-API.md).

Second, prepare system for Redis.

```
option="vm.overcommit_memory=1"
sudo sysctl -w "{option}"
sudo echo "{option}" >> /etc/sysctl.conf
```

Run the `docker-compose.yml`, after adjusting its values & setting up your personalised Zoom Meetings configuration.

## Where
Linux via Docker

## Goals
* Reliability

## Project Status
Production

## TODO
* ~~Support E-Mail~~
* ~~Add good enough keyword filter via configuration~~
* ~~Quit early on invalid configuration~~
* ~~Error out on duplicate patternKeywords across Contexts~~
* ~~Allow usage of multiple Zoom accounts for single Context~~
* ~~Add Documentation on how to setup Zoom API Access~~
* ~~Add Documentation on how to retrieve User ID~~
* ~~Change Licence to AGPL~~
* ~~Open Source~~
* ~~Verify automatic Docker Hub Deployment~~
* ~~Make SSL/TLS work on Alpine inside Docker~~
* ~~Optimise Docker Compose YAML files~~
* ~~Improve Error Handling on Database Connection Defect~~
* ~~Cache Zoom responses for 1, 12 or 24 hours~~
* ~~Minimise Zoom API call amount~~
* ~~Save Contexts in Database~~
* ~~Make Meta Options configurable via Configuration File~~
* ~~Fix ambiguous Identifier~~
* Publish Configuration File Documentation
* Publish via [Nimble](https://nimble.directory/)

## License
Copyright © 2023  Akito <the@akito.ooo>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.