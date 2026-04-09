# REQ-001: Morning Routine View (Child-Facing)

**Status:** Approved
**Priority:** Must
**Effort:** M

## Description

The main screen of the app is the child-facing morning routine view. It displays all three children side by side on an iPad. Each child has their own column showing their name, avatar/photo, and their list of morning tasks. The design must be appropriate for children aged 2–6: large icons, minimal text, bright colors.

## User Story

As a child (age 2–6), I want to see my morning tasks clearly so that I know what I need to do without needing to read.

## Details

- The screen shows all **3 children simultaneously** in a column layout (one column per child)
- Each child column displays:
  - Child's name (large, readable font)
  - A visual avatar or illustration representing the child
  - The child's task list (see REQ-002 for task completion behaviour)
- Child names are **fixed** in the app (not editable)
- Tasks are displayed as **icon + label pairs** — icons are primary, text is secondary
- Touch targets must be **at minimum 60×60pt** (larger than standard WCAG minimum, appropriate for small children)
- The layout must fill the **full iPad screen** in landscape orientation
- The screen must support **Dark Mode** and **Dynamic Type**

## Acceptance Criteria

1. Launching the app shows the routine view immediately — no splash screen delay > 1 second
2. All 3 children are visible simultaneously without scrolling in landscape orientation on iPad (all supported sizes: mini, standard, Pro)
3. Each child column displays the child's name and avatar
4. Each task in the list shows an icon and a text label
5. All interactive elements have a minimum touch target of 60×60pt
6. The view is fully navigable via VoiceOver (each child column and task is announced correctly)

## E2E Test Requirements

- App launches and routine view is the first screen shown (XCUITest)
- All 3 child columns are present and labelled correctly (XCUITest, accessibility identifiers)
- Tasks are listed under the correct child column (XCUITest)
- Touch targets meet minimum size requirement (XCUITest frame check)
