# Task Bank (REQ-008) Implementation Notes

## Date: 2026-04-03

## New Models Created
- `MiniMissions/Models/TaskTemplate.swift` — Global task definition (name + icon)
- `MiniMissions/Models/TaskAssignment.swift` — Links template to child+topic with sortOrder

## Models Updated
- `TaskCompletion.swift` — task is now optional, added optional assignment relationship
- `Child.swift` — added assignments relationship
- `Topic.swift` — added topicAssignments relationship
- `Task.swift` — removed @Relationship inverse on completions (since task is now optional)

## New UI Files
- `AddEditTemplateSheet.swift` — Create/edit template (name + icon)
- `BankSelectorSheet.swift` — Multi-select templates for assignment to child+topic

## Updated UI Files
- `ParentHomeView.swift` — Added Task Bank section between Topics and Children
- `TaskEditorView.swift` — Now shows TaskAssignments, "Add from Bank" replaces "Add Task"
- `ChildColumnView.swift` — Uses TaskAssignment instead of Task
- `TaskRowView.swift` — Takes TaskAssignment instead of Task
- `ChildRoutineViewModel.swift` — Added assignment-based completion methods
- `ChildTopicPickerView.swift` — Uses topicAssignments for task count
- `ResetService.swift` — Handles both legacy Task and TaskAssignment completions

## Xcode Project
- pbxproj IDs: FA000034-FA000037 (file refs), AA000034-AA000037 (build files)
- Added to Models group and ParentManagement group

## Key Patterns
- `String.pascalCase` extension in TaskEditorView.swift for AX identifiers
- AX identifiers follow `AX.TaskBank.*` and `AX.TaskAssignment.*` namespaces
- BankSelectorSheet uses @Query for all templates, computed properties for assigned/filtered
- AddEditTemplateSheet has optional `onSave` callback for pre-selecting in BankSelector
- Task model kept for backward compat; child-facing views now use TaskAssignment only

## Known Issue
- Pre-existing: UI tests fail in simulator due to app startup issue (parentSettingsButton not found)
  This affects ALL existing UI tests, not just Task Bank tests. Not caused by REQ-008 changes.
