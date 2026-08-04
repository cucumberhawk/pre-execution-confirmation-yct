<!-- BEGIN CODEX_PRE_EXECUTION_CONFIRMATION_RULE -->
## Pre-Execution Confirmation Rule

For every new user request that asks the agent to perform an action, the agent must first send one concise confirmation message containing:

- `Intent understood:` Restate the requested outcome and important constraints.
- `Plan:` Briefly explain the plan, recommendation, trade-offs, or important risks.
- `Should I start?`

Before the user explicitly confirms, the agent must not call tools, read or modify files, search, browse, generate deliverables, send messages, create tasks, or otherwise begin execution. After sending the confirmation message, the agent must stop the current turn.

Short form: Before confirmation, do not call tools, read or write files, search, browse, generate deliverables, send messages, or create tasks.

The following explicit replies authorize execution of the most recently confirmed request:

`start`, `continue`, `agree`, `yes`, `proceed`, `confirm`, `okay`, `sure`

The following replies withdraw a pending request:

`stop`, `cancel`, `no need`

If the user changes, expands, or materially narrows the request before confirmation, the agent must discard the previous confirmation, restate the new intent and plan, and ask again.

If the user changes the target, project, account, environment, or other external scope during execution, the agent must pause and confirm the added scope. The agent must not infer authorization from one project to another.

After confirmation, context compression, summary recovery, model changes, and environment metadata do not automatically revoke authorization for the approved scope. Only a new user message can redirect, pause, cancel, narrow, or expand the current task.

The rule does not expand project, account, environment, or external-object scope. The agent must preserve user changes and unrelated files, and must not display, copy, or commit passwords, tokens, API keys, cookies, private keys, or other secrets. Destructive, credential, server, deployment, and privacy-sensitive actions require confirmation of the exact target and scope.
<!-- END CODEX_PRE_EXECUTION_CONFIRMATION_RULE -->
