# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2026-04-25

### Added
- `Url#same_origin?(other)` for RFC 6454 same-origin checks (scheme, host, effective port)
- `Url#same_host?(other)` for case-insensitive host-only comparison

## [0.4.0] - 2026-04-20

### Added
- `Url#keep_params(*keys)` — return a new `Url` containing only the listed query parameters, dropping every other key. Accepts individual `String`/`Symbol` keys or a single array argument; calling with no keys drops the whole query.

## [0.3.1] - 2026-04-15

### Changed
- Update homepage metadata URL to use hyphenated package slug

## [0.3.0] - 2026-04-09

### Added
- Component accessors: `scheme`, `host`, `port`, `path`, `query`, `fragment`
- Value equality: `==`, `eql?`, `hash` based on string representation

## [0.2.0] - 2026-04-03

### Added
- Path manipulation: `append_path`, `path_segments`, `replace_path`
- Query helpers: `add_params`, `clear_params`
- `base_url` for extracting scheme + host + port

## [0.1.6] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.5] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.4] - 2026-03-24

### Fixed
- Standardize README code examples to use double-quote require statements

## [0.1.3] - 2026-03-24

### Fixed
- Fix Installation section quote style to double quotes
- Remove inline comments from Development section to match template

## [0.1.2] - 2026-03-23

### Fixed
- Standardize README description to match template guide
- Update gemspec summary to match README description

## [0.1.1] - 2026-03-22

### Added
- Add bug_tracker_uri metadata to gemspec

## [0.1.0] - 2026-03-22

### Added
- Initial release
- Parse and manipulate URLs with query parameter management
- URL normalization with scheme/host lowercasing and default port removal
- Domain and subdomain extraction
- URL building from components
- URL joining with relative path resolution
