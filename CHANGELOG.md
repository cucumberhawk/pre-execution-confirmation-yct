# Changelog

This file records changes to the public distribution.

## [0.1.1] - 2026-08-04

### Changed

- Translated the public README, Skill, template, and PowerShell messages to English.
- Kept the repository and Skill name as `pre-execution-confirmation-yct`.

## [0.1.0] - 2026-08-02

### Added

- Added public documentation for the pre-execution confirmation rule.
- Added the `pre-execution-confirmation-yct` Skill.
- Added a copyable user-level `AGENTS.md` rule template.
- Added an interactive local installer with timestamped backups and idempotent block merging.
- Added a read-only installation verification script.
- Added an MIT license.

### Security

- The installer does not connect to the network, connect to servers, install plugins, or modify project source.
- The installer does not print or copy credentials and stops when it detects obvious credential formats.
