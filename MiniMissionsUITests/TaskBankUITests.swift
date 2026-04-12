// TaskBankUITests.swift
// XCUITest suite for Task Bank (Tehtavapankki).
//
// REQ coverage: REQ-008
// DSGN coverage: DSGN-006 acceptance criteria TB-AC-01 through TB-AC-27
// ADR coverage: ADR-006 (data model), ADR-004 (testability)
//
// TDD Red Phase: All tests below compile but WILL FAIL because no implementation exists yet.
// These tests constitute the specification that MDEV must satisfy.

import XCTest

// MARK: - Task Bank CRUD Tests

final class TaskBankCRUDUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = AppLauncher.launchWithPIN()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - Navigation helpers

    /// Opens parent management by tapping the gear button and entering the correct PIN.
    private func openParentManagement() {
        let gearButton = app.row(AX.ChildRoutine.parentSettingsButton)
        XCTAssertTrue(
            gearButton.waitForExistence(timeout: 5),
            "Gear button must exist to open parent management"
        )
        gearButton.tap()

        XCTAssertTrue(
            app.row(AX.PINGate.dotDisplay).waitForExistence(timeout: 3),
            "PIN entry screen must appear"
        )
        enterPIN(TestConstants.testPIN)

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

    /// Creates a task template in the Task Bank section.
    /// Assumes the user is already in parent management.
    private func addTemplate(name: String) {
        let addButton = app.row(AX.TaskBank.addTemplateButton)
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 3),
            "Add Template button must exist in parent management"
        )
        addButton.tap()

        // Fill in template name
        let nameField = app.textFields[AX.TaskBank.templateNameField]
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 3),
            "Template name field must appear in Create Template sheet"
        )
        nameField.tap()
        nameField.typeText(name)

        // Select an icon (choose first available built-in icon)
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

        // Tap Save
        let saveButton = app.row(AX.TaskBank.templateFormSaveButton)
        XCTAssertTrue(
            saveButton.waitForExistence(timeout: 3),
            "Save button must be enabled and visible after filling template form"
        )
        saveButton.tap()
    }

    // MARK: - TB-AC-01: Task Bank section visible on Parent Home

    func testTaskBankSectionVisibleOnParentHome() throws {
        // REQ-008 AC: Task bank section exists on parent management screen.
        // DSGN-006 TB-AC-01: Task Bank section is visible between Topics and Children sections.
        openParentManagement()

        let addTemplateButton = app.row(AX.TaskBank.addTemplateButton)
        XCTAssertTrue(
            addTemplateButton.waitForExistence(timeout: 5),
            "Task Bank section must be visible on Parent Home (addTemplateButton must exist)"
        )

        // Verify Task Bank is positioned between Topics and Children sections.
        // Topics section has addTopicButton, Children section has addChildButton.
        let addTopicButton = app.row(AX.TopicManagement.addTopicButton)
        let addChildButton = app.row(AX.ChildManagement.addChildButton)

        XCTAssertTrue(
            addTopicButton.waitForExistence(timeout: 5),
            "Topics section must exist above Task Bank"
        )
        XCTAssertTrue(
            addChildButton.waitForExistence(timeout: 5),
            "Children section must exist below Task Bank"
        )

        // Task Bank button should be vertically between Topics and Children
        XCTAssertGreaterThan(
            addTemplateButton.frame.origin.y,
            addTopicButton.frame.origin.y,
            "Task Bank section must appear below Topics section"
        )
        XCTAssertLessThan(
            addTemplateButton.frame.origin.y,
            addChildButton.frame.origin.y,
            "Task Bank section must appear above Children section"
        )
    }

    // MARK: - TB-AC-22: Empty task bank shows placeholder

    func testEmptyTaskBankShowsPlaceholder() throws {
        // DSGN-006 TB-AC-22: With no templates, taskBankEmptyLabel exists.
        openParentManagement()

        let emptyLabel = app.staticTexts[AX.TaskBank.taskBankEmptyLabel]
        XCTAssertTrue(
            emptyLabel.waitForExistence(timeout: 5),
            "Empty task bank must show placeholder label when no templates exist"
        )
    }

    // MARK: - TB-AC-02: Create task template

    func testCreateTaskTemplate() throws {
        // REQ-008 AC-1: Parent can create a task template with name and icon.
        // DSGN-006 TB-AC-02: Create template flow.
        openParentManagement()

        addTemplate(name: "BrushTeeth")

        // Verify template row appears in the Task Bank section
        let templateRow = app.row(AX.TaskBank.templateRow("BrushTeeth"))
        XCTAssertTrue(
            templateRow.waitForExistence(timeout: 5),
            "Template row for 'BrushTeeth' must appear in Task Bank after creation"
        )
    }

    // MARK: - TB-AC-03: Template name max 30 chars

    func testTemplateNameMaxThirtyChars() throws {
        // DSGN-006 TB-AC-03: Template name field enforces 30-character maximum.
        openParentManagement()

        let addButton = app.row(AX.TaskBank.addTemplateButton)
        addButton.assertExists(timeout: 3)
        addButton.tap()

        let nameField = app.textFields[AX.TaskBank.templateNameField]
        nameField.assertExists(timeout: 3)
        nameField.tap()

        // Type 35 characters
        let thirtyFiveChars = String(repeating: "A", count: 35)
        nameField.typeText(thirtyFiveChars)

        // Field value must be truncated to 30 characters
        let fieldValue = nameField.value as? String ?? ""
        XCTAssertEqual(
            fieldValue.count,
            30,
            "Template name field must enforce 30-character maximum. Got \(fieldValue.count) characters."
        )
    }

    // MARK: - TB-AC-04: Save button disabled when name empty

    func testSaveButtonDisabledWhenNameEmpty() throws {
        // DSGN-006 TB-AC-04: Save button disabled when template name empty or no icon.
        openParentManagement()

        let addButton = app.row(AX.TaskBank.addTemplateButton)
        addButton.assertExists(timeout: 3)
        addButton.tap()

        // Save button must be disabled on an empty form
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

    // MARK: - TB-AC-05: Edit task template

    func testEditTaskTemplate() throws {
        // REQ-008 AC-2: Parent can edit a task template -- changes reflected for all assigned children.
        // DSGN-006 TB-AC-05: Edit template name.
        openParentManagement()

        // Create a template first
        addTemplate(name: "BrushTeeth")

        // Tap edit button on the template row
        let editButton = app.row(AX.TaskBank.templateEditButton("BrushTeeth"))
        XCTAssertTrue(
            editButton.waitForExistence(timeout: 3),
            "Edit button for 'BrushTeeth' must exist on the template row"
        )
        editButton.tap()

        // Edit the name
        let nameField = app.textFields[AX.TaskBank.templateNameField]
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 3),
            "Template name field must appear in Edit Template sheet"
        )
        nameField.tap()
        nameField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        nameField.typeText("WashFace")

        // Save
        let saveButton = app.row(AX.TaskBank.templateFormSaveButton)
        saveButton.assertExists(timeout: 3)
        saveButton.tap()

        // Verify new name row exists
        let updatedRow = app.row(AX.TaskBank.templateRow("WashFace"))
        XCTAssertTrue(
            updatedRow.waitForExistence(timeout: 3),
            "Template row must now show updated name 'WashFace'"
        )

        // Old name should no longer exist
        let oldRow = app.row(AX.TaskBank.templateRow("BrushTeeth"))
        XCTAssertFalse(
            oldRow.exists,
            "Old template name 'BrushTeeth' must no longer exist after editing"
        )
    }

    // MARK: - TB-AC-07: Delete task template with confirmation

    func testDeleteTaskTemplateWithConfirmation() throws {
        // REQ-008 AC-3: Parent can delete a task template (with confirmation).
        // DSGN-006 TB-AC-07: Swipe left shows confirmation with deleteTemplateConfirmButton.
        openParentManagement()

        addTemplate(name: "BrushTeeth")

        // Swipe left on the template row
        let templateRow = app.row(AX.TaskBank.templateRow("BrushTeeth"))
        XCTAssertTrue(
            templateRow.waitForExistence(timeout: 3),
            "Template row for 'BrushTeeth' must exist before deletion"
        )
        templateRow.swipeLeft()

        // Delete action must appear
        let deleteAction = app.row(AX.TaskBank.templateDeleteAction("BrushTeeth"))
        XCTAssertTrue(
            deleteAction.waitForExistence(timeout: 3),
            "Delete swipe action must appear after swiping left on template row"
        )
        deleteAction.tap()

        // Confirmation dialog must appear
        let confirmButton = app.row(AX.TaskBank.deleteTemplateConfirmButton)
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 3),
            "Delete confirmation button must appear before template is removed"
        )
    }

    // MARK: - TB-AC-08 (partial): Delete template removes it from bank

    func testDeleteTemplateRemovesItFromBank() throws {
        // DSGN-006 TB-AC-08: Deleting a template removes it from the bank.
        openParentManagement()

        addTemplate(name: "BrushTeeth")

        // Swipe left and confirm delete
        let templateRow = app.row(AX.TaskBank.templateRow("BrushTeeth"))
        templateRow.assertExists(timeout: 3)
        templateRow.swipeLeft()

        let deleteAction = app.row(AX.TaskBank.templateDeleteAction("BrushTeeth"))
        deleteAction.assertExists(timeout: 3)
        deleteAction.tap()

        let confirmButton = app.row(AX.TaskBank.deleteTemplateConfirmButton)
        confirmButton.assertExists(timeout: 3)
        confirmButton.tap()

        // Template row must be gone
        XCTAssertFalse(
            app.row(AX.TaskBank.templateRow("BrushTeeth")).waitForExistence(timeout: 2),
            "Template row for 'BrushTeeth' must be removed from Task Bank after confirmed deletion"
        )
    }
}

// MARK: - Task Bank Assignment Tests

final class TaskBankAssignmentUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = AppLauncher.launchWithPIN()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - Navigation helpers

    /// Opens parent management by tapping the gear button and entering the correct PIN.
    private func openParentManagement() {
        let gearButton = app.row(AX.ChildRoutine.parentSettingsButton)
        XCTAssertTrue(
            gearButton.waitForExistence(timeout: 5),
            "Gear button must exist to open parent management"
        )
        gearButton.tap()

        XCTAssertTrue(
            app.row(AX.PINGate.dotDisplay).waitForExistence(timeout: 3),
            "PIN entry screen must appear"
        )
        enterPIN(TestConstants.testPIN)

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

    /// Dismisses parent management back to the routine view.
    private func dismissParentManagement() {
        let doneButton = app.row(AX.ParentManagement.doneButton)
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
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

        // Select an icon
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
    /// Navigation: Parent Home -> Child row -> Child Topic Picker -> Task Editor.
    private func navigateToTaskEditor(child: String, topic: String) {
        let childRow = app.row(AX.ParentManagement.childRowByName(child))
        XCTAssertTrue(
            childRow.waitForExistence(timeout: 3),
            "Child row for '\(child)' must exist in parent management"
        )
        childRow.tap()

        // Select the topic from the child topic picker
        let topicRow = app.row(AX.TopicManagement.childTopicRow(child: child, topic: topic))
        XCTAssertTrue(
            topicRow.waitForExistence(timeout: 3),
            "Child topic row for '\(child)' + '\(topic)' must exist"
        )
        topicRow.tap()
    }

    /// Navigates back from task editor to parent management root.
    private func navigateBackToParentHome() {
        // Back from task editor to child topic picker
        app.navigationBars.buttons.firstMatch.tap()
        // Back from child topic picker to parent home
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        }
    }

    // MARK: - TB-AC-09: Task Editor shows "Add from Bank" button

    func testTaskEditorShowsAddFromBankButton() throws {
        // DSGN-006 TB-AC-09: Task Editor shows addFromBankButton instead of addTaskButton.
        openParentManagement()
        addChild(name: "Mia")
        navigateToTaskEditor(child: "Mia", topic: "Aamu")

        // "Add from Bank" button must exist
        let addFromBankButton = app.row(AX.TaskAssignment.addFromBankButton)
        XCTAssertTrue(
            addFromBankButton.waitForExistence(timeout: 5),
            "Task Editor must show 'Add from Bank' button"
        )

        // Old "Add Task" button must NOT exist
        let addTaskButton = app.row(AX.ParentManagement.addTaskButton)
        XCTAssertFalse(
            addTaskButton.exists,
            "Task Editor must NOT show old 'Add Task' button -- replaced by 'Add from Bank'"
        )
    }

    // MARK: - TB-AC-23: Empty task editor shows placeholder

    func testEmptyTaskEditorShowsPlaceholder() throws {
        // DSGN-006 TB-AC-23: With no assignments, taskEditorEmptyLabel exists.
        openParentManagement()
        addChild(name: "Mia")
        navigateToTaskEditor(child: "Mia", topic: "Aamu")

        let emptyLabel = app.staticTexts[AX.TaskAssignment.taskEditorEmptyLabel]
        XCTAssertTrue(
            emptyLabel.waitForExistence(timeout: 5),
            "Empty task editor must show placeholder label when no tasks are assigned"
        )
    }

    // MARK: - TB-AC-10, TB-AC-13: Assign template to child

    func testAssignTemplateToChild() throws {
        // REQ-008 AC-4: Parent can assign a task template to a child within a topic.
        // DSGN-006 TB-AC-10: Bank Selector shows all templates.
        // DSGN-006 TB-AC-13: Confirming assignment adds templates to the task editor.
        openParentManagement()
        addChild(name: "Mia")
        addTemplate(name: "BrushTeeth")

        navigateToTaskEditor(child: "Mia", topic: "Aamu")

        // Open bank selector
        let addFromBankButton = app.row(AX.TaskAssignment.addFromBankButton)
        addFromBankButton.assertExists(timeout: 3)
        addFromBankButton.tap()

        // Select the template
        let selectorRow = app.row(AX.TaskAssignment.bankSelectorRow("BrushTeeth"))
        XCTAssertTrue(
            selectorRow.waitForExistence(timeout: 5),
            "Bank selector must show 'BrushTeeth' template row"
        )
        selectorRow.tap()

        // Tap Add button
        let addButton = app.row(AX.TaskAssignment.bankSelectorAddButton)
        addButton.assertExists(timeout: 3)
        addButton.tap()

        // Verify assignment row appears in task editor
        let assignmentRow = app.cells[
            AX.TaskAssignment.assignmentRow(child: "Mia", topic: "Aamu", template: "BrushTeeth")
        ]
        XCTAssertTrue(
            assignmentRow.waitForExistence(timeout: 5),
            "Assignment row for 'Mia/Aamu/BrushTeeth' must appear in task editor after assignment"
        )
    }

    // MARK: - TB-AC-10: Bank Selector shows all templates

    func testBankSelectorShowsAllTemplates() throws {
        // DSGN-006 TB-AC-10: Bank Selector shows all templates with selection checkboxes.
        openParentManagement()
        addChild(name: "Mia")
        addTemplate(name: "BrushTeeth")
        addTemplate(name: "GetDressed")

        navigateToTaskEditor(child: "Mia", topic: "Aamu")

        let addFromBankButton = app.row(AX.TaskAssignment.addFromBankButton)
        addFromBankButton.assertExists(timeout: 3)
        addFromBankButton.tap()

        // Both templates must be visible
        let brushRow = app.row(AX.TaskAssignment.bankSelectorRow("BrushTeeth"))
        let dressRow = app.row(AX.TaskAssignment.bankSelectorRow("GetDressed"))

        XCTAssertTrue(
            brushRow.waitForExistence(timeout: 5),
            "Bank selector must show 'BrushTeeth' template"
        )
        XCTAssertTrue(
            dressRow.waitForExistence(timeout: 3),
            "Bank selector must show 'GetDressed' template"
        )
    }

    // MARK: - TB-AC-11: Already assigned template shows assigned badge

    func testAlreadyAssignedTemplateShowsAssignedBadge() throws {
        // DSGN-006 TB-AC-11: Already-assigned templates show "ASSIGNED" badge and are non-interactive.
        openParentManagement()
        addChild(name: "Mia")
        addTemplate(name: "BrushTeeth")

        // Assign template first
        navigateToTaskEditor(child: "Mia", topic: "Aamu")

        let addFromBankButton = app.row(AX.TaskAssignment.addFromBankButton)
        addFromBankButton.assertExists(timeout: 3)
        addFromBankButton.tap()

        let selectorRow = app.row(AX.TaskAssignment.bankSelectorRow("BrushTeeth"))
        selectorRow.assertExists(timeout: 3)
        selectorRow.tap()

        let addButton = app.row(AX.TaskAssignment.bankSelectorAddButton)
        addButton.assertExists(timeout: 3)
        addButton.tap()

        // Reopen bank selector
        addFromBankButton.assertExists(timeout: 3)
        addFromBankButton.tap()

        // Already assigned row should be non-interactive
        let assignedRow = app.row(AX.TaskAssignment.bankSelectorRow("BrushTeeth"))
        XCTAssertTrue(
            assignedRow.waitForExistence(timeout: 5),
            "Bank selector must still show 'BrushTeeth' row after assignment"
        )
        XCTAssertFalse(
            assignedRow.isEnabled,
            "Already-assigned template must be non-interactive (isEnabled == false)"
        )
    }

    // MARK: - TB-AC-12: Multi-select templates for assignment

    func testMultiSelectTemplatesForAssignment() throws {
        // DSGN-006 TB-AC-12: Parent can multi-select templates -- Add button count updates.
        openParentManagement()
        addChild(name: "Mia")
        addTemplate(name: "BrushTeeth")
        addTemplate(name: "GetDressed")

        navigateToTaskEditor(child: "Mia", topic: "Aamu")

        let addFromBankButton = app.row(AX.TaskAssignment.addFromBankButton)
        addFromBankButton.assertExists(timeout: 3)
        addFromBankButton.tap()

        // Select both templates
        let brushRow = app.row(AX.TaskAssignment.bankSelectorRow("BrushTeeth"))
        brushRow.assertExists(timeout: 3)
        brushRow.tap()

        let dressRow = app.row(AX.TaskAssignment.bankSelectorRow("GetDressed"))
        dressRow.assertExists(timeout: 3)
        dressRow.tap()

        // Add button label should show "Add (2)"
        let addButton = app.row(AX.TaskAssignment.bankSelectorAddButton)
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 3),
            "Bank selector Add button must exist"
        )
        let addButtonLabel = addButton.label
        XCTAssertTrue(
            addButtonLabel.contains("2"),
            "Bank selector Add button label must contain '2' when 2 templates are selected. Got: '\(addButtonLabel)'"
        )
    }

    // MARK: - TB-AC-14: Unassign template from child

    func testUnassignTemplateFromChild() throws {
        // REQ-008 AC-5: Parent can unassign a task template from a child/topic.
        // DSGN-006 TB-AC-14: Swipe left to remove assignment.
        openParentManagement()
        addChild(name: "Mia")
        addTemplate(name: "BrushTeeth")

        // Assign template
        navigateToTaskEditor(child: "Mia", topic: "Aamu")

        let addFromBankButton = app.row(AX.TaskAssignment.addFromBankButton)
        addFromBankButton.assertExists(timeout: 3)
        addFromBankButton.tap()

        let selectorRow = app.row(AX.TaskAssignment.bankSelectorRow("BrushTeeth"))
        selectorRow.assertExists(timeout: 3)
        selectorRow.tap()

        let bankAddButton = app.row(AX.TaskAssignment.bankSelectorAddButton)
        bankAddButton.assertExists(timeout: 3)
        bankAddButton.tap()

        // Now unassign: swipe left on assignment row
        let assignmentRow = app.cells[
            AX.TaskAssignment.assignmentRow(child: "Mia", topic: "Aamu", template: "BrushTeeth")
        ]
        assignmentRow.assertExists(timeout: 3)
        assignmentRow.swipeLeft()

        let removeAction = app.row(AX.TaskAssignment.assignmentRemoveAction("BrushTeeth"))
        XCTAssertTrue(
            removeAction.waitForExistence(timeout: 3),
            "Remove swipe action must appear after swiping left on assignment row"
        )
        removeAction.tap()

        // Assignment row must be gone
        XCTAssertFalse(
            app.cells[
                AX.TaskAssignment.assignmentRow(child: "Mia", topic: "Aamu", template: "BrushTeeth")
            ].waitForExistence(timeout: 2),
            "Assignment row must be removed after unassignment"
        )
    }

    // MARK: - TB-AC-15: Unassign does not delete from bank

    func testUnassignDoesNotDeleteFromBank() throws {
        // DSGN-006 TB-AC-15: Removing an assignment does not delete the template from the bank.
        openParentManagement()
        addChild(name: "Mia")
        addTemplate(name: "BrushTeeth")

        // Assign template
        navigateToTaskEditor(child: "Mia", topic: "Aamu")

        let addFromBankButton = app.row(AX.TaskAssignment.addFromBankButton)
        addFromBankButton.assertExists(timeout: 3)
        addFromBankButton.tap()

        let selectorRow = app.row(AX.TaskAssignment.bankSelectorRow("BrushTeeth"))
        selectorRow.assertExists(timeout: 3)
        selectorRow.tap()

        let bankAddButton = app.row(AX.TaskAssignment.bankSelectorAddButton)
        bankAddButton.assertExists(timeout: 3)
        bankAddButton.tap()

        // Unassign
        let assignmentRow = app.cells[
            AX.TaskAssignment.assignmentRow(child: "Mia", topic: "Aamu", template: "BrushTeeth")
        ]
        assignmentRow.assertExists(timeout: 3)
        assignmentRow.swipeLeft()

        let removeAction = app.row(AX.TaskAssignment.assignmentRemoveAction("BrushTeeth"))
        removeAction.assertExists(timeout: 3)
        removeAction.tap()

        // Navigate back to parent home
        navigateBackToParentHome()

        // Template must still exist in the Task Bank
        let templateRow = app.row(AX.TaskBank.templateRow("BrushTeeth"))
        XCTAssertTrue(
            templateRow.waitForExistence(timeout: 5),
            "Template 'BrushTeeth' must still exist in Task Bank after unassignment from child"
        )
    }

    // MARK: - TB-AC-24: Bank Selector search filters templates

    func testBankSelectorSearchFiltersTemplates() throws {
        // DSGN-006 TB-AC-24: Bank Selector has search functionality.
        openParentManagement()
        addChild(name: "Mia")
        addTemplate(name: "BrushTeeth")
        addTemplate(name: "GetDressed")

        navigateToTaskEditor(child: "Mia", topic: "Aamu")

        let addFromBankButton = app.row(AX.TaskAssignment.addFromBankButton)
        addFromBankButton.assertExists(timeout: 3)
        addFromBankButton.tap()

        // Type in search field
        let searchField = app.searchFields[AX.TaskAssignment.bankSelectorSearchField]
        XCTAssertTrue(
            searchField.waitForExistence(timeout: 5),
            "Bank selector search field must exist"
        )
        searchField.tap()
        searchField.typeText("Brush")

        // Only BrushTeeth should be visible
        let brushRow = app.row(AX.TaskAssignment.bankSelectorRow("BrushTeeth"))
        XCTAssertTrue(
            brushRow.waitForExistence(timeout: 3),
            "BrushTeeth must be visible when searching 'Brush'"
        )

        let dressRow = app.row(AX.TaskAssignment.bankSelectorRow("GetDressed"))
        XCTAssertFalse(
            dressRow.waitForExistence(timeout: 2),
            "GetDressed must NOT be visible when searching 'Brush'"
        )
    }

    // MARK: - TB-AC-25: Create new template from bank selector

    func testCreateNewTemplateFromBankSelector() throws {
        // DSGN-006 TB-AC-25: "Create New Template" button in Bank Selector opens template creation form.
        openParentManagement()
        addChild(name: "Mia")

        navigateToTaskEditor(child: "Mia", topic: "Aamu")

        let addFromBankButton = app.row(AX.TaskAssignment.addFromBankButton)
        addFromBankButton.assertExists(timeout: 3)
        addFromBankButton.tap()

        // Tap "Create New Template" button
        let createNewButton = app.row(AX.TaskAssignment.bankSelectorCreateNewButton)
        XCTAssertTrue(
            createNewButton.waitForExistence(timeout: 5),
            "Bank selector must show 'Create New Template' button"
        )
        createNewButton.tap()

        // Template form should appear
        let saveButton = app.row(AX.TaskBank.templateFormSaveButton)
        XCTAssertTrue(
            saveButton.waitForExistence(timeout: 5),
            "Template creation form (with Save button) must appear after tapping 'Create New Template'"
        )
    }
}

// MARK: - Task Bank Routine View Tests

final class TaskBankRoutineViewUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = AppLauncher.launchWithPIN()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - Navigation helpers

    /// Opens parent management by tapping the gear button and entering the correct PIN.
    private func openParentManagement() {
        let gearButton = app.row(AX.ChildRoutine.parentSettingsButton)
        XCTAssertTrue(
            gearButton.waitForExistence(timeout: 5),
            "Gear button must exist to open parent management"
        )
        gearButton.tap()

        XCTAssertTrue(
            app.row(AX.PINGate.dotDisplay).waitForExistence(timeout: 3),
            "PIN entry screen must appear"
        )
        enterPIN(TestConstants.testPIN)

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

    /// Dismisses parent management back to the routine view.
    private func dismissParentManagement() {
        let doneButton = app.row(AX.ParentManagement.doneButton)
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }
    }

    /// Adds a child with the given name. Assumes already in parent management.
    private func addChild(name: String) {
        let addButton = app.row(AX.ChildManagement.addChildButton)
        addButton.assertExists(timeout: 3)
        addButton.tap()

        let nameField = app.textFields[AX.ChildManagement.childNameField]
        nameField.assertExists(timeout: 3)
        nameField.tap()
        nameField.typeText(name)

        let saveButton = app.row(AX.ChildManagement.childFormSaveButton)
        saveButton.assertExists(timeout: 3)
        saveButton.tap()
    }

    /// Creates a task template. Assumes already in parent management.
    private func addTemplate(name: String) {
        let addButton = app.row(AX.TaskBank.addTemplateButton)
        addButton.assertExists(timeout: 3)
        addButton.tap()

        let nameField = app.textFields[AX.TaskBank.templateNameField]
        nameField.assertExists(timeout: 3)
        nameField.tap()
        nameField.typeText(name)

        // Select an icon
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
    /// Assumes already in parent management.
    private func navigateToTaskEditor(child: String, topic: String) {
        let childRow = app.row(AX.ParentManagement.childRowByName(child))
        childRow.assertExists(timeout: 3)
        childRow.tap()

        let topicRow = app.row(AX.TopicManagement.childTopicRow(child: child, topic: topic))
        topicRow.assertExists(timeout: 3)
        topicRow.tap()
    }

    /// Assigns a template to a child+topic via bank selector.
    /// Assumes already in the task editor for the desired child+topic.
    private func assignTemplate(_ templateName: String) {
        let addFromBankButton = app.row(AX.TaskAssignment.addFromBankButton)
        addFromBankButton.assertExists(timeout: 3)
        addFromBankButton.tap()

        let selectorRow = app.row(AX.TaskAssignment.bankSelectorRow(templateName))
        selectorRow.assertExists(timeout: 5)
        selectorRow.tap()

        let addButton = app.row(AX.TaskAssignment.bankSelectorAddButton)
        addButton.assertExists(timeout: 3)
        addButton.tap()
    }

    /// Navigates back from task editor to parent management root.
    private func navigateBackToParentHome() {
        // Back from task editor to child topic picker
        app.navigationBars.buttons.firstMatch.tap()
        // Back from child topic picker to parent home
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        }
    }

    // MARK: - Assigned task appears in routine view

    func testAssignedTaskAppearsInRoutineView() throws {
        // REQ-008 AC-10: Child-facing view displays assigned tasks.
        openParentManagement()
        addChild(name: "Mia")
        addTemplate(name: "BrushTeeth")

        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate("BrushTeeth")

        navigateBackToParentHome()
        dismissParentManagement()

        // Verify task appears in routine view
        let taskElement = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: "BrushTeeth"))
        let taskButton = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: "BrushTeeth"))
        let taskExists = taskElement.waitForExistence(timeout: 5) || taskButton.waitForExistence(timeout: 2)

        XCTAssertTrue(
            taskExists,
            "Assigned task 'BrushTeeth' must appear in Mia's routine view after assignment"
        )
    }

    // MARK: - TB-AC-06: Editing template updates routine view

    func testEditingTemplateUpdatesRoutineView() throws {
        // REQ-008 AC-2, AC-11: Editing a template updates display for all assigned children.
        // DSGN-006 TB-AC-06.
        openParentManagement()
        addChild(name: "Mia")
        addTemplate(name: "BrushTeeth")

        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate("BrushTeeth")

        navigateBackToParentHome()

        // Edit the template name in the bank
        let editButton = app.row(AX.TaskBank.templateEditButton("BrushTeeth"))
        editButton.assertExists(timeout: 3)
        editButton.tap()

        let nameField = app.textFields[AX.TaskBank.templateNameField]
        nameField.assertExists(timeout: 3)
        nameField.tap()
        nameField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        nameField.typeText("WashFace")

        let saveButton = app.row(AX.TaskBank.templateFormSaveButton)
        saveButton.assertExists(timeout: 3)
        saveButton.tap()

        // Go to routine view
        dismissParentManagement()

        // New name must appear
        let updatedTask = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: "WashFace"))
        let updatedTaskButton = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: "WashFace"))
        let newNameExists = updatedTask.waitForExistence(timeout: 5) || updatedTaskButton.waitForExistence(timeout: 2)

        XCTAssertTrue(
            newNameExists,
            "Routine view must show updated template name 'WashFace' after editing in Task Bank"
        )

        // Old name must be gone
        let oldTask = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: "BrushTeeth"))
        let oldTaskButton = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: "BrushTeeth"))
        XCTAssertFalse(
            oldTask.exists || oldTaskButton.exists,
            "Routine view must NOT show old template name 'BrushTeeth' after editing"
        )
    }

    // MARK: - TB-AC-08: Deleting template removes from routine view

    func testDeletingTemplateRemovesFromRoutineView() throws {
        // REQ-008 AC-3: Deleting template removes from all children's routine views.
        // DSGN-006 TB-AC-08.
        openParentManagement()
        addChild(name: "Mia")
        addTemplate(name: "BrushTeeth")

        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate("BrushTeeth")

        navigateBackToParentHome()

        // Delete the template from the bank
        let templateRow = app.row(AX.TaskBank.templateRow("BrushTeeth"))
        templateRow.assertExists(timeout: 3)
        templateRow.swipeLeft()

        let deleteAction = app.row(AX.TaskBank.templateDeleteAction("BrushTeeth"))
        deleteAction.assertExists(timeout: 3)
        deleteAction.tap()

        let confirmButton = app.row(AX.TaskBank.deleteTemplateConfirmButton)
        confirmButton.assertExists(timeout: 3)
        confirmButton.tap()

        // Go to routine view
        dismissParentManagement()

        // Task must be gone from routine view
        let taskElement = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: "BrushTeeth"))
        let taskButton = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: "BrushTeeth"))
        XCTAssertFalse(
            taskElement.exists || taskButton.exists,
            "Deleted template 'BrushTeeth' must be removed from Mia's routine view"
        )
    }

    // MARK: - TB-AC-18: Same template to two children

    func testSameTemplateTwoChildren() throws {
        // REQ-008 AC-6: A task template can be assigned to multiple children.
        // DSGN-006 TB-AC-18.
        openParentManagement()
        addChild(name: "Mia")
        addChild(name: "Leo")
        addTemplate(name: "BrushTeeth")

        // Assign to Mia
        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate("BrushTeeth")
        navigateBackToParentHome()

        // Assign to Leo
        navigateToTaskEditor(child: "Leo", topic: "Aamu")
        assignTemplate("BrushTeeth")
        navigateBackToParentHome()

        // Go to routine view
        dismissParentManagement()

        // Both children should show the task
        let miaTask = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: "BrushTeeth"))
        let miaTaskButton = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: "BrushTeeth"))
        let miaHasTask = miaTask.waitForExistence(timeout: 5) || miaTaskButton.waitForExistence(timeout: 2)

        XCTAssertTrue(
            miaHasTask,
            "Mia must show 'BrushTeeth' task in routine view"
        )

        let leoTask = app.row(AX.ChildRoutine.taskByName(child: "Leo", task: "BrushTeeth"))
        let leoTaskButton = app.row(AX.ChildRoutine.taskByName(child: "Leo", task: "BrushTeeth"))
        let leoHasTask = leoTask.waitForExistence(timeout: 5) || leoTaskButton.waitForExistence(timeout: 2)

        XCTAssertTrue(
            leoHasTask,
            "Leo must show 'BrushTeeth' task in routine view"
        )
    }

    // MARK: - TB-AC-20: Completion independent per child

    func testCompletionIndependentPerChild() throws {
        // REQ-008 AC-8: Each child has independent completion state per assigned task.
        // DSGN-006 TB-AC-20.
        openParentManagement()
        addChild(name: "Mia")
        addChild(name: "Leo")
        addTemplate(name: "BrushTeeth")

        // Assign to both
        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate("BrushTeeth")
        navigateBackToParentHome()

        navigateToTaskEditor(child: "Leo", topic: "Aamu")
        assignTemplate("BrushTeeth")
        navigateBackToParentHome()

        dismissParentManagement()

        // Complete task for Mia
        let miaTaskButton = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: "BrushTeeth"))
        XCTAssertTrue(
            miaTaskButton.waitForExistence(timeout: 5),
            "Mia's BrushTeeth task button must exist in routine view"
        )
        miaTaskButton.tap()

        // Wait for Mia's task to be marked done
        let donePredicate = NSPredicate(format: "value == 'done'")
        let doneExpectation = expectation(for: donePredicate, evaluatedWith: miaTaskButton)
        wait(for: [doneExpectation], timeout: 5.0)

        // Leo's task must NOT be done
        let leoTaskButton = app.row(AX.ChildRoutine.taskByName(child: "Leo", task: "BrushTeeth"))
        XCTAssertTrue(
            leoTaskButton.waitForExistence(timeout: 3),
            "Leo's BrushTeeth task button must exist in routine view"
        )
        XCTAssertEqual(
            leoTaskButton.value as? String,
            "not done",
            "Leo's BrushTeeth task must remain 'not done' after completing Mia's task"
        )
    }

    // MARK: - TB-AC-19: Same template in two topics

    func testSameTemplateInTwoTopics() throws {
        // REQ-008 AC-7: A task template can be assigned to the same child in multiple topics.
        // DSGN-006 TB-AC-19.
        openParentManagement()
        addChild(name: "Mia")
        addTemplate(name: "BrushTeeth")

        // Create a second topic "Ilta"
        app.row(AX.TopicManagement.addTopicButton).tap()
        let topicNameField = app.textFields[AX.TopicManagement.addTopicNameField]
        topicNameField.assertExists(timeout: 3)
        topicNameField.tap()
        topicNameField.typeText("Ilta")
        app.row(AX.TopicManagement.addTopicConfirmButton).tap()

        // Assign BrushTeeth to Mia in Aamu
        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate("BrushTeeth")
        navigateBackToParentHome()

        // Assign BrushTeeth to Mia in Ilta
        navigateToTaskEditor(child: "Mia", topic: "Ilta")
        assignTemplate("BrushTeeth")
        navigateBackToParentHome()

        dismissParentManagement()

        // Verify task appears in Aamu topic tab
        let aamuTab = app.row(AX.TopicTab.tab("Aamu"))
        if aamuTab.waitForExistence(timeout: 3) {
            aamuTab.tap()
        }

        let miaTaskAamu = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: "BrushTeeth"))
        let miaTaskAamuButton = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: "BrushTeeth"))
        let aamuHasTask = miaTaskAamu.waitForExistence(timeout: 5) || miaTaskAamuButton.waitForExistence(timeout: 2)

        XCTAssertTrue(
            aamuHasTask,
            "BrushTeeth must appear in Mia's Aamu topic view"
        )

        // Switch to Ilta topic tab
        let iltaTab = app.row(AX.TopicTab.tab("Ilta"))
        XCTAssertTrue(
            iltaTab.waitForExistence(timeout: 3),
            "Ilta topic tab must exist"
        )
        iltaTab.tap()

        let miaTaskIlta = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: "BrushTeeth"))
        let miaTaskIltaButton = app.row(AX.ChildRoutine.taskByName(child: "Mia", task: "BrushTeeth"))
        let iltaHasTask = miaTaskIlta.waitForExistence(timeout: 5) || miaTaskIltaButton.waitForExistence(timeout: 2)

        XCTAssertTrue(
            iltaHasTask,
            "BrushTeeth must appear in Mia's Ilta topic view"
        )
    }
}
