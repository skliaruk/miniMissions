// DailyResetUITests.swift
// XCUITest suite for automatic daily reset feature.
//
// REQ coverage: Automatic daily reset -- when the app becomes active and the date has changed
// since the last reset, all task completions are deleted automatically.
//
// TDD Red Phase: Tests below compile but WILL FAIL if the daily reset feature is not yet
// implemented or if launch argument support for --resetDateYesterday is missing.

import XCTest

final class DailyResetUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - Helpers

    private func openParentManagement() {
        let gearButton = app.row(AX.ChildRoutine.parentSettingsButton)
        XCTAssertTrue(gearButton.waitForExistence(timeout: 5), "Gear button must exist")
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
        childRow.assertExists(timeout: 3)
        childRow.tap()

        let topicRow = app.row(AX.TopicManagement.childTopicRow(child: child, topic: topic))
        topicRow.assertExists(timeout: 3)
        topicRow.tap()
    }

    private func assignTemplate(named templateName: String) {
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

    /// Sets up a child with a task using persistent storage (no --uitesting).
    /// Uses the PIN-enabled persistence launcher.
    private func setupChildWithTaskPersistent() {
        openParentManagement()
        addChild(name: "Mia")
        addTemplate(name: "DailyTask")
        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate(named: "DailyTask")
        navigateBackToParentHome()
        dismissParentManagement()
    }

    // MARK: - Test 1: Daily reset clears completions on new day

    /// REQ: Automatic daily reset -- covers: "When the app becomes active and the date has changed
    /// since the last reset, all task completions are deleted automatically."
    func testDailyResetClearsCompletionsOnNewDay() throws {
        // Step 1: Launch with persistent storage and set up a child with task
        app = AppLauncher.launchWithPersistenceAndPIN()
        setupChildWithTaskPersistent()

        // Step 2: Find and complete a task
        let taskButton = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        ).firstMatch

        guard taskButton.waitForExistence(timeout: 5) else {
            XCTFail("No task buttons found after setup.")
            return
        }

        XCTAssertEqual(
            taskButton.value as? String,
            "not done",
            "Task must start as 'not done' before completion"
        )

        taskButton.tap()

        let donePredicate = NSPredicate(format: "value == 'done'")
        let doneExpectation = expectation(for: donePredicate, evaluatedWith: taskButton)
        wait(for: [doneExpectation], timeout: 2.0)

        // Step 3: Terminate the app
        app.terminate()

        // Step 4: Relaunch with --resetDateYesterday to simulate date change
        // Must use persistence + resetDateYesterday but no --uitesting
        let resetApp = XCUIApplication()
        resetApp.launchArguments = ["--skip-pin-setup", "--resetDateYesterday"]
        resetApp.launch()
        app = resetApp

        // Step 5: Find the same task button and verify it is back to "not done"
        let taskButtonAfterReset = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        ).firstMatch

        XCTAssertTrue(
            taskButtonAfterReset.waitForExistence(timeout: 5),
            "Task button must exist after relaunch with daily reset"
        )

        XCTAssertEqual(
            taskButtonAfterReset.value as? String,
            "not done",
            "After daily reset (date changed), task completion must be cleared -- accessibilityValue must be 'not done'"
        )
    }

    // MARK: - Test 2: Daily reset does NOT clear on same day

    /// REQ: Automatic daily reset -- covers: "Reset only triggers when the date has changed."
    func testDailyResetDoesNotClearOnSameDay() throws {
        // Launch with persistent storage and set up a child with task
        app = AppLauncher.launchWithPersistenceAndPIN()
        setupChildWithTaskPersistent()

        // Find and complete a task
        let taskButton = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        ).firstMatch

        guard taskButton.waitForExistence(timeout: 5) else {
            XCTFail("No task buttons found after setup.")
            return
        }

        taskButton.tap()

        let donePredicate = NSPredicate(format: "value == 'done'")
        let doneExpectation = expectation(for: donePredicate, evaluatedWith: taskButton)
        wait(for: [doneExpectation], timeout: 2.0)

        // Simulate backgrounding and foregrounding on the same day.
        XCUIDevice.shared.press(.home)
        Thread.sleep(forTimeInterval: 1.0)
        app.activate()

        let taskButtonAfterForeground = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        ).firstMatch

        XCTAssertTrue(
            taskButtonAfterForeground.waitForExistence(timeout: 5),
            "Task button must exist after returning to foreground"
        )

        let stillDonePredicate = NSPredicate(format: "value == 'done'")
        let stillDoneExpectation = expectation(for: stillDonePredicate, evaluatedWith: taskButtonAfterForeground)
        wait(for: [stillDoneExpectation], timeout: 2.0)
    }

    // MARK: - Test 3: Daily reset runs on first launch (no stored date)

    /// REQ: Automatic daily reset -- covers: "On first launch (no stored date), reset runs immediately."
    func testDailyResetRunsOnFirstLaunch() throws {
        // Launch with a fresh in-memory store
        app = AppLauncher.launchWithPIN()

        // Set up a child with a task so we have something to verify
        openParentManagement()
        addChild(name: "Mia")
        addTemplate(name: "FirstLaunchTask")
        navigateToTaskEditor(child: "Mia", topic: "Aamu")
        assignTemplate(named: "FirstLaunchTask")
        navigateBackToParentHome()
        dismissParentManagement()

        // Verify routine view appears
        let routineRoot = app.row(AX.ChildRoutine.root)
        XCTAssertTrue(
            routineRoot.waitForExistence(timeout: 5),
            "Routine view must appear on first launch"
        )

        // Verify all visible task buttons are in "not done" state (clean slate)
        let allTaskButtons = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        )

        for index in 0..<allTaskButtons.count {
            let button = allTaskButtons.element(boundBy: index)
            if button.exists {
                XCTAssertEqual(
                    button.value as? String,
                    "not done",
                    "On first launch (no stored reset date), all tasks must be in 'not done' state -- " +
                    "daily reset must have cleared any stale completions. " +
                    "Task at index \(index) (id: '\(button.identifier)') has unexpected value."
                )
            }
        }
    }
}
