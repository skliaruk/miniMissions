// CopyTasksUITests.swift
// XCUITest suite for "Copy tasks from another child" feature.
//
// REQ coverage: Copy tasks — when in TaskEditorView (child + topic), a "Kopioi" (Copy)
// toolbar button allows copying all TaskAssignments from another child in the same topic.
//
// TDD Red Phase: All tests below compile but WILL FAIL because no implementation exists yet.
// These tests constitute the specification that MDEV must satisfy.

import XCTest

final class CopyTasksUITests: XCTestCase {

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
            childRow.waitForExistence(timeout: 10),
            "Child row for '\(child)' must exist in parent management"
        )
        childRow.tap()

        // Select the topic from the child topic picker
        let topicRow = app.row(AX.TopicManagement.childTopicRow(child: child, topic: topic))
        XCTAssertTrue(
            topicRow.waitForExistence(timeout: 10),
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
        // Wait for parent management root to be visible
        _ = app.row(AX.ParentManagement.root).waitForExistence(timeout: 3)
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

    // MARK: - Test 1: Copy button visible when other children have tasks in same topic

    /// REQ: Copy tasks — covers: "The 'Copy' button appears in TaskEditorView when there are
    /// other children with tasks in the same topic."
    ///
    /// Strategy:
    /// 1. Create two children (Mia, Leo) and a template (BrushTeeth).
    /// 2. Assign BrushTeeth to Leo in the "Aamu" topic.
    /// 3. Navigate to Mia's task editor for "Aamu".
    /// 4. Verify the "Kopioi" (Copy) button is visible.
    func testCopyButtonVisibleWhenOtherChildrenHaveTasks() throws {
        openParentManagement()

        // Create two children and a template
        addChild(name: "Mia")
        addChild(name: "Leo")
        addTemplate(name: "BrushTeeth")

        // Assign BrushTeeth to Leo in "Aamu" topic
        navigateToTaskEditor(child: "Leo", topic: "Aamu")
        assignTemplate(named: "BrushTeeth")
        navigateBackToParentHome()

        // Navigate to Mia's task editor for "Aamu"
        navigateToTaskEditor(child: "Mia", topic: "Aamu")

        // The "Kopioi" (Copy) button must be visible
        let copyButton = app.row(AX.TaskAssignment.copyFromButton)
        XCTAssertTrue(
            copyButton.waitForExistence(timeout: 5),
            "Copy button must be visible in TaskEditorView when another child (Leo) has tasks " +
            "in the same topic (Aamu). MDEV must add a toolbar button with identifier " +
            "'\(AX.TaskAssignment.copyFromButton)' to TaskEditorView."
        )
    }

    // MARK: - Test 2: Copy button hidden when no other children have tasks in same topic

    /// REQ: Copy tasks — covers: "The 'Copy' button is hidden when no other children have tasks
    /// in the same topic."
    ///
    /// Strategy:
    /// 1. Create one child (Mia) only — no other children exist.
    /// 2. Navigate to Mia's task editor for "Aamu".
    /// 3. Verify the "Kopioi" (Copy) button is NOT visible.
    func testCopyButtonHiddenWhenNoOtherChildrenHaveTasks() throws {
        openParentManagement()

        // Create only one child — no other children with tasks
        addChild(name: "Mia")

        navigateToTaskEditor(child: "Mia", topic: "Aamu")

        // The "Kopioi" (Copy) button must NOT be visible
        let copyButton = app.row(AX.TaskAssignment.copyFromButton)
        let buttonExists = copyButton.waitForExistence(timeout: 2)
        XCTAssertFalse(
            buttonExists,
            "Copy button must be hidden when no other children have tasks in the same topic. " +
            "Only one child (Mia) exists, so there is nobody to copy from."
        )
    }

    // MARK: - Test 3: Copying brings all templates from source child

    /// REQ: Copy tasks — covers: "After copying, all templates from the source child appear in
    /// the target child's task list."
    ///
    /// Strategy:
    /// 1. Create two children (Mia, Leo) and two templates (BrushTeeth, GetDressed).
    /// 2. Assign both templates to Leo in "Aamu".
    /// 3. Navigate to Mia's task editor for "Aamu".
    /// 4. Tap the Copy button, select Leo, confirm.
    /// 5. Verify both templates appear in Mia's task list.
    func testCopyingBringsAllTemplatesFromSourceChild() throws {
        openParentManagement()

        // Create children and templates
        addChild(name: "Mia")
        addChild(name: "Leo")
        addTemplate(name: "BrushTeeth")
        addTemplate(name: "GetDressed")

        // Assign both templates to Leo in "Aamu"
        navigateToTaskEditor(child: "Leo", topic: "Aamu")
        assignTemplate(named: "BrushTeeth")
        assignTemplate(named: "GetDressed")
        navigateBackToParentHome()

        // Navigate to Mia's task editor for "Aamu"
        navigateToTaskEditor(child: "Mia", topic: "Aamu")

        // Tap Copy button
        let copyButton = app.row(AX.TaskAssignment.copyFromButton)
        XCTAssertTrue(
            copyButton.waitForExistence(timeout: 5),
            "Copy button must be visible to initiate copy from Leo"
        )
        copyButton.tap()

        // Select Leo from the copy source sheet
        let leoRow = app.row(AX.TaskAssignment.copySourceChildRow("Leo"))
        XCTAssertTrue(
            leoRow.waitForExistence(timeout: 5),
            "Copy source sheet must show Leo as a source child. MDEV must present a sheet " +
            "listing other children with identifier '\(AX.TaskAssignment.copySourceChildRow("Leo"))'."
        )
        leoRow.tap()

        // Confirm copy
        let confirmButton = app.row(AX.TaskAssignment.copySourceConfirmButton)
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 3),
            "Confirm button must exist in copy source sheet"
        )
        confirmButton.tap()

        // Verify both templates now appear in Mia's task editor
        let brushRow = app.row(
            AX.TaskAssignment.assignmentRow(child: "Mia", topic: "Aamu", template: "BrushTeeth")
        )
        let dressRow = app.row(
            AX.TaskAssignment.assignmentRow(child: "Mia", topic: "Aamu", template: "GetDressed")
        )

        XCTAssertTrue(
            brushRow.waitForExistence(timeout: 5),
            "After copying from Leo, 'BrushTeeth' must appear in Mia's task list for Aamu"
        )
        XCTAssertTrue(
            dressRow.waitForExistence(timeout: 3),
            "After copying from Leo, 'GetDressed' must appear in Mia's task list for Aamu"
        )
    }

    // MARK: - Test 4: Already assigned templates are not duplicated

    /// REQ: Copy tasks — covers: "Templates already assigned to the target child are not duplicated."
    ///
    /// Strategy:
    /// 1. Create two children (Mia, Leo) and two templates (BrushTeeth, GetDressed).
    /// 2. Assign BrushTeeth to both Mia and Leo in "Aamu".
    /// 3. Assign GetDressed to Leo only.
    /// 4. Copy from Leo to Mia.
    /// 5. Verify Mia has both templates, but BrushTeeth appears only once (not duplicated).
    func testAlreadyAssignedTemplatesAreNotDuplicated() throws {
        openParentManagement()

        // Create children and templates
        addChild(name: "Mia")
        addChild(name: "Leo")
        addTemplate(name: "BrushTeeth")
        addTemplate(name: "GetDressed")

        // Assign BrushTeeth to Mia in "Aamu"
        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate(named: "BrushTeeth")
        navigateBackToParentHome()

        // Assign both BrushTeeth and GetDressed to Leo in "Aamu"
        navigateToTaskEditor(child: "Leo", topic: "Aamu")
        assignTemplate(named: "BrushTeeth")
        assignTemplate(named: "GetDressed")
        navigateBackToParentHome()

        // Navigate to Mia's task editor and copy from Leo
        navigateToTaskEditor(child: "Mia", topic: "Aamu")

        let copyButton = app.row(AX.TaskAssignment.copyFromButton)
        XCTAssertTrue(
            copyButton.waitForExistence(timeout: 5),
            "Copy button must be visible"
        )
        copyButton.tap()

        let leoRow = app.row(AX.TaskAssignment.copySourceChildRow("Leo"))
        XCTAssertTrue(
            leoRow.waitForExistence(timeout: 5),
            "Leo must appear in copy source sheet"
        )
        leoRow.tap()

        let confirmButton = app.row(AX.TaskAssignment.copySourceConfirmButton)
        confirmButton.assertExists(timeout: 3)
        confirmButton.tap()

        // Verify Mia has both templates
        let brushRow = app.row(
            AX.TaskAssignment.assignmentRow(child: "Mia", topic: "Aamu", template: "BrushTeeth")
        )
        let dressRow = app.row(
            AX.TaskAssignment.assignmentRow(child: "Mia", topic: "Aamu", template: "GetDressed")
        )

        XCTAssertTrue(
            brushRow.waitForExistence(timeout: 5),
            "BrushTeeth must exist in Mia's task list after copy"
        )
        XCTAssertTrue(
            dressRow.waitForExistence(timeout: 3),
            "GetDressed must appear in Mia's task list after copying from Leo"
        )

        // Verify BrushTeeth is NOT duplicated — count assignment rows matching BrushTeeth
        let brushRowPredicate = NSPredicate(
            format: "identifier == %@",
            AX.TaskAssignment.assignmentRow(child: "Mia", topic: "Aamu", template: "BrushTeeth")
        )
        let brushMatches = app.descendants(matching: .any).matching(brushRowPredicate)
        XCTAssertEqual(
            brushMatches.count,
            1,
            "BrushTeeth must appear exactly once in Mia's task list — already-assigned templates " +
            "must not be duplicated during copy. Found \(brushMatches.count) instances."
        )
    }

    // MARK: - Test 5: Copying does not remove tasks from source child

    /// REQ: Copy tasks — covers: "Copying does not remove existing tasks from the source child."
    ///
    /// Strategy:
    /// 1. Create two children (Mia, Leo) and two templates (BrushTeeth, GetDressed).
    /// 2. Assign both templates to Leo in "Aamu".
    /// 3. Copy from Leo to Mia.
    /// 4. Navigate to Leo's task editor for "Aamu".
    /// 5. Verify both templates still exist in Leo's task list.
    func testCopyingDoesNotRemoveTasksFromSourceChild() throws {
        openParentManagement()

        // Create children and templates
        addChild(name: "Mia")
        addChild(name: "Leo")
        addTemplate(name: "BrushTeeth")
        addTemplate(name: "GetDressed")

        // Assign both templates to Leo in "Aamu"
        navigateToTaskEditor(child: "Leo", topic: "Aamu")
        assignTemplate(named: "BrushTeeth")
        assignTemplate(named: "GetDressed")
        navigateBackToParentHome()

        // Navigate to Mia's task editor and copy from Leo
        navigateToTaskEditor(child: "Mia", topic: "Aamu")

        let copyButton = app.row(AX.TaskAssignment.copyFromButton)
        XCTAssertTrue(
            copyButton.waitForExistence(timeout: 5),
            "Copy button must be visible"
        )
        copyButton.tap()

        let leoRow = app.row(AX.TaskAssignment.copySourceChildRow("Leo"))
        XCTAssertTrue(
            leoRow.waitForExistence(timeout: 5),
            "Leo must appear in copy source sheet"
        )
        leoRow.tap()

        let confirmButton = app.row(AX.TaskAssignment.copySourceConfirmButton)
        confirmButton.assertExists(timeout: 3)
        confirmButton.tap()

        // Wait for copy to complete — Mia's assignments should appear
        let miaAssignment = app.row(
            AX.TaskAssignment.assignmentRow(child: "Mia", topic: "Aamu", template: "BrushTeeth")
        )
        XCTAssertTrue(
            miaAssignment.waitForExistence(timeout: 5),
            "Copy must complete — Mia should have BrushTeeth"
        )

        // Navigate back to parent home
        navigateBackToParentHome()

        // Navigate to Leo's task editor for "Aamu"
        navigateToTaskEditor(child: "Leo", topic: "Aamu")

        // Verify Leo still has both templates
        let leoBrushRow = app.row(
            AX.TaskAssignment.assignmentRow(child: "Leo", topic: "Aamu", template: "BrushTeeth")
        )
        let leoDressRow = app.row(
            AX.TaskAssignment.assignmentRow(child: "Leo", topic: "Aamu", template: "GetDressed")
        )

        XCTAssertTrue(
            leoBrushRow.waitForExistence(timeout: 5),
            "After copying to Mia, Leo must still have 'BrushTeeth' in Aamu — copy must not " +
            "remove tasks from the source child"
        )
        XCTAssertTrue(
            leoDressRow.waitForExistence(timeout: 3),
            "After copying to Mia, Leo must still have 'GetDressed' in Aamu — copy must not " +
            "remove tasks from the source child"
        )
    }
}
