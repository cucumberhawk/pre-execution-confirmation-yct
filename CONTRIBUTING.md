# Contributing

Contributions are welcome when they make the confirmation boundary clearer, more portable, or easier to follow without adding unnecessary ceremony.

## Guidelines

- Keep the core Skill concise and instruction-focused.
- Put public explanation and examples in the repository README, not in `SKILL.md`.
- Do not add runtime dependencies for behavior that can be expressed as agent instructions.
- Preserve the distinction between understanding a request and authorization to act.
- Describe limitations honestly; the Skill depends on the host agent following the instructions.
- Use lowercase hyphenated Skill names. Skills published in this collection should end with `-yct`.

## Pull requests

Include the problem being solved, the changed behavior, and at least one example conversation showing the confirmation boundary.
