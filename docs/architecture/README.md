# Architecture Documentation

This directory contains Architecture Decision Records (ADRs) maintained by the **ARCH** agent.

## Naming Convention

```
ADR-NNN-short-description.md
```

- `NNN` — zero-padded sequential number (001, 002, ...)
- Always check existing files to assign the correct next number

## ADR Statuses

| Status | Meaning |
|--------|---------|
| Proposed | Under discussion, not yet accepted |
| Accepted | Active decision governing the project |
| Deprecated | No longer relevant |
| Superseded | Replaced by another ADR (reference the new one) |

## Document Template

```markdown
# ADR-NNN: Title

**Status:** Proposed | Accepted | Deprecated | Superseded by ADR-XXX
**Date:** YYYY-MM-DD
**Deciders:** ARCH, [others]

## Context
What problem requires a decision?

## Decision
What was decided?

## Rationale
Why this decision? What alternatives were considered?

## Consequences
Positive and negative consequences.

## Acceptance Criteria Impact
How does this affect REQ acceptance criteria?
```

## Index

<!-- ARCH updates this list when adding new ADRs -->
| ADR | Title | Status |
|-----|-------|--------|
| [ADR-001](ADR-001-tech-stack.md) | Tech Stack (Swift, SwiftUI, SwiftData, iPadOS 17+) | Accepted |
| [ADR-002](ADR-002-app-architecture.md) | App Architecture Pattern and Structure (MVVM-Lite, folder layout, navigation model) | Accepted |
| [ADR-003](ADR-003-data-model.md) | Data Model (SwiftData entities, daily reset, PIN storage) | Accepted |
| [ADR-004](ADR-004-testability.md) | Testability and E2E Test Architecture (AppEnvironment DI, launch arguments, accessibility identifiers) | Accepted |
