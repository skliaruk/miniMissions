// AccessibilityIdentifiers.swift
// Centralised accessibility identifier constants for XCUITest queries.
// This file is included in BOTH the app target and the MiniMissionsUITests target.
// Source of truth: ADR-004 §4 Accessibility Identifier Strategy + DSGN-002 + DSGN-003.
//
// Never use raw strings in tests — always reference constants from this file.

import Foundation

// MARK: - Top-level AX namespace

/// Top-level namespace for all accessibility identifiers used by XCUITest.
enum AX {

    // MARK: - Child Routine View

    /// Identifiers for the child-facing Morning Routine View (REQ-001, REQ-002, DSGN-002).
    enum ChildRoutine {
        /// Root container of the child routine screen.
        static let root = "childRoutine_root"

        /// Child column card at the given sort-order index (0, 1, or 2).
        static func column(_ index: Int) -> String { "childRoutine_column_\(index)" }

        /// Child name label inside the column at the given sort-order index.
        static func childName(_ index: Int) -> String { "childRoutine_childName_\(index)" }

        /// Task row for a specific child (childIndex) and task (taskIndex).
        static func taskRow(_ childIndex: Int, _ taskIndex: Int) -> String {
            "childRoutine_taskRow_\(childIndex)_\(taskIndex)"
        }

        /// Tappable task completion button for a specific child and task.
        static func taskButton(_ childIndex: Int, _ taskIndex: Int) -> String {
            "childRoutine_taskButton_\(childIndex)_\(taskIndex)"
        }

        /// The small gear/settings button that opens the parental gate.
        static let parentEntryButton = "childRoutine_parentEntryButton"

        /// Celebration overlay shown when all tasks in a child's column are complete.
        static func celebrationView(_ childIndex: Int) -> String {
            "childRoutine_celebrationView_\(childIndex)"
        }

        /// Star animation overlay (full burst) shown after tapping an incomplete task.
        /// ABSENT when --reduce-motion is active. Compare with starAnimation which shows a static state.
        static func starBurstAnimation(_ childIndex: Int, _ taskIndex: Int) -> String {
            "childRoutine_starBurstAnimation_\(childIndex)_\(taskIndex)"
        }

        /// Static star highlight shown instead of the burst animation when Reduce Motion is ON.
        static func starAnimation(_ childIndex: Int, _ taskIndex: Int) -> String {
            "childRoutine_starAnimation_\(childIndex)_\(taskIndex)"
        }

        // MARK: DSGN-002 name-based identifiers (used alongside index-based ones)

        /// Child column card identified by the child's name (PascalCase, spaces removed).
        static func columnByName(_ name: String) -> String { "childColumn_\(name)" }

        /// Child name label identified by the child's name.
        static func childNameLabel(_ name: String) -> String { "childName_\(name)" }

        /// Child avatar image identified by the child's name.
        static func childAvatar(_ name: String) -> String { "childAvatar_\(name)" }

        /// Progress indicator (dot row) for a child identified by name.
        static func progressIndicator(_ name: String) -> String { "progressIndicator_\(name)" }

        /// Task row identified by child name and task name (PascalCase, spaces removed).
        static func taskByName(child: String, task: String) -> String { "task_\(child)_\(task)" }

        /// Celebration view identified by child name.
        static func celebrationByName(_ name: String) -> String { "celebrationView_\(name)" }

        /// Star reward overlay identified by child name.
        static func starRewardOverlay(_ name: String) -> String { "starRewardOverlay_\(name)" }

        /// Parent settings gear button — DSGN-002 uses this identifier.
        static let parentSettingsButton = "parentSettingsButton"
    }

    // MARK: - PIN Gate View

    /// Identifiers for the PIN entry and PIN setup screens (REQ-003, DSGN-003).
    enum PINGate {
        /// Root container of the PIN entry screen.
        static let root = "pinGate_root"

        /// Individual digit field at position 0–3 in the PIN entry screen.
        static func digitField(_ index: Int) -> String { "pinGate_digitField_\(index)" }

        /// Submit / confirm button on the PIN entry screen.
        static let submitButton = "pinGate_submitButton"

        /// Error message label shown after an incorrect PIN attempt.
        static let errorMessage = "pinGate_errorMessage"

        /// Countdown label shown during the 30-second lockout period.
        static let lockoutCountdown = "pinGate_lockoutCountdown"

        /// Root container of the first-launch PIN setup screen.
        static let setupRoot = "pinSetup_root"

        /// Confirm/continue button on the PIN setup screen.
        static let setupConfirmButton = "pinSetup_confirmButton"

        // MARK: DSGN-003 identifiers

        /// Cancel/dismiss button (xmark) on the PIN entry screen.
        static let cancelButton = "pinCancelButton"

        /// The PIN dot display component (shows N of 4 filled dots).
        static let dotDisplay = "pinDotDisplay"

        /// A PIN keypad digit button (digit 0–9).
        static func key(_ digit: Int) -> String { "pinKey_\(digit)" }

        /// Delete/backspace button on the PIN keypad.
        static let deleteButton = "pinDeleteButton"

        /// Error label shown after one or two wrong PIN attempts.
        static let errorLabel = "pinErrorLabel"

        /// Lockout countdown label shown after three wrong PIN attempts.
        static let lockoutLabel = "pinLockoutLabel"
    }

    // MARK: - Parent Management View

    /// Identifiers for the parent home screen, task editor, and related flows (REQ-004, DSGN-003).
    enum ParentManagement {
        /// Root container of the parent home screen.
        static let root = "parentMgmt_root"

        /// A child row in the parent home list, by sort-order index.
        static func childRow(_ index: Int) -> String { "parentMgmt_childRow_\(index)" }

        /// A child row identified by the child's name (PascalCase).
        static func childRowByName(_ name: String) -> String { "childRow_\(name)" }

        /// The "Reset Day" button in the navigation bar.
        static let resetDayButton = "parentMgmt_resetDayButton"

        /// The destructive "Reset Day" confirmation button in the alert.
        static let resetConfirmButton = "parentMgmt_resetConfirmButton"

        /// The "Cancel" button in the Reset Day confirmation alert.
        static let resetCancelButton = "parentMgmt_resetCancelButton"

        /// The "+ Add Task" button in the task editor navigation bar.
        static let addTaskButton = "parentMgmt_addTaskButton"

        /// A row in the task editor list, by task index.
        static func taskEditorRow(_ index: Int) -> String { "parentMgmt_taskEditorRow_\(index)" }

        /// A row in the task editor list, identified by task name (PascalCase, spaces removed).
        static func taskEditorRowByName(_ name: String) -> String { "taskEditorRow_\(name)" }

        /// The delete button revealed by swiping left on a task row, by index.
        static func deleteTaskButton(_ index: Int) -> String {
            "parentMgmt_deleteTaskButton_\(index)"
        }

        /// The delete swipe action on a task row, identified by task name.
        static func deleteTaskAction(_ name: String) -> String { "taskDeleteAction_\(name)" }

        /// The destructive confirm button in the delete task alert.
        static let deleteConfirmButton = "parentMgmt_deleteConfirmButton"

        /// "Change PIN" row in the parent settings list.
        static let changePINButton = "parentMgmt_changePINButton"

        /// "Done" navigation button that exits parent management back to routine view.
        static let doneButton = "parentDoneButton"

        // MARK: DSGN-003 additional identifiers

        /// The destructive "Reset Day" confirm button identifier from DSGN-003.
        static let resetDayConfirmButton = "resetDayConfirmButton"

        /// The "Cancel" button in the Reset Day alert — DSGN-003 identifier.
        static let resetDayCancelButton = "resetDayCancelButton"

        /// The destructive "Delete Task" confirm button in the delete alert.
        static let deleteTaskConfirmButton = "deleteTaskConfirmButton"

        /// The "Cancel" button in the delete task alert.
        static let deleteTaskCancelButton = "deleteTaskCancelButton"

        /// The "Change PIN" row identified by DSGN-003.
        static let changePINRow = "changePINRow"

        /// The edit button for a specific task row, identified by task name.
        static func taskEditButton(_ name: String) -> String { "taskEditButton_\(name)" }

        /// The reorder drag handle for a specific task row, identified by task name.
        static func taskReorderHandle(_ name: String) -> String { "taskReorderHandle_\(name)" }
    }

    // MARK: - Task Editor Sheet

    /// Identifiers for the Add / Edit Task sheet (REQ-004, DSGN-003).
    enum TaskEditor {
        /// Task name text field in the Add/Edit sheet.
        static let nameField = "taskEditor_nameField"

        /// Save button in the Add/Edit sheet.
        static let saveButton = "taskEditor_saveButton"

        // MARK: DSGN-003 additional identifiers

        /// Cancel button in the Add/Edit Task sheet.
        static let cancelButton = "taskFormCancelButton"

        /// Save button in the Add/Edit Task sheet — DSGN-003 identifier.
        static let formSaveButton = "taskFormSaveButton"

        /// Task name field — DSGN-003 identifier.
        static let taskNameField = "taskNameField"

        /// "Choose Icon" button in the Add/Edit Task sheet.
        static let chooseIconButton = "chooseIconButton"

        /// Search field in the icon picker sheet.
        static let iconSearchField = "iconSearchField"

        /// A specific icon cell in the icon picker, identified by SF Symbol name.
        static func iconPickerCell(_ symbolName: String) -> String {
            "iconPicker_\(symbolName)"
        }

        /// Success toast shown after a PIN change completes.
        static let pinChangedToast = "pinChangedToast"
    }

    // MARK: - Topic Tab Bar (REQ-006, DSGN-004)

    /// Identifiers for the child-facing topic tab bar.
    enum TopicTab {
        /// The container element for the topic tab bar.
        static let tabBar = "topicTabBar"

        /// A topic tab button, identified by topic name.
        static func tab(_ topicName: String) -> String { "topicTab_\(topicName)" }
    }

    // MARK: - Topic Management (REQ-006, DSGN-004)

    /// Identifiers for topic CRUD and reset in the parent management view.
    enum TopicManagement {
        /// "Add Topic" button in the Topics section header.
        static let addTopicButton = "parentMgmt_addTopicButton"

        /// Text field in the Add Topic alert dialog.
        static let addTopicNameField = "parentMgmt_addTopicNameField"

        /// Confirm button in the Add Topic alert dialog.
        static let addTopicConfirmButton = "parentMgmt_addTopicConfirmButton"

        /// A topic row in the parent management Topics section, identified by topic name.
        static func topicRow(_ topicName: String) -> String { "topicRow_\(topicName)" }

        /// Edit/rename button for a topic row, identified by topic name.
        static func topicEditButton(_ topicName: String) -> String { "topicEditButton_\(topicName)" }

        /// Text field in the Rename Topic alert dialog.
        static let renameTopicNameField = "parentMgmt_renameTopicNameField"

        /// Confirm/Save button in the Rename Topic alert dialog.
        static let renameTopicConfirmButton = "parentMgmt_renameTopicConfirmButton"

        /// Delete swipe action for a topic row, identified by topic name.
        static func topicDeleteAction(_ topicName: String) -> String { "topicDeleteAction_\(topicName)" }

        /// Destructive confirm button in the Delete Topic confirmation dialog.
        static let deleteTopicConfirmButton = "parentMgmt_deleteTopicConfirmButton"

        /// Reorder drag handle for a topic row, identified by topic name.
        static func topicReorderHandle(_ topicName: String) -> String { "topicReorderHandle_\(topicName)" }

        /// Per-topic reset button on a topic row, identified by topic name.
        static func topicResetButton(_ topicName: String) -> String { "topicResetButton_\(topicName)" }

        /// Confirm button in the per-topic reset confirmation dialog, identified by topic name.
        static func resetTopicConfirmButton(_ topicName: String) -> String { "resetTopicConfirmButton_\(topicName)" }

        /// Cancel button in the per-topic reset confirmation dialog, identified by topic name.
        static func resetTopicCancelButton(_ topicName: String) -> String { "resetTopicCancelButton_\(topicName)" }

        /// "Reset All" button in the parent management view.
        static let resetAllButton = "parentMgmt_resetAllButton"

        /// Confirm button in the Reset All confirmation dialog.
        static let resetAllConfirmButton = "parentMgmt_resetAllConfirmButton"

        /// Cancel button in the Reset All confirmation dialog.
        static let resetAllCancelButton = "parentMgmt_resetAllCancelButton"

        /// A topic row in the child topic picker, identified by child name and topic name.
        static func childTopicRow(child: String, topic: String) -> String {
            "childTopicRow_\(child)_\(topic)"
        }
    }

    // MARK: - Child Management (REQ-007, DSGN-005)

    /// Identifiers for the dynamic children CRUD in parent management.
    enum ChildManagement {
        /// "+ Add Child" button in the Children section header.
        static let addChildButton = "addChildButton"

        /// Child row in parent management, identified by child name (PascalCase).
        static func childRow(_ name: String) -> String { "childRow_\(name)" }

        /// Reorder drag handle on a child row, identified by child name.
        static func childReorderHandle(_ name: String) -> String { "childReorderHandle_\(name)" }

        /// Edit (pencil) button on a child row, identified by child name.
        static func childEditButton(_ name: String) -> String { "childEditButton_\(name)" }

        /// Delete swipe action on a child row, identified by child name.
        static func childDeleteAction(_ name: String) -> String { "childDeleteAction_\(name)" }

        /// Info label shown when the maximum of 6 children has been reached.
        static let maxChildrenInfoLabel = "maxChildrenInfoLabel"

        /// Info label shown when only one child exists (cannot delete).
        static let lastChildInfoLabel = "lastChildInfoLabel"

        // MARK: Add / Edit Child Sheet

        /// Cancel button in the Add/Edit Child sheet.
        static let childFormCancelButton = "childFormCancelButton"

        /// Save button in the Add/Edit Child sheet.
        static let childFormSaveButton = "childFormSaveButton"

        /// Child name text field in the Add/Edit Child sheet.
        static let childNameField = "childNameField"

        /// "Choose Photo" button in the Add/Edit Child sheet.
        static let childPhotoPickerButton = "childPhotoPickerButton"

        /// "Remove Photo" button in the Add/Edit Child sheet (visible only when photo is set).
        static let childPhotoRemoveButton = "childPhotoRemoveButton"

        // MARK: Delete Child Dialog

        /// Destructive confirm button in the Delete Child confirmation dialog.
        static let deleteChildConfirmButton = "deleteChildConfirmButton"

        /// Cancel button in the Delete Child confirmation dialog.
        static let deleteChildCancelButton = "deleteChildCancelButton"

        // MARK: Empty State (no children)

        /// Empty state container shown when no children exist.
        static let emptyStateView = "emptyStateView"

        /// "Open Settings" button in the empty state view.
        static let emptyStateSettingsButton = "emptyStateSettingsButton"
    }

    // MARK: - Task Bank (REQ-008, DSGN-006)

    /// Identifiers for the Task Bank section in parent management and related sheets.
    enum TaskBank {
        /// "+ New Template" button in the Task Bank section header.
        static let addTemplateButton = "addTemplateButton"

        /// A template row in the Task Bank section, identified by template name (PascalCase, spaces removed).
        static func templateRow(_ name: String) -> String { "templateRow_\(name)" }

        /// Edit (pencil) button on a template row, identified by template name.
        static func templateEditButton(_ name: String) -> String { "templateEditButton_\(name)" }

        /// Delete swipe action on a template row, identified by template name.
        static func templateDeleteAction(_ name: String) -> String { "templateDeleteAction_\(name)" }

        /// Placeholder label shown when the task bank is empty.
        static let taskBankEmptyLabel = "taskBankEmptyLabel"

        // MARK: Create / Edit Template Sheet

        /// Cancel button in the Create/Edit Template sheet.
        static let templateFormCancelButton = "templateFormCancelButton"

        /// Save button in the Create/Edit Template sheet.
        static let templateFormSaveButton = "templateFormSaveButton"

        /// Template name text field in the Create/Edit Template sheet.
        static let templateNameField = "templateNameField"

        /// "Choose Icon" button in the Create/Edit Template sheet.
        static let templateChooseIconButton = "templateChooseIconButton"

        // MARK: Delete Template Dialog

        /// Destructive confirm button in the Delete Template confirmation dialog.
        static let deleteTemplateConfirmButton = "deleteTemplateConfirmButton"

        /// Cancel button in the Delete Template confirmation dialog.
        static let deleteTemplateCancelButton = "deleteTemplateCancelButton"
    }

    // MARK: - Task Assignment / Bank Selector (REQ-008, DSGN-006)

    /// Identifiers for the task assignment flow (child+topic task editor and bank selector sheet).
    enum TaskAssignment {
        /// "+ Add from Bank" button in the task editor navigation bar.
        static let addFromBankButton = "addFromBankButton"

        /// An assignment row in the task editor, identified by child name, topic name, and template name.
        static func assignmentRow(child: String, topic: String, template: String) -> String {
            "assignmentRow_\(child)_\(topic)_\(template)"
        }

        /// Reorder drag handle on an assignment row, identified by template name.
        static func assignmentReorderHandle(_ name: String) -> String { "assignmentReorderHandle_\(name)" }

        /// "Remove" swipe action on an assignment row, identified by template name.
        static func assignmentRemoveAction(_ name: String) -> String { "assignmentRemoveAction_\(name)" }

        /// Placeholder label shown when no templates are assigned to this child+topic.
        static let taskEditorEmptyLabel = "taskEditorEmptyLabel"

        // MARK: Bank Selector Sheet

        /// Cancel button in the Bank Selector sheet.
        static let bankSelectorCancelButton = "bankSelectorCancelButton"

        /// "Add (N)" button in the Bank Selector sheet.
        static let bankSelectorAddButton = "bankSelectorAddButton"

        /// Search field in the Bank Selector sheet.
        static let bankSelectorSearchField = "bankSelectorSearchField"

        /// A template row in the Bank Selector, identified by template name.
        static func bankSelectorRow(_ name: String) -> String { "bankSelectorRow_\(name)" }

        /// "Create New Template" shortcut button at the bottom of the Bank Selector.
        static let bankSelectorCreateNewButton = "bankSelectorCreateNewButton"
    }

    // MARK: - Seed data child names (from ADR-003 SeedDataService.fixedChildren)

    /// The three fixed child names seeded on first launch (see ADR-003).
    enum ChildNames {
        static let child0 = "Сара"
        static let child1 = "Самуил"
        static let child2 = "Бен"

        static let all = [child0, child1, child2]
    }
}
