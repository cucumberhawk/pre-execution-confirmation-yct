# pre-execution-confirmation-yct

An open, reusable distribution project for requiring explicit user confirmation from the root, user-facing agent before it performs tools, file operations, searches, browsing, or other external actions.

This project provides:

- `skills/pre-execution-confirmation-yct/SKILL.md`: the reusable Codex Skill.
- `templates/AGENTS.md`: a copyable rule block for a user-level `AGENTS.md`.
- `scripts/`: local installation and verification scripts.

The existing `tmp/` directory and `RECOVERY_STATUS.md` are preserved recovery artifacts. They are not required by this distribution and are not modified by the installation script.

## Scope

Use this project when an agent should request explicit authorization before:

- calling tools or external connectors;
- reading, creating, changing, moving, or deleting files;
- searching, browsing, or accessing external services;
- generating deliverables, sending messages, or creating tasks;
- changing code, configuration, or other external state.

This is a user-level behavior rule, not a plugin. It does not install itself, replace project-specific safeguards, or grant permissions.

## Agent Scope

The confirmation gate is intentionally root-agent only:

- The root agent, which directly receives the user's request, asks for confirmation before execution.
- Sub-agents are explicitly excluded and must not repeat the confirmation or wait for another user reply.
- Sub-agents continue to follow their existing system, project, and task-specific instructions.
- This exclusion does not grant permissions or allow a sub-agent to expand the assigned scope.

This distinction avoids a deadlock where the root agent is authorized but every delegated sub-agent pauses for a second confirmation.

## Language Behavior

The public distribution stays in English, but runtime replies follow the user:

- Use the language of the user's latest meaningful message for confirmation messages, progress updates, final results, errors, and summaries of sub-agent work.
- If the user switches languages, follow the latest language choice.
- Do not force English because the repository and Skill files are English.
- Translate the three confirmation labels as well; do not force the English labels on users who are communicating in another language.
- Keep code, command names, file paths, API names, exact protocol values, and literal authorization keywords unchanged when they must remain exact; translate the surrounding explanation.

## Project Structure

```text
skills/
`-- pre-execution-confirmation-yct/
    |-- SKILL.md
    `-- agents/
        `-- openai.yaml
templates/
`-- AGENTS.md
scripts/
|-- install-global-rule.ps1
`-- verify-install.ps1
CHANGELOG.md
CONTRIBUTING.md
LICENSE
README.md
.gitignore
```

## Installation

The installer changes only local user configuration. It does not connect to a server or modify the project source. The target file is:

1. `CODEX_HOME\AGENTS.md` when `CODEX_HOME` is set;
2. otherwise `.codex\AGENTS.md` under the current Windows user's profile directory.

From the project root, run:

```powershell
.\scripts\install-global-rule.ps1
```

The script prints the target path and requires the user to type `INSTALL`. If the target `AGENTS.md` exists, the script creates a timestamped backup and merges only the explicitly marked rule block. Repeated runs do not append duplicate blocks.

The installer does not modify the current project's source files, recovery artifacts, tool snapshots, or images.

## Verification

After installation, run:

```powershell
.\scripts\verify-install.ps1
```

The verification script checks:

- whether the user-level `AGENTS.md` exists;
- whether the rule start and end markers occur exactly once;
- whether the rule is root-agent-only and explicitly excludes sub-agents;
- whether user-facing language follows the user's latest meaningful message;
- whether the rule contains the intent, plan, confirmation question, authorization words, withdrawal words, and scope-change requirements;
- whether the local Skill and template are complete;
- whether duplicate rule blocks or conflicting unscoped legacy rules exist.

The verification script is read-only and does not print the body of `AGENTS.md`.

## Uninstallation

Remove only the content between these markers. Keep all other user content in `AGENTS.md`:

```text
<!-- BEGIN CODEX_PRE_EXECUTION_CONFIRMATION_RULE -->
...
<!-- END CODEX_PRE_EXECUTION_CONFIRMATION_RULE -->
```

Keep installer backups until the result is confirmed. Do not use recursive deletion commands against the user configuration directory.

## Security Notes

- The installer requires interactive confirmation and does not silently overwrite configuration.
- Existing target files are backed up before changes.
- Only the marked rule block is merged; content outside the block is preserved.
- The scripts do not connect to the network, install plugins, or modify project source.
- The scripts do not print, copy, or commit passwords, tokens, API keys, cookies, private keys, or other secrets.
- Do not publish a user-level `AGENTS.md`, its backups, or environment files to a public repository.
- If the user changes the target, scope, project, account, environment, or constraints, request confirmation again.
- Do not apply this confirmation gate to sub-agents launched by an authorized root agent.

## Publishing to GitHub

Before publishing:

1. Review `git diff` and the file list.
2. Confirm that no environment files, backup configuration, credentials, or machine-specific paths are included.
3. Run the documentation and PowerShell static checks.
4. Initialize or connect the repository only after the project boundary is confirmed.
5. Use a clear commit message, such as `feat: publish pre-execution confirmation rule bundle`.
6. Create a version tag only after the published contents are reviewed.

The local installer does not initialize Git, create commits, or push to GitHub automatically.
