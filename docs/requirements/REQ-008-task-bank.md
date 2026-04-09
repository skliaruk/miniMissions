# REQ-008: Task Bank (Tehtäväpankki)

**Status:** Approved
**Priority:** Must
**Effort:** L

## Description

A global task bank where parents create task definitions once and assign them to multiple children. Tasks in the bank are shared — editing a task definition updates it for all assigned children. Each child has their own completion state per task.

## User Story

As a parent, I want to create a task once (e.g. "Brush teeth") and assign it to multiple children so I don't have to recreate the same task for each child separately.

## Details

### Task Bank Concept

- A **task template** is a global task definition: name (max 30 chars) + icon
- Task templates live in the **task bank**, managed in the parent management view
- A template can be **assigned** to one or more children within a specific topic
- The assignment creates a link: child + topic + task template
- Each assignment has its own **completion state** (done/not done) — independent per child
- **Editing** a task template (name or icon) updates it everywhere it's assigned
- **Deleting** a task template removes it from all children and topics

### Task Bank CRUD (Parent Management)

- Parent can **create a task template** — enter name + select icon
- Parent can **edit a task template** — change name or icon (reflected everywhere)
- Parent can **delete a task template** — with confirmation; removes from all assignments
- Task bank is displayed as a list/grid in parent management

### Assigning Tasks to Children

- From the child's task editor (child + topic view), parent can:
  - **Add from bank** — select one or more task templates to assign to this child in this topic
  - **Remove assignment** — unassign a task template from this child/topic (does not delete the template)
- A task template can be assigned to the same child in multiple topics (e.g. "Brush teeth" in both "Morning" and "Evening")
- **Sort order** of assigned tasks is per child per topic (independent of other children)

### Backward Compatibility

- Existing per-child tasks (if any) should be migrated to task bank templates
- The old "add task directly to child" flow is replaced by "add from bank" or "create new in bank and assign"

### Child-Facing View

- Tasks displayed to children look the same as before — name + icon + completion state
- The child does not see or know about the task bank — it's a parent-only concept

## Data Model Impact

- New entity: `TaskTemplate` (id, name, iconIdentifier) — the global task definition
- New entity: `TaskAssignment` (id, child, topic, taskTemplate, sortOrder) — links a template to a child+topic
- `TaskCompletion` now references `TaskAssignment` instead of `Task`
- Old `Task` entity is replaced by `TaskTemplate` + `TaskAssignment`

## Acceptance Criteria

1. Parent can create a task template with name (max 30 chars) and icon
2. Parent can edit a task template — changes reflected for all assigned children
3. Parent can delete a task template (with confirmation) — removed from all children
4. Parent can assign a task template to a child within a topic
5. Parent can unassign a task template from a child/topic without deleting the template
6. A task template can be assigned to multiple children
7. A task template can be assigned to the same child in multiple topics
8. Each child has independent completion state per assigned task
9. Task sort order is per child per topic
10. Child-facing view displays assigned tasks with correct name, icon, and completion state
11. Editing a task template name/icon updates the display for all assigned children immediately

## E2E Test Requirements

- Create task template in bank, assign to child — appears in routine view (XCUITest)
- Edit task template name — updated in all assigned children's routine views (XCUITest)
- Delete task template — removed from all children's routine views (XCUITest)
- Assign same template to two children — both show it (XCUITest)
- Complete task for child A — child B's state remains unchanged (XCUITest)
- Unassign template from child — removed from that child only, others unaffected (XCUITest)
- Assign same template to same child in two topics — appears in both (XCUITest)

## Impact on Existing Requirements

| REQ | Change |
|---|---|
| REQ-004 | Task management replaced by task bank + assignment flow |
| REQ-006 | Per-topic reset now resets TaskAssignment completions, not Task completions |
| ADR-003 | Task entity replaced by TaskTemplate + TaskAssignment |
| ADR-005 | Topic relationship changes from Task to TaskAssignment |
