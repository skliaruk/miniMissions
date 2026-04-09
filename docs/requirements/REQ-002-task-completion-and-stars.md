# REQ-002: Task Completion and Star Rewards

**Status:** Approved
**Priority:** Must
**Effort:** M

## Description

A child taps a task to mark it as done. Completing a task triggers a rewarding visual reaction (star). When all tasks for a child are completed, a celebration animation is shown. Stars serve as positive reinforcement appropriate for ages 2–6.

## User Story

As a child, I want to tap my task and see a star so that I feel proud when I complete it.

## Details

- Tapping an incomplete task marks it as **done**:
  - The task gets a clear visual "done" state (e.g. checkmark, greyed out, star overlay)
  - A **star animation** plays immediately on tap (brief, celebratory)
- Tapping a done task has **no effect** (tasks cannot be accidentally un-done by the child — only parent can reset, see REQ-004)
- When **all tasks for one child** are completed:
  - A **celebration animation** plays in that child's column (e.g. confetti, bouncing stars)
  - The column remains visible and shows the completed state
- Stars are **visual only** — there is no score, counter, or persistent star collection in this version
- Animations must respect **Reduce Motion** accessibility setting — show a simple fade/highlight instead of motion

## Acceptance Criteria

1. Tapping an incomplete task changes its visual state to "done" within 100ms
2. A star animation plays immediately after tapping a task
3. Tapping a completed task does nothing (no state change)
4. When all tasks in a child's column are done, a celebration animation plays in that column only
5. Celebration animation does not affect other children's columns
6. With Reduce Motion enabled, no movement-based animations play — a static highlight is shown instead
7. Done state is visually distinct from incomplete state (not colour-only — must also differ in shape/icon for colour-blind users)

## E2E Test Requirements

- Tapping a task changes its accessibility state to "completed" (XCUITest)
- Tapping a completed task produces no state change (XCUITest)
- Celebration view appears when all tasks in one column are tapped (XCUITest)
- With Reduce Motion launch argument, animation elements are absent (XCUITest)
