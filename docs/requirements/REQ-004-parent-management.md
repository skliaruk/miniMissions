# REQ-004: Parent Management View

**Status:** Approved
**Priority:** Must
**Effort:** L

## Description

After passing the parental gate (REQ-003), the parent can manage each child's task list and manually reset the day's routines. The parent management view is functional and adult-oriented — it does not need to be child-friendly.

## User Story

As a parent, I want to manage my children's task lists and reset completed tasks each morning so that the routine is always relevant and ready for a new day.

## Details

### Task Management (per child)
- The parent sees a list of all three children
- Selecting a child opens that child's task list editor
- The parent can:
  - **Add a task** — enter a task name and select or upload an icon
  - **Edit a task** — change name or icon
  - **Delete a task** — with a confirmation prompt
  - **Reorder tasks** — drag to reorder
- Task names have a maximum length of 30 characters
- Each task requires an icon — parent can choose from a **built-in icon library** or use the device **photo library**
- There is no minimum or maximum number of tasks per child (at least 1 required)
- Changes are saved immediately (no explicit save button needed)

### Daily Reset
- A prominent **"Reset day"** button resets all tasks for all children to incomplete simultaneously
- Requires a single confirmation tap (not PIN re-entry)
- Reset cannot be undone
- After reset, the routine view shows all tasks as incomplete

## Acceptance Criteria

1. Parent management view lists all three children
2. Tapping a child opens their task list editor
3. Parent can add a task with a name (max 30 chars) and icon (library or photo)
4. Parent can edit an existing task's name and icon
5. Parent can delete a task — a confirmation prompt appears before deletion
6. Parent can reorder tasks via drag-and-drop
7. Task list updates are reflected immediately in the child-facing routine view
8. "Reset day" button is clearly visible in parent management
9. Tapping "Reset day" shows a confirmation prompt
10. Confirming reset sets all tasks across all children to incomplete
11. After reset, the routine view reflects the cleared state immediately

## E2E Test Requirements

- Add task flow: task appears in child column on routine view (XCUITest)
- Edit task flow: updated name/icon appears in routine view (XCUITest)
- Delete task: confirmation required, task removed from routine view (XCUITest)
- Reorder tasks: order in routine view matches parent-set order (XCUITest)
- Reset day: all tasks show as incomplete in routine view after confirmation (XCUITest)
- Reset day: cancelling confirmation leaves task states unchanged (XCUITest)
