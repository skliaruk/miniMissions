// ParentManagementUITests.swift
// XCUITest suite for the Parent Management View (task CRUD, daily reset).
//
// REQ coverage: REQ-004
// DSGN coverage: DSGN-003 acceptance criteria PM-AC-08 through PM-AC-17, PM-AC-21, PM-AC-22
//
// TDD Red Phase: All tests below compile but WILL FAIL because no implementation exists yet.
// These tests constitute the specification that MDEV must satisfy.

import XCTest

final class ParentManagementUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        // Launch with a pre-set PIN so PIN gate tests don't interfere.
        // The in-memory store gives a clean state with 3 children seeded.
        app = AppLauncher.launchWithPIN()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - Navigation helpers

    /// Opens the parent management screen by tapping the gear button and entering the correct PIN.
    private func openParentManagement() {
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        XCTAssertTrue(
            gearButton.waitForExistence(timeout: 5),
            "Gear button must exist to open parent management"
        )
        gearButton.tap()

        // Enter PIN
        XCTAssertTrue(
            app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3),
            "PIN entry screen must appear"
        )
        enterPIN(TestConstants.testPIN)

        // Wait for parent management root
        XCTAssertTrue(
            app.otherElements[AX.ParentManagement.root].waitForExistence(timeout: 5),
            "Parent management root must appear after correct PIN"
        )
    }

    /// Opens the task editor for the specified child (0-indexed by sort order).
    private func openTaskEditorForChild(_ childName: String) {
        let childRow = app.cells[AX.ParentManagement.childRowByName(childName)]
        XCTAssertTrue(
            childRow.waitForExistence(timeout: 3),
            "Child row for '\(childName)' must exist in parent management"
        )
        childRow.tap()
    }

    /// Enters a 4-digit PIN via keypad buttons.
    private func enterPIN(_ pin: String) {
        for character in pin {
            guard let digit = Int(String(character)) else { continue }
            let key = app.buttons[AX.PINGate.key(digit)]
            key.waitForExistence(timeout: 3)
            key.tap()
        }
    }

    /// Adds a task with the given name to the currently open task editor.
    /// Assumes a pre-seeded icon exists or selects the first available icon.
    private func addTask(name: String) {
        let addButton = app.buttons[AX.ParentManagement.addTaskButton]
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 3),
            "Add task button must exist in task editor"
        )
        addButton.tap()

        // Fill in task name
        let nameField = app.textFields[AX.TaskEditor.taskNameField]
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 3),
            "Task name field must appear in Add Task sheet"
        )
        nameField.tap()
        nameField.typeText(name)

        // Select an icon (choose first available built-in icon)
        let chooseIconButton = app.buttons[AX.TaskEditor.chooseIconButton]
        if chooseIconButton.waitForExistence(timeout: 2) {
            chooseIconButton.tap()
            // Select the first icon in the picker
            let firstIcon = app.buttons.matching(
                NSPredicate(format: "identifier BEGINSWITH 'iconPicker_'")
            ).firstMatch
            if firstIcon.waitForExistence(timeout: 3) {
                firstIcon.tap()
            }
        }

        // Tap Save
        let saveButton = app.buttons[AX.TaskEditor.formSaveButton]
        XCTAssertTrue(
            saveButton.waitForExistence(timeout: 3),
            "Save button must be enabled and visible after filling task form"
        )
        saveButton.tap()
    }

    // MARK: - REQ-004 AC-1 / DSGN-003 PM-AC-08
    // Parent management view lists all 3 children.

    func testParentManagementListsAllThreeChildren() throws {
        // REQ-004 AC-1: Parent management view lists all three children.
        // DSGN-003 PM-AC-08: childRow_<Name> elements exist for all 3 children.
        openParentManagement()

        for childName in AX.ChildNames.all {
            let childRow = app.cells[AX.ParentManagement.childRowByName(childName)]
            XCTAssertTrue(
                childRow.waitForExistence(timeout: 3),
                "Child row for '\(childName)' must exist in parent management list"
            )
        }
    }

    func testParentManagementChildRowsAreHittable() throws {
        // REQ-004 AC-2: Tapping a child opens their task list editor.
        // Prerequisite: all rows must be hittable.
        openParentManagement()

        for childName in AX.ChildNames.all {
            let childRow = app.cells[AX.ParentManagement.childRowByName(childName)]
            childRow.waitForExistence(timeout: 3)
            XCTAssertTrue(
                childRow.isHittable,
                "Child row for '\(childName)' must be hittable"
            )
        }
    }

    // MARK: - REQ-004 AC-3 / DSGN-003 PM-AC-10
    // Add task: appears in routine view under correct child.

    func testAddTaskAppearsInRoutineViewUnderCorrectChild() throws {
        // REQ-004 AC-3: Parent can add a task; it appears in routine view.
        // DSGN-003 PM-AC-10: save task in editor → task_<Name>_<TaskName> exists in routine view.
        openParentManagement()
        openTaskEditorForChild(AX.ChildNames.child0)

        let newTaskName = "BrushTeeth"
        addTask(name: newTaskName)

        // Navigate back to parent management then to routine view
        app.navigationBars.buttons.firstMatch.tap() // Back button
        let doneButton = app.buttons[AX.ParentManagement.doneButton]
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }

        // Verify task appears in routine view for child 0 (Mia)
        let taskElement = app.buttons[AX.ChildRoutine.taskByName(child: AX.ChildNames.child0, task: newTaskName)]
        let taskRow = app.otherElements[AX.ChildRoutine.taskByName(child: AX.ChildNames.child0, task: newTaskName)]
        let taskExists = taskElement.waitForExistence(timeout: 5) || taskRow.waitForExistence(timeout: 2)

        XCTAssertTrue(
            taskExists,
            "Task '\(newTaskName)' must appear in routine view under child '\(AX.ChildNames.child0)' after being added in parent management"
        )
    }

    func testAddedTaskIsAssociatedWithCorrectChild() throws {
        // REQ-004 AC-7: Task list updates are reflected immediately in the child-facing routine view.
        // Verify that a task added to child 1 (Noah) appears ONLY in child 1's column.
        openParentManagement()
        openTaskEditorForChild(AX.ChildNames.child1)

        let noahTask = "PackBackpack"
        addTask(name: noahTask)

        app.navigationBars.buttons.firstMatch.tap()
        let doneButton = app.buttons[AX.ParentManagement.doneButton]
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }

        // Task must appear under Noah (child 1)
        let noahTaskElement = app.buttons[AX.ChildRoutine.taskByName(child: AX.ChildNames.child1, task: noahTask)]
        XCTAssertTrue(
            noahTaskElement.waitForExistence(timeout: 5),
            "Task '\(noahTask)' must appear in child 1 '\(AX.ChildNames.child1)' column after being added"
        )

        // Task must NOT appear under Mia (child 0) — wrong child
        let miaTaskElement = app.buttons[AX.ChildRoutine.taskByName(child: AX.ChildNames.child0, task: noahTask)]
        XCTAssertFalse(
            miaTaskElement.exists,
            "Task '\(noahTask)' must NOT appear in child 0 '\(AX.ChildNames.child0)' column"
        )
    }

    // MARK: - REQ-004 AC-4 / DSGN-003 PM-AC-11
    // Edit task: updated name appears in routine view.

    func testEditTaskUpdatedNameAppearsInRoutineView() throws {
        // REQ-004 AC-4: Parent can edit a task's name; updated name appears in routine view.
        // DSGN-003 PM-AC-11: edit task → verify accessibilityLabel updated in routine view.
        openParentManagement()
        openTaskEditorForChild(AX.ChildNames.child0)

        // First add a task to edit
        let originalName = "GetDressed"
        addTask(name: originalName)

        // Now edit that task
        let editButton = app.buttons[AX.ParentManagement.taskEditButton(originalName)]
        XCTAssertTrue(
            editButton.waitForExistence(timeout: 3),
            "Edit button for task '\(originalName)' must exist in task editor"
        )
        editButton.tap()

        // Clear and retype the name
        let updatedName = "WearUniform"
        let nameField = app.textFields[AX.TaskEditor.taskNameField]
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 3),
            "Task name field must appear in Edit Task sheet"
        )
        nameField.tap()
        // Select all existing text and replace
        nameField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        nameField.typeText(updatedName)

        let saveButton = app.buttons[AX.TaskEditor.formSaveButton]
        saveButton.waitForExistence(timeout: 3)
        saveButton.tap()

        // Navigate back to routine view
        app.navigationBars.buttons.firstMatch.tap()
        let doneButton = app.buttons[AX.ParentManagement.doneButton]
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }

        // Updated task name must appear in routine view
        let updatedTaskElement = app.buttons[AX.ChildRoutine.taskByName(child: AX.ChildNames.child0, task: updatedName)]
        XCTAssertTrue(
            updatedTaskElement.waitForExistence(timeout: 5),
            "Updated task name '\(updatedName)' must appear in routine view after edit"
        )

        // Original name must no longer appear
        let originalTaskElement = app.buttons[AX.ChildRoutine.taskByName(child: AX.ChildNames.child0, task: originalName)]
        XCTAssertFalse(
            originalTaskElement.exists,
            "Original task name '\(originalName)' must no longer appear in routine view after edit"
        )
    }

    // MARK: - REQ-004 AC-5 / DSGN-003 PM-AC-12, PM-AC-13
    // Delete task: confirmation required, task removed from routine view.

    func testDeleteTaskRequiresConfirmationBeforeRemoval() throws {
        // REQ-004 AC-5: Parent can delete a task — a confirmation prompt appears before deletion.
        // DSGN-003 PM-AC-12: swipe delete → deleteTaskConfirmButton.exists before task is removed.
        openParentManagement()
        openTaskEditorForChild(AX.ChildNames.child0)

        let taskName = "EatBreakfast"
        addTask(name: taskName)

        // Swipe left on the task row to reveal delete action
        let taskEditorRow = app.cells[AX.ParentManagement.taskEditorRowByName(taskName)]
        XCTAssertTrue(
            taskEditorRow.waitForExistence(timeout: 3),
            "Task editor row for '\(taskName)' must exist before deletion"
        )
        taskEditorRow.swipeLeft()

        // Delete action button must appear
        let deleteAction = app.buttons[AX.ParentManagement.deleteTaskAction(taskName)]
        XCTAssertTrue(
            deleteAction.waitForExistence(timeout: 3),
            "Delete swipe action must appear after swiping left on task row '\(taskName)'"
        )
        deleteAction.tap()

        // Confirmation dialog must appear before deletion
        let confirmButton = app.buttons[AX.ParentManagement.deleteTaskConfirmButton]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 3),
            "Delete confirmation button '\(AX.ParentManagement.deleteTaskConfirmButton)' must appear before task is removed"
        )

        // Task must still exist at this point (not yet deleted)
        XCTAssertTrue(
            taskEditorRow.exists,
            "Task '\(taskName)' must still exist in editor before confirmation is tapped"
        )
    }

    func testDeleteTaskRemovedAfterConfirmation() throws {
        // REQ-004 AC-5 (continued): After confirmation, task is removed from routine view.
        openParentManagement()
        openTaskEditorForChild(AX.ChildNames.child0)

        let taskName = "WashHands"
        addTask(name: taskName)

        // Swipe and delete
        let taskEditorRow = app.cells[AX.ParentManagement.taskEditorRowByName(taskName)]
        taskEditorRow.waitForExistence(timeout: 3)
        taskEditorRow.swipeLeft()

        let deleteAction = app.buttons[AX.ParentManagement.deleteTaskAction(taskName)]
        deleteAction.waitForExistence(timeout: 3)
        deleteAction.tap()

        // Confirm deletion
        let confirmButton = app.buttons[AX.ParentManagement.deleteTaskConfirmButton]
        confirmButton.waitForExistence(timeout: 3)
        confirmButton.tap()

        // Task must be removed from editor
        XCTAssertFalse(
            app.cells[AX.ParentManagement.taskEditorRowByName(taskName)].exists,
            "Task '\(taskName)' must be removed from editor after delete confirmation"
        )

        // Navigate to routine view and verify task is absent there too
        app.navigationBars.buttons.firstMatch.tap()
        let doneButton = app.buttons[AX.ParentManagement.doneButton]
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }

        let taskInRoutineView = app.buttons[AX.ChildRoutine.taskByName(child: AX.ChildNames.child0, task: taskName)]
        XCTAssertFalse(
            taskInRoutineView.exists,
            "Deleted task '\(taskName)' must not appear in routine view"
        )
    }

    func testCancellingDeleteLeavesTaskIntact() throws {
        // DSGN-003 PM-AC-13: deleteTaskCancelButton tap → task still exists.
        openParentManagement()
        openTaskEditorForChild(AX.ChildNames.child0)

        let taskName = "ComBHair"
        addTask(name: taskName)

        // Swipe to reveal delete, then cancel
        let taskEditorRow = app.cells[AX.ParentManagement.taskEditorRowByName(taskName)]
        taskEditorRow.waitForExistence(timeout: 3)
        taskEditorRow.swipeLeft()

        let deleteAction = app.buttons[AX.ParentManagement.deleteTaskAction(taskName)]
        deleteAction.waitForExistence(timeout: 3)
        deleteAction.tap()

        // Cancel the confirmation
        let cancelButton = app.buttons[AX.ParentManagement.deleteTaskCancelButton]
        XCTAssertTrue(
            cancelButton.waitForExistence(timeout: 3),
            "Delete cancel button '\(AX.ParentManagement.deleteTaskCancelButton)' must exist in confirmation dialog"
        )
        cancelButton.tap()

        // Task must still exist in editor
        XCTAssertTrue(
            app.cells[AX.ParentManagement.taskEditorRowByName(taskName)].waitForExistence(timeout: 3),
            "Task '\(taskName)' must still exist in editor after cancelling delete"
        )
    }

    // MARK: - REQ-004 AC-6 / DSGN-003 PM-AC-14
    // Reorder tasks: order in routine view matches reordered state.

    func testReorderTasksOrderReflectedInRoutineView() throws {
        // REQ-004 AC-6: Parent can reorder tasks via drag-and-drop.
        // DSGN-003 PM-AC-14: reorder tasks → routine view shows new order.
        openParentManagement()
        openTaskEditorForChild(AX.ChildNames.child0)

        // Add two tasks
        let taskA = "TaskAlpha"
        let taskB = "TaskBeta"
        addTask(name: taskA)
        addTask(name: taskB)

        // Drag task B's reorder handle above task A
        let handleB = app.buttons[AX.ParentManagement.taskReorderHandle(taskB)]
        let handleA = app.buttons[AX.ParentManagement.taskReorderHandle(taskA)]

        XCTAssertTrue(
            handleB.waitForExistence(timeout: 3),
            "Reorder handle for task '\(taskB)' must exist"
        )
        XCTAssertTrue(
            handleA.exists,
            "Reorder handle for task '\(taskA)' must exist"
        )

        // Perform drag to reorder: drag B's handle to above A's position
        handleB.press(forDuration: 0.5, thenDragTo: handleA)

        // Navigate back to routine view
        app.navigationBars.buttons.firstMatch.tap()
        let doneButton = app.buttons[AX.ParentManagement.doneButton]
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }

        // Verify both tasks exist in routine view
        let taskAInRoutine = app.buttons.matching(
            NSPredicate(format: "identifier CONTAINS %@", taskA)
        ).firstMatch
        let taskBInRoutine = app.buttons.matching(
            NSPredicate(format: "identifier CONTAINS %@", taskB)
        ).firstMatch

        XCTAssertTrue(
            taskAInRoutine.waitForExistence(timeout: 5),
            "Task '\(taskA)' must exist in routine view after reorder"
        )
        XCTAssertTrue(
            taskBInRoutine.exists,
            "Task '\(taskB)' must exist in routine view after reorder"
        )

        // Verify B appears before A in visual position (y-coordinate check)
        // After dragging B above A, B's frame should have a smaller y-origin than A's.
        XCTAssertLessThan(
            taskBInRoutine.frame.origin.y,
            taskAInRoutine.frame.origin.y,
            "After reordering, task '\(taskB)' must appear above task '\(taskA)' in routine view"
        )
    }

    // MARK: - REQ-004 AC-8–AC-11 / DSGN-003 PM-AC-15, PM-AC-16, PM-AC-17
    // Reset day button: confirmation required, all tasks incomplete after confirm.

    func testResetDayButtonIsVisibleInParentManagement() throws {
        // REQ-004 AC-8: "Reset day" button is clearly visible in parent management.
        // DSGN-003 PM-AC-15: resetDayButton exists in nav bar.
        openParentManagement()

        let resetButton = app.buttons[AX.ParentManagement.resetDayButton]
        XCTAssertTrue(
            resetButton.waitForExistence(timeout: 3),
            "Reset Day button '\(AX.ParentManagement.resetDayButton)' must be visible in parent management"
        )
    }

    func testResetDayShowsConfirmationPrompt() throws {
        // REQ-004 AC-9: Tapping "Reset day" shows a confirmation prompt.
        // DSGN-003 PM-AC-15: resetDayButton tap → resetDayConfirmButton.exists == true
        openParentManagement()

        let resetButton = app.buttons[AX.ParentManagement.resetDayButton]
        resetButton.waitForExistence(timeout: 3)
        resetButton.tap()

        // Confirmation prompt must appear
        let confirmButton = app.buttons[AX.ParentManagement.resetDayConfirmButton]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 3),
            "Reset Day confirmation button '\(AX.ParentManagement.resetDayConfirmButton)' must appear after tapping Reset Day"
        )
    }

    func testConfirmingResetDaySetsAllTasksToIncomplete() throws {
        // REQ-004 AC-10, AC-11: Confirming reset sets all tasks across all children to incomplete;
        // routine view reflects cleared state immediately.
        // DSGN-003 PM-AC-16: resetDayConfirmButton tap → all task_* elements have accessibilityValue == "not done"
        openParentManagement()

        // Add a task to child 0 so we have something to reset
        openTaskEditorForChild(AX.ChildNames.child0)
        addTask(name: "TestReset")
        app.navigationBars.buttons.firstMatch.tap()

        // Go to routine view and complete the task
        let doneButton = app.buttons[AX.ParentManagement.doneButton]
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }

        // Complete the task in routine view
        let taskButton = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_0_'")
        ).firstMatch
        if taskButton.waitForExistence(timeout: 5) {
            taskButton.tap()
            let donePredicate = NSPredicate(format: "value == 'done'")
            let doneExpectation = expectation(for: donePredicate, evaluatedWith: taskButton)
            wait(for: [doneExpectation], timeout: 2.0)
        }

        // Re-enter parent management and reset the day
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        gearButton.waitForExistence(timeout: 5)
        gearButton.tap()
        app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3)
        enterPIN(TestConstants.testPIN)
        app.otherElements[AX.ParentManagement.root].waitForExistence(timeout: 5)

        let resetButton = app.buttons[AX.ParentManagement.resetDayButton]
        resetButton.waitForExistence(timeout: 3)
        resetButton.tap()

        let confirmButton = app.buttons[AX.ParentManagement.resetDayConfirmButton]
        confirmButton.waitForExistence(timeout: 3)
        confirmButton.tap()

        // Navigate back to routine view
        if app.buttons[AX.ParentManagement.doneButton].waitForExistence(timeout: 3) {
            app.buttons[AX.ParentManagement.doneButton].tap()
        }

        // All task buttons must have accessibilityValue "not done"
        let allTaskButtons = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        )
        for i in 0..<allTaskButtons.count {
            let button = allTaskButtons.element(boundBy: i)
            XCTAssertEqual(
                button.value as? String,
                "not done",
                "All task buttons must have accessibilityValue 'not done' after Reset Day confirmation. " +
                "Button '\(button.identifier)' still shows '\(button.value as? String ?? "nil")'"
            )
        }
    }

    func testCancellingResetDayLeavesTaskStatesUnchanged() throws {
        // REQ-004 AC-9 (cancel): Cancelling the confirmation leaves task states unchanged.
        // DSGN-003 PM-AC-17: resetDayCancelButton tap → task states unchanged.
        openParentManagement()

        // Add and complete a task
        openTaskEditorForChild(AX.ChildNames.child0)
        addTask(name: "CancelTest")
        app.navigationBars.buttons.firstMatch.tap()

        let doneButton = app.buttons[AX.ParentManagement.doneButton]
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }

        // Complete the task in routine view
        let taskButton = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_0_'")
        ).firstMatch
        if taskButton.waitForExistence(timeout: 5) {
            taskButton.tap()
            let donePredicate = NSPredicate(format: "value == 'done'")
            let doneExpectation = expectation(for: donePredicate, evaluatedWith: taskButton)
            wait(for: [doneExpectation], timeout: 2.0)
        }

        // Re-enter parent management and attempt reset but cancel
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        gearButton.waitForExistence(timeout: 5)
        gearButton.tap()
        app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3)
        enterPIN(TestConstants.testPIN)
        app.otherElements[AX.ParentManagement.root].waitForExistence(timeout: 5)

        let resetButton = app.buttons[AX.ParentManagement.resetDayButton]
        resetButton.waitForExistence(timeout: 3)
        resetButton.tap()

        // Cancel the reset
        let cancelButton = app.buttons[AX.ParentManagement.resetDayCancelButton]
        XCTAssertTrue(
            cancelButton.waitForExistence(timeout: 3),
            "Reset Day cancel button '\(AX.ParentManagement.resetDayCancelButton)' must exist in confirmation dialog"
        )
        cancelButton.tap()

        // Navigate back to routine view
        if app.buttons[AX.ParentManagement.doneButton].waitForExistence(timeout: 3) {
            app.buttons[AX.ParentManagement.doneButton].tap()
        }

        // Task that was completed before must STILL be "done" after cancelling reset
        let previouslyDoneTask = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_0_'")
        ).firstMatch
        if previouslyDoneTask.waitForExistence(timeout: 5) {
            XCTAssertEqual(
                previouslyDoneTask.value as? String,
                "done",
                "Previously completed task must remain 'done' after cancelling Reset Day"
            )
        }
    }

    // MARK: - DSGN-003 PM-AC-21
    // Task name field enforces 30-character maximum.

    func testTaskNameFieldEnforces30CharacterMaximum() throws {
        // DSGN-003 PM-AC-21: type 35 chars → taskNameField.value.count == 30
        openParentManagement()
        openTaskEditorForChild(AX.ChildNames.child0)

        let addButton = app.buttons[AX.ParentManagement.addTaskButton]
        addButton.waitForExistence(timeout: 3)
        addButton.tap()

        let nameField = app.textFields[AX.TaskEditor.taskNameField]
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 3),
            "Task name field must appear in Add Task sheet"
        )
        nameField.tap()

        // Type 35 characters
        let thirtyFiveChars = String(repeating: "A", count: 35)
        nameField.typeText(thirtyFiveChars)

        // Field value must be truncated to 30 characters
        let fieldValue = nameField.value as? String ?? ""
        XCTAssertLessThanOrEqual(
            fieldValue.count,
            30,
            "Task name field must enforce 30-character maximum. Got \(fieldValue.count) characters."
        )
        XCTAssertEqual(
            fieldValue.count,
            30,
            "Task name field must contain exactly 30 characters when 35 are typed (truncated to max)"
        )
    }

    // MARK: - DSGN-003 PM-AC-22
    // Save button is disabled when task name is empty or no icon is selected.

    func testSaveButtonDisabledWhenTaskFormIsEmpty() throws {
        // DSGN-003 PM-AC-22: empty form → taskFormSaveButton.isEnabled == false
        openParentManagement()
        openTaskEditorForChild(AX.ChildNames.child0)

        let addButton = app.buttons[AX.ParentManagement.addTaskButton]
        addButton.waitForExistence(timeout: 3)
        addButton.tap()

        // Save button must be disabled on an empty form (no name, no icon)
        let saveButton = app.buttons[AX.TaskEditor.formSaveButton]
        XCTAssertTrue(
            saveButton.waitForExistence(timeout: 3),
            "Save button must exist in Add Task sheet"
        )
        XCTAssertFalse(
            saveButton.isEnabled,
            "Save button must be disabled when task name is empty and no icon is selected"
        )
    }

    func testSaveButtonDisabledWithNameButNoIcon() throws {
        // DSGN-003 PM-AC-22: Save must require both name AND icon to be enabled.
        openParentManagement()
        openTaskEditorForChild(AX.ChildNames.child0)

        app.buttons[AX.ParentManagement.addTaskButton].tap()

        let nameField = app.textFields[AX.TaskEditor.taskNameField]
        nameField.waitForExistence(timeout: 3)
        nameField.tap()
        nameField.typeText("SomeTask")

        // Without selecting an icon, save must remain disabled
        let saveButton = app.buttons[AX.TaskEditor.formSaveButton]
        saveButton.waitForExistence(timeout: 3)
        XCTAssertFalse(
            saveButton.isEnabled,
            "Save button must remain disabled when a name is entered but no icon is selected"
        )
    }
}
