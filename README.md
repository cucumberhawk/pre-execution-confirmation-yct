# pre-execution-confirmation-yct

An open, cross-agent confirmation gate for AI coding assistants. After receiving an instruction, the agent first restates what the user asked for and explains its own understanding before touching the code. This catches misunderstandings early, reduces rework, and helps prevent the frustration of discovering at the end of a long task that the AI misunderstood the request from the beginning.

## Why use it?

AI coding agents can begin changing a project based on a mistaken interpretation of the request. The real cost often appears much later: a long task is finished, only to reveal that the agent misunderstood the user's intent from the start. This Skill creates a deliberate boundary between **understanding** and **execution**.

Benefits:

- Prevents accidental file changes, deletion, installation, publishing, or deployment.
- Makes the agent's interpretation visible before work starts.
- Gives the user an opportunity to correct misunderstandings before code is changed.
- Gives the user one clear approval point for consequential operations.
- Reduces ambiguity when a message mixes discussion and execution.
- Preserves authorization after context compression or a model handoff.
- Works as a lightweight human-in-the-loop layer for long-running tasks.
- Does not require a runtime dependency, API key, database, or service.
- Can be combined with a task-progress Skill such as an execution anchor.

## What it does

For an action request, the agent must first reply with:

```text
Intent understood: Restate the requested outcome and important constraints.
Plan: Explain the plan, recommendation, trade-offs, or risks.
Should I start?
```

The agent must wait for an explicit approval such as `start`, `continue`, `agree`, `yes`, `proceed`, `confirm`, `okay`, or `sure`.

The agent must ask again if the user changes the scope before approval. `stop`, `cancel`, and `no need` withdraw the pending request.

After approval, context compression, summary recovery, model changes, and environment metadata do not revoke authorization for the already-approved scope.

## What it does not do

- It does not persist a full task plan or progress log by itself.
- It does not replace project memory, tests, permissions, or deployment safeguards.
- It does not guarantee safe behavior when the host agent ignores loaded instructions.
- It does not require confirmation for pure explanations, conceptual discussion, or clarifying questions that do not start an operation.

## Install

The Skill is the directory at:

```text
skills/pre-execution-confirmation-yct/
```

Copy that directory into the Skill directory supported by your agent. For Codex, install it under:

```text
~/.codex/skills/pre-execution-confirmation-yct/
```

Then restart or refresh the agent so it can discover the Skill.

## Recommended pairing

Use this Skill together with a durable task-progress workflow for long tasks:

```text
pre-execution-confirmation-yct
+
execution-anchor or an equivalent task journal
```

The confirmation Skill answers **"Has the user authorized this action?"**. A task journal answers **"Which approved step is currently in progress?"**. Keep those responsibilities separate.

## Examples

### Action request

User: `Inspect this project and fix the homepage issues.`

Agent: ask for confirmation first, then wait.

### Pure explanation

User: `Why does this error occur?`

Agent: explain the cause directly; no execution gate is needed unless the user asks for a change.

### Scope change

User approves a code review, then asks to deploy the fix. The deployment is a new consequential action and requires a new confirmation.

## Naming convention

The `-yct` suffix identifies Skills published by this author. New Skills in this author's collection should use a lowercase, hyphenated name followed by `-yct`.

## License

MIT. See [LICENSE](LICENSE).
