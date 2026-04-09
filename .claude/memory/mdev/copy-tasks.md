# Copy Tasks Feature

## Implementation (2026-04-09)

### Files created/modified
- `MorningRoutine/Features/ParentManagement/CopyTasksSheet.swift` — NEW: Sheet listing other children with tasks in the same topic. Uses @Query for all children, selection + confirm pattern.
- `MorningRoutine/Features/ParentManagement/TaskEditorView.swift` — MODIFIED: Added `@Query allChildrenForCopy`, computed `otherChildrenWithTasks`, "Kopioi" toolbar button (leading placement), and `.sheet` for CopyTasksSheet.
- All 3 Localizable.strings — Added `taskEditor.copyFrom`, `copySource.title`, `copySource.confirm`, `copySource.empty` keys.
- `MorningRoutine.xcodeproj/project.pbxproj` — Added CopyTasksSheet.swift with UUIDs FA000050/AA000050.

### Architecture notes
- Copy button visibility is conditional: only shown when `otherChildrenWithTasks` is non-empty.
- CopyTasksSheet uses select-then-confirm pattern (not single-tap) to match UI test expectations.
- Copy logic skips templates already assigned to target child (deduplication by template.id).
- Source child's tasks are never modified (read-only access).

### Accessibility identifiers used
- `AX.TaskAssignment.copyFromButton` — toolbar button
- `AX.TaskAssignment.copySourceChildRow(_:)` — child row in sheet
- `AX.TaskAssignment.copySourceConfirmButton` — confirm button in sheet toolbar
- `AX.TaskAssignment.copySourceCancelButton` — cancel button in sheet toolbar
