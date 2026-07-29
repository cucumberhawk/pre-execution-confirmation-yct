---
name: pre-execution-confirmation-yct
description: Require explicit user confirmation before carrying out any requested action, including tool calls, file reads or edits, browsing, searches, generated deliverables, messages, or task creation. Use for agent workflows that need a clear separation between understanding a request and receiving authorization to execute it.
---

# Pre-Execution Confirmation YCT

## Overview

Add a human-in-the-loop confirmation gate before agent actions. The agent may explain, inspect a request conceptually, or ask clarifying questions without confirmation, but it must not begin the requested operation until the user explicitly authorizes the latest confirmed scope.

## Confirmation Workflow

### 1. Classify the message

Treat a message as an action request when it asks the agent to do, change, inspect, search, browse, generate, send, install, delete, publish, or otherwise operate on something.

Pure explanations, conceptual discussion, clarifying questions, and comparisons that do not start an operation do not require this gate.

### 2. Ask for confirmation before acting

Before any action, send one concise confirmation message containing:

- `意图理解：` Restate the requested outcome and important constraints.
- `想法：` Give a brief plan, recommendation, trade-off, or notable risk.
- A direct question such as `是否开始执行？`

End that turn after asking. Do not call tools or begin the operation in the same turn.

### 3. Wait for explicit authorization

Treat these short replies as authorization to execute the most recently confirmed scope:

- `开始`
- `继续`
- `同意`
- `可以`
- `执行`
- `确认`
- `好的`
- `是的`

Do not treat a vague acknowledgment, discussion, plan adjustment, or statement of awareness as authorization.

### 4. Handle scope changes and cancellation

If the user changes, adds to, or materially narrows the request before confirming, discard the pending confirmation and ask again for the new scope.

Treat `停止`, `取消`, and `不用了` as withdrawal. Do not execute the pending request.

If the user changes scope after authorization, pause and confirm the new scope before acting on it.

### 5. Preserve execution state

Once the user has authorized a task, context compression, summary recovery, model changes, and environment metadata do not count as new user messages and do not revoke authorization.

Continue the latest authorized task from its current state. Do not restart the confirmation flow merely because context was compressed.

For long or interruption-prone work, pair this gate with a durable task-progress mechanism such as an execution anchor. Keep authorization state and task progress separate.

## Message Template

Use a short format such as:

```text
意图理解：我会读取并分析指定项目，输出功能、风险和适用性结论。
想法：我会先检查项目结构和文档，再验证关键结论；不会修改文件。
是否开始执行？
```

Do not add implementation details or progress updates before the user answers.
