# Changelog

This file records changes to the public distribution.

## [0.5.0] - 2026-08-08

### Fixed

- Prevented the confirmation Skill from re-triggering after context compression, summary recovery, model switching, or continuation of the same task.
- Added explicit pending, authorized, withdrawn, and completed request-state handling for continuation events.
- Updated the Skill launcher hint and verifier to recognize continuation behavior.

## [0.4.0] - 2026-08-08

### Changed

- Made the three confirmation labels follow the user's latest meaningful language instead of forcing English labels.
- Kept authorization keywords, safety boundaries, and the root-agent-only scope unchanged.

## [0.3.0] - 2026-08-07

### Changed

- Added a language policy that keeps public repository files in English while making user-facing replies follow the user's latest meaningful language.
- Applied the language policy to confirmations, progress updates, final results, errors, and summaries of sub-agent work.
- Documented that exact code, command names, paths, API names, protocol values, and authorization keywords remain unchanged.

## [0.2.0] - 2026-08-07

### Changed

- Scoped the confirmation gate to the root, user-facing agent.
- Explicitly excluded sub-agents so delegated work does not wait for a second user confirmation.
- Documented that sub-agents keep following their existing system, project, and task-specific instructions.
- Added installer and verifier checks for conflicting unscoped legacy rules.

### Security

- The sub-agent exclusion does not grant permissions or allow scope expansion.
- The installer stops when it detects an old unscoped confirmation rule outside the managed block, preventing contradictory rules from being silently merged.

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
