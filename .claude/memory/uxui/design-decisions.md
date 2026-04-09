# UXUI Design Decisions Memory

## Design System
- All tokens defined in DSGN-001 (colors, typography, spacing, radius, shadows, animations)
- Child-facing: SF Rounded, min 24pt, min 60x60pt touch targets
- Parent-facing: SF Pro, standard iOS HIG, 44x44pt touch targets
- 8pt base grid, 4pt half-step allowed

## Documents Created
- DSGN-001: Design System (Draft, 2026-03-26)
- DSGN-002: Morning Routine View (Draft, 2026-03-26)
- DSGN-003: Parent Management View (Draft, 2026-03-26)
- DSGN-004: Topic Tab Navigation & Topic Management (Draft, 2026-03-30)
- DSGN-005: Dynamic Children UI (Draft, 2026-03-30)
- DSGN-006: Task Bank UI (Draft, 2026-03-30)

## Key DSGN-004 Decisions
- Topic tab bar placed at top of routine view, above child columns, within a card container
- Gear icon moved inside the tab bar container (right-aligned)
- Active tab: purple pill with white text; Inactive: purple-light pill with primary text
- Tab minimum: 120x60pt, pill shape (radius.full)
- Tab transition: horizontal slide (direction-aware), 300ms easeInOut
- Single tab still shows tab bar for consistency
- Parent Home gets new "Topics" section above "Children"
- Child row now navigates to Child Topic Picker -> then to Task Editor (scoped to child+topic)
- "Reset Day" renamed to "Reset All"; per-topic reset added
- Last topic cannot be deleted (swipe action hidden)
- Topic add/rename via alerts with text field; delete via confirmationDialog

## Key DSGN-005 Decisions
- Adaptive column layout: 1-3 children = single row, 4-6 children = 2-row grid
- 1 child: single centred column, max 400pt
- 4 children: 2x2 grid; 5: 3+2 centred; 6: 2x3 grid
- Compact card variant for 4-6: smaller avatar (56pt), smaller task rows (64pt min), smaller fonts (20pt tasks)
- Compact mode touch targets still >= 60x60pt (full row is tap target)
- Empty state (0 children): welcome card with "Open Settings" button
- 3 new child accent colour pairs: child4 (pink #E91E63), child5 (blue #1E88E5), child6 (amber #E68900)
- Default avatar: first initial on accent colour background (no photo)
- Add/Edit Child sheet: name field (max 30) + photo picker (PHPicker, optional)
- Delete child: confirmation dialog, swipe-to-delete hidden on last child
- Max 6 children: add button disabled + info label
- Child reorder: drag-and-drop in parent management
- Transition animations: scale+opacity for add/remove, layout reconfiguration animated

## Key DSGN-006 Decisions
- Task Bank section on Parent Home between Topics and Children
- Template CRUD: create/edit via sheet (name + icon), delete via confirmationDialog with assignment count
- Task Editor updated: "Add from Bank" replaces "Add Task", no inline edit, "Remove" (orange) replaces "Delete" (red)
- Bank Selector: multi-select sheet, already-assigned shown as non-interactive with "ASSIGNED" badge
- "Create New Template" shortcut in bank selector for inline creation
- Remove (unassign) does NOT require confirmation (non-destructive)
- Remove swipe action uses orange (#FF9500) not red to distinguish from delete
- Sort order per child per topic, managed by drag-and-drop in task editor
- Child-facing view: tasks transparent, identical to DSGN-002 regardless of bank origin

## Superseded Identifiers (DSGN-006 replaces DSGN-003)
- addTaskButton -> addFromBankButton
- taskEditorRow_<TaskName> -> assignmentRow_<Child>_<Topic>_<Template>
- taskEditButton_<TaskName> -> (removed, edit in bank section)
- taskDeleteAction_<TaskName> -> assignmentRemoveAction_<TemplateName>
- taskReorderHandle_<TaskName> -> assignmentReorderHandle_<TemplateName>
- taskFormCancelButton -> templateFormCancelButton
- taskFormSaveButton -> templateFormSaveButton
- taskNameField -> templateNameField
- chooseIconButton -> templateChooseIconButton

## Renamed Accessibility Identifiers (DSGN-004)
- resetDayButton -> resetAllButton
- resetDayConfirmButton -> resetAllConfirmButton
- resetDayCancelButton -> resetAllCancelButton

## Open Design Issues
- None currently
