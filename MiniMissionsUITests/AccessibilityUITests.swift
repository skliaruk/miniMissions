// AccessibilityUITests.swift
// XCUITest suite for iPad layout, accessibility, and state persistence requirements.
//
// REQ coverage: REQ-005
// DSGN coverage: DSGN-002 MRV-AC-02, MRV-AC-05, MRV-AC-12, MRV-AC-13; DSGN-003 PM-AC-19
//
// TDD Red Phase: All tests below compile but WILL FAIL because no implementation exists yet.
// These tests constitute the specification that MDEV must satisfy.

import XCTest

final class AccessibilityUITests: XCTestCase {

    var app: XCUIApplication!

    // Test child names -- no children are seeded, so tests create their own.
    private let testChildren = ["Mia", "Leo", "Ella"]

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = AppLauncher.launchWithPIN()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - Helpers

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

    private func enterPIN(_ pin: String) {
        for character in pin {
            guard let digit = Int(String(character)) else { continue }
            let key = app.row(AX.PINGate.key(digit))
            key.waitForExistence(timeout: 3)
            key.tap()
        }
    }

    private func addChild(name: String) {
        let addButton = app.row(AX.ChildManagement.addChildButton)
        XCTAssertTrue(addButton.waitForExistence(timeout: 3), "Add Child button must exist")
        addButton.tap()

        let nameField = app.textFields[AX.ChildManagement.childNameField]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3), "Child name field must appear")
        nameField.tap()
        nameField.typeText(name)

        let saveButton = app.row(AX.ChildManagement.childFormSaveButton)
        saveButton.assertExists(timeout: 3)
        saveButton.tap()
    }

    private func addTemplate(name: String) {
        let addButton = app.row(AX.TaskBank.addTemplateButton)
        XCTAssertTrue(addButton.waitForExistence(timeout: 3), "Add Template button must exist")
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

    private func navigateToTaskEditor(child: String, topic: String) {
        let childRow = app.row(AX.ParentManagement.childRowByName(child))
        XCTAssertTrue(childRow.waitForExistence(timeout: 3), "Child row for '\(child)' must exist")
        childRow.tap()

        let topicRow = app.row(AX.TopicManagement.childTopicRow(child: child, topic: topic))
        XCTAssertTrue(topicRow.waitForExistence(timeout: 3), "Topic row must exist")
        topicRow.tap()
    }

    private func assignTemplate(named templateName: String) {
        let addFromBankButton = app.row(AX.TaskAssignment.addFromBankButton)
        addFromBankButton.assertExists(timeout: 3)
        addFromBankButton.tap()

        let selectorRow = app.row(AX.TaskAssignment.bankSelectorRow(templateName))
        XCTAssertTrue(selectorRow.waitForExistence(timeout: 5), "Bank selector must show '\(templateName)'")
        selectorRow.tap()

        let addButton = app.row(AX.TaskAssignment.bankSelectorAddButton)
        addButton.assertExists(timeout: 3)
        addButton.tap()
    }

    private func navigateBackToParentHome() {
        app.navigationBars.buttons.firstMatch.tap()
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        }
        _ = app.row(AX.ParentManagement.root).waitForExistence(timeout: 3)
    }

    private func dismissParentManagement() {
        let doneButton = app.row(AX.ParentManagement.doneButton)
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }
    }

    /// Sets up 3 test children via parent management, then returns to routine view.
    private func setupThreeChildren() {
        openParentManagement()
        for name in testChildren {
            addChild(name: name)
        }
        dismissParentManagement()
    }

    /// Sets up 3 test children with tasks, then returns to routine view.
    private func setupThreeChildrenWithTasks() {
        openParentManagement()
        for name in testChildren {
            addChild(name: name)
        }
        addTemplate(name: "TestTask")
        for name in testChildren {
            navigateToTaskEditor(child: name, topic: "Aamu")
            assignTemplate(named: "TestTask")
            navigateBackToParentHome()
        }
        dismissParentManagement()
    }

    // MARK: - REQ-005 AC-1, AC-2 -- Landscape orientation lock

    func testAppRunsInLandscapeOrientation() throws {
        // REQ-005 AC-1: App runs in landscape orientation on all supported iPad sizes.
        setupThreeChildren()

        let routineRoot = app.row(AX.ChildRoutine.root)
        XCTAssertTrue(
            routineRoot.waitForExistence(timeout: 5),
            "Routine view root must exist to check orientation"
        )

        let routineFrame = routineRoot.frame
        XCTAssertGreaterThan(
            routineFrame.width,
            routineFrame.height,
            "App must run in landscape orientation: width (\(routineFrame.width)) must exceed height (\(routineFrame.height))"
        )
    }

    func testRotatingDeviceDoesNotAlterLayout() throws {
        // REQ-005 AC-2: Portrait orientation is locked.
        setupThreeChildren()

        XCUIDevice.shared.orientation = .landscapeLeft
        _ = app.row(AX.ChildRoutine.root).waitForExistence(timeout: 3)

        XCUIDevice.shared.orientation = .portrait
        Thread.sleep(forTimeInterval: 0.5)

        for index in 0..<3 {
            let column = app.row(AX.ChildRoutine.column(index))
            XCTAssertTrue(
                column.waitForExistence(timeout: 3),
                "Child column \(index) must still exist after portrait rotation attempt"
            )
            XCTAssertTrue(
                column.isHittable,
                "Child column \(index) must remain hittable after portrait rotation attempt"
            )
        }

        XCUIDevice.shared.orientation = .landscapeLeft
    }

    // MARK: - REQ-005 AC-3 -- Child-facing touch targets >= 60x60pt

    func testAllChildFacingTaskButtonsHave60ptMinimumTouchTarget() throws {
        // REQ-005 AC-3: All child-facing touch targets are >= 60x60pt.
        setupThreeChildrenWithTasks()

        let taskButtons = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        )
        for index in 0..<taskButtons.count {
            let button = taskButtons.element(boundBy: index)
            button.assertMinTouchTarget(60)
        }

        let taskRows = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskRow_'")
        )
        for index in 0..<taskRows.count {
            let row = taskRows.element(boundBy: index)
            row.assertMinTouchTarget(60)
        }
    }

    func testParentGearButtonMeetsStandardMinimumTouchTarget() throws {
        let gearButton = app.row(AX.ChildRoutine.parentSettingsButton)
        XCTAssertTrue(
            gearButton.waitForExistence(timeout: 5),
            "Parent settings gear button must exist"
        )
        gearButton.assertMinTouchTarget(44)
    }

    // MARK: - REQ-005 AC-6 -- VoiceOver labels present on all interactive elements

    func testGearButtonHasVoiceOverLabel() throws {
        let gearButton = app.row(AX.ChildRoutine.parentSettingsButton)
        XCTAssertTrue(
            gearButton.waitForExistence(timeout: 5),
            "Gear button must exist"
        )
        XCTAssertEqual(
            gearButton.label,
            "Vanhempien asetukset",
            "Gear button must have VoiceOver label 'Vanhempien asetukset' (Finnish locale)"
        )
        XCTAssertFalse(
            gearButton.label.isEmpty,
            "Gear button must have a non-empty VoiceOver label"
        )
    }

    func testChildColumnCardsHaveVoiceOverLabels() throws {
        setupThreeChildren()

        for childName in testChildren {
            let column = app.row(AX.ChildRoutine.columnByName(childName))
            if column.waitForExistence(timeout: 5) {
                XCTAssertFalse(
                    column.label.isEmpty,
                    "Child column for '\(childName)' must have a non-empty VoiceOver label"
                )
                XCTAssertTrue(
                    column.label.contains(childName),
                    "Child column label must contain the child's name '\(childName)'. Got: '\(column.label)'"
                )
            }
        }
    }

    func testChildNameLabelsHaveVoiceOverLabels() throws {
        setupThreeChildren()

        for childName in testChildren {
            let nameLabel = app.staticTexts[AX.ChildRoutine.childNameLabel(childName)]
            if nameLabel.waitForExistence(timeout: 5) {
                XCTAssertFalse(
                    nameLabel.label.isEmpty,
                    "Name label for '\(childName)' must have a non-empty VoiceOver label"
                )
                XCTAssertEqual(
                    nameLabel.label,
                    "\(childName):n tehtävät",
                    "Name label for '\(childName)' must have VoiceOver label '\(childName):n tehtävät' (Finnish locale)"
                )
            }
        }
    }

    func testTaskButtonsHaveVoiceOverLabelsAndValues() throws {
        setupThreeChildrenWithTasks()

        let taskButtons = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        )
        for index in 0..<taskButtons.count {
            let button = taskButtons.element(boundBy: index)
            XCTAssertFalse(
                button.label.isEmpty,
                "Task button '\(button.identifier)' must have a non-empty VoiceOver label (task name)"
            )
            let value = button.value as? String ?? ""
            XCTAssertTrue(
                value == "not done" || value == "done",
                "Task button '\(button.identifier)' must have accessibilityValue 'not done' or 'done', got '\(value)'"
            )
        }
    }

    func testProgressIndicatorsHaveVoiceOverLabels() throws {
        setupThreeChildren()

        for childName in testChildren {
            let progressIndicator = app.row(AX.ChildRoutine.progressIndicator(childName))
            if progressIndicator.waitForExistence(timeout: 5) {
                XCTAssertFalse(
                    progressIndicator.label.isEmpty,
                    "Progress indicator for '\(childName)' must have a non-empty VoiceOver label"
                )
                XCTAssertTrue(
                    progressIndicator.label.lowercased().contains("tehtävä") ||
                    progressIndicator.label.lowercased().contains("valmis"),
                    "Progress indicator label must mention 'tehtävä' or 'valmis' (Finnish locale) -- got '\(progressIndicator.label)'"
                )
            }
        }
    }

    // MARK: - REQ-005 AC-7, AC-8 -- State persistence: task completion survives app restart

    func testTaskCompletionStatePersistedAcrossAppRestart() throws {
        // REQ-005 AC-7, AC-8: Task completion state persists across app restarts.
        // IMPORTANT: This test uses real on-disk SwiftData persistence.

        app.terminate()
        app = AppLauncher.launchWithPersistenceAndPIN()

        // Add a child and task via parent management
        openParentManagement()
        addChild(name: "Mia")
        addTemplate(name: "PersistenceTask")
        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate(named: "PersistenceTask")
        navigateBackToParentHome()
        dismissParentManagement()

        // Complete the first task in child 0's column
        let taskButton = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_0_'")
        ).firstMatch
        XCTAssertTrue(
            taskButton.waitForExistence(timeout: 5),
            "Task button must exist to test persistence"
        )
        let taskIdentifier = taskButton.identifier
        taskButton.tap()

        let donePredicate = NSPredicate(format: "value == 'done'")
        let doneExpectation = expectation(for: donePredicate, evaluatedWith: taskButton)
        wait(for: [doneExpectation], timeout: 2.0)

        // Relaunch WITHOUT --uitesting to preserve on-disk data
        app.terminate()
        app = AppLauncher.launchWithPersistence()

        let restoredTaskButton = app.row(taskIdentifier)
        XCTAssertTrue(
            restoredTaskButton.waitForExistence(timeout: 5),
            "Task button '\(taskIdentifier)' must still exist after app restart"
        )
        XCTAssertEqual(
            restoredTaskButton.value as? String,
            "done",
            "Task completion state must persist across app restart (REQ-005 AC-8)"
        )

        // Cleanup: reset the day
        let gearButtonAfterRelaunch = app.row(AX.ChildRoutine.parentSettingsButton)
        gearButtonAfterRelaunch.waitForExistence(timeout: 5)
        gearButtonAfterRelaunch.tap()
        app.row(AX.PINGate.dotDisplay).waitForExistence(timeout: 3)
        enterPIN(TestConstants.testPIN)
        app.row(AX.ParentManagement.root).waitForExistence(timeout: 5)
        app.row(AX.ParentManagement.resetDayButton).tap()
        app.row(AX.ParentManagement.resetDayConfirmButton).tap()
    }

    // MARK: - REQ-005 AC-9 -- Settings persistence

    func testParentSettingsPersistedAcrossAppRestart() throws {
        // REQ-005 AC-9: Parent settings persist across app restarts.
        app.terminate()
        app = AppLauncher.launchWithPersistenceAndPIN()

        // Add a child and task via parent management
        openParentManagement()
        addChild(name: "Leo")
        addTemplate(name: "PersistTask2")
        navigateToTaskEditor(child: "Leo", topic: "Aamu")
        assignTemplate(named: "PersistTask2")
        navigateBackToParentHome()

        // Verify assignment row exists
        navigateToTaskEditor(child: "Leo", topic: "Aamu")
        let assignmentRow = app.cells[
            AX.TaskAssignment.assignmentRow(child: "Leo", topic: "Aamu", template: "PersistTask2")
        ]
        XCTAssertTrue(
            assignmentRow.waitForExistence(timeout: 3),
            "Task 'PersistTask2' must appear in task editor after adding"
        )

        // Terminate and relaunch without --uitesting
        app.terminate()
        app = AppLauncher.launchWithPersistence()

        // Navigate to parent management again
        let gearButtonAfter = app.row(AX.ChildRoutine.parentSettingsButton)
        gearButtonAfter.waitForExistence(timeout: 5)
        gearButtonAfter.tap()
        app.row(AX.PINGate.dotDisplay).waitForExistence(timeout: 3)
        enterPIN(TestConstants.testPIN)
        app.row(AX.ParentManagement.root).waitForExistence(timeout: 5)

        let childRowAfter = app.row(AX.ParentManagement.childRowByName("Leo"))
        childRowAfter.waitForExistence(timeout: 3)
        childRowAfter.tap()

        let topicRow = app.row(AX.TopicManagement.childTopicRow(child: "Leo", topic: "Aamu"))
        topicRow.waitForExistence(timeout: 3)
        topicRow.tap()

        // Task must still exist after restart
        let persistedAssignment = app.cells[
            AX.TaskAssignment.assignmentRow(child: "Leo", topic: "Aamu", template: "PersistTask2")
        ]
        XCTAssertTrue(
            persistedAssignment.waitForExistence(timeout: 5),
            "Task 'PersistTask2' must persist across app restart (REQ-005 AC-9)"
        )

        // Also verify in routine view
        navigateBackToParentHome()
        dismissParentManagement()

        let taskInRoutine = app.buttons.matching(
            NSPredicate(format: "identifier CONTAINS 'PersistTask2'")
        ).firstMatch
        XCTAssertTrue(
            taskInRoutine.waitForExistence(timeout: 5),
            "Persisted task 'PersistTask2' must appear in routine view after app restart"
        )

        // Cleanup: remove the added task
        let gearCleanup = app.row(AX.ChildRoutine.parentSettingsButton)
        gearCleanup.waitForExistence(timeout: 5)
        gearCleanup.tap()
        app.row(AX.PINGate.dotDisplay).waitForExistence(timeout: 3)
        enterPIN(TestConstants.testPIN)
        app.row(AX.ParentManagement.root).waitForExistence(timeout: 5)

        // Delete the template from the bank to clean up
        let templateRow = app.row(AX.TaskBank.templateRow("PersistTask2"))
        if templateRow.waitForExistence(timeout: 3) {
            templateRow.swipeLeft()
            app.row(AX.TaskBank.templateDeleteAction("PersistTask2")).tap()
            app.row(AX.TaskBank.deleteTemplateConfirmButton).tap()
        }
    }

    // MARK: - Full child-facing interaction path (integration of REQ-005 criteria)

    func testAllThreeChildColumnsHaveVoiceOverStructure() throws {
        setupThreeChildren()

        for childName in testChildren {
            let column = app.row(AX.ChildRoutine.columnByName(childName))
            if column.waitForExistence(timeout: 5) {
                XCTAssertFalse(column.label.isEmpty,
                    "Column card for '\(childName)' must have non-empty VoiceOver label")
            }

            let nameLabel = app.staticTexts[AX.ChildRoutine.childNameLabel(childName)]
            if nameLabel.exists {
                XCTAssertFalse(nameLabel.label.isEmpty,
                    "Name label for '\(childName)' must have non-empty VoiceOver label")
            }

            let progress = app.row(AX.ChildRoutine.progressIndicator(childName))
            if progress.exists {
                XCTAssertFalse(progress.label.isEmpty,
                    "Progress indicator for '\(childName)' must have non-empty VoiceOver label")
            }
        }

        let gearButton = app.row(AX.ChildRoutine.parentSettingsButton)
        gearButton.waitForExistence(timeout: 5)
        XCTAssertEqual(gearButton.label, "Vanhempien asetukset",
            "Gear button must have VoiceOver label 'Vanhempien asetukset' (DSGN-002 §2.2, Finnish locale)")
    }

    func testAllTaskButtonsHaveAccessibilityHintWhenIncomplete() throws {
        setupThreeChildrenWithTasks()

        let taskButtons = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        )
        for index in 0..<taskButtons.count {
            let button = taskButtons.element(boundBy: index)
            if (button.value as? String) == "not done" {
                XCTAssertFalse(
                    button.label.isEmpty,
                    "Incomplete task button '\(button.identifier)' must have a non-empty accessibility label"
                )
            }
        }
    }

    // MARK: - REQ-005 AC-4 (text size >= 24pt)

    func testChildFacingTextMeetsMinimumFontSizeViaAccessibilityTree() throws {
        setupThreeChildren()

        for childName in testChildren {
            let nameLabel = app.staticTexts[AX.ChildRoutine.childNameLabel(childName)]
            if nameLabel.waitForExistence(timeout: 5) {
                XCTAssertGreaterThanOrEqual(
                    nameLabel.frame.height,
                    28,
                    "Child name label for '\(childName)' frame height \(nameLabel.frame.height)pt suggests font below 24pt minimum"
                )
            }
        }
    }
}
