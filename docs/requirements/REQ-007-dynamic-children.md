# REQ-007: Dynamic Children Management

**Status:** Approved
**Priority:** Must
**Effort:** L

## Description

Parents can add and remove children dynamically instead of having three fixed children. Each child has a name and optionally a photo. Maximum 6 children allowed. When more children exist than fit on screen as columns, the layout switches to a scrollable list.

## User Story

As a parent, I want to add my own children with their names and photos so that the app reflects my actual family.

## Details

### Child CRUD (Parent Management)

- Parent can **add a child** — enter a name (max 30 characters) and optionally select a photo from the device photo library
- Parent can **edit a child** — change name and/or photo
- Parent can **delete a child** — with confirmation prompt; deleting a child deletes all their task assignments and completion states
- Parent can **reorder children** — drag to reorder (changes column/list order)
- **Maximum 6 children** — "Add child" button hidden/disabled when limit reached
- **Minimum 1 child** — last child cannot be deleted
- Name is required; photo is optional (default avatar/illustration shown if no photo)

### First Launch

- App launches with **no children** — parent must add at least one child before using the routine view
- Or: app launches with one default child named "Lapsi 1" that can be renamed/deleted (if more are added)

### Child-Facing View Layout

- **1–3 children**: displayed as columns side by side (current layout)
- **4–6 children**: displayed as a horizontally scrollable list of columns, or a grid layout that fits iPad landscape
- Each child column still shows: name, avatar/photo, task list for active topic

### Data Model Impact

- `Child` entity is no longer seeded with fixed records
- `Child.name` is now editable
- `Child.avatarImageData` is set from photo library (already exists in model)
- `SeedDataService` no longer seeds fixed children

## Acceptance Criteria

1. Parent can add a child with a name (max 30 chars) and optional photo
2. Parent can edit a child's name and photo
3. Parent can delete a child (with confirmation) — all associated tasks and completions are removed
4. Parent cannot delete the last remaining child
5. Maximum 6 children enforced — add button disabled at limit
6. Parent can reorder children via drag-and-drop
7. Child-facing view shows all children (columns for ≤3, scrollable for 4–6)
8. Each child's name and photo are displayed in the routine view
9. Deleting a child removes their column from the routine view immediately
10. Adding a child adds a new column to the routine view immediately

## E2E Test Requirements

- Add child flow: new child column appears in routine view (XCUITest)
- Edit child: updated name/photo appears in routine view (XCUITest)
- Delete child: confirmation required, column removed from routine view (XCUITest)
- Cannot delete last child — UI prevents it (XCUITest)
- Cannot add more than 6 children — add button disabled (XCUITest)
- Reorder children: column order matches parent-defined order (XCUITest)
- 4+ children: scrollable/grid layout works (XCUITest)

## Impact on Existing Requirements

| REQ | Change |
|---|---|
| REQ-001 | Layout adapts to variable number of children (1–6) instead of fixed 3 |
| REQ-004 | Child list in parent management is dynamic, not fixed 3 |
| ADR-003 | Child entity no longer fixed; SeedDataService changes |
