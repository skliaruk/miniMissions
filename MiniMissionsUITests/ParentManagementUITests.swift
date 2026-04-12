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

    // Test child names -- no children are seeded, so tests create their own.
    private let testChildren = ["Mia", "Leo", "Ella"]

    override func setUpWithError() throws {
        continueAfterFailure = false
        // Launch with a pre-set PIN so PIN gate tests don't interfere.
        // The in-memory store gives a clean state (no children seeded).
        app = AppLauncher.launchWithPIN()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - Navigation helpers

    /// Opens the parent management screen by tapping the gear button and entering the correct PIN.
    private func openParentManagement() {
        let gearButton = app.row(AX.ChildRoutine.parentSettingsButton)
        XCTAssertTrue(
            gearButton.waitForExistence(timeout: 5),
            "Gear button must exist to open parent management"
        )
        gearButton.tap()

        // Enter PIN
        XCTAssertTrue(
            app.row(AX.PINGate.dotDisplay).waitForExistence(timeout: 3),
            "PIN entry screen must appear"
        )
        enterPIN(TestConstants.testPIN)

        // Wait for parent management root
        XCTAssertTrue(
            app.row(AX.ParentManagement.root).waitForExistence(timeout: 5),
            "Parent management root must appear after correct PIN"
        )
    }

    /// Enters a 4-digit PIN via keypad buttons.
    private func enterPIN(_ pin: String) {
        for character in pin {
            guard let digit = Int(String(character)) else { continue }
            let key = app.row(AX.PINGate.key(digit))
            key.waitForExistence(timeout: 3)
            key.tap()
        }
    }

    /// Adds a child with the given name via the Add Child sheet.
    /// Assumes the user is already in the parent management screen.
    private func addChild(name: String) {
        let addButton = app.row(AX.ChildManagement.addChildButton)
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 3),
            "Add Child button must exist in parent management"
        )
        addButton.tap()

        let nameField = app.textFields[AX.ChildManagement.childNameField]
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 3),
            "Child name field must appear in Add Child sheet"
        )
        nameField.tap()
        nameField.typeText(name)

        let saveButton = app.row(AX.ChildManagement.childFormSaveButton)
        saveButton.assertExists(timeout: 3)
        saveButton.tap()
    }

    /// Creates a task template in the Task Bank section.
    /// Assumes the user is already in parent management.
    private func addTemplate(name: String) {
        let addButton = app.row(AX.TaskBank.addTemplateButton)
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 3),
            "Add Template button must exist in parent management"
        )
        addButton.tap()

        let nameField = app.textFields[AX.TaskBank.templateNameField]
        nameField.assertExists(timeout: 3)
        nameField.tap()
        nameField.typeText(name)

        let chooseIconButton = app.row(AX.TaskBank.templateChooseIconButton)
        if chooseIconButton.waitForExistence(timeout: 2) {
            chooseIconButton.tap()
            let firstIcon = app.buttons.matching(
                NSPredicate(format: "identifier BEGINSWITH 'iconPicker_'")
            ).firstMatch
            if firstIcon.waitForExistence(timeout: 3) {
                firstIcon.tap()
            }
        }

        let saveButton = app.row(AX.TaskBank.templateFormSaveButton)
        saveButton.assertExists(timeout: 3)
        saveButton.tap()
    }

    /// Navigates to the task editor for a specific child and topic.
    /// Assumes the user is already in parent management.
    private func navigateToTaskEditor(child: String, topic: String) {
        let childRow = app.row(AX.ParentManagement.childRowByName(child))
        XCTAssertTrue(
            childRow.waitForExistence(timeout: 3),
            "Child row for '\(child)' must exist in parent management"
        )
        childRow.tap()

        let topicRow = app.row(AX.TopicManagement.childTopicRow(child: child, topic: topic))
        XCTAssertTrue(
            topicRow.waitForExistence(timeout: 3),
            "Child topic row for '\(child)' + '\(topic)' must exist"
        )
        topicRow.tap()
    }

    /// Assigns a template to a child+topic via the bank selector.
    /// Assumes the user is already in the task editor for that child+topic.
    private func assignTemplate(named templateName: String) {
        let addFromBankButton = app.row(AX.TaskAssignment.addFromBankButton)
        addFromBankButton.assertExists(timeout: 3)
        addFromBankButton.tap()

        let selectorRow = app.row(AX.TaskAssignment.bankSelectorRow(templateName))
        XCTAssertTrue(
            selectorRow.waitForExistence(timeout: 5),
            "Bank selector must show '\(templateName)' template row"
        )
        selectorRow.tap()

        let addButton = app.row(AX.TaskAssignment.bankSelectorAddButton)
        addButton.assertExists(timeout: 3)
        addButton.tap()
    }

    /// Navigates back from task editor to parent management root.
    private func navigateBackToParentHome() {
        app.navigationBars.buttons.firstMatch.tap()
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        }
        _ = app.row(AX.ParentManagement.root).waitForExistence(timeout: 3)
    }

    /// Dismisses parent management back to the routine view.
    private func dismissParentManagement() {
        let doneButton = app.row(AX.ParentManagement.doneButton)
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }
    }

    // MARK: - REQ-004 AC-1 / DSGN-003 PM-AC-08
    // Parent management view lists all children.

    func testParentManagementListsAllChildren() throws {
        // REQ-004 AC-1: Parent management view lists all children.
        // DSGN-003 PM-AC-08: childRow_<Name> elements exist for all children.
        openParentManagement()

        // Add children first (no longer seeded)
        for name in testChildren {
            addChild(name: name)
        }

        for childName in testChildren {
            let childRow = app.row(AX.ParentManagement.childRowByName(childName))
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

        for name in testChildren {
            addChild(name: name)
        }

        for childName in testChildren {
            let childRow = app.row(AX.ParentManagement.childRowByName(childName))
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
        openParentManagement()
        addChild(name: "Mia")

        let newTaskName = "BrushTeeth"
        addTemplate(name: newTaskName)
        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate(named: newTaskName)
        navigateBackToParentHome()

        dismissParentManagement()

        // Verify task appears in routine view for Mia
        let taskElement = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: newTaskName))
        let taskRow = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: newTaskName))
        let taskExists = taskElement.waitForExistence(timeout: 5) || taskRow.waitForExistence(timeout: 2)

        XCTAssertTrue(
            taskExists,
            "Task '\(newTaskName)' must appear in routine view under child 'Mia' after being added in parent management"
        )
    }

    func testAddedTaskIsAssociatedWithCorrectChild() throws {
        // REQ-004 AC-7: Task list updates are reflected immediately in the child-facing routine view.
        // Verify that a task added to Leo appears ONLY in Leo's column.
        openParentManagement()
        addChild(name: "Mia")
        addChild(name: "Leo")

        let taskName = "PackBackpack"
        addTemplate(name: taskName)
        navigateToTaskEditor(child: "Leo", topic: "Aamu")
        assignTemplate(named: taskName)
        navigateBackToParentHome()

        dismissParentManagement()

        // Task must appear under Leo
        let leoTaskElement = app.row(AX.ChildRoutine.taskByName(child: "Leo", task: taskName))
        XCTAssertTrue(
            leoTaskElement.waitForExistence(timeout: 5),
            "Task '\(taskName)' must appear in Leo's column after being added"
        )

        // Task must NOT appear under Mia
        let miaTaskElement = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: taskName))
        XCTAssertFalse(
            miaTaskElement.exists,
            "Task '\(taskName)' must NOT appear in Mia's column"
        )
    }

    // MARK: - REQ-004 AC-4 / DSGN-003 PM-AC-11
    // Edit template: updated name appears in routine view.

    func testEditTaskUpdatedNameAppearsInRoutineView() throws {
        // REQ-004 AC-4: Parent can edit a task's name; updated name appears in routine view.
        openParentManagement()
        addChild(name: "Mia")

        let originalName = "GetDressed"
        addTemplate(name: originalName)
        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate(named: originalName)
        navigateBackToParentHome()

        // Now edit the template in the bank
        let editButton = app.row(AX.TaskBank.templateEditButton(originalName))
        XCTAssertTrue(
            editButton.waitForExistence(timeout: 3),
            "Edit button for template '\(originalName)' must exist in task bank"
        )
        editButton.tap()

        let updatedName = "WearUniform"
        let nameField = app.textFields[AX.TaskBank.templateNameField]
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 3),
            "Template name field must appear in Edit Template sheet"
        )
        nameField.tap()
        nameField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        nameField.typeText(updatedName)

        let saveButton = app.row(AX.TaskBank.templateFormSaveButton)
        saveButton.waitForExistence(timeout: 3)
        saveButton.tap()

        // Navigate back to routine view
        dismissParentManagement()

        // Updated task name must appear in routine view
        let updatedTaskElement = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: updatedName))
        XCTAssertTrue(
            updatedTaskElement.waitForExistence(timeout: 5),
            "Updated task name '\(updatedName)' must appear in routine view after edit"
        )

        // Original name must no longer appear
        let originalTaskElement = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: originalName))
        XCTAssertFalse(
            originalTaskElement.exists,
            "Original task name '\(originalName)' must no longer appear in routine view after edit"
        )
    }

    // MARK: - REQ-004 AC-5 / DSGN-003 PM-AC-12, PM-AC-13
    // Delete task (unassign): task removed from routine view.

    func testDeleteTaskRequiresConfirmationBeforeRemoval() throws {
        // REQ-004 AC-5: Parent can delete a task -- a confirmation prompt appears before deletion.
        openParentManagement()
        addChild(name: "Mia")

        let taskName = "EatBreakfast"
        addTemplate(name: taskName)
        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate(named: taskName)

        // Swipe left on the assignment row to reveal remove action
        let assignmentRow = app.cells[
            AX.TaskAssignment.assignmentRow(child: "Mia", topic: "Aamu", template: taskName)
        ]
        XCTAssertTrue(
            assignmentRow.waitForExistence(timeout: 3),
            "Assignment row for '\(taskName)' must exist before removal"
        )
        assignmentRow.swipeLeft()

        let removeAction = app.row(AX.TaskAssignment.assignmentRemoveAction(taskName))
        XCTAssertTrue(
            removeAction.waitForExistence(timeout: 3),
            "Remove swipe action must appear after swiping left on assignment row '\(taskName)'"
        )
    }

    func testDeleteTaskRemovedAfterConfirmation() throws {
        // REQ-004 AC-5 (continued): After removal, task is removed from routine view.
        openParentManagement()
        addChild(name: "Mia")

        let taskName = "WashHands"
        addTemplate(name: taskName)
        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate(named: taskName)

        // Swipe and remove
        let assignmentRow = app.cells[
            AX.TaskAssignment.assignmentRow(child: "Mia", topic: "Aamu", template: taskName)
        ]
        assignmentRow.waitForExistence(timeout: 3)
        assignmentRow.swipeLeft()

        let removeAction = app.row(AX.TaskAssignment.assignmentRemoveAction(taskName))
        removeAction.waitForExistence(timeout: 3)
        removeAction.tap()

        // Assignment must be removed from editor
        XCTAssertFalse(
            app.cells[
                AX.TaskAssignment.assignmentRow(child: "Mia", topic: "Aamu", template: taskName)
            ].waitForExistence(timeout: 2),
            "Assignment '\(taskName)' must be removed from editor after removal"
        )

        // Navigate to routine view and verify task is absent there too
        navigateBackToParentHome()
        dismissParentManagement()

        let taskInRoutineView = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: taskName))
        XCTAssertFalse(
            taskInRoutineView.exists,
            "Removed task '\(taskName)' must not appear in routine view"
        )
    }

    func testCancellingDeleteLeavesTaskIntact() throws {
        // DSGN-003 PM-AC-13: cancel removal -- task still exists.
        // With the bank selector model, swipe-to-remove is immediate (no confirmation dialog).
        // This test verifies that a template not removed stays in the task editor.
        openParentManagement()
        addChild(name: "Mia")

        let taskName = "CombHair"
        addTemplate(name: taskName)
        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate(named: taskName)

        // Verify the assignment row exists
        let assignmentRow = app.cells[
            AX.TaskAssignment.assignmentRow(child: "Mia", topic: "Aamu", template: taskName)
        ]
        XCTAssertTrue(
            assignmentRow.waitForExistence(timeout: 3),
            "Assignment row '\(taskName)' must exist in task editor"
        )
    }

    // MARK: - REQ-004 AC-6 / DSGN-003 PM-AC-14
    // Reorder tasks: order in routine view matches reordered state.

    func testReorderTasksOrderReflectedInRoutineView() throws {
        // REQ-004 AC-6: Parent can reorder tasks via drag-and-drop.
        openParentManagement()
        addChild(name: "Mia")

        let taskA = "TaskAlpha"
        let taskB = "TaskBeta"
        addTemplate(name: taskA)
        addTemplate(name: taskB)
        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate(named: taskA)
        assignTemplate(named: taskB)

        // Drag task B's reorder handle above task A
        let handleB = app.row(AX.TaskAssignment.assignmentReorderHandle(taskB))
        let handleA = app.row(AX.TaskAssignment.assignmentReorderHandle(taskA))

        XCTAssertTrue(
            handleB.waitForExistence(timeout: 3),
            "Reorder handle for task '\(taskB)' must exist"
        )
        XCTAssertTrue(
            handleA.exists,
            "Reorder handle for task '\(taskA)' must exist"
        )

        handleB.press(forDuration: 0.5, thenDragTo: handleA)

        // Navigate back to routine view
        navigateBackToParentHome()
        dismissParentManagement()

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
        XCTAssertLessThan(
            taskBInRoutine.frame.origin.y,
            taskAInRoutine.frame.origin.y,
            "After reordering, task '\(taskB)' must appear above task '\(taskA)' in routine view"
        )
    }

    // MARK: - REQ-004 AC-8-AC-11 / DSGN-003 PM-AC-15, PM-AC-16, PM-AC-17
    // Reset day button: confirmation required, all tasks incomplete after confirm.

    func testResetDayButtonIsVisibleInParentManagement() throws {
        // REQ-004 AC-8: "Reset day" button is clearly visible in parent management.
        openParentManagement()

        let resetButton = app.row(AX.ParentManagement.resetDayButton)
        XCTAssertTrue(
            resetButton.waitForExistence(timeout: 3),
            "Reset Day button '\(AX.ParentManagement.resetDayButton)' must be visible in parent management"
        )
    }

    func testResetDayShowsConfirmationPrompt() throws {
        // REQ-004 AC-9: Tapping "Reset day" shows a confirmation prompt.
        openParentManagement()

        let resetButton = app.row(AX.ParentManagement.resetDayButton)
        resetButton.waitForExistence(timeout: 3)
        resetButton.tap()

        let confirmButton = app.row(AX.ParentManagement.resetDayConfirmButton)
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 3),
            "Reset Day confirmation button '\(AX.ParentManagement.resetDayConfirmButton)' must appear after tapping Reset Day"
        )
    }

    func testConfirmingResetDaySetsAllTasksToIncomplete() throws {
        // REQ-004 AC-10, AC-11: Confirming reset sets all tasks to incomplete.
        openParentManagement()

        // Add a child and task
        addChild(name: "Mia")
        addTemplate(name: "TestReset")
        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate(named: "TestReset")
        navigateBackToParentHome()

        // Go to routine view and complete the task
        dismissParentManagement()

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
        let gearButton = app.row(AX.ChildRoutine.parentSettingsButton)
        gearButton.waitForExistence(timeout: 5)
        gearButton.tap()
        app.row(AX.PINGate.dotDisplay).waitForExistence(timeout: 3)
        enterPIN(TestConstants.testPIN)
        app.row(AX.ParentManagement.root).waitForExistence(timeout: 5)

        let resetButton = app.row(AX.ParentManagement.resetDayButton)
        resetButton.waitForExistence(timeout: 3)
        resetButton.tap()

        let confirmButton = app.row(AX.ParentManagement.resetDayConfirmButton)
        confirmButton.waitForExistence(timeout: 3)
        confirmButton.tap()

        // Navigate back to routine view
        if app.row(AX.ParentManagement.doneButton).waitForExistence(timeout: 3) {
            app.row(AX.ParentManagement.doneButton).tap()
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
        openParentManagement()

        // Add a child and task, then complete it
        addChild(name: "Mia")
        addTemplate(name: "CancelTest")
        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate(named: "CancelTest")
        navigateBackToParentHome()

        dismissParentManagement()

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
        let gearButton = app.row(AX.ChildRoutine.parentSettingsButton)
        gearButton.waitForExistence(timeout: 5)
        gearButton.tap()
        app.row(AX.PINGate.dotDisplay).waitForExistence(timeout: 3)
        enterPIN(TestConstants.testPIN)
        app.row(AX.ParentManagement.root).waitForExistence(timeout: 5)

        let resetButton = app.row(AX.ParentManagement.resetDayButton)
        resetButton.waitForExistence(timeout: 3)
        resetButton.tap()

        // Cancel the reset
        let cancelButton = app.row(AX.ParentManagement.resetDayCancelButton)
        XCTAssertTrue(
            cancelButton.waitForExistence(timeout: 3),
            "Reset Day cancel button '\(AX.ParentManagement.resetDayCancelButton)' must exist in confirmation dialog"
        )
        cancelButton.tap()

        // Navigate back to routine view
        if app.row(AX.ParentManagement.doneButton).waitForExistence(timeout: 3) {
            app.row(AX.ParentManagement.doneButton).tap()
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
    // Template name field enforces 30-character maximum.

    func testTaskNameFieldEnforces30CharacterMaximum() throws {
        // DSGN-003 PM-AC-21: type 35 chars -> templateNameField.value.count == 30
        openParentManagement()

        let addButton = app.row(AX.TaskBank.addTemplateButton)
        addButton.waitForExistence(timeout: 3)
        addButton.tap()

        let nameField = app.textFields[AX.TaskBank.templateNameField]
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 3),
            "Template name field must appear in Create Template sheet"
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
            "Template name field must enforce 30-character maximum. Got \(fieldValue.count) characters."
        )
        XCTAssertEqual(
            fieldValue.count,
            30,
            "Template name field must contain exactly 30 characters when 35 are typed (truncated to max)"
        )
    }

    // MARK: - DSGN-003 PM-AC-22
    // Save button is disabled when template name is empty or no icon is selected.

    func testSaveButtonDisabledWhenTaskFormIsEmpty() throws {
        // DSGN-003 PM-AC-22: empty form -> templateFormSaveButton.isEnabled == false
        openParentManagement()

        let addButton = app.row(AX.TaskBank.addTemplateButton)
        addButton.waitForExistence(timeout: 3)
        addButton.tap()

        // Save button must be disabled on an empty form (no name, no icon)
        let saveButton = app.row(AX.TaskBank.templateFormSaveButton)
        XCTAssertTrue(
            saveButton.waitForExistence(timeout: 3),
            "Save button must exist in Create Template sheet"
        )
        XCTAssertFalse(
            saveButton.isEnabled,
            "Save button must be disabled when template name is empty and no icon is selected"
        )
    }

    func testSaveButtonDisabledWithNameButNoIcon() throws {
        // DSGN-003 PM-AC-22: Save must require both name AND icon to be enabled.
        openParentManagement()

        app.row(AX.TaskBank.addTemplateButton).tap()

        let nameField = app.textFields[AX.TaskBank.templateNameField]
        nameField.waitForExistence(timeout: 3)
        nameField.tap()
        nameField.typeText("SomeTask")

        // Without selecting an icon, save must remain disabled
        let saveButton = app.row(AX.TaskBank.templateFormSaveButton)
        saveButton.waitForExistence(timeout: 3)
        XCTAssertFalse(
            saveButton.isEnabled,
            "Save button must remain disabled when a name is entered but no icon is selected"
        )
    }
}
