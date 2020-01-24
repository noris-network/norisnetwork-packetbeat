# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v0.2.1](https://github.com/noris-network/norisnetwork-packetbeat/tree/v0.2.1) (2020-01-24)

[Full Changelog](https://github.com/noris-network/norisnetwork-packetbeat/compare/v0.2.0...v0.2.1)

# Added

- added **monitoring** Hash for new elastic major version 7 and 8
- added **$gpg_key_id** to repo.pp variables in case of elastic wants to change the gpg key some time
- added **Puppet version 4 testing** since PDK does not test puppet 4

# Fixed

- fixed typo in **metadata.json**
- improved **dependencies versions** in metadata.json for stdlib and apt

## [v0.2.0](https://github.com/noris-network/norisnetwork-packetbeat/tree/v0.2.0) (2020-01-10)

[Full Changelog](https://github.com/noris-network/norisnetwork-packetbeat/compare/v0.1.1...v0.2.0)

### Added

- added **LICENCE** since every project should have one
- switched to latest Puppet Development Kit **PDK 1.15.0.0**
- added possibility to install major version **5** additional to already configured versions **6** and **7**
- changed default major version from **6** to **7**
- added **$apt_repo_url**, **$yum_repo_url** and **$gpg_key_url** variables to enhance repo management
- enhanced repo management itself by better variable management
- updated spec tests to elastic major version **7** instead of major version **6** tests
- execute a **apt update** before installing the package for Debian

### Fixed

- **.fixtures** updated and yaml structure fixed
- **.vscode** folder readded to repo and removed from **.gitignore** since it is a part of the current pdk
- removed **.project** file since it is a part of **.gitignore** now
- switched from github pdk template to default pdk template
- improved **metadata.json** format, fixed some path issues, added tags and changed depencency and os versions

## [v0.1.1](https://github.com/noris-network/norisnetwork-packetbeat/tree/v0.1.1) (2018-08-23)

[Full Changelog](https://github.com/noris-network/norisnetwork-packetbeat/compare/v6.1.0...v0.1.1)

### Fixed

- Modified the allowed values for the parameter *service_provider*.
- The repo file is created only when *manage_repo* is set to *true* and *ensure* is set to *present*.

## [v0.1.0](https://github.com/noris-network/norisnetwork-packetbeat/tree/v0.1.0) (2018-06-19)

### Added

- First implementation.

### Known issues

- Only Linux (Debian, CentOS, SuSE Ubuntu) supported.
