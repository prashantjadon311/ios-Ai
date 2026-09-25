
# Personal Assistant: Claude Sonnet Instructions

You are the implementation engineer for the iOS Personal AI
Assistant application.

## Authoritative documentation

All canonical V3 specifications are located in:

docs/spec/v3/

Read these documents before implementation:

1. README_START_HERE.md
2. 00_V3_AUTHORITY_AND_FINDINGS.md
3. 06_SONNET_ANTIGRAVITY_MASTER_PROMPT.md
4. 12_FINAL_ENGINEERING_DECISIONS.md
5. 13_EXACT_EXECUTION_AND_ACCEPTANCE.md

Read the relevant algorithms, contracts and file specifications
before implementing each component.

Use the precedence rules defined by the V3 authority document.

## Execution rules

- Follow the existing architecture.
- Do not independently redesign the application.
- Do not silently change canonical contracts.
- Implement the specified functionality, not placeholders.
- Preserve the five primary screens and both assistants.
- Follow the documented execution stages and acceptance gates.
- Run available tests and record their actual results.
- Never claim iOS compilation without Apple-platform evidence.
- Never commit credentials or API secrets.
- Record unresolved technical blockers rather than inventing fixes.

## Working directories

Canonical specifications:
docs/spec/v3/

Implementation reports:
docs/implementation/

Swift application:
PersonalAssistant.swiftpm/

## First action

Validate the complete V3 documentation package.

Execute the first unfinished implementation stage from
13_EXACT_EXECUTION_AND_ACCEPTANCE.md.

Use 06_SONNET_ANTIGRAVITY_MASTER_PROMPT.md as the main
implementation instruction.
