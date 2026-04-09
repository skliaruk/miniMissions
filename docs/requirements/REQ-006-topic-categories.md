# REQ-006: Topic Categories (Aihealueet)

**Status:** Approved
**Priority:** Must
**Effort:** L

## Description

Tasks are organized under topic categories (aihealueet) such as "Morning", "After daycare", "Before bedtime". Each child has their own tasks per topic — tasks are not shared between children. Parents can add and remove topic categories. The child-facing view navigates between topics via tabs.

## User Story

As a parent, I want to organize my children's daily routines into topic categories so that each part of the day has its own clear task list.

As a child, I want to switch between different routines (e.g. morning, evening) using simple tabs so I can see what to do next.

## Details

### Topic Categories

- A **topic** is a named category that groups tasks (e.g. "Aamu", "Päiväkodin jälkeen", "Ennen nukkumaanmenoa")
- Topics are **global** — the same topic names appear for all children
- Each child has their **own tasks** within each topic (parent defines per child per topic)
- Topics have a **sort order** that determines tab display order

### Default Topic

- On first launch, one default topic is created: **"Aamu"** (Morning)
- The default topic can be renamed or deleted like any other topic

### Child-Facing View (Tab Navigation)

- Topics are displayed as **tabs** at the top of the routine view
- Tapping a tab switches all three child columns to show that topic's tasks
- The active tab is visually highlighted
- Tab design must be child-friendly: large touch targets (minimum 60x60pt), clear visual distinction
- If only one topic exists, the tab bar is still visible (single tab)

### Parent Management — Topic CRUD

- In the parent management view, the parent can:
  - **Add a topic** — enter a name (max 30 characters)
  - **Rename a topic** — edit the name
  - **Delete a topic** — with confirmation prompt; deleting a topic deletes all associated tasks for all children
  - **Reorder topics** — drag to reorder (changes tab order)
- There must be **at least 1 topic** — the last topic cannot be deleted

### Reset per Topic

- The "Reset day" functionality is replaced with **per-topic reset**
- Each topic has its own reset button in the parent management view
- Resetting a topic sets all tasks for all children within that topic to incomplete
- A "Reset all" button is also available to reset all topics at once
- Both require confirmation before executing

## Acceptance Criteria

1. Default topic "Aamu" exists on first launch
2. Child-facing view shows tabs for each topic
3. Tapping a tab switches all child columns to that topic's tasks
4. Active tab is visually distinct from inactive tabs
5. Tab touch targets are at minimum 60x60pt
6. Parent can add a new topic with a name (max 30 chars)
7. Parent can rename an existing topic
8. Parent can delete a topic (with confirmation) — all associated tasks are deleted
9. Parent cannot delete the last remaining topic
10. Parent can reorder topics via drag-and-drop
11. Each child has independent tasks per topic
12. Per-topic reset sets all tasks in that topic to incomplete for all children
13. "Reset all" resets all topics at once
14. Both reset actions require confirmation
15. Tab order matches parent-defined sort order

## E2E Test Requirements

- First launch shows "Aamu" tab and default topic tasks (XCUITest)
- Adding a topic creates a new tab in the child view (XCUITest)
- Switching tabs changes displayed tasks for all children (XCUITest)
- Deleting a topic removes its tab and all associated tasks (XCUITest)
- Cannot delete the last topic — UI prevents it (XCUITest)
- Renaming a topic updates the tab label (XCUITest)
- Reordering topics changes tab order (XCUITest)
- Per-topic reset only affects tasks in that topic (XCUITest)
- Reset all clears all topics (XCUITest)
- Each child has different tasks in the same topic (XCUITest)

## Impact on Existing Requirements

| REQ | Change |
|---|---|
| REQ-001 | Routine view now has tab navigation; tasks shown per active topic |
| REQ-002 | Task completion unchanged — works within topic context |
| REQ-004 | Reset is now per-topic + reset-all; task management is per child per topic |
| ADR-003 | Data model needs a new `Topic` entity; `Task` gains a `topic` relationship |
