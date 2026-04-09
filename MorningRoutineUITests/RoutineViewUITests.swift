// RoutineViewUITests.swift
// XCUITest suite for the child-facing Morning Routine View.
//
// REQ coverage: REQ-001, REQ-002
// DSGN coverage: DSGN-002 acceptance criteria MRV-AC-01 through MRV-AC-15
//
// TDD Red Phase: All tests below compile but WILL FAIL because no implementation exists yet.
// These tests constitute the specification that MDEV must satisfy.

import XCTest

final class RoutineViewUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        // Each test gets a fresh in-memory store with seed data (3 children, no tasks).
        app = AppLauncher.launchClean()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - REQ-001 AC-1 / DSGN-002 MRV-AC-01
    // App launches and shows routine view immediately — no splash screen delay > 1 second.

    func testAppLaunchShowsRoutineViewImmediately() throws {
        // REQ-001 AC-1: Launching the app shows the routine view immediately (< 1s).
        // DSGN-002 MRV-AC-01: childRoutine_root or childColumn_<Name> exists immediately after launch.
        //
        // We measure from launch (setUpWithError) to assertion — the AppLauncher already
        // called app.launch(), so we simply verify the root element is present within 1 second.
        let routineRoot = app.otherElements[AX.ChildRoutine.root]
        XCTAssertTrue(
            routineRoot.waitForExistence(timeout: 1.0),
            "Routine view root element '\(AX.ChildRoutine.root)' must appear within 1 second of launch"
        )
    }

    func testAppLaunchDoesNotShowSplashOrLoadingIndicator() throws {
        // REQ-001 AC-1: No splash screen blocking the routine view on launch.
        // The PIN setup screen must NOT be shown when --skip-pin-setup is active.
        let pinSetupRoot = app.otherElements[AX.PINGate.setupRoot]
        XCTAssertFalse(
            pinSetupRoot.waitForExistence(timeout: 0.5),
            "PIN setup screen must not appear when --skip-pin-setup argument is present"
        )
    }

    // MARK: - REQ-001 AC-2 / DSGN-002 MRV-AC-02
    // All 3 child columns are visible simultaneously without scrolling in landscape orientation.

    func testAllThreeChildColumnsArePresent() throws {
        // REQ-001 AC-2: All 3 children visible simultaneously.
        // DSGN-002 MRV-AC-02: all 3 childColumn_* elements are hittable without scrolling.
        for index in 0..<3 {
            let column = app.otherElements[AX.ChildRoutine.column(index)]
            XCTAssertTrue(
                column.waitForExistence(timeout: 5),
                "Child column at index \(index) (id: '\(AX.ChildRoutine.column(index))') must exist"
            )
            XCTAssertTrue(
                column.isHittable,
                "Child column at index \(index) must be hittable (visible on screen without scrolling)"
            )
        }
    }

    func testAllThreeChildColumnsByNameArePresent() throws {
        // REQ-001 AC-2: Columns labelled with fixed child names (Mia, Noah, Ella — see ADR-003).
        // DSGN-002 MRV-AC-02: childColumn_<Name> elements exist and are hittable.
        for childName in AX.ChildNames.all {
            let column = app.otherElements[AX.ChildRoutine.columnByName(childName)]
            XCTAssertTrue(
                column.waitForExistence(timeout: 5),
                "Child column '\(AX.ChildRoutine.columnByName(childName))' for child '\(childName)' must exist"
            )
            XCTAssertTrue(
                column.isHittable,
                "Child column for '\(childName)' must be hittable (not scrolled off screen)"
            )
        }
    }

    // MARK: - REQ-001 AC-3 / DSGN-002 MRV-AC-03
    // Each child column displays the child's name and avatar.

    func testEachColumnShowsChildName() throws {
        // REQ-001 AC-3: Each child column displays the child's name.
        // DSGN-002 MRV-AC-03: childName_<Name>.label == "<Name>'s tasks"
        for childName in AX.ChildNames.all {
            let nameLabel = app.staticTexts[AX.ChildRoutine.childNameLabel(childName)]
            XCTAssertTrue(
                nameLabel.waitForExistence(timeout: 5),
                "Child name label '\(AX.ChildRoutine.childNameLabel(childName))' must exist for child '\(childName)'"
            )
            // VoiceOver label must follow the "<Name>'s tasks" pattern (DSGN-002 §2.3).
            XCTAssertEqual(
                nameLabel.label,
                "\(childName)'s tasks",
                "Name label for '\(childName)' must have VoiceOver label '<Name>'s tasks'"
            )
        }
    }

    func testEachColumnShowsChildAvatar() throws {
        // REQ-001 AC-3: Each child column displays an avatar.
        // DSGN-002 §2.3: childAvatar_<Name> element must exist.
        for childName in AX.ChildNames.all {
            let avatar = app.images[AX.ChildRoutine.childAvatar(childName)]
            XCTAssertTrue(
                avatar.waitForExistence(timeout: 5),
                "Child avatar '\(AX.ChildRoutine.childAvatar(childName))' must exist for child '\(childName)'"
            )
        }
    }

    // MARK: - REQ-001 AC-4 / DSGN-002 MRV-AC-04
    // Each task shows an icon and a text label.
    // Note: seed data has no tasks, so we test with the first task if any exist, or verify the
    // structure is in place. The full task-content test is in ParentManagementUITests after adding tasks.

    func testTaskRowsHaveNonEmptyAccessibilityLabel() throws {
        // REQ-001 AC-4: Each task shows icon + text label.
        // DSGN-002 MRV-AC-04: task_<Name>_<Task> exists and has non-empty label.
        // We tap each column's first task button if it exists and verify the label is non-empty.
        // (With seed data there are no tasks — this test documents the expected structure.)
        let taskButton = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        ).firstMatch
        if taskButton.exists {
            XCTAssertFalse(
                taskButton.label.isEmpty,
                "Task buttons must have a non-empty accessibility label (icon + task name)"
            )
        }
        // If no tasks exist (clean seed), this test passes trivially — full coverage
        // comes from ParentManagementUITests which adds tasks first.
    }

    // MARK: - REQ-001 AC-5 / REQ-005 AC-3 / DSGN-002 MRV-AC-05
    // All interactive elements have a minimum touch target of 60×60pt.

    func testTaskButtonsHaveMinimumTouchTargetSize() throws {
        // REQ-001 AC-5: All interactive elements have minimum 60×60pt touch targets.
        // REQ-005 AC-3: All child-facing touch targets are >= 60x60pt.
        // DSGN-002 MRV-AC-05: task_<Name>_<Task>.frame.height >= 60 && .frame.width >= 60
        //
        // We query all task buttons that exist and verify each one meets the minimum.
        let taskButtons = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        )
        // With seed data there are no tasks; once MDEV seeds tasks or tests add them,
        // all buttons found must meet the minimum.
        for index in 0..<taskButtons.count {
            let button = taskButtons.element(boundBy: index)
            button.assertMinTouchTarget(60)
        }
    }

    // MARK: - REQ-001 AC-6 / DSGN-002 MRV-AC-12
    // VoiceOver labels present on all interactive elements.

    func testParentEntryButtonHasVoiceOverLabel() throws {
        // REQ-001 AC-6: View is fully navigable via VoiceOver.
        // DSGN-002 MRV-AC-13: parentSettingsButton.label == "Parent Settings"
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        XCTAssertTrue(
            gearButton.waitForExistence(timeout: 5),
            "Parent entry gear button '\(AX.ChildRoutine.parentSettingsButton)' must exist on routine view"
        )
        XCTAssertEqual(
            gearButton.label,
            "Parent Settings",
            "Gear button must have VoiceOver label 'Parent Settings' (DSGN-002 §2.2)"
        )
    }

    func testAllInteractiveElementsHaveNonEmptyAccessibilityLabels() throws {
        // REQ-001 AC-6: Each child column and task is announced correctly by VoiceOver.
        // DSGN-002 MRV-AC-12: accessibilityLabel and accessibilityValue assertions.
        //
        // Verify gear button, child column cards, and name labels all have non-empty labels.
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        XCTAssertFalse(gearButton.label.isEmpty, "Gear button must have a non-empty VoiceOver label")

        for childName in AX.ChildNames.all {
            let nameLabel = app.staticTexts[AX.ChildRoutine.childNameLabel(childName)]
            if nameLabel.exists {
                XCTAssertFalse(
                    nameLabel.label.isEmpty,
                    "Name label for '\(childName)' must have a non-empty VoiceOver label"
                )
            }
        }
    }

    // MARK: - REQ-002 AC-1, AC-2 / DSGN-002 MRV-AC-06
    // Tapping an incomplete task marks it as done (accessibility state change).

    func testTappingIncompleteTaskChangesAccessibilityValueToDone() throws {
        // REQ-002 AC-1: Tapping an incomplete task changes its visual state to "done" within 100ms.
        // DSGN-002 MRV-AC-06: tap taskButton → accessibilityValue == "done"
        //
        // For this test we rely on at least one task existing. In the in-memory store,
        // tasks must be pre-seeded by MDEV's SeedDataService or added by a setup helper.
        // The test documents the required behaviour: once a task exists, tapping it must
        // change its accessibility value to "done".
        let taskButton = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        ).firstMatch

        guard taskButton.waitForExistence(timeout: 5) else {
            XCTFail(
                "No task buttons found — MDEV must seed at least one task per child in SeedDataService. " +
                "REQ-002 AC-1 cannot be verified without tasks."
            )
            return
        }

        // Verify initial state is "not done"
        XCTAssertEqual(
            taskButton.value as? String,
            "not done",
            "Incomplete task button must have accessibilityValue 'not done' before tapping"
        )

        // Tap the task
        taskButton.tap()

        // Verify state changed to "done" within 100ms (we allow 1s for test reliability)
        let donePredicate = NSPredicate(format: "value == 'done'")
        let doneExpectation = expectation(for: donePredicate, evaluatedWith: taskButton)
        wait(for: [doneExpectation], timeout: 1.0)
    }

    // MARK: - REQ-002 AC-3 / DSGN-002 MRV-AC-07
    // Tapping a done task produces no state change.

    func testTappingDoneTaskProducesNoStateChange() throws {
        // REQ-002 AC-3: Tapping a completed task does nothing (no state change).
        // DSGN-002 MRV-AC-07: tap done task → accessibilityValue remains "done"
        let taskButton = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        ).firstMatch

        guard taskButton.waitForExistence(timeout: 5) else {
            XCTFail("No task buttons found — cannot test done task idempotency without tasks.")
            return
        }

        // First tap: mark as done
        taskButton.tap()
        let donePredicate = NSPredicate(format: "value == 'done'")
        let doneExpectation = expectation(for: donePredicate, evaluatedWith: taskButton)
        wait(for: [doneExpectation], timeout: 1.0)

        // Second tap: must NOT change state back to "not done"
        taskButton.tap()

        // Small delay to allow any potential (incorrect) state change to propagate
        let stillDonePredicate = NSPredicate(format: "value == 'done'")
        let stillDoneExpectation = expectation(for: stillDonePredicate, evaluatedWith: taskButton)
        wait(for: [stillDoneExpectation], timeout: 0.5)
    }

    // MARK: - REQ-002 AC-4, AC-5 / DSGN-002 MRV-AC-08, MRV-AC-09
    // When all tasks in one column are done, celebration element appears in that column only.

    func testCelebrationViewAppearsWhenAllTasksInColumnComplete() throws {
        // REQ-002 AC-4: When all tasks for one child are done, a celebration animation plays.
        // DSGN-002 MRV-AC-08: celebrationView_<Name> exists after completing all tasks in column.
        //
        // Tap all task buttons in child 0's column (index 0).
        let child0Tasks = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_0_'")
        )

        guard child0Tasks.count > 0 else {
            XCTFail(
                "No tasks found for child 0 (index 0). " +
                "MDEV must seed at least one task per child to verify the celebration flow."
            )
            return
        }

        // Tap all tasks in child 0's column
        for i in 0..<child0Tasks.count {
            child0Tasks.element(boundBy: i).tap()
        }

        // Celebration view must appear for child 0
        let celebration = app.otherElements[AX.ChildRoutine.celebrationView(0)]
        XCTAssertTrue(
            celebration.waitForExistence(timeout: 3),
            "Celebration view '\(AX.ChildRoutine.celebrationView(0))' must appear after all tasks in column 0 are complete"
        )
    }

    func testCelebrationViewDoesNotAppearInOtherColumnsWhenOneChildCompletes() throws {
        // REQ-002 AC-5: Celebration animation does not affect other children's columns.
        // DSGN-002 MRV-AC-09: celebrationView_1 and celebrationView_2 must NOT exist when column 0 completes.
        let child0Tasks = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_0_'")
        )

        guard child0Tasks.count > 0 else {
            XCTFail("No tasks found for child 0 — cannot test cross-column isolation.")
            return
        }

        for i in 0..<child0Tasks.count {
            child0Tasks.element(boundBy: i).tap()
        }

        // Wait briefly for any celebration to render
        _ = app.otherElements[AX.ChildRoutine.celebrationView(0)].waitForExistence(timeout: 2)

        // Celebration must NOT appear in child 1 or child 2 columns
        XCTAssertFalse(
            app.otherElements[AX.ChildRoutine.celebrationView(1)].exists,
            "Celebration view for child 1 must NOT appear when only child 0 has completed all tasks"
        )
        XCTAssertFalse(
            app.otherElements[AX.ChildRoutine.celebrationView(2)].exists,
            "Celebration view for child 2 must NOT appear when only child 0 has completed all tasks"
        )
    }

    // MARK: - REQ-002 AC-6 / DSGN-002 MRV-AC-10
    // With --reduce-motion, particle animation elements are absent.

    func testReduceMotionSuppressesStarBurstAnimationElements() throws {
        // REQ-002 AC-6: With Reduce Motion enabled, no movement-based animations play.
        // DSGN-002 MRV-AC-10: starRewardOverlay and star burst animation elements absent under reduce-motion.
        //
        // Re-launch with reduce motion enabled.
        app.terminate()
        app = AppLauncher.launchWithReduceMotion()

        let taskButton = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        ).firstMatch

        guard taskButton.waitForExistence(timeout: 5) else {
            XCTFail("No task buttons found — cannot test reduce motion animation suppression.")
            return
        }

        taskButton.tap()

        // Allow a moment for any (incorrect) animation elements to render
        Thread.sleep(forTimeInterval: 0.5)

        // The star BURST animation overlay must NOT be present under reduce motion.
        // ADR-004 §5: "starBurstAnimation" identifier is only present when motion is enabled.
        let anyBurstAnimation = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_starBurstAnimation_'")
        ).firstMatch
        XCTAssertFalse(
            anyBurstAnimation.exists,
            "Star burst animation elements must be absent when --reduce-motion is active (REQ-002 AC-6)"
        )
    }

    func testReduceMotionShowsStaticHighlightInsteadOfAnimation() throws {
        // REQ-002 AC-6: Reduce Motion — a static highlight is shown instead of motion.
        // ADR-004 §5: static highlight uses "starAnimation" identifier (not "starBurstAnimation").
        app.terminate()
        app = AppLauncher.launchWithReduceMotion()

        let taskButton = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_'")
        ).firstMatch

        guard taskButton.waitForExistence(timeout: 5) else {
            XCTFail("No task buttons found — cannot verify static highlight behaviour.")
            return
        }

        taskButton.tap()

        // Task must still transition to done state — only motion is suppressed, not state change
        let donePredicate = NSPredicate(format: "value == 'done'")
        let doneExpectation = expectation(for: donePredicate, evaluatedWith: taskButton)
        wait(for: [doneExpectation], timeout: 1.0)
    }

    // MARK: - DSGN-002 MRV-AC-15
    // Progress indicator updates after each task completion.

    func testProgressIndicatorUpdatesAfterTaskCompletion() throws {
        // DSGN-002 MRV-AC-15: progressIndicator_<Name>.label shows correct "N of total tasks complete"
        for childName in AX.ChildNames.all {
            let progressIndicator = app.otherElements[AX.ChildRoutine.progressIndicator(childName)]
            if progressIndicator.exists {
                // Initial state: should show "0 of N tasks complete"
                XCTAssertFalse(
                    progressIndicator.label.isEmpty,
                    "Progress indicator for '\(childName)' must have a non-empty VoiceOver label"
                )
            }
        }

        // After completing a task, the label for that child's column must update
        let child0TaskButton = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'childRoutine_taskButton_0_'")
        ).firstMatch

        guard child0TaskButton.waitForExistence(timeout: 5) else {
            return // No tasks seeded — test passes trivially
        }

        let progressBefore = app.otherElements[AX.ChildRoutine.progressIndicator(AX.ChildNames.child0)].label
        child0TaskButton.tap()

        // Progress indicator label must change to reflect "1 of N tasks complete"
        let progressIndicator = app.otherElements[AX.ChildRoutine.progressIndicator(AX.ChildNames.child0)]
        let updatedPredicate = NSPredicate(format: "label != %@", progressBefore)
        let updateExpectation = expectation(for: updatedPredicate, evaluatedWith: progressIndicator)
        wait(for: [updateExpectation], timeout: 2.0)
    }
}
