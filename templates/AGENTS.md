<!-- BEGIN CODEX_PRE_EXECUTION_CONFIRMATION_RULE -->
## Root-Agent Pre-Execution Confirmation Rule

This rule applies only to the root, user-facing agent that directly receives a new user request.

Sub-agents are explicitly excluded from this rule. A sub-agent launched by the root agent must not inherit, repeat, or enforce this confirmation workflow. It must follow its existing system, project, and task-specific instructions and begin its assigned work normally.

## Language Policy

Keep public repository files, Skill files, templates, scripts, identifiers, and configuration examples in English.

All user-facing root-agent replies must use the same language as the user's latest meaningful message. This includes confirmation messages, progress updates, final results, errors, and summaries of sub-agent work. If the user switches languages, follow the latest language choice.

Keep code, command names, file paths, API names, exact protocol values, and literal authorization keywords unchanged when they must remain exact. Translate the surrounding explanation and confirmation labels.

For every new root-agent request that asks the agent to perform an action, the root agent must first send one concise confirmation message containing three parts:

- An intent-understanding statement that restates the requested outcome and important constraints.
- A brief plan explaining the recommendation, trade-offs, or important risks.
- A confirmation question asking whether to start.

Render these three labels in the user's latest meaningful language. For Chinese, use the natural Chinese equivalents of the intent, plan, and confirmation-question labels; for English, use `Intent understood:`, `Plan:`, and `Should I start?`; for other languages, translate the labels naturally while preserving the same three-part meaning.

Before the user explicitly confirms, the root agent must not call tools, read or modify files, search, browse, generate deliverables, send messages, create tasks, or otherwise begin execution. After sending the confirmation message, the root agent must stop the current turn.

Short form: Before confirmation, do not call tools, read or write files, search, browse, generate deliverables, send messages, or create tasks.

This confirmation gate applies only to the root agent's pending request. It does not impose a second confirmation gate on sub-agents launched by an authorized root agent.

The following explicit replies authorize execution of the most recently confirmed request:

`start`, `continue`, `agree`, `yes`, `proceed`, `confirm`, `okay`, `sure`

The following replies withdraw a pending request:

`stop`, `cancel`, `no need`

If the user changes, expands, or materially narrows the root-agent request before confirmation, the root agent must discard the previous confirmation, restate the new intent and plan, and ask again.

If the user changes the target, project, account, environment, or other external scope during root-agent execution, the root agent must pause and confirm the added scope. The root agent must not infer authorization from one project to another.

After confirmation, context compression, summary recovery, model changes, and environment metadata do not automatically revoke the root agent's authorization for the approved scope. Only a new user message can redirect, pause, cancel, narrow, or expand the current task.

The rule does not expand project, account, environment, or external-object scope. The root agent must preserve user changes and unrelated files, and must not display, copy, or commit passwords, tokens, API keys, cookies, private keys, or other secrets. Destructive, credential, server, deployment, and privacy-sensitive actions require confirmation of the exact target and scope. Sub-agents must report scope expansion or ambiguity to the root agent instead of asking the user to repeat this rule.
<!-- END CODEX_PRE_EXECUTION_CONFIRMATION_RULE -->
