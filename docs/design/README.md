# Design Documentation

This directory contains design specifications maintained by the **UXUI** agent.

## Naming Convention

```
DSGN-NNN-short-description.md
```

- `NNN` — zero-padded sequential number (001, 002, ...)
- Always check existing files to assign the correct next number

## DSGN Statuses

| Status | Meaning |
|--------|---------|
| Draft | Work in progress, not ready for implementation |
| Approved | Approved by PO, ready for MDEV to implement |
| Implemented | Feature built and reviewed against this spec |

## Document Template

```markdown
# DSGN-NNN: Title

**Status:** Draft | Approved | Implemented
**Date:** YYYY-MM-DD
**REQ:** REQ-NNN

## Overview
What user problem does this design solve?

## User Flow
Step-by-step flow.

## Screens & Components
Screen descriptions and component behaviour.

## Visual Design
Colors, typography, spacing, iconography.

## Accessibility (WCAG 2.2 AA)
Contrast ratios, touch targets, VoiceOver, Dynamic Type, Reduce Motion.

## iOS-Specific Considerations
Safe area, dark mode, HIG alignment.

## Acceptance Criteria for Design
Testable criteria for QA.
```

## Accessibility Standards

All designs must meet **WCAG 2.2 AA**:
- Text contrast ≥ 4.5:1
- UI component contrast ≥ 3:1
- Touch targets ≥ 44×44pt
- VoiceOver labels on all interactive elements
- Dynamic Type support (xSmall → AX5)
- Reduce Motion support

## Index

<!-- UXUI updates this list when adding new DSGN documents -->
| DSGN | Title | Status | REQ |
|------|-------|--------|-----|
| [DSGN-001](DSGN-001-design-system.md) | Design System | Draft | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005 |
| [DSGN-002](DSGN-002-morning-routine-view.md) | Morning Routine View (Child-Facing) | Draft | REQ-001, REQ-002, REQ-005 |
| [DSGN-003](DSGN-003-parent-management.md) | Parent Management View | Draft | REQ-003, REQ-004, REQ-005 |
