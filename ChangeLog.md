# Change Log
All notable changes to this project will be documented in [this file](http://keepachangelog.com/).
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.1.0] - 2016-07-20
### Changed
- Detect built-in '$env:chocolateyPackageFolder' and prompt the caller to use it.
### Added
- Added `bootstrap.ps1`: ensure extension modules and '$env:chocolateyPackageFolder', import local modules.

## [1.0.0] - 2016-06-12
### Added
- Added cmdlet `Get-ChocolateyPackagePath`.
