// TopicCategoriesUITests.swift
// XCUITest suite for Topic Categories (Aihealueet) feature.
//
// REQ coverage: REQ-006
// DSGN coverage: DSGN-004 acceptance criteria TT-AC-01 through TT-AC-25
// ADR coverage: ADR-005 (data model), ADR-004 (testability)
//
// TDD Red Phase: All tests below compile but WILL FAIL because no implementation exists yet.
// These tests constitute the specification that MDEV must satisfy.

import XCTest

// MARK: - Child-Facing View: Topic Tab Bar Tests

final class TopicTabBarUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        // Each test gets a fresh in-memory store with seed data (3 children, default "Aamu" topic).
        app = AppLauncher.launchClean()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - REQ-006 AC-1 / DSGN-004 TT-AC-01, TT-AC-02
    // Default topic "Aamu" exists on first launch; tab bar is visible.

    func testFirstLaunchShowsAamuTabAsDefault() throws {
        // REQ-006 AC-1: Default topic "Aamu" exists on first launch.
        // DSGN-004 TT-AC-02: topicTab_Aamu has accessibilityValue == "Selected"
        let aamuTab = app.buttons[AX.TopicTab.tab("Aamu")]
        XCTAssertTrue(
            aamuTab.waitForExistence(timeout: 5),
            "Default topic tab 'Aamu' (id: '\(AX.TopicTab.tab("Aamu"))') must exist on first launch"
        )
        XCTAssertEqual(
            aamuTab.value as? String,
            "Selected",
            "Default topic 'Aamu' must be selected (accessibilityValue == 'Selected') on first launch"
        )
    }

    func testTabBarIsVisibleOnLaunch() throws {
        // REQ-006 AC-2: Child-facing view shows tabs for each topic.
        // DSGN-004 TT-AC-01: topicTabBar.exists == true on launch.
        let tabBar = app.otherElements[AX.TopicTab.tabBar]
        XCTAssertTrue(
            tabBar.waitForExistence(timeout: 5),
            "Topic tab bar '\(AX.TopicTab.tabBar)' must be visible on app launch"
        )
    }

    // MARK: - REQ-006 AC-2 / DSGN-004 TT-AC-03
    // Tapping a tab switches all child columns to that topic's tasks.

    func testTappingTabSwitchesAllChildColumnsToThatTopicsTasks() throws {
        // REQ-006 AC-3: Tapping a tab switches all child columns to that topic's tasks.
        // DSGN-004 TT-AC-03: tap topicTab_<Name> -> accessibilityValue == "Selected", task content changes.
        //
        // Precondition: a second topic must exist. This test creates one via parent management.
        // First, add a second topic via parent management.
        addTopicViaParentManagement(name: "Ilta")

        // Return to routine view
        dismissParentManagement()

        // Verify the new tab exists
        let iltaTab = app.buttons[AX.TopicTab.tab("Ilta")]
        XCTAssertTrue(
            iltaTab.waitForExistence(timeout: 5),
            "Newly added topic tab 'Ilta' must appear in the child-facing tab bar"
        )

        // Tap the new tab
        iltaTab.tap()

        // Verify the Ilta tab becomes active
        let selectedPredicate = NSPredicate(format: "value == 'Selected'")
        let selectedExpectation = expectation(for: selectedPredicate, evaluatedWith: iltaTab)
        wait(for: [selectedExpectation], timeout: 3.0)

        // Verify the Aamu tab is no longer selected
        let aamuTab = app.buttons[AX.TopicTab.tab("Aamu")]
        XCTAssertNotEqual(
            aamuTab.value as? String,
            "Selected",
            "Previously active tab 'Aamu' must no longer be selected after switching to 'Ilta'"
        )
    }

    // MARK: - REQ-006 AC-4 / DSGN-004 TT-AC-02
    // Active tab is visually distinct from inactive tabs.

    func testActiveTabIsVisuallyDistinct() throws {
        // REQ-006 AC-4: Active tab is visually distinct from inactive tabs.
        // DSGN-004 TT-AC-02: active tab has accessibilityTraits containing .isSelected.
        // Verified via accessibilityValue == "Selected".
        let aamuTab = app.buttons[AX.TopicTab.tab("Aamu")]
        XCTAssertTrue(
            aamuTab.waitForExistence(timeout: 5),
            "Aamu tab must exist to verify active state"
        )
        XCTAssertEqual(
            aamuTab.value as? String,
            "Selected",
            "Active tab must have accessibilityValue 'Selected' to indicate visual distinction"
        )
    }

    // MARK: - REQ-006 AC-5 / DSGN-004 TT-AC-04
    // Tab touch targets are at minimum 60x60pt.

    func testTabTouchTargetsMeetMinimumSize() throws {
        // REQ-006 AC-5: Tab touch targets are at minimum 60x60pt.
        // DSGN-004 TT-AC-04: topicTab_<Name>.frame.height >= 60 && .frame.width >= 120
        let aamuTab = app.buttons[AX.TopicTab.tab("Aamu")]
        XCTAssertTrue(
            aamuTab.waitForExistence(timeout: 5),
            "Aamu tab must exist to check touch target size"
        )
        aamuTab.assertMinTouchTarget(60)

        // Also check minimum width of 120pt per DSGN-004
        XCTAssertGreaterThanOrEqual(
            aamuTab.frame.width,
            120,
            "Topic tab width \(aamuTab.frame.width)pt must be at minimum 120pt per DSGN-004"
        )
    }

    // MARK: - DSGN-004 TT-AC-06
    // Single tab state: tab bar still visible with one topic.

    func testSingleTopicStillShowsTabBar() throws {
        // DSGN-004 TT-AC-06: when 1 topic exists, topicTabBar.exists == true and 1 tab visible.
        // Default seed data has only one topic ("Aamu"), so this is the natural first-launch state.
        let tabBar = app.otherElements[AX.TopicTab.tabBar]
        XCTAssertTrue(
            tabBar.waitForExistence(timeout: 5),
            "Tab bar must be visible even when only one topic exists"
        )

        let aamuTab = app.buttons[AX.TopicTab.tab("Aamu")]
        XCTAssertTrue(
            aamuTab.exists,
            "Single topic 'Aamu' tab must be visible in the tab bar"
        )

        // The single tab must always be in active/selected state
        XCTAssertEqual(
            aamuTab.value as? String,
            "Selected",
            "Single topic tab must always be selected (cannot be deselected)"
        )
    }

    // MARK: - DSGN-004 TT-AC-08
    // Tab order matches parent-defined sort order.

    func testTabOrderMatchesParentDefinedSortOrder() throws {
        // REQ-006 AC-15: Tab order matches parent-defined sort order.
        // DSGN-004 TT-AC-08: verify tab positions match topic order from parent management.
        //
        // Add two more topics to verify ordering.
        addTopicViaParentManagement(name: "Ilta")
        addTopicViaParentManagement(name: "Yoe")
        dismissParentManagement()

        let aamuTab = app.buttons[AX.TopicTab.tab("Aamu")]
        let iltaTab = app.buttons[AX.TopicTab.tab("Ilta")]
        let yoeTab = app.buttons[AX.TopicTab.tab("Yoe")]

        XCTAssertTrue(aamuTab.waitForExistence(timeout: 5), "Aamu tab must exist")
        XCTAssertTrue(iltaTab.waitForExistence(timeout: 3), "Ilta tab must exist")
        XCTAssertTrue(yoeTab.waitForExistence(timeout: 3), "Yoe tab must exist")

        // Tabs should appear left-to-right in the order they were added:
        // Aamu (default, sortOrder 0) -> Ilta (sortOrder 1) -> Yoe (sortOrder 2)
        XCTAssertLessThan(
            aamuTab.frame.origin.x,
            iltaTab.frame.origin.x,
            "Aamu tab must appear to the left of Ilta tab"
        )
        XCTAssertLessThan(
            iltaTab.frame.origin.x,
            yoeTab.frame.origin.x,
            "Ilta tab must appear to the left of Yoe tab"
        )
    }

    // MARK: - Private helpers

    /// Opens parent management by tapping gear, entering PIN, and waiting for root.
    private func openParentManagement() {
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        XCTAssertTrue(gearButton.waitForExistence(timeout: 5), "Gear button must exist")
        gearButton.tap()

        XCTAssertTrue(
            app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3),
            "PIN entry screen must appear"
        )
        enterPIN(TestConstants.testPIN)

        XCTAssertTrue(
            app.otherElements[AX.ParentManagement.root].waitForExistence(timeout: 5),
            "Parent management root must appear after correct PIN"
        )
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

    /// Adds a topic via parent management. Leaves the user in parent management view.
    /// Assumes app is launched with PIN (uses launchClean -> re-enters for this).
    private func addTopicViaParentManagement(name: String) {
        // If not already in parent management, open it
        if !app.otherElements[AX.ParentManagement.root].exists {
            // Need PIN for this. Re-launch with PIN.
            app.terminate()
            app = AppLauncher.launchWithPIN()
            openParentManagement()
        }

        let addButton = app.buttons[AX.TopicManagement.addTopicButton]
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 3),
            "Add Topic button must exist in parent management"
        )
        addButton.tap()

        // Fill in the name in the alert text field
        let nameField = app.textFields[AX.TopicManagement.addTopicNameField]
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 3),
            "Add Topic name field must appear in the alert"
        )
        nameField.tap()
        nameField.typeText(name)

        // Confirm
        let confirmButton = app.buttons[AX.TopicManagement.addTopicConfirmButton]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 3),
            "Add Topic confirm button must exist"
        )
        confirmButton.tap()
    }

    /// Dismisses parent management back to the routine view.
    private func dismissParentManagement() {
        let doneButton = app.buttons[AX.ParentManagement.doneButton]
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }
    }
}

// MARK: - Parent Management: Topic CRUD Tests

final class TopicCRUDUITests: XCTestCase {

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

    private func openParentManagement() {
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        XCTAssertTrue(gearButton.waitForExistence(timeout: 5), "Gear button must exist")
        gearButton.tap()

        XCTAssertTrue(
            app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3),
            "PIN entry screen must appear"
        )
        enterPIN(TestConstants.testPIN)

        XCTAssertTrue(
            app.otherElements[AX.ParentManagement.root].waitForExistence(timeout: 5),
            "Parent management root must appear after correct PIN"
        )
    }

    private func enterPIN(_ pin: String) {
        for character in pin {
            guard let digit = Int(String(character)) else { continue }
            let key = app.buttons[AX.PINGate.key(digit)]
            key.waitForExistence(timeout: 3)
            key.tap()
        }
    }

    private func dismissParentManagement() {
        let doneButton = app.buttons[AX.ParentManagement.doneButton]
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }
    }

    // MARK: - REQ-006 AC-6 / DSGN-004 TT-AC-10, TT-AC-21
    // Parent can add a new topic — new tab appears in child view.

    func testParentCanAddNewTopic() throws {
        // REQ-006 AC-6: Parent can add a new topic with a name (max 30 chars).
        // DSGN-004 TT-AC-10: addTopicButton tap -> addTopicConfirmButton visible, enter name, confirm -> new topicRow appears.
        openParentManagement()

        let addButton = app.buttons[AX.TopicManagement.addTopicButton]
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 3),
            "Add Topic button '\(AX.TopicManagement.addTopicButton)' must exist in parent management"
        )
        addButton.tap()

        // Alert with text field must appear
        let nameField = app.textFields[AX.TopicManagement.addTopicNameField]
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 3),
            "Add Topic name text field must appear in the alert dialog"
        )
        nameField.tap()
        nameField.typeText("Ilta")

        let confirmButton = app.buttons[AX.TopicManagement.addTopicConfirmButton]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 3),
            "Add Topic confirm button must be visible"
        )
        confirmButton.tap()

        // New topic row must appear in the Topics section
        let newTopicRow = app.cells[AX.TopicManagement.topicRow("Ilta")]
            .firstMatch
        XCTAssertTrue(
            newTopicRow.waitForExistence(timeout: 3),
            "New topic 'Ilta' must appear as a row in the parent management Topics section"
        )
    }

    func testNewTopicAppearsAsTabInChildView() throws {
        // REQ-006 AC-6 + DSGN-004 TT-AC-21: add topic in parent management -> topicTab_<NewName>.exists == true in routine view.
        openParentManagement()

        // Add the topic
        let addButton = app.buttons[AX.TopicManagement.addTopicButton]
        addButton.waitForExistence(timeout: 3)
        addButton.tap()

        let nameField = app.textFields[AX.TopicManagement.addTopicNameField]
        nameField.waitForExistence(timeout: 3)
        nameField.tap()
        nameField.typeText("Ilta")

        app.buttons[AX.TopicManagement.addTopicConfirmButton].tap()

        // Dismiss parent management to return to routine view
        dismissParentManagement()

        // Verify new tab appears in child-facing view
        let newTab = app.buttons[AX.TopicTab.tab("Ilta")]
        XCTAssertTrue(
            newTab.waitForExistence(timeout: 5),
            "Newly added topic 'Ilta' must appear as a tab in the child-facing routine view"
        )
    }

    // MARK: - REQ-006 AC-7 / DSGN-004 TT-AC-11, TT-AC-23
    // Parent can rename a topic — tab label updates.

    func testParentCanRenameTopic() throws {
        // REQ-006 AC-7: Parent can rename an existing topic.
        // DSGN-004 TT-AC-11: topicEditButton_<Name> tap -> renameTopicConfirmButton visible, change name, confirm -> row label updated.
        openParentManagement()

        // Default topic "Aamu" should exist
        let aamuRow = app.cells[AX.TopicManagement.topicRow("Aamu")]
        XCTAssertTrue(
            aamuRow.waitForExistence(timeout: 3),
            "Default topic row 'Aamu' must exist in parent management"
        )

        // Tap rename/edit button
        let editButton = app.buttons[AX.TopicManagement.topicEditButton("Aamu")]
        XCTAssertTrue(
            editButton.waitForExistence(timeout: 3),
            "Edit button for topic 'Aamu' must exist"
        )
        editButton.tap()

        // Rename dialog must appear with pre-filled name
        let nameField = app.textFields[AX.TopicManagement.renameTopicNameField]
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 3),
            "Rename Topic name field must appear in the alert"
        )

        // Clear and type new name
        nameField.tap()
        nameField.press(forDuration: 1.0)
        if app.menuItems["Select All"].waitForExistence(timeout: 2) {
            app.menuItems["Select All"].tap()
        }
        nameField.typeText("Aamupala")

        let saveButton = app.buttons[AX.TopicManagement.renameTopicConfirmButton]
        XCTAssertTrue(
            saveButton.waitForExistence(timeout: 3),
            "Rename Topic confirm (Save) button must be visible"
        )
        saveButton.tap()

        // Row must now show the new name
        let renamedRow = app.cells[AX.TopicManagement.topicRow("Aamupala")]
        XCTAssertTrue(
            renamedRow.waitForExistence(timeout: 3),
            "Topic row must update to show new name 'Aamupala' after renaming"
        )

        // Old name must no longer exist
        XCTAssertFalse(
            app.cells[AX.TopicManagement.topicRow("Aamu")].exists,
            "Old topic name 'Aamu' must no longer appear in parent management after rename"
        )
    }

    func testRenamingTopicUpdatesTabLabelInChildView() throws {
        // DSGN-004 TT-AC-23: rename topic -> topicTab_<NewName>.exists == true and topicTab_<OldName>.exists == false.
        openParentManagement()

        // Rename "Aamu" to "Aamupala"
        let editButton = app.buttons[AX.TopicManagement.topicEditButton("Aamu")]
        editButton.waitForExistence(timeout: 3)
        editButton.tap()

        let nameField = app.textFields[AX.TopicManagement.renameTopicNameField]
        nameField.waitForExistence(timeout: 3)
        nameField.tap()
        nameField.press(forDuration: 1.0)
        if app.menuItems["Select All"].waitForExistence(timeout: 2) {
            app.menuItems["Select All"].tap()
        }
        nameField.typeText("Aamupala")
        app.buttons[AX.TopicManagement.renameTopicConfirmButton].tap()

        // Navigate to routine view
        dismissParentManagement()

        // Verify tab label updated
        let newTab = app.buttons[AX.TopicTab.tab("Aamupala")]
        XCTAssertTrue(
            newTab.waitForExistence(timeout: 5),
            "Tab label must update to 'Aamupala' after renaming topic"
        )

        let oldTab = app.buttons[AX.TopicTab.tab("Aamu")]
        XCTAssertFalse(
            oldTab.exists,
            "Old tab label 'Aamu' must no longer exist after renaming topic"
        )
    }

    // MARK: - REQ-006 AC-8 / DSGN-004 TT-AC-12, TT-AC-22
    // Parent can delete a topic (with confirmation) — tab and tasks removed.

    func testParentCanDeleteTopicWithConfirmation() throws {
        // REQ-006 AC-8: Parent can delete a topic (with confirmation) -- all associated tasks are deleted.
        // DSGN-004 TT-AC-12: swipe left on topicRow_<Name> -> deleteTopicConfirmButton visible, confirm -> row removed.
        openParentManagement()

        // First add a second topic so deletion of the first is allowed
        let addButton = app.buttons[AX.TopicManagement.addTopicButton]
        addButton.waitForExistence(timeout: 3)
        addButton.tap()
        let nameField = app.textFields[AX.TopicManagement.addTopicNameField]
        nameField.waitForExistence(timeout: 3)
        nameField.tap()
        nameField.typeText("Ilta")
        app.buttons[AX.TopicManagement.addTopicConfirmButton].tap()

        // Verify both topics exist
        let aamuRow = app.cells[AX.TopicManagement.topicRow("Aamu")]
        XCTAssertTrue(aamuRow.waitForExistence(timeout: 3), "Aamu row must exist")

        // Swipe to delete "Aamu"
        aamuRow.swipeLeft()

        // Delete action must appear
        let deleteAction = app.buttons[AX.TopicManagement.topicDeleteAction("Aamu")]
        XCTAssertTrue(
            deleteAction.waitForExistence(timeout: 3),
            "Delete swipe action must appear for topic 'Aamu'"
        )
        deleteAction.tap()

        // Confirmation dialog must appear
        let confirmButton = app.buttons[AX.TopicManagement.deleteTopicConfirmButton]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 3),
            "Delete Topic confirmation button must appear before topic is removed"
        )

        // Confirm deletion
        confirmButton.tap()

        // Topic row must be removed
        XCTAssertFalse(
            app.cells[AX.TopicManagement.topicRow("Aamu")].waitForExistence(timeout: 2),
            "Topic 'Aamu' must be removed from parent management after confirmed deletion"
        )
    }

    func testDeletedTopicRemovedFromChildView() throws {
        // DSGN-004 TT-AC-22: delete topic in parent management -> topicTab_<Name>.exists == false in routine view.
        openParentManagement()

        // Add a second topic
        app.buttons[AX.TopicManagement.addTopicButton].tap()
        let nameField = app.textFields[AX.TopicManagement.addTopicNameField]
        nameField.waitForExistence(timeout: 3)
        nameField.tap()
        nameField.typeText("Ilta")
        app.buttons[AX.TopicManagement.addTopicConfirmButton].tap()

        // Delete "Aamu"
        let aamuRow = app.cells[AX.TopicManagement.topicRow("Aamu")]
        aamuRow.waitForExistence(timeout: 3)
        aamuRow.swipeLeft()
        app.buttons[AX.TopicManagement.topicDeleteAction("Aamu")].tap()
        app.buttons[AX.TopicManagement.deleteTopicConfirmButton].tap()

        // Navigate to routine view
        dismissParentManagement()

        // Deleted tab must be gone
        let deletedTab = app.buttons[AX.TopicTab.tab("Aamu")]
        XCTAssertFalse(
            deletedTab.waitForExistence(timeout: 2),
            "Deleted topic 'Aamu' must not appear as a tab in the routine view"
        )

        // Remaining tab "Ilta" must exist and be active
        let iltaTab = app.buttons[AX.TopicTab.tab("Ilta")]
        XCTAssertTrue(
            iltaTab.waitForExistence(timeout: 5),
            "Remaining topic 'Ilta' must be visible as a tab"
        )
    }

    // MARK: - REQ-006 AC-9 / DSGN-004 TT-AC-13
    // Cannot delete the last remaining topic.

    func testCannotDeleteLastRemainingTopic() throws {
        // REQ-006 AC-9: Parent cannot delete the last remaining topic.
        // DSGN-004 TT-AC-13: with 1 topic, swipe left on topicRow_<Name> -> deleteTopicConfirmButton.exists == false.
        openParentManagement()

        // Only default topic "Aamu" exists (single topic state)
        let aamuRow = app.cells[AX.TopicManagement.topicRow("Aamu")]
        XCTAssertTrue(
            aamuRow.waitForExistence(timeout: 3),
            "Default topic 'Aamu' must exist as the only topic"
        )

        // Attempt to swipe left to delete
        aamuRow.swipeLeft()

        // Delete action must NOT appear for the last remaining topic
        let deleteAction = app.buttons[AX.TopicManagement.topicDeleteAction("Aamu")]
        XCTAssertFalse(
            deleteAction.waitForExistence(timeout: 2),
            "Delete swipe action must NOT be available for the last remaining topic 'Aamu'"
        )

        // And the confirmation button must definitely not appear
        let confirmButton = app.buttons[AX.TopicManagement.deleteTopicConfirmButton]
        XCTAssertFalse(
            confirmButton.exists,
            "Delete Topic confirmation button must NOT appear when trying to delete the last topic"
        )
    }

    // MARK: - REQ-006 AC-10 / DSGN-004 TT-AC-14
    // Parent can reorder topics — tab order changes.

    func testParentCanReorderTopics() throws {
        // REQ-006 AC-10: Parent can reorder topics via drag-and-drop.
        // DSGN-004 TT-AC-14: reorder topics in parent management -> tab order changes in child view.
        openParentManagement()

        // Add a second topic
        app.buttons[AX.TopicManagement.addTopicButton].tap()
        let nameField = app.textFields[AX.TopicManagement.addTopicNameField]
        nameField.waitForExistence(timeout: 3)
        nameField.tap()
        nameField.typeText("Ilta")
        app.buttons[AX.TopicManagement.addTopicConfirmButton].tap()

        // Drag "Ilta" reorder handle above "Aamu" reorder handle
        let iltaHandle = app.buttons[AX.TopicManagement.topicReorderHandle("Ilta")]
        let aamuHandle = app.buttons[AX.TopicManagement.topicReorderHandle("Aamu")]

        XCTAssertTrue(
            iltaHandle.waitForExistence(timeout: 3),
            "Reorder handle for topic 'Ilta' must exist"
        )
        XCTAssertTrue(
            aamuHandle.exists,
            "Reorder handle for topic 'Aamu' must exist"
        )

        // Perform drag to reorder: move Ilta above Aamu
        iltaHandle.press(forDuration: 0.5, thenDragTo: aamuHandle)

        // Navigate to routine view to verify tab order changed
        dismissParentManagement()

        let aamuTab = app.buttons[AX.TopicTab.tab("Aamu")]
        let iltaTab = app.buttons[AX.TopicTab.tab("Ilta")]

        XCTAssertTrue(aamuTab.waitForExistence(timeout: 5), "Aamu tab must exist")
        XCTAssertTrue(iltaTab.waitForExistence(timeout: 3), "Ilta tab must exist")

        // After reorder, Ilta should appear to the left of Aamu
        XCTAssertLessThan(
            iltaTab.frame.origin.x,
            aamuTab.frame.origin.x,
            "After reordering, 'Ilta' tab must appear to the left of 'Aamu' tab"
        )
    }

    // MARK: - DSGN-004 TT-AC-25
    // Topic name field enforces 30-character maximum.

    func testTopicNameFieldEnforces30CharacterMaximum() throws {
        // DSGN-004 TT-AC-25: type 35 chars in add dialog -> field value length == 30.
        openParentManagement()

        app.buttons[AX.TopicManagement.addTopicButton].tap()

        let nameField = app.textFields[AX.TopicManagement.addTopicNameField]
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 3),
            "Topic name field must appear in Add Topic alert"
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
            "Topic name field must enforce 30-character maximum. Got \(fieldValue.count) characters."
        )
        XCTAssertEqual(
            fieldValue.count,
            30,
            "Topic name field must contain exactly 30 characters when 35 are typed"
        )
    }

    // MARK: - DSGN-004 TT-AC-09
    // Parent Home shows Topics section with all topics listed.

    func testParentHomeShowsTopicsSectionWithAllTopics() throws {
        // DSGN-004 TT-AC-09: topicRow_<Name>.exists == true for each topic.
        openParentManagement()

        // Default topic must be listed
        let aamuRow = app.cells[AX.TopicManagement.topicRow("Aamu")]
        XCTAssertTrue(
            aamuRow.waitForExistence(timeout: 3),
            "Default topic 'Aamu' must appear as a row in the Topics section of parent management"
        )

        // Add Topic button must be visible
        let addButton = app.buttons[AX.TopicManagement.addTopicButton]
        XCTAssertTrue(
            addButton.exists,
            "Add Topic button must be visible in the Topics section header"
        )
    }
}

// MARK: - Per-Topic Reset Tests

final class TopicResetUITests: XCTestCase {

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

    private func openParentManagement() {
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        XCTAssertTrue(gearButton.waitForExistence(timeout: 5), "Gear button must exist")
        gearButton.tap()

        XCTAssertTrue(
            app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3),
            "PIN entry screen must appear"
        )
        enterPIN(TestConstants.testPIN)

        XCTAssertTrue(
            app.otherElements[AX.ParentManagement.root].waitForExistence(timeout: 5),
            "Parent management root must appear after correct PIN"
        )
    }

    private func enterPIN(_ pin: String) {
        for character in pin {
            guard let digit = Int(String(character)) else { continue }
            let key = app.buttons[AX.PINGate.key(digit)]
            key.waitForExistence(timeout: 3)
            key.tap()
        }
    }

    private func dismissParentManagement() {
        let doneButton = app.buttons[AX.ParentManagement.doneButton]
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }
    }

    /// Adds a topic from parent management. Assumes already in parent management.
    private func addTopic(name: String) {
        app.buttons[AX.TopicManagement.addTopicButton].tap()
        let nameField = app.textFields[AX.TopicManagement.addTopicNameField]
        nameField.waitForExistence(timeout: 3)
        nameField.tap()
        nameField.typeText(name)
        app.buttons[AX.TopicManagement.addTopicConfirmButton].tap()
    }

    /// Adds a task to a child in a given topic. Assumes already in parent management.
    private func addTaskToChild(_ childName: String, topicName: String, taskName: String) {
        // Tap child row to go to child topic picker
        let childRow = app.cells[AX.ParentManagement.childRowByName(childName)]
        childRow.waitForExistence(timeout: 3)
        childRow.tap()

        // Select the topic from the child topic picker
        let topicRow = app.cells[AX.TopicManagement.childTopicRow(child: childName, topic: topicName)]
        XCTAssertTrue(
            topicRow.waitForExistence(timeout: 3),
            "Child topic row for '\(childName)' + '\(topicName)' must exist"
        )
        topicRow.tap()

        // Now in task editor scoped to child+topic. Add the task.
        let addButton = app.buttons[AX.ParentManagement.addTaskButton]
        addButton.waitForExistence(timeout: 3)
        addButton.tap()

        let nameField = app.textFields[AX.TaskEditor.taskNameField]
        nameField.waitForExistence(timeout: 3)
        nameField.tap()
        nameField.typeText(taskName)

        // Select first icon if icon picker is required
        let chooseIcon = app.buttons[AX.TaskEditor.chooseIconButton]
        if chooseIcon.waitForExistence(timeout: 2) {
            chooseIcon.tap()
            let firstIcon = app.buttons.matching(
                NSPredicate(format: "identifier BEGINSWITH 'iconPicker_'")
            ).firstMatch
            if firstIcon.waitForExistence(timeout: 3) {
                firstIcon.tap()
            }
        }

        app.buttons[AX.TaskEditor.formSaveButton].tap()

        // Navigate back to parent home (back from task editor, then back from child topic picker)
        app.navigationBars.buttons.firstMatch.tap()
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        }
    }

    /// Completes a task in the routine view for a given child index and task index.
    private func completeTask(childIndex: Int, taskIndex: Int) {
        let taskButton = app.buttons[AX.ChildRoutine.taskButton(childIndex, taskIndex)]
        XCTAssertTrue(
            taskButton.waitForExistence(timeout: 5),
            "Task button \(childIndex)_\(taskIndex) must exist"
        )
        taskButton.tap()
        let donePredicate = NSPredicate(format: "value == 'done'")
        let doneExpectation = expectation(for: donePredicate, evaluatedWith: taskButton)
        wait(for: [doneExpectation], timeout: 2.0)
    }

    // MARK: - REQ-006 AC-12 / DSGN-004 TT-AC-15, TT-AC-16
    // Per-topic reset only affects tasks in that topic.

    func testPerTopicResetShowsConfirmation() throws {
        // REQ-006 AC-14: Both reset actions require confirmation.
        // DSGN-004 TT-AC-15: topicResetButton_<Name> tap -> resetTopicConfirmButton_<Name>.exists == true.
        openParentManagement()

        let resetButton = app.buttons[AX.TopicManagement.topicResetButton("Aamu")]
        XCTAssertTrue(
            resetButton.waitForExistence(timeout: 3),
            "Per-topic reset button for 'Aamu' must exist"
        )
        resetButton.tap()

        let confirmButton = app.buttons[AX.TopicManagement.resetTopicConfirmButton("Aamu")]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 3),
            "Per-topic reset confirmation button for 'Aamu' must appear after tapping reset"
        )
    }

    func testPerTopicResetOnlyAffectsTasksInThatTopic() throws {
        // REQ-006 AC-12: Per-topic reset sets all tasks in that topic to incomplete for all children.
        // DSGN-004 TT-AC-16: confirm reset -> tasks in that topic have accessibilityValue == "not done", other topics unchanged.
        openParentManagement()

        // Add a second topic "Ilta"
        addTopic(name: "Ilta")

        // Add tasks to child 0 in both topics
        addTaskToChild(AX.ChildNames.child0, topicName: "Aamu", taskName: "AamuTask1")
        addTaskToChild(AX.ChildNames.child0, topicName: "Ilta", taskName: "IltaTask1")

        // Go to routine view and complete tasks in both topics
        dismissParentManagement()

        // Complete the Aamu task (default topic is active)
        completeTask(childIndex: 0, taskIndex: 0)

        // Switch to Ilta and complete its task
        let iltaTab = app.buttons[AX.TopicTab.tab("Ilta")]
        iltaTab.waitForExistence(timeout: 5)
        iltaTab.tap()
        completeTask(childIndex: 0, taskIndex: 0)

        // Now go to parent management and reset only "Aamu"
        openParentManagement()

        let resetButton = app.buttons[AX.TopicManagement.topicResetButton("Aamu")]
        resetButton.waitForExistence(timeout: 3)
        resetButton.tap()

        let confirmButton = app.buttons[AX.TopicManagement.resetTopicConfirmButton("Aamu")]
        confirmButton.waitForExistence(timeout: 3)
        confirmButton.tap()

        // Navigate back to routine view
        dismissParentManagement()

        // Aamu topic should be active; its task must be "not done"
        let aamuTab = app.buttons[AX.TopicTab.tab("Aamu")]
        aamuTab.waitForExistence(timeout: 5)
        aamuTab.tap()

        let aamuTask = app.buttons[AX.ChildRoutine.taskButton(0, 0)]
        XCTAssertTrue(aamuTask.waitForExistence(timeout: 5), "Aamu task must exist")
        XCTAssertEqual(
            aamuTask.value as? String,
            "not done",
            "After per-topic reset of 'Aamu', tasks in that topic must be 'not done'"
        )

        // Switch to Ilta; its task must STILL be "done" (unaffected by Aamu reset)
        let iltaTabAfterReset = app.buttons[AX.TopicTab.tab("Ilta")]
        iltaTabAfterReset.tap()

        let iltaTask = app.buttons[AX.ChildRoutine.taskButton(0, 0)]
        XCTAssertTrue(iltaTask.waitForExistence(timeout: 5), "Ilta task must exist")
        XCTAssertEqual(
            iltaTask.value as? String,
            "done",
            "Per-topic reset of 'Aamu' must NOT affect tasks in 'Ilta' -- task must remain 'done'"
        )
    }

    // MARK: - REQ-006 AC-13 / DSGN-004 TT-AC-17
    // "Reset All" resets all topics at once.

    func testResetAllShowsConfirmation() throws {
        // REQ-006 AC-14: Both reset actions require confirmation.
        // DSGN-004 TT-AC-17: resetAllButton tap -> resetAllConfirmButton.exists == true.
        openParentManagement()

        let resetAllButton = app.buttons[AX.TopicManagement.resetAllButton]
        XCTAssertTrue(
            resetAllButton.waitForExistence(timeout: 3),
            "Reset All button '\(AX.TopicManagement.resetAllButton)' must exist in parent management"
        )
        resetAllButton.tap()

        let confirmButton = app.buttons[AX.TopicManagement.resetAllConfirmButton]
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 3),
            "Reset All confirmation button must appear after tapping Reset All"
        )
    }

    func testResetAllClearsAllTopics() throws {
        // REQ-006 AC-13: "Reset all" resets all topics at once.
        // DSGN-004 TT-AC-17: confirm -> all tasks accessibilityValue == "not done".
        openParentManagement()

        // Add a second topic and tasks
        addTopic(name: "Ilta")
        addTaskToChild(AX.ChildNames.child0, topicName: "Aamu", taskName: "AamuTask1")
        addTaskToChild(AX.ChildNames.child0, topicName: "Ilta", taskName: "IltaTask1")

        // Go to routine view and complete tasks in both topics
        dismissParentManagement()
        completeTask(childIndex: 0, taskIndex: 0)

        let iltaTab = app.buttons[AX.TopicTab.tab("Ilta")]
        iltaTab.waitForExistence(timeout: 5)
        iltaTab.tap()
        completeTask(childIndex: 0, taskIndex: 0)

        // Reset all via parent management
        openParentManagement()

        let resetAllButton = app.buttons[AX.TopicManagement.resetAllButton]
        resetAllButton.waitForExistence(timeout: 3)
        resetAllButton.tap()

        let confirmButton = app.buttons[AX.TopicManagement.resetAllConfirmButton]
        confirmButton.waitForExistence(timeout: 3)
        confirmButton.tap()

        // Navigate back and check both topics
        dismissParentManagement()

        // Check Aamu tasks
        let aamuTab = app.buttons[AX.TopicTab.tab("Aamu")]
        aamuTab.waitForExistence(timeout: 5)
        aamuTab.tap()

        let aamuTask = app.buttons[AX.ChildRoutine.taskButton(0, 0)]
        if aamuTask.waitForExistence(timeout: 5) {
            XCTAssertEqual(
                aamuTask.value as? String,
                "not done",
                "After Reset All, tasks in 'Aamu' must be 'not done'"
            )
        }

        // Check Ilta tasks
        let iltaTabAfterReset = app.buttons[AX.TopicTab.tab("Ilta")]
        iltaTabAfterReset.tap()

        let iltaTask = app.buttons[AX.ChildRoutine.taskButton(0, 0)]
        if iltaTask.waitForExistence(timeout: 5) {
            XCTAssertEqual(
                iltaTask.value as? String,
                "not done",
                "After Reset All, tasks in 'Ilta' must be 'not done'"
            )
        }
    }

    // MARK: - REQ-006 AC-14 / DSGN-004 TT-AC-18
    // Cancelling reset leaves state unchanged.

    func testCancellingPerTopicResetLeavesStateUnchanged() throws {
        // DSGN-004 TT-AC-18: tap cancel on reset dialogs -> verify task states unchanged.
        openParentManagement()
        addTaskToChild(AX.ChildNames.child0, topicName: "Aamu", taskName: "AamuTask1")

        // Complete the task
        dismissParentManagement()
        completeTask(childIndex: 0, taskIndex: 0)

        // Open parent management and attempt reset but cancel
        openParentManagement()

        let resetButton = app.buttons[AX.TopicManagement.topicResetButton("Aamu")]
        resetButton.waitForExistence(timeout: 3)
        resetButton.tap()

        let cancelButton = app.buttons[AX.TopicManagement.resetTopicCancelButton("Aamu")]
        XCTAssertTrue(
            cancelButton.waitForExistence(timeout: 3),
            "Reset Topic cancel button must exist in confirmation dialog"
        )
        cancelButton.tap()

        // Navigate back and verify task is still done
        dismissParentManagement()

        let taskButton = app.buttons[AX.ChildRoutine.taskButton(0, 0)]
        XCTAssertTrue(taskButton.waitForExistence(timeout: 5), "Task must exist")
        XCTAssertEqual(
            taskButton.value as? String,
            "done",
            "After cancelling per-topic reset, task must remain 'done'"
        )
    }

    func testCancellingResetAllLeavesStateUnchanged() throws {
        // DSGN-004 TT-AC-18: cancelling Reset All leaves task states unchanged.
        openParentManagement()
        addTaskToChild(AX.ChildNames.child0, topicName: "Aamu", taskName: "AamuTask1")

        // Complete the task
        dismissParentManagement()
        completeTask(childIndex: 0, taskIndex: 0)

        // Open parent management and attempt Reset All but cancel
        openParentManagement()

        let resetAllButton = app.buttons[AX.TopicManagement.resetAllButton]
        resetAllButton.waitForExistence(timeout: 3)
        resetAllButton.tap()

        let cancelButton = app.buttons[AX.TopicManagement.resetAllCancelButton]
        XCTAssertTrue(
            cancelButton.waitForExistence(timeout: 3),
            "Reset All cancel button must exist in confirmation dialog"
        )
        cancelButton.tap()

        // Navigate back and verify task is still done
        dismissParentManagement()

        let taskButton = app.buttons[AX.ChildRoutine.taskButton(0, 0)]
        XCTAssertTrue(taskButton.waitForExistence(timeout: 5), "Task must exist")
        XCTAssertEqual(
            taskButton.value as? String,
            "done",
            "After cancelling Reset All, task must remain 'done'"
        )
    }
}

// MARK: - Task-Topic Association Tests

final class TaskTopicAssociationUITests: XCTestCase {

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

    private func openParentManagement() {
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        XCTAssertTrue(gearButton.waitForExistence(timeout: 5), "Gear button must exist")
        gearButton.tap()

        XCTAssertTrue(
            app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3),
            "PIN entry screen must appear"
        )
        enterPIN(TestConstants.testPIN)

        XCTAssertTrue(
            app.otherElements[AX.ParentManagement.root].waitForExistence(timeout: 5),
            "Parent management root must appear after correct PIN"
        )
    }

    private func enterPIN(_ pin: String) {
        for character in pin {
            guard let digit = Int(String(character)) else { continue }
            let key = app.buttons[AX.PINGate.key(digit)]
            key.waitForExistence(timeout: 3)
            key.tap()
        }
    }

    private func dismissParentManagement() {
        let doneButton = app.buttons[AX.ParentManagement.doneButton]
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }
    }

    private func addTopic(name: String) {
        app.buttons[AX.TopicManagement.addTopicButton].tap()
        let nameField = app.textFields[AX.TopicManagement.addTopicNameField]
        nameField.waitForExistence(timeout: 3)
        nameField.tap()
        nameField.typeText(name)
        app.buttons[AX.TopicManagement.addTopicConfirmButton].tap()
    }

    /// Adds a task to a child in a given topic. Assumes already in parent management.
    private func addTaskToChild(_ childName: String, topicName: String, taskName: String) {
        let childRow = app.cells[AX.ParentManagement.childRowByName(childName)]
        childRow.waitForExistence(timeout: 3)
        childRow.tap()

        let topicRow = app.cells[AX.TopicManagement.childTopicRow(child: childName, topic: topicName)]
        XCTAssertTrue(
            topicRow.waitForExistence(timeout: 3),
            "Child topic row for '\(childName)' + '\(topicName)' must exist"
        )
        topicRow.tap()

        let addButton = app.buttons[AX.ParentManagement.addTaskButton]
        addButton.waitForExistence(timeout: 3)
        addButton.tap()

        let nameField = app.textFields[AX.TaskEditor.taskNameField]
        nameField.waitForExistence(timeout: 3)
        nameField.tap()
        nameField.typeText(taskName)

        let chooseIcon = app.buttons[AX.TaskEditor.chooseIconButton]
        if chooseIcon.waitForExistence(timeout: 2) {
            chooseIcon.tap()
            let firstIcon = app.buttons.matching(
                NSPredicate(format: "identifier BEGINSWITH 'iconPicker_'")
            ).firstMatch
            if firstIcon.waitForExistence(timeout: 3) {
                firstIcon.tap()
            }
        }

        app.buttons[AX.TaskEditor.formSaveButton].tap()

        // Navigate back to parent home
        app.navigationBars.buttons.firstMatch.tap()
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        }
    }

    // MARK: - REQ-006 AC-11 / DSGN-004 TT-AC-19, TT-AC-20
    // Each child has independent tasks per topic.

    func testEachChildHasIndependentTasksPerTopic() throws {
        // REQ-006 AC-11: Each child has independent tasks per topic.
        // Verify that adding a task to child 0 in "Aamu" does not show it under child 1 in "Aamu".
        openParentManagement()

        // Add a task to child 0 in default topic "Aamu"
        addTaskToChild(AX.ChildNames.child0, topicName: "Aamu", taskName: "Child0OnlyTask")

        dismissParentManagement()

        // In routine view, the task should appear in child 0's column
        let child0Task = app.buttons.matching(
            NSPredicate(format: "identifier CONTAINS 'Child0OnlyTask'")
        ).firstMatch
        XCTAssertTrue(
            child0Task.waitForExistence(timeout: 5),
            "Task 'Child0OnlyTask' must appear in child 0's column"
        )

        // The task must NOT appear in child 1's column
        // Since the task identifiers include child information, check child 1's column for the same task name
        let child1TaskByName = app.buttons[AX.ChildRoutine.taskByName(child: AX.ChildNames.child1, task: "Child0OnlyTask")]
        XCTAssertFalse(
            child1TaskByName.exists,
            "Task 'Child0OnlyTask' must NOT appear in child 1's column -- tasks are per-child"
        )
    }

    // MARK: - Adding task in a topic only appears under that topic.

    func testAddingTaskInTopicOnlyAppearsUnderThatTopic() throws {
        // REQ-006: Tasks added to a specific topic only appear when that topic's tab is active.
        openParentManagement()

        // Add a second topic
        addTopic(name: "Ilta")

        // Add a task to child 0 in "Ilta" only
        addTaskToChild(AX.ChildNames.child0, topicName: "Ilta", taskName: "IltaOnlyTask")

        dismissParentManagement()

        // In routine view, default tab is "Aamu" -- the Ilta task must NOT be visible
        let taskInAamu = app.buttons.matching(
            NSPredicate(format: "identifier CONTAINS 'IltaOnlyTask'")
        ).firstMatch
        XCTAssertFalse(
            taskInAamu.waitForExistence(timeout: 2),
            "Task 'IltaOnlyTask' must NOT appear under 'Aamu' tab -- it belongs to 'Ilta'"
        )

        // Switch to Ilta tab -- now the task must appear
        let iltaTab = app.buttons[AX.TopicTab.tab("Ilta")]
        XCTAssertTrue(iltaTab.waitForExistence(timeout: 5), "Ilta tab must exist")
        iltaTab.tap()

        let taskInIlta = app.buttons.matching(
            NSPredicate(format: "identifier CONTAINS 'IltaOnlyTask'")
        ).firstMatch
        XCTAssertTrue(
            taskInIlta.waitForExistence(timeout: 5),
            "Task 'IltaOnlyTask' must appear when 'Ilta' tab is active"
        )
    }

    // MARK: - Deleting a topic deletes all its tasks for all children.

    func testDeletingTopicDeletesAllItsTasksForAllChildren() throws {
        // REQ-006 AC-8: Deleting a topic deletes all associated tasks for all children.
        openParentManagement()

        // Add a second topic and tasks in it
        addTopic(name: "Ilta")
        addTaskToChild(AX.ChildNames.child0, topicName: "Ilta", taskName: "IltaChild0Task")
        addTaskToChild(AX.ChildNames.child1, topicName: "Ilta", taskName: "IltaChild1Task")

        // Also add a task to Aamu for comparison (should survive the Ilta deletion)
        addTaskToChild(AX.ChildNames.child0, topicName: "Aamu", taskName: "AamuSurvivorTask")

        // Delete "Ilta" topic
        let iltaRow = app.cells[AX.TopicManagement.topicRow("Ilta")]
        iltaRow.waitForExistence(timeout: 3)
        iltaRow.swipeLeft()
        app.buttons[AX.TopicManagement.topicDeleteAction("Ilta")].tap()
        app.buttons[AX.TopicManagement.deleteTopicConfirmButton].tap()

        // Navigate to routine view
        dismissParentManagement()

        // "Ilta" tab must no longer exist
        let iltaTab = app.buttons[AX.TopicTab.tab("Ilta")]
        XCTAssertFalse(
            iltaTab.waitForExistence(timeout: 2),
            "Deleted topic 'Ilta' tab must not exist in routine view"
        )

        // Tasks from Ilta must be gone -- no element with IltaChild0Task or IltaChild1Task
        let iltaChild0Task = app.buttons.matching(
            NSPredicate(format: "identifier CONTAINS 'IltaChild0Task'")
        ).firstMatch
        XCTAssertFalse(
            iltaChild0Task.exists,
            "Tasks from deleted topic 'Ilta' must be removed for child 0"
        )

        let iltaChild1Task = app.buttons.matching(
            NSPredicate(format: "identifier CONTAINS 'IltaChild1Task'")
        ).firstMatch
        XCTAssertFalse(
            iltaChild1Task.exists,
            "Tasks from deleted topic 'Ilta' must be removed for child 1"
        )

        // Aamu task must still exist (unaffected by Ilta deletion)
        let aamuTask = app.buttons.matching(
            NSPredicate(format: "identifier CONTAINS 'AamuSurvivorTask'")
        ).firstMatch
        XCTAssertTrue(
            aamuTask.waitForExistence(timeout: 5),
            "Task in 'Aamu' topic must survive deletion of 'Ilta' topic"
        )
    }

    // MARK: - DSGN-004 TT-AC-19, TT-AC-20
    // Child topic picker navigation.

    func testTappingChildRowNavigatesToTopicPicker() throws {
        // DSGN-004 TT-AC-19: childRow_<Name> tap -> childTopicRow_<Name>_<TopicName>.exists == true.
        openParentManagement()

        let childRow = app.cells[AX.ParentManagement.childRowByName(AX.ChildNames.child0)]
        XCTAssertTrue(
            childRow.waitForExistence(timeout: 3),
            "Child row for '\(AX.ChildNames.child0)' must exist"
        )
        childRow.tap()

        // Child topic picker must show the default topic "Aamu"
        let topicRow = app.cells[AX.TopicManagement.childTopicRow(child: AX.ChildNames.child0, topic: "Aamu")]
        XCTAssertTrue(
            topicRow.waitForExistence(timeout: 5),
            "Child topic picker must show topic 'Aamu' for child '\(AX.ChildNames.child0)'"
        )
    }

    func testTappingTopicInChildTopicPickerOpensTaskEditor() throws {
        // DSGN-004 TT-AC-20: childTopicRow_<Name>_<TopicName> tap -> addTaskButton.exists == true.
        openParentManagement()

        let childRow = app.cells[AX.ParentManagement.childRowByName(AX.ChildNames.child0)]
        childRow.waitForExistence(timeout: 3)
        childRow.tap()

        let topicRow = app.cells[AX.TopicManagement.childTopicRow(child: AX.ChildNames.child0, topic: "Aamu")]
        topicRow.waitForExistence(timeout: 3)
        topicRow.tap()

        // Task editor must be visible with Add Task button
        let addTaskButton = app.buttons[AX.ParentManagement.addTaskButton]
        XCTAssertTrue(
            addTaskButton.waitForExistence(timeout: 5),
            "Task editor (scoped to child + topic) must show Add Task button"
        )
    }
}
