# DSGN-006: Task Bank UI

**Status:** Draft
**Date:** 2026-03-30
**REQ:** REQ-008, REQ-004 (amended), REQ-006 (amended)

---

## Overview

This design specifies the UI for the Task Bank (Tehtavapankki), a global library of task templates that parents create once and assign to multiple children. The task bank solves the problem of parents having to create the same task (e.g. "Brush teeth") individually for each child -- now a task template is defined once and linked to any number of children within any topic.

From the child's perspective, tasks look identical regardless of whether they originate from a shared template -- the task bank is a parent-only concept, fully transparent to children.

---

## User Flow -- Parent: Managing the Task Bank

1. Parent enters parent management (via PIN gate)
2. Parent Home Screen now shows a "Task Bank" section between "Topics" and "Children" sections
3. Parent creates task templates in the bank (name + icon)
4. Parent can edit or delete templates from the bank
5. Changes to a template propagate to all children who have it assigned

## User Flow -- Parent: Assigning Tasks to Children

1. Parent navigates: Parent Home -> Child row -> Child Topic Picker -> Task Editor (child + topic)
2. In the Task Editor, parent taps "Add from Bank" button
3. A sheet appears showing all task bank templates
4. Templates already assigned to this child+topic are visually marked
5. Parent selects one or more unassigned templates
6. Parent confirms -- selected templates are assigned to this child+topic
7. Parent can remove (unassign) a template from this child+topic by swiping left on the task row
8. Parent can reorder assigned tasks per child per topic via drag-and-drop

## User Flow -- Child-Facing

1. Child sees their task list exactly as before (DSGN-002)
2. Tasks show name + icon + completion state
3. Child does not see or interact with the task bank concept
4. Completing a task for one child does not affect other children's completion state

---

## Parent Management: Task Bank Section

### Updated Parent Home Screen Layout

The Parent Home Screen (DSGN-003, updated by DSGN-004 and DSGN-005) adds a new "Task Bank" section between "Topics" and "Children".

### ASCII Wireframe -- Updated Parent Home Screen

```
+-------------------------------------------------------------------------------------------+
| < Done                        Parent Settings                    [Reset All]              |
|  (44pt tap target)            (Navigation Title)                 (button, red)            |
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|  +-------------------------------------------------------------------+                   |
|  |  Topics                                           [+ Add Topic]   |                   |
|  |-------------------------------------------------------------------|                   |
|  |  ==  Aamu                    [Reset]   [pencil]               >   |                   |
|  |  ==  Ilta                    [Reset]   [pencil]               >   |                   |
|  +-------------------------------------------------------------------+                   |
|                                                                                           |
|  +-------------------------------------------------------------------+                   |
|  |  Task Bank                                    [+ New Template]    |                   |
|  |-------------------------------------------------------------------|                   |
|  |  [icon 36pt]   Brush Teeth               [pencil]                 |                   |
|  |-------------------------------------------------------------------|                   |
|  |  [icon 36pt]   Get Dressed               [pencil]                 |                   |
|  |-------------------------------------------------------------------|                   |
|  |  [icon 36pt]   Eat Breakfast             [pencil]                 |                   |
|  |-------------------------------------------------------------------|                   |
|  |  [icon 36pt]   Pack Backpack             [pencil]                 |                   |
|  |-------------------------------------------------------------------|                   |
|  |  [icon 36pt]   Wash Hands                [pencil]                 |                   |
|  +-------------------------------------------------------------------+                   |
|                                                                                           |
|  +-------------------------------------------------------------------+                   |
|  |  Children                                         [+ Add Child]   |                   |
|  |-------------------------------------------------------------------|                   |
|  |  [avatar]   Mia                          [Edit]               >   |                   |
|  |  [avatar]   Leo                          [Edit]               >   |                   |
|  +-------------------------------------------------------------------+                   |
|                                                                                           |
|  +-------------------------------------------------------------------+                   |
|  |  Settings                                                         |                   |
|  |-------------------------------------------------------------------|                   |
|  |  [lock.fill]   Change PIN                                     >   |                   |
|  +-------------------------------------------------------------------+                   |
|                                                                                           |
+-------------------------------------------------------------------------------------------+
```

### Task Bank Section Details

**Section Header:**
- Label: "Task Bank" (`type.parent.headline`, `color.text.secondary`)
- Right-aligned: "+ New Template" button
  - Icon: `plus.circle.fill`, 24pt, `color.brand.purple`
  - `accessibilityIdentifier`: `"addTemplateButton"`
  - `accessibilityLabel`: "New Template"
  - `accessibilityHint`: "Creates a new task template in the task bank"

**Template Row:**
- Height: 56pt minimum (standard iOS list row)
- Left: task icon thumbnail, 36pt, displayed within a 44x44pt container, `color.brand.purpleLight` background, `radius.sm` (8pt) corner radius
- Centre: template name (`type.parent.headline`, `color.text.primary`)
- Right: edit button
  - Icon: `pencil`, 18pt, `color.brand.purple`
  - Container: 44x44pt tap target
  - `accessibilityIdentifier`: `"templateEditButton_<TemplateName>"`
  - `accessibilityLabel`: "Edit [Template Name]"
  - `accessibilityHint`: "Opens form to edit template name and icon"
- Swipe left: reveals "Delete" action in `color.brand.red`
  - `accessibilityIdentifier`: `"templateDeleteAction_<TemplateName>"`

**Template Row Accessibility:**
- `accessibilityIdentifier`: `"templateRow_<TemplateName>"`
- `accessibilityLabel`: `"<Template Name>"`
- `accessibilityHint`: "Swipe left to delete. Tap edit to change name or icon."

### Empty Task Bank State

When no templates exist:
- Section shows a placeholder row:
  - Text: "No task templates yet. Tap + to create one." (`type.parent.body`, `color.text.secondary`)
  - `accessibilityIdentifier`: `"taskBankEmptyLabel"`

---

## Sheet: Create / Edit Task Template

Presented as a `.sheet` when the parent taps "+ New Template" or the edit pencil on a template row. This sheet is identical in structure to the existing Add/Edit Task sheet (DSGN-003) with minor labelling changes.

### ASCII Wireframe

```
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|  +-------------------------------------------------------------+                         |
|  | Cancel              New Template                      Save  |                         |
|  |-------------------------------------------------------------|                         |
|  |                                                             |                         |
|  |  Task Icon                                                  |                         |
|  |  +---------------------------+                             |                         |
|  |  | [icon 80x80pt]            |  [Choose Icon button]       |                         |
|  |  |  selected icon preview    |  "Choose Icon"              |                         |
|  |  |  radius.md bg tint        |  (opens icon picker)        |                         |
|  |  +---------------------------+                             |                         |
|  |                                                             |                         |
|  |  Template Name                                              |                         |
|  |  +-------------------------------------------------------+ |                         |
|  |  | Brush Teeth                              [11/30]       | |                         |
|  |  +-------------------------------------------------------+ |                         |
|  |  Text field, 17pt, max 30 chars, character counter         |                         |
|  |                                                             |                         |
|  +-------------------------------------------------------------+                         |
|                                                                                           |
+-------------------------------------------------------------------------------------------+
```

### Sheet Component Details

**Header:**
- Cancel button (left): dismisses sheet with no changes
  - `type.parent.headline`, `color.brand.purple`
  - `accessibilityIdentifier`: `"templateFormCancelButton"`
- Title: "New Template" or "Edit Template" (`type.parent.headline`, centre)
- Save button (right): enabled only when name is non-empty AND an icon is selected
  - `type.parent.headline`, `color.brand.purple`
  - `accessibilityIdentifier`: `"templateFormSaveButton"`
  - `accessibilityLabel`: "Save template"
  - Disabled state: opacity 0.4

**Icon Picker Area:**
- Identical to DSGN-003 icon picker (same SF Symbol library from DSGN-001 Section 6.3, same photo library option)
- Selected icon preview: 80x80pt container, `color.brand.purpleLight` background, `radius.md`
- "Choose Icon" button:
  - `accessibilityIdentifier`: `"templateChooseIconButton"`
  - `accessibilityLabel`: "Choose icon"
  - `accessibilityHint`: "Opens icon library or photo picker"
- Default state (new template): `questionmark.circle.fill`, muted
- An icon MUST be selected to enable Save

**Template Name Field:**
- Placeholder: "Template name"
- Max length: 30 characters, enforced in real time
- Character counter: "[current]/30", `type.parent.caption` (13pt), `color.text.secondary`
- Counter turns `color.brand.red` at 30
- `accessibilityIdentifier`: `"templateNameField"`
- `accessibilityLabel`: "Template name"
- `accessibilityHint`: "Maximum 30 characters"

### Presentation

- `.presentationDetents([.medium, .large])` -- starts at medium height
- Background: `color.background.parentScreen`

---

## Dialog: Delete Task Template Confirmation

Triggered by swiping left on a template row in the Task Bank section.

### Presentation

Presented as a `.confirmationDialog`:

```
+-----------------------------------------------+
|                                               |
|   Delete "Brush Teeth"?                       |
|                                               |
|   This template is assigned to 3 children     |
|   across 2 topics. Deleting it will remove    |
|   it from all assignments. This cannot be     |
|   undone.                                     |
|                                               |
|   [ Delete Template ]   <- destructive, red   |
|   [ Cancel ]            <- cancel             |
|                                               |
+-----------------------------------------------+
```

### Details

- Title: `Delete "<Template Name>"?`
- Message: dynamically constructed based on current assignment count:
  - If assigned: `This template is assigned to [N] children across [M] topics. Deleting it will remove it from all assignments. This cannot be undone.`
  - If not assigned: `This template is not assigned to any children. This cannot be undone.`
- Destructive button: "Delete Template" (`color.brand.red`)
  - `accessibilityIdentifier`: `"deleteTemplateConfirmButton"`
- Cancel button: "Cancel"
  - `accessibilityIdentifier`: `"deleteTemplateCancelButton"`
- On confirm: template is deleted from the bank and removed from all child+topic assignments; affected children's routine views update immediately

---

## Task Editor: Updated with Bank Assignment Flow

The existing Task Editor screen (DSGN-003 Screen 4, scoped to child+topic per DSGN-004) is updated to work with the task bank instead of inline task creation.

### ASCII Wireframe -- Updated Task Editor

```
+-------------------------------------------------------------------------------------------+
| < Mia's Topics          Mia's Tasks - Aamu                    [+ Add from Bank]          |
|                          (Navigation Title)                                               |
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|  +-------------------------------------------------------------------+                   |
|  |  ==  [icon 44pt]   Brush Teeth                                    |                   |
|  |-------------------------------------------------------------------|                   |
|  |  ==  [icon 44pt]   Get Dressed                                    |                   |
|  |-------------------------------------------------------------------|                   |
|  |  ==  [icon 44pt]   Eat Breakfast                                  |                   |
|  |-------------------------------------------------------------------|                   |
|  |  ==  [icon 44pt]   Pack Backpack                                  |                   |
|  +-------------------------------------------------------------------+                   |
|                                                                                           |
|  (Swipe left on a row to reveal "Remove" -- unassigns template                           |
|   from this child+topic, does NOT delete from bank)                                      |
|  (Drag reorder handle == to reorder)                                                     |
|                                                                                           |
|  Background: color.background.parentScreen                                               |
+-------------------------------------------------------------------------------------------+
```

### Key Changes from DSGN-003 Task Editor

1. **No inline "Add Task" or "Edit Task" buttons** -- tasks are added via bank assignment
2. **"+ Add from Bank"** replaces "+ Add Task" in the navigation bar
3. **No per-row edit pencil** -- editing a template is done in the Task Bank section, not inline
4. **Swipe-left action** is "Remove" (unassign), not "Delete" -- the template remains in the bank
5. **Reorder** is preserved -- per child per topic sort order

### Navigation Bar Buttons

- Left: Back button (system default, "[Child Name]'s Topics" as back label)
- Right: "+ Add from Bank"
  - Icon: `plus.circle.fill`, 24pt, `color.brand.purple`
  - Label: "Add from Bank" (text visible alongside icon)
  - `accessibilityIdentifier`: `"addFromBankButton"`
  - `accessibilityLabel`: "Add from Bank"
  - `accessibilityHint`: "Opens task bank to assign templates to this child and topic"

### Assigned Task Row

Each task row represents an assigned template:
- Height: 56pt minimum
- Left: reorder handle (`line.3.horizontal`, 18pt, `color.text.secondary`)
  - `accessibilityIdentifier`: `"assignmentReorderHandle_<TemplateName>"`
  - `accessibilityLabel`: "Reorder [Template Name]"
- Left+1: task icon thumbnail, 44x44pt, corner radius `radius.md` (16pt), background `color.child{N}.tint`
- Centre: task name label (`type.parent.headline`, `color.text.primary`)
- Swipe left: reveals "Remove" action in `color.brand.orange`
  - Label: "Remove" (not "Delete" -- visual differentiation from destructive delete)
  - Background: `color.brand.orange` (instead of `color.brand.red` -- indicates unassignment, not deletion)
  - `accessibilityIdentifier`: `"assignmentRemoveAction_<TemplateName>"`
  - `accessibilityLabel`: "Remove [Template Name] from [Child Name]'s [Topic Name]"

**Row accessibility:**
- `accessibilityIdentifier`: `"assignmentRow_<ChildName>_<TopicName>_<TemplateName>"`
- `accessibilityLabel`: `"<Template Name>"`
- `accessibilityHint`: "Swipe left to remove from this child's topic."

### Empty Task Editor State

When no templates are assigned to this child+topic:
- Placeholder text centred in the list area:
  - Text: "No tasks assigned. Tap 'Add from Bank' to assign tasks." (`type.parent.body`, `color.text.secondary`)
  - `accessibilityIdentifier`: `"taskEditorEmptyLabel"`

---

## Sheet: Add from Bank (Template Selector)

Presented as a `.sheet` when the parent taps "+ Add from Bank" in the Task Editor.

### ASCII Wireframe

```
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|  +-------------------------------------------------------------+                         |
|  | Cancel            Add Tasks from Bank           [Add (3)]   |                         |
|  |-------------------------------------------------------------|                         |
|  |  [Search field: "Search templates..."]                       |                         |
|  |-------------------------------------------------------------|                         |
|  |                                                             |                         |
|  |  [v]  [icon 44pt]   Brush Teeth          ASSIGNED           |                         |
|  |  [v]  [icon 44pt]   Get Dressed          ASSIGNED           |                         |
|  |  [ ]  [icon 44pt]   Eat Breakfast                           |                         |
|  |  [ ]  [icon 44pt]   Pack Backpack                           |                         |
|  |  [ ]  [icon 44pt]   Wash Hands                              |                         |
|  |  [ ]  [icon 44pt]   Take Medicine                           |                         |
|  |  [ ]  [icon 44pt]   Reading Time                            |                         |
|  |                                                             |                         |
|  |  (Scroll for more)                                          |                         |
|  |                                                             |                         |
|  |-------------------------------------------------------------|                         |
|  |  Don't see what you need?                                   |                         |
|  |  [ Create New Template ]                                    |                         |
|  +-------------------------------------------------------------+                         |
|                                                                                           |
+-------------------------------------------------------------------------------------------+
```

### Sheet Component Details

**Header:**
- Cancel button (left): dismisses sheet with no changes
  - `type.parent.headline`, `color.brand.purple`
  - `accessibilityIdentifier`: `"bankSelectorCancelButton"`
- Title: "Add Tasks from Bank" (`type.parent.headline`, centre)
- Add button (right): shows count of newly selected templates, e.g. "Add (3)"
  - `type.parent.headline`, `color.brand.purple`
  - Enabled only when at least 1 new template is selected
  - `accessibilityIdentifier`: `"bankSelectorAddButton"`
  - `accessibilityLabel`: "Add [N] templates"
  - `accessibilityHint`: "Assigns selected templates to this child and topic"
  - Disabled state: "Add (0)", opacity 0.4

**Search Field:**
- Placeholder: "Search templates..."
- Real-time filter of template list by name
- `accessibilityIdentifier`: `"bankSelectorSearchField"`

**Template List:**

Each template row in the selector:
- Height: 56pt minimum
- Left: selection indicator
  - **Already assigned** (to this child+topic): filled checkbox `checkmark.square.fill`, `color.brand.green`, non-interactive (cannot re-assign an already-assigned template)
  - **Not assigned, selected for assignment:** filled checkbox `checkmark.square.fill`, `color.brand.purple`
  - **Not assigned, not selected:** empty checkbox `square`, `color.text.secondary`
  - Checkbox size: 24pt icon in 44x44pt tap target
- Left+1: task icon thumbnail, 44x44pt, `color.brand.purpleLight` background, `radius.md`
- Centre: template name (`type.parent.headline`, `color.text.primary`)
- Right (already assigned): "ASSIGNED" badge
  - `type.parent.caption` (13pt), `color.brand.green`, uppercase
  - Background: `color.background.taskComplete`, `radius.full` (pill), horizontal padding `spacing.xs` (8pt)

**Template Row Accessibility:**
- `accessibilityIdentifier`: `"bankSelectorRow_<TemplateName>"`
- `accessibilityLabel` (not assigned): `"<Template Name>, not assigned"`
- `accessibilityLabel` (already assigned): `"<Template Name>, already assigned"`
- `accessibilityLabel` (selected for assignment): `"<Template Name>, selected for assignment"`
- `accessibilityTraits` (already assigned): `.isButton`, `.isSelected`, `.isNotEnabled`
- `accessibilityTraits` (selectable): `.isButton`
- `accessibilityHint` (selectable): "Double tap to select for assignment"
- `accessibilityHint` (already assigned): "Already assigned to this child and topic"

**Multi-Select Behaviour:**
- Tapping a non-assigned, non-selected row toggles its selection ON (checkbox fills)
- Tapping a selected row toggles its selection OFF (checkbox empties)
- Already-assigned rows cannot be toggled (they remain checked and non-interactive)
- The "Add (N)" button count updates in real time as selections change
- Selection uses `.listStyle(.plain)` with custom row tap handling

**Create New Template Shortcut:**
- At the bottom of the list, a "Create New Template" button allows the parent to create a new template without leaving the flow
- `type.parent.headline`, `color.brand.purple`
- `accessibilityIdentifier`: `"bankSelectorCreateNewButton"`
- `accessibilityLabel`: "Create New Template"
- `accessibilityHint`: "Opens form to create a new task template"
- Tapping presents the Create Template sheet (same as from the Task Bank section) as a nested sheet
- After creating, the new template appears in the selector list, pre-selected for assignment

### Presentation

- `.presentationDetents([.large])` -- full height to show the complete template list
- Background: `color.background.parentScreen`

---

## Unassign (Remove) Confirmation

Swiping left on an assignment row in the Task Editor reveals the "Remove" action. Unlike deleting a template, removing an assignment does NOT require a confirmation dialog -- the action is non-destructive (the template remains in the bank and can be re-assigned).

- Swipe action label: "Remove"
- Swipe action background: `color.brand.orange` (not red -- signals unassignment, not deletion)
- Result: the template is unassigned from this child+topic; the task row disappears from the Task Editor
- The template remains in the Task Bank and in any other child+topic assignments
- VoiceOver announcement after removal: "[Template Name] removed from [Child Name]'s [Topic Name]"

---

## Sort Order Management

Each child has an independent sort order per topic for their assigned tasks.

- Reorder via drag-and-drop in the Task Editor (same as DSGN-003 reorder behaviour)
- Drag handle: `line.3.horizontal`, 18pt, `color.text.secondary`
- During drag: row lifts with `shadow.card` and slight scale (1.02)
- Drop: row settles with `easing.spring` (300ms)
- Reduce Motion: no lift, instant position swap
- Changes persist immediately (SwiftData)
- Routine view column task order matches parent-defined order per child per topic
- When a new template is assigned, it is added at the end of the sort order for that child+topic
- VoiceOver: `accessibilityCustomActions` "Move Up" and "Move Down" on each assignment row

---

## Child-Facing View: Transparent Task Display

Tasks in the child-facing routine view look and behave identically regardless of their origin from the task bank. The child sees:

- Task icon (from the template's icon)
- Task name (from the template's name)
- Completion state (per assignment, independent per child)
- All visual styling as defined in DSGN-002 (task row states, star animation, celebration)

### What Happens When a Template is Edited

If a parent edits a template's name or icon in the Task Bank:
- All children who have this template assigned see the updated name and icon immediately
- Completion states are NOT affected (completed tasks remain completed)
- No animation or notification is shown to the child

### What Happens When a Template is Deleted

If a parent deletes a template from the Task Bank:
- The task disappears from all children's routine views immediately
- If a child had completed this task, the completion is deleted
- Progress indicators update to reflect the new task count
- If all remaining tasks are complete after deletion, the celebration state activates

---

## Visual Design

### Design Tokens Used

No new tokens are required. This design uses existing tokens from DSGN-001:

| Usage | Token |
|-------|-------|
| Template row icon container bg | `color.brand.purpleLight` |
| Template row icon container radius | `radius.sm` (8pt) |
| Template row icon size | 36pt (in parent list), 44pt (in task editor) |
| "ASSIGNED" badge bg | `color.background.taskComplete` |
| "ASSIGNED" badge text | `color.brand.green` |
| "ASSIGNED" badge radius | `radius.full` (pill) |
| Remove swipe action bg | `color.brand.orange` |
| Selection checkbox (selected) | `color.brand.purple` |
| Selection checkbox (assigned) | `color.brand.green` |
| Selection checkbox (empty) | `color.text.secondary` |
| Create New button | `color.brand.purple` |
| Template form icon preview | `color.brand.purpleLight`, `radius.md` |

### Dark Mode

All elements use existing tokens with defined dark mode variants. No additional dark mode handling required.

---

## Accessibility (WCAG 2.2 AA)

### Contrast Ratios

| Foreground | Background | Ratio | Requirement | Status |
|------------|------------|-------|-------------|--------|
| "ASSIGNED" badge text (`color.brand.green` #34C759) | `color.background.taskComplete` (#E8FAF0) | **3.4:1** | >= 3:1 UI | PASS |
| Template name (`color.text.primary` #1C1C1E) | `color.background.parentScreen` (#F2F2F7) | **15.4:1** | >= 4.5:1 text | PASS |
| Checkbox (`color.text.secondary` #3A3A3C) | row bg (#FFFFFF) | **10.4:1** | >= 3:1 UI | PASS |
| "Remove" label (#FFFFFF) | `color.brand.orange` (#FF9500) | **3.1:1** | >= 3:1 UI | PASS |
| All dark mode variants | respective backgrounds | >= 4.5:1 | >= 4.5:1 text | PASS |

### Touch Targets

| Element | Visual Size | Touch Target | Minimum Required | Status |
|---------|------------|--------------|------------------|--------|
| Template row (bank section) | 56pt x full | 56pt x full | 44x44pt | PASS |
| Template edit button | 18pt icon | 44x44pt | 44x44pt | PASS |
| Template form Save button | text | 44x44pt | 44x44pt | PASS |
| Selector checkbox | 24pt icon | 44x44pt | 44x44pt | PASS |
| Selector row | 56pt x full | 56pt x full | 44x44pt | PASS |
| "Add from Bank" button | text + icon | 44x44pt | 44x44pt | PASS |
| Assignment row (task editor) | 56pt x full | 56pt x full | 44x44pt | PASS |
| "Create New Template" button | text | 44x44pt | 44x44pt | PASS |

### VoiceOver

**Task Bank section (Parent Home):**
- VoiceOver reads: "Task Bank" section header, then template rows in order
- Each template row: "[Template Name]. Swipe left to delete. Tap edit to change name or icon."

**Bank Selector sheet:**
- VoiceOver announces selection state for each row
- Multi-select count is announced via the "Add (N)" button label update
- Already-assigned templates are announced as "already assigned" and non-interactive

**Task Editor (updated):**
- Assignment rows announce template name and available actions
- "Add from Bank" button in navigation bar is announced

**Routine view (child-facing):**
- No change -- tasks are announced identically to DSGN-002

### Dynamic Type

- All parent-facing text uses standard `type.parent.*` tokens that scale with Dynamic Type
- Template list rows accommodate taller text at larger sizes by expanding row height
- Bank selector sheet uses `.presentationDetents([.large])` to ensure enough space

### Reduce Motion

- Template form sheet presentation: system default sheet animation (respects OS setting)
- Bank selector sheet: same
- Assignment removal: row disappears without animation (no slide-out)

### Switch Control / Full Keyboard Access

**Updated focus order for Parent Home:**
1. Done button
2. Reset All button
3. Topics section (as defined in DSGN-004)
4. "Task Bank" section header
5. Template rows (each: name, edit button)
6. "+ New Template" button
7. Children section (as defined in DSGN-004/005)
8. Settings section

**Focus order for Bank Selector:**
1. Cancel button
2. Search field
3. Template rows (each: checkbox, name)
4. "Create New Template" button
5. Add button

**Focus order for Updated Task Editor:**
1. Back button
2. "Add from Bank" button
3. Assignment rows in sort order (each: reorder handle, icon, name)

---

## iOS-Specific Considerations

### Modal Presentation

- Create/Edit Template sheet: `.presentationDetents([.medium, .large])` -- starts at medium height
- Bank Selector sheet: `.presentationDetents([.large])` -- full height for browsing
- Nested "Create New Template" sheet from within Bank Selector: `.presentationDetents([.medium, .large])` -- standard nested sheet presentation (iOS 16.4+)

### Safe Area Handling

- All parent management screens use standard `NavigationStack` views -- system handles safe area
- Sheets respect system presentation logic

### iPadOS Keyboard

- Template name field: `submitLabel: .done`, dismiss keyboard on submit
- Bank selector search field: `submitLabel: .search`
- Arrow keys navigate template list when keyboard is focused on the list

### SwiftData Considerations

- Editing a `TaskTemplate` name/icon propagates to all `TaskAssignment` references automatically (relationship)
- Deleting a `TaskTemplate` cascades to delete all `TaskAssignment` records (cascade delete rule)
- `TaskCompletion` references `TaskAssignment`, which references `TaskTemplate` -- cascading deletions handle cleanup

---

## Accessibility Identifiers -- Full Reference (XCUITest)

### Parent Home -- Task Bank Section

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| "+ New Template" button | `addTemplateButton` |
| Template row | `templateRow_<TemplateName>` |
| Template edit button | `templateEditButton_<TemplateName>` |
| Template delete swipe action | `templateDeleteAction_<TemplateName>` |
| Task bank empty label | `taskBankEmptyLabel` |

### Create / Edit Template Sheet

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| Cancel button | `templateFormCancelButton` |
| Save button | `templateFormSaveButton` |
| Template name field | `templateNameField` |
| Choose icon button | `templateChooseIconButton` |

### Delete Template Dialog

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| Delete confirm button | `deleteTemplateConfirmButton` |
| Delete cancel button | `deleteTemplateCancelButton` |

### Updated Task Editor (Child + Topic)

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| "Add from Bank" button | `addFromBankButton` |
| Assignment row | `assignmentRow_<ChildName>_<TopicName>_<TemplateName>` |
| Assignment reorder handle | `assignmentReorderHandle_<TemplateName>` |
| Assignment remove swipe action | `assignmentRemoveAction_<TemplateName>` |
| Task editor empty label | `taskEditorEmptyLabel` |

### Bank Selector Sheet

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| Cancel button | `bankSelectorCancelButton` |
| Add button | `bankSelectorAddButton` |
| Search field | `bankSelectorSearchField` |
| Template selector row | `bankSelectorRow_<TemplateName>` |
| Create New Template button | `bankSelectorCreateNewButton` |

### Identifier Naming Convention

`<TemplateName>` uses PascalCase with spaces removed, consistent with existing naming (DSGN-002). Example: "Brush Teeth" becomes `BrushTeeth`.

### Superseded Identifiers from DSGN-003

The following identifiers from DSGN-003 Task Editor are replaced by the new bank-based flow:

| Old (DSGN-003) | New (DSGN-006) | Reason |
|----------------|----------------|--------|
| `addTaskButton` | `addFromBankButton` | Tasks are now assigned from bank, not created inline |
| `taskEditorRow_<TaskName>` | `assignmentRow_<Child>_<Topic>_<Template>` | Rows represent assignments, not standalone tasks |
| `taskEditButton_<TaskName>` | (removed) | Templates are edited in the Task Bank section |
| `taskDeleteAction_<TaskName>` | `assignmentRemoveAction_<TemplateName>` | "Remove" (unassign) replaces "Delete" |
| `taskReorderHandle_<TaskName>` | `assignmentReorderHandle_<TemplateName>` | Renamed for clarity |
| `deleteTaskConfirmButton` | (removed) | Unassignment does not require confirmation |
| `deleteTaskCancelButton` | (removed) | No confirmation dialog for unassignment |
| `taskFormCancelButton` | `templateFormCancelButton` | Template form replaces task form |
| `taskFormSaveButton` | `templateFormSaveButton` | Template form replaces task form |
| `taskNameField` | `templateNameField` | Template field replaces task field |
| `chooseIconButton` | `templateChooseIconButton` | Scoped to template context |

---

## Acceptance Criteria for Design

| ID | Criterion | `accessibilityIdentifier` / Method |
|----|-----------|-----------------------------------|
| TB-AC-01 | Task Bank section is visible on Parent Home Screen between Topics and Children | XCUITest: `addTemplateButton.exists == true` between topics section and children section |
| TB-AC-02 | Parent can create a task template with name and icon | XCUITest: `addTemplateButton` tap -> fill `templateNameField`, choose icon -> `templateFormSaveButton` tap -> `templateRow_<Name>.exists == true` |
| TB-AC-03 | Template name field enforces 30-character maximum | XCUITest: type 35 chars -> `templateNameField.value.count == 30` |
| TB-AC-04 | Save button disabled when template name empty or no icon | XCUITest: empty form -> `templateFormSaveButton.isEnabled == false` |
| TB-AC-05 | Parent can edit a task template (name and icon) | XCUITest: `templateEditButton_<Name>` tap -> sheet with pre-filled fields, change name -> save -> `templateRow_<NewName>.exists == true` |
| TB-AC-06 | Editing a template updates display for all assigned children | XCUITest: edit template name -> verify routine view task labels updated for all assigned children |
| TB-AC-07 | Parent can delete a task template with confirmation showing assignment count | XCUITest: swipe left on `templateRow_<Name>` -> `deleteTemplateConfirmButton.exists == true`, dialog message contains assignment count |
| TB-AC-08 | Deleting a template removes it from all children's routine views | XCUITest: confirm delete -> `task_<ChildName>_<TemplateName>.exists == false` for all previously assigned children |
| TB-AC-09 | Task Editor shows "Add from Bank" button instead of "Add Task" | XCUITest: navigate to task editor -> `addFromBankButton.exists == true` and `addTaskButton.exists == false` |
| TB-AC-10 | Bank Selector shows all templates with selection checkboxes | XCUITest: `addFromBankButton` tap -> `bankSelectorRow_<Name>.exists == true` for each template |
| TB-AC-11 | Already-assigned templates show "ASSIGNED" badge and are non-interactive | XCUITest: `bankSelectorRow_<AssignedName>` has `isEnabled == false` or appropriate accessibility trait |
| TB-AC-12 | Parent can multi-select templates for assignment | XCUITest: tap multiple `bankSelectorRow_*` rows -> `bankSelectorAddButton.label` updates count |
| TB-AC-13 | Confirming assignment adds templates to the task editor | XCUITest: select templates, tap `bankSelectorAddButton` -> new `assignmentRow_*` elements appear |
| TB-AC-14 | Parent can unassign (remove) a template by swiping left | XCUITest: swipe left on `assignmentRow_*` -> "Remove" action -> row disappears |
| TB-AC-15 | Removing an assignment does not delete the template from the bank | XCUITest: remove assignment -> `templateRow_<Name>.exists == true` still in Task Bank |
| TB-AC-16 | Remove swipe action uses orange (not red) background | Visual inspection: swipe-left background is `color.brand.orange` |
| TB-AC-17 | Sort order is per child per topic (independent) | XCUITest: reorder tasks for child A in topic X -> child B's order in topic X is unchanged |
| TB-AC-18 | Same template can be assigned to multiple children | XCUITest: assign template to child A and child B -> both show it in routine view |
| TB-AC-19 | Same template can be assigned to same child in multiple topics | XCUITest: assign template to child A in both "Aamu" and "Ilta" -> appears in both tabs |
| TB-AC-20 | Completing a task for child A does not affect child B | XCUITest: complete task for child A -> child B's same task `accessibilityValue == "not done"` |
| TB-AC-21 | Child-facing view displays tasks identically regardless of bank origin | Visual inspection: task rows match DSGN-002 spec exactly |
| TB-AC-22 | Empty task bank shows placeholder message | XCUITest: with no templates, `taskBankEmptyLabel.exists == true` |
| TB-AC-23 | Empty task editor shows placeholder message | XCUITest: with no assignments, `taskEditorEmptyLabel.exists == true` |
| TB-AC-24 | Bank Selector has search functionality | XCUITest: `bankSelectorSearchField` type -> list filters by template name |
| TB-AC-25 | "Create New Template" button in Bank Selector opens template creation form | XCUITest: `bankSelectorCreateNewButton` tap -> `templateFormSaveButton.exists == true` |
| TB-AC-26 | All touch targets in parent views are >= 44x44pt | XCUITest: frame assertions on all interactive elements |
| TB-AC-27 | VoiceOver announces template selection states correctly | Manual VoiceOver test: verify "not assigned", "already assigned", "selected for assignment" states announced |
