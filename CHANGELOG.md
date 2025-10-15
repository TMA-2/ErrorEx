# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.2] - 2025-10-14

### Added
- Added `ErrorEx.Format.ps1xml` for table and list view
- Added `[Exception]$Exception` parameter to `Get-ActualError`

### Changed
- Renamed `[ErrorRecord]$Exception` to `[ErrorRecord]$ErrorRecord`

## [0.1.2] - 2025-10-14

### Fixed
- Win32 error code conversion via bitor `0x80070000`.

## [0.1.1] - 2025-10-10

### Added
- Supports Win32 error code conversion

## [0.1.0] - 2025-10-10

### Added
- Initial release
- `Get-ActualError` function to decode HRESULT codes
- `ErrorEx` class with bit field extraction
- `FacilityCode` enum with all Windows facility codes
- Support for both HResult integers and ErrorRecord objects
- Custom type data for formatted display

[Unreleased]: https://github.com/yourusername/ErrorEx/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/yourusername/ErrorEx/releases/tag/v0.1.0
