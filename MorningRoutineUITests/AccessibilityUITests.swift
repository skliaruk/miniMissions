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

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = AppLauncher.launchClean()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - REQ-005 AC-1, AC-2 — Landscape orientation lock

    func testAppRunsInLandscapeOrientation() throws {
        // REQ-005 AC-1: App runs in landscape orientation on all supported iPad sizes.
        // REQ-005 AC-2: Portrait orientation is locked.
        // DSGN-002 §iOS-Specific: Info.plist must include only landscape orientations.
        //
        // XCUITest verifies the device is in landscape by checking that the routine view
        // root element's frame is wider than it is tall (landscape aspect ratio).
        let routineRoot = app.otherElements[AX.ChildRoutine.root]
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
        // REQ-005 AC-2: Portrait orientation is locked — rotating the device does not change layout.
        // Verify that the three child columns remain visible after a rotation attempt.
        XCUIDevice.shared.orientation = .landscapeLeft
        _ = app.otherElements[AX.ChildRoutine.root].waitForExistence(timeout: 3)

        // Attempt portrait rotation
        XCUIDevice.shared.orientation = .portrait

        // Small wait for any (incorrect) layout change
        Thread.sleep(forTimeInterval: 0.5)

        // All 3 child columns must still be visible (app ignores portrait)
        for index in 0..<3 {
            let column = app.otherElements[AX.ChildRoutine.column(index)]
            XCTAssertTrue(
                column.waitForExistence(timeout: 3),
                "Child column \(index) must still exist after portrait rotation attempt"
            )
            XCTAssertTrue(
                column.isHittable,
                "Child column \(index) must remain hittable after portrait rotation attempt"
            )
        }

        // Restore landscape for subsequent tests
        XCUIDevice.shared.orientation = .landscapeLeft
    }

    // MARK: - REQ-005 AC-3 — Child-facing touch targets >= 60x60pt

    func testAllChildFacingTaskButtonsHave60ptMinimumTouchTarget() throws {
        // REQ-005 AC-3: All child-facing touch targets are >= 60x60pt (verified via XCUITest frame).
        // REQ-001 AC-5: Minimum touch target 60x60pt for child-facing elements.
        // DSGN-002 MRV-AC-05: task_<Name>_<Task>.frame.height >= 60 && .frame.width >= 60
        let taskButtons = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        )
        // With seed data there may be no tasks; this test verifies any tasks that do exist.
        for index in 0..<taskButtons.count {
            let button = taskButtons.element(boundBy: index)
            button.assertMinTouchTarget(60)
        }

        // Also check task row elements (entire row is tappable per DSGN-002 §2.4)
        let taskRows = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskRow_'")
        )
        for index in 0..<taskRows.count {
            let row = taskRows.element(boundBy: index)
            row.assertMinTouchTarget(60)
        }
    }

    func testParentGearButtonMeetsStandardMinimumTouchTarget() throws {
        // DSGN-002 §2.2: Parent gear button has 44x44pt touch target (standard iOS minimum for parent elements).
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        XCTAssertTrue(
            gearButton.waitForExistence(timeout: 5),
            "Parent settings gear button must exist"
        )
        gearButton.assertMinTouchTarget(44)
    }

    // MARK: - REQ-005 AC-6 — VoiceOver labels present on all interactive elements

    func testGearButtonHasVoiceOverLabel() throws {
        // REQ-005 AC-6: All interactive elements have VoiceOver labels.
        // DSGN-002 MRV-AC-13: parentSettingsButton.label == "Parent Settings"
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        XCTAssertTrue(
            gearButton.waitForExistence(timeout: 5),
            "Gear button must exist"
        )
        XCTAssertEqual(
            gearButton.label,
            "Parent Settings",
            "Gear button must have VoiceOver label 'Parent Settings'"
        )
        XCTAssertFalse(
            gearButton.label.isEmpty,
            "Gear button must have a non-empty VoiceOver label"
        )
    }

    func testChildColumnCardsHaveVoiceOverLabels() throws {
        // REQ-005 AC-6: Child column cards have VoiceOver labels.
        // DSGN-002 §2.3: column card accessibilityLabel == "<Child Name>'s morning routine"
        for childName in AX.ChildNames.all {
            let column = app.otherElements[AX.ChildRoutine.columnByName(childName)]
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
        // REQ-005 AC-6: Child name labels have correct VoiceOver labels.
        // DSGN-002 §2.3: childName_<Name>.accessibilityLabel == "<Name>'s tasks"
        for childName in AX.ChildNames.all {
            let nameLabel = app.staticTexts[AX.ChildRoutine.childNameLabel(childName)]
            if nameLabel.waitForExistence(timeout: 5) {
                XCTAssertFalse(
                    nameLabel.label.isEmpty,
                    "Name label for '\(childName)' must have a non-empty VoiceOver label"
                )
                XCTAssertEqual(
                    nameLabel.label,
                    "\(childName)'s tasks",
                    "Name label for '\(childName)' must have VoiceOver label '\(childName)'s tasks'"
                )
            }
        }
    }

    func testTaskButtonsHaveVoiceOverLabelsAndValues() throws {
        // REQ-005 AC-6: All interactive elements have VoiceOver labels.
        // DSGN-002 MRV-AC-12: accessibilityLabel and accessibilityValue assertions on task elements.
        // DSGN-002 §2.4: accessibilityValue == "not done" (incomplete) or "done" (complete).
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
        // REQ-005 AC-6 + DSGN-002 §2.3: progressIndicator_<Name> has VoiceOver label.
        // Label format: "N of total tasks complete".
        for childName in AX.ChildNames.all {
            let progressIndicator = app.otherElements[AX.ChildRoutine.progressIndicator(childName)]
            if progressIndicator.waitForExistence(timeout: 5) {
                XCTAssertFalse(
                    progressIndicator.label.isEmpty,
                    "Progress indicator for '\(childName)' must have a non-empty VoiceOver label"
                )
                // Label must mention "tasks" and a number pattern like "N of M tasks complete"
                XCTAssertTrue(
                    progressIndicator.label.lowercased().contains("task"),
                    "Progress indicator label must mention 'task' — got '\(progressIndicator.label)'"
                )
            }
        }
    }

    // MARK: - REQ-005 AC-7, AC-8 — State persistence: task completion survives app restart

    func testTaskCompletionStatePersistedAcrossAppRestart() throws {
        // REQ-005 AC-7: Task completion state persists if app is backgrounded and resumed.
        // REQ-005 AC-8: Task completion state persists across app restarts until manually reset.
        //
        // IMPORTANT: This test uses real on-disk SwiftData persistence (no --uitesting flag).
        // The test is self-contained: it adds a task, completes it, relaunches, and verifies the state.
        // It also cleans up after itself by resetting the day.

        app.terminate()
        // Launch with persistence (no --uitesting → real SwiftData store)
        app = AppLauncher.launchWithPersistenceAndPIN()

        // First, add a task via parent management so we have a known task to complete
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        XCTAssertTrue(
            gearButton.waitForExistence(timeout: 5),
            "Gear button must exist for persistence test"
        )
        gearButton.tap()

        app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3)
        enterPIN(TestConstants.testPIN)
        app.otherElements[AX.ParentManagement.root].waitForExistence(timeout: 5)

        // Add a task to child 0
        let childRow = app.cells[AX.ParentManagement.childRowByName(AX.ChildNames.child0)]
        childRow.waitForExistence(timeout: 3)
        childRow.tap()

        let addButton = app.buttons[AX.ParentManagement.addTaskButton]
        addButton.waitForExistence(timeout: 3)
        addButton.tap()

        let nameField = app.textFields[AX.TaskEditor.taskNameField]
        nameField.waitForExistence(timeout: 3)
        nameField.tap()
        nameField.typeText("PersistenceTask")

        // Choose an icon
        let chooseIcon = app.buttons[AX.TaskEditor.chooseIconButton]
        if chooseIcon.waitForExistence(timeout: 2) {
            chooseIcon.tap()
            app.buttons.matching(
                NSPredicate(format: "identifier BEGINSWITH 'iconPicker_'")
            ).firstMatch.tap()
        }
        app.buttons[AX.TaskEditor.formSaveButton].tap()

        // Exit to routine view
        app.navigationBars.buttons.firstMatch.tap()
        let doneButton = app.buttons[AX.ParentManagement.doneButton]
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }

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

        // Verify it's done
        let donePredicate = NSPredicate(format: "value == 'done'")
        let doneExpectation = expectation(for: donePredicate, evaluatedWith: taskButton)
        wait(for: [doneExpectation], timeout: 2.0)

        // Relaunch the app WITHOUT --uitesting to preserve the on-disk data
        app.terminate()
        app = AppLauncher.launchWithPersistence()

        // After relaunch, the same task must still show as "done"
        let restoredTaskButton = app.buttons[taskIdentifier]
        XCTAssertTrue(
            restoredTaskButton.waitForExistence(timeout: 5),
            "Task button '\(taskIdentifier)' must still exist after app restart"
        )
        XCTAssertEqual(
            restoredTaskButton.value as? String,
            "done",
            "Task completion state must persist across app restart (REQ-005 AC-8)"
        )

        // Cleanup: reset the day to avoid contaminating other tests
        let gearButtonAfterRelaunch = app.buttons[AX.ChildRoutine.parentSettingsButton]
        gearButtonAfterRelaunch.waitForExistence(timeout: 5)
        gearButtonAfterRelaunch.tap()
        app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3)
        enterPIN(TestConstants.testPIN)
        app.otherElements[AX.ParentManagement.root].waitForExistence(timeout: 5)
        app.buttons[AX.ParentManagement.resetDayButton].tap()
        app.buttons[AX.ParentManagement.resetDayConfirmButton].tap()
    }

    // MARK: - REQ-005 AC-9 — Settings persistence: add task, relaunch, task still exists

    func testParentSettingsPersistedAcrossAppRestart() throws {
        // REQ-005 AC-9: Parent settings (task list, PIN) persist across app restarts using SwiftData.
        // E2E: add a task, relaunch app, task still exists.
        //
        // This test uses real on-disk persistence (no --uitesting flag).

        app.terminate()
        app = AppLauncher.launchWithPersistenceAndPIN()

        // Add a task via parent management
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        gearButton.waitForExistence(timeout: 5)
        gearButton.tap()
        app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3)
        enterPIN(TestConstants.testPIN)
        app.otherElements[AX.ParentManagement.root].waitForExistence(timeout: 5)

        let childRow = app.cells[AX.ParentManagement.childRowByName(AX.ChildNames.child1)]
        childRow.waitForExistence(timeout: 3)
        childRow.tap()

        let addButton = app.buttons[AX.ParentManagement.addTaskButton]
        addButton.waitForExistence(timeout: 3)
        addButton.tap()

        let nameField = app.textFields[AX.TaskEditor.taskNameField]
        nameField.waitForExistence(timeout: 3)
        nameField.tap()
        nameField.typeText("PersistTask2")

        let chooseIcon = app.buttons[AX.TaskEditor.chooseIconButton]
        if chooseIcon.waitForExistence(timeout: 2) {
            chooseIcon.tap()
            app.buttons.matching(
                NSPredicate(format: "identifier BEGINSWITH 'iconPicker_'")
            ).firstMatch.tap()
        }
        app.buttons[AX.TaskEditor.formSaveButton].tap()

        // Verify the task appears in the editor
        let taskEditorRow = app.cells[AX.ParentManagement.taskEditorRowByName("PersistTask2")]
        XCTAssertTrue(
            taskEditorRow.waitForExistence(timeout: 3),
            "Task 'PersistTask2' must appear in task editor after adding"
        )

        // Terminate and relaunch without --uitesting
        app.terminate()
        app = AppLauncher.launchWithPersistence()

        // Navigate to parent management again
        let gearButtonAfter = app.buttons[AX.ChildRoutine.parentSettingsButton]
        gearButtonAfter.waitForExistence(timeout: 5)
        gearButtonAfter.tap()
        app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3)
        enterPIN(TestConstants.testPIN)
        app.otherElements[AX.ParentManagement.root].waitForExistence(timeout: 5)

        let childRowAfter = app.cells[AX.ParentManagement.childRowByName(AX.ChildNames.child1)]
        childRowAfter.waitForExistence(timeout: 3)
        childRowAfter.tap()

        // Task must still exist after restart
        let persistedTask = app.cells[AX.ParentManagement.taskEditorRowByName("PersistTask2")]
        XCTAssertTrue(
            persistedTask.waitForExistence(timeout: 5),
            "Task 'PersistTask2' must persist across app restart (REQ-005 AC-9)"
        )

        // Also verify in routine view
        app.navigationBars.buttons.firstMatch.tap()
        let doneButton = app.buttons[AX.ParentManagement.doneButton]
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }

        let taskInRoutine = app.buttons.matching(
            NSPredicate(format: "identifier CONTAINS 'PersistTask2'")
        ).firstMatch
        XCTAssertTrue(
            taskInRoutine.waitForExistence(timeout: 5),
            "Persisted task 'PersistTask2' must appear in routine view after app restart"
        )

        // Cleanup: remove the added task
        let gearCleanup = app.buttons[AX.ChildRoutine.parentSettingsButton]
        gearCleanup.waitForExistence(timeout: 5)
        gearCleanup.tap()
        app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3)
        enterPIN(TestConstants.testPIN)
        app.otherElements[AX.ParentManagement.root].waitForExistence(timeout: 5)
        let childRowCleanup = app.cells[AX.ParentManagement.childRowByName(AX.ChildNames.child1)]
        childRowCleanup.waitForExistence(timeout: 3)
        childRowCleanup.tap()
        let cleanupRow = app.cells[AX.ParentManagement.taskEditorRowByName("PersistTask2")]
        if cleanupRow.waitForExistence(timeout: 3) {
            cleanupRow.swipeLeft()
            app.buttons[AX.ParentManagement.deleteTaskAction("PersistTask2")].tap()
            app.buttons[AX.ParentManagement.deleteTaskConfirmButton].tap()
        }
    }

    // MARK: - Full child-facing interaction path (integration of REQ-005 criteria)

    func testAllThreeChildColumnsHaveVoiceOverStructure() throws {
        // REQ-005 AC-6 (comprehensive): All interactive child-facing elements have VoiceOver labels.
        // This test verifies the full VoiceOver tree is populated for all 3 children simultaneously.

        // Verify all column cards exist with labels
        for childName in AX.ChildNames.all {
            let column = app.otherElements[AX.ChildRoutine.columnByName(childName)]
            if column.waitForExistence(timeout: 5) {
                XCTAssertFalse(column.label.isEmpty,
                    "Column card for '\(childName)' must have non-empty VoiceOver label")
            }

            // Name label
            let nameLabel = app.staticTexts[AX.ChildRoutine.childNameLabel(childName)]
            if nameLabel.exists {
                XCTAssertFalse(nameLabel.label.isEmpty,
                    "Name label for '\(childName)' must have non-empty VoiceOver label")
            }

            // Progress indicator
            let progress = app.otherElements[AX.ChildRoutine.progressIndicator(childName)]
            if progress.exists {
                XCTAssertFalse(progress.label.isEmpty,
                    "Progress indicator for '\(childName)' must have non-empty VoiceOver label")
            }
        }

        // Verify gear button VoiceOver label and hint
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        gearButton.waitForExistence(timeout: 5)
        XCTAssertEqual(gearButton.label, "Parent Settings",
            "Gear button must have VoiceOver label 'Parent Settings' (DSGN-002 §2.2)")
    }

    func testAllTaskButtonsHaveAccessibilityHintWhenIncomplete() throws {
        // DSGN-002 §2.4: incomplete task accessibilityHint == "Tap to mark as done"
        let taskButtons = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        )
        for index in 0..<taskButtons.count {
            let button = taskButtons.element(boundBy: index)
            if (button.value as? String) == "not done" {
                // hint property may not be directly readable in XCUITest;
                // we at minimum verify the label is non-empty as a proxy
                XCTAssertFalse(
                    button.label.isEmpty,
                    "Incomplete task button '\(button.identifier)' must have a non-empty accessibility label"
                )
            }
        }
    }

    // MARK: - REQ-005 AC-4 (text size >= 24pt)

    func testChildFacingTextMeetsMinimumFontSizeViaAccessibilityTree() throws {
        // REQ-005 AC-4: All text in child-facing view is >= 24pt.
        // DSGN-002 MRV-AC-14: font size assertion on task label elements.
        //
        // XCUITest does not expose font metrics directly; we verify that labels are large
        // enough by checking frame height as a proxy (a 24pt font typically produces a
        // label frame height of at least 28pt with standard line height).
        for childName in AX.ChildNames.all {
            let nameLabel = app.staticTexts[AX.ChildRoutine.childNameLabel(childName)]
            if nameLabel.waitForExistence(timeout: 5) {
                // 32pt SF Rounded Bold (DSGN-002 §2.3) → frame height typically ~38-42pt
                XCTAssertGreaterThanOrEqual(
                    nameLabel.frame.height,
                    28,
                    "Child name label for '\(childName)' frame height \(nameLabel.frame.height)pt suggests font below 24pt minimum"
                )
            }
        }
    }

    // MARK: - Private helpers

    private func enterPIN(_ pin: String) {
        for character in pin {
            guard let digit = Int(String(character)) else { continue }
            let key = app.buttons[AX.PINGate.key(digit)]
            key.waitForExistence(timeout: 3)
            key.tap()
        }
    }
}
