// DynamicChildrenUITests.swift
// XCUITest suite for Dynamic Children Management.
//
// REQ coverage: REQ-007
// DSGN coverage: DSGN-005 acceptance criteria DC-AC-01 through DC-AC-21
// ADR coverage: ADR-006 (data model), ADR-004 (testability)
//
// TDD Red Phase: All tests below compile but WILL FAIL because no implementation exists yet.
// These tests constitute the specification that MDEV must satisfy.

import XCTest

// MARK: - Child CRUD Tests

final class DynamicChildrenCRUDUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        // Launch with a pre-set PIN so PIN gate tests don't interfere.
        // The in-memory store gives a clean state per launch.
        app = AppLauncher.launchWithPIN()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - Navigation helpers

    /// Opens parent management by tapping the gear button and entering the correct PIN.
    private func openParentManagement() {
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        XCTAssertTrue(
            gearButton.waitForExistence(timeout: 5),
            "Gear button must exist to open parent management"
        )
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

    /// Dismisses parent management back to the routine view.
    private func dismissParentManagement() {
        let doneButton = app.buttons[AX.ParentManagement.doneButton]
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }
    }

    /// Adds a child with the given name via the Add Child sheet.
    /// Assumes the user is already in the parent management screen.
    private func addChild(name: String) {
        let addButton = app.buttons[AX.ChildManagement.addChildButton]
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 3),
            "Add Child button must exist in parent management"
        )
        addButton.tap()

        // Fill in name
        let nameField = app.textFields[AX.ChildManagement.childNameField]
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 3),
            "Child name field must appear in Add Child sheet"
        )
        nameField.tap()
        nameField.typeText(name)

        // Save
        let saveButton = app.buttons[AX.ChildManagement.childFormSaveButton]
        XCTAssertTrue(
            saveButton.waitForExistence(timeout: 3),
            "Save button must be visible in Add Child sheet"
        )
        saveButton.tap()
    }

    // MARK: - REQ-007 AC-1 / DSGN-005 DC-AC-11
    // Parent can add a child with a name -- new column appears in routine view.

    func testAddChildCreatesNewColumnInRoutineView() throws {
        // REQ-007 AC-1: Parent can add a child with a name (max 30 chars) and optional photo.
        // REQ-007 AC-10: Adding a child adds a new column to the routine view immediately.
        openParentManagement()

        // Add a new child
        addChild(name: "Mia")

        // Verify child row appears in parent management
        let childRow = app.cells[AX.ChildManagement.childRow("Mia")]
        XCTAssertTrue(
            childRow.waitForExistence(timeout: 3),
            "Child row for 'Mia' must appear in parent management after adding"
        )

        // Go back to routine view
        dismissParentManagement()

        // Verify the new child column appears in the routine view
        let childColumn = app.otherElements[AX.ChildRoutine.columnByName("Mia")]
        XCTAssertTrue(
            childColumn.waitForExistence(timeout: 5),
            "Child column for 'Mia' must appear in the routine view after adding"
        )

        // Verify child name label is displayed
        let childNameLabel = app.staticTexts[AX.ChildRoutine.childNameLabel("Mia")]
        XCTAssertTrue(
            childNameLabel.exists,
            "Child name label 'Mia' must be displayed in the routine view column"
        )
    }

    // MARK: - REQ-007 AC-2 / DSGN-005 DC-AC-14
    // Parent can edit a child's name -- updated in routine view.

    func testEditChildNameUpdatesRoutineView() throws {
        // REQ-007 AC-2: Parent can edit a child's name and photo.
        // REQ-007 AC-8: Each child's name and photo are displayed in the routine view.
        openParentManagement()

        // Add a child to edit
        addChild(name: "Leo")

        // Tap edit button on the child row
        let editButton = app.buttons[AX.ChildManagement.childEditButton("Leo")]
        XCTAssertTrue(
            editButton.waitForExistence(timeout: 3),
            "Edit button for 'Leo' must exist on the child row"
        )
        editButton.tap()

        // Edit the name
        let nameField = app.textFields[AX.ChildManagement.childNameField]
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 3),
            "Child name field must appear in Edit Child sheet"
        )
        // Clear existing text and type new name
        nameField.tap()
        nameField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        nameField.typeText("Aino")

        // Save
        let saveButton = app.buttons[AX.ChildManagement.childFormSaveButton]
        saveButton.tap()

        // Verify updated name in parent management
        let updatedRow = app.cells[AX.ChildManagement.childRow("Aino")]
        XCTAssertTrue(
            updatedRow.waitForExistence(timeout: 3),
            "Child row must now show updated name 'Aino'"
        )

        // Go back to routine view
        dismissParentManagement()

        // Verify updated name in routine view
        let updatedColumn = app.otherElements[AX.ChildRoutine.columnByName("Aino")]
        XCTAssertTrue(
            updatedColumn.waitForExistence(timeout: 5),
            "Routine view must show column with updated name 'Aino'"
        )

        // Old name should no longer exist
        let oldColumn = app.otherElements[AX.ChildRoutine.columnByName("Leo")]
        XCTAssertFalse(
            oldColumn.exists,
            "Routine view must not show column with old name 'Leo'"
        )
    }

    // MARK: - REQ-007 AC-2 (photo) / DSGN-005 DC-AC-14
    // Parent can add a photo to a child (test photo picker appears).

    func testPhotoPickerAppearsWhenAddingPhotoToChild() throws {
        // REQ-007 AC-2: Parent can edit a child's name and photo.
        // DSGN-005: Photo picker uses PHPickerViewController.
        openParentManagement()
        addChild(name: "Mia")

        // Edit the child to add a photo
        let editButton = app.buttons[AX.ChildManagement.childEditButton("Mia")]
        XCTAssertTrue(
            editButton.waitForExistence(timeout: 3),
            "Edit button for 'Mia' must exist"
        )
        editButton.tap()

        // Tap photo picker button
        let photoButton = app.buttons[AX.ChildManagement.childPhotoPickerButton]
        XCTAssertTrue(
            photoButton.waitForExistence(timeout: 3),
            "Photo picker button must appear in Edit Child sheet"
        )
        photoButton.tap()

        // The system photo picker should appear (it is a separate process, so we check
        // that the app's sheet is no longer in the foreground or the picker is visible)
        // PHPicker is presented as a system sheet; we check for its existence briefly.
        let photoPicker = app.navigationBars["Photos"]
        let photoPickerExists = photoPicker.waitForExistence(timeout: 5)
        // We accept that the photo picker may present differently, but the button must at least be tappable
        XCTAssertTrue(
            photoPickerExists || app.otherElements["PhotosGridView"].waitForExistence(timeout: 3),
            "System photo picker must appear after tapping 'Choose Photo'"
        )
    }

    // MARK: - REQ-007 AC-3 / DSGN-005 DC-AC-15, DC-AC-16
    // Parent can delete a child (with confirmation) -- column removed.

    func testDeleteChildWithConfirmationRemovesColumn() throws {
        // REQ-007 AC-3: Parent can delete a child (with confirmation).
        // REQ-007 AC-9: Deleting a child removes their column from the routine view immediately.
        openParentManagement()

        // Add two children (need at least 2 to delete one)
        addChild(name: "Mia")
        addChild(name: "Leo")

        // Swipe left on Mia's row to trigger delete
        let miaRow = app.cells[AX.ChildManagement.childRow("Mia")]
        XCTAssertTrue(
            miaRow.waitForExistence(timeout: 3),
            "Child row for 'Mia' must exist"
        )
        miaRow.swipeLeft()

        // Confirmation dialog should appear
        let deleteConfirm = app.buttons[AX.ChildManagement.deleteChildConfirmButton]
        XCTAssertTrue(
            deleteConfirm.waitForExistence(timeout: 3),
            "Delete confirmation button must appear after swiping to delete"
        )
        deleteConfirm.tap()

        // Mia's row should be gone from parent management
        XCTAssertFalse(
            miaRow.waitForExistence(timeout: 2),
            "Child row for 'Mia' must be removed after delete confirmation"
        )

        // Go to routine view
        dismissParentManagement()

        // Mia's column should be gone
        let miaColumn = app.otherElements[AX.ChildRoutine.columnByName("Mia")]
        XCTAssertFalse(
            miaColumn.exists,
            "Routine view must not show column for deleted child 'Mia'"
        )

        // Leo's column should still exist
        let leoColumn = app.otherElements[AX.ChildRoutine.columnByName("Leo")]
        XCTAssertTrue(
            leoColumn.waitForExistence(timeout: 3),
            "Routine view must still show column for remaining child 'Leo'"
        )
    }

    // MARK: - REQ-007 AC-4 / DSGN-005 DC-AC-17, DC-AC-18
    // Cannot delete last remaining child.

    func testCannotDeleteLastRemainingChild() throws {
        // REQ-007 AC-4: Parent cannot delete the last remaining child.
        // DSGN-005 DC-AC-17: swipe-to-delete action not available on the only child.
        // DSGN-005 DC-AC-18: lastChildInfoLabel shown when only 1 child exists.
        openParentManagement()

        // Add exactly one child
        addChild(name: "Mia")

        let miaRow = app.cells[AX.ChildManagement.childRow("Mia")]
        XCTAssertTrue(
            miaRow.waitForExistence(timeout: 3),
            "Single child row must exist"
        )

        // Attempt to swipe left -- delete action should not appear
        miaRow.swipeLeft()

        let deleteConfirm = app.buttons[AX.ChildManagement.deleteChildConfirmButton]
        XCTAssertFalse(
            deleteConfirm.waitForExistence(timeout: 2),
            "Delete confirmation must NOT appear for the last remaining child"
        )

        // Verify info label
        let lastChildLabel = app.staticTexts[AX.ChildManagement.lastChildInfoLabel]
        XCTAssertTrue(
            lastChildLabel.exists,
            "Info label 'At least one child is required' must be shown when only 1 child exists"
        )
    }

    // MARK: - REQ-007 AC-5 / DSGN-005 DC-AC-19, DC-AC-20
    // Maximum 6 children enforced -- add button disabled at limit.

    func testMaximumSixChildrenEnforced() throws {
        // REQ-007 AC-5: Maximum 6 children enforced -- add button disabled at limit.
        // DSGN-005 DC-AC-19: addChildButton.isEnabled == false when 6 children exist.
        // DSGN-005 DC-AC-20: maxChildrenInfoLabel shown when 6 children exist.
        openParentManagement()

        // Add 6 children
        let childNames = ["Mia", "Leo", "Aino", "Elias", "Sofia", "Oliver"]
        for name in childNames {
            addChild(name: name)
        }

        // Verify add button is disabled
        let addButton = app.buttons[AX.ChildManagement.addChildButton]
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 3),
            "Add Child button must still be visible"
        )
        XCTAssertFalse(
            addButton.isEnabled,
            "Add Child button must be disabled when 6 children exist (maximum reached)"
        )

        // Verify max children info label
        let maxLabel = app.staticTexts[AX.ChildManagement.maxChildrenInfoLabel]
        XCTAssertTrue(
            maxLabel.exists,
            "Max children info label must be shown when 6 children exist"
        )
    }

    // MARK: - REQ-007 AC-6 / DSGN-005 DC-AC-21
    // Parent can reorder children -- column order changes.

    func testReorderChildrenChangesColumnOrder() throws {
        // REQ-007 AC-6: Parent can reorder children via drag-and-drop.
        // DSGN-005 DC-AC-21: reorder children -> column order changes in routine view.
        openParentManagement()

        // Add two children in order
        addChild(name: "Mia")
        addChild(name: "Leo")

        // Verify initial order: Mia before Leo
        dismissParentManagement()

        let miaColumn = app.otherElements[AX.ChildRoutine.columnByName("Mia")]
        let leoColumn = app.otherElements[AX.ChildRoutine.columnByName("Leo")]

        XCTAssertTrue(miaColumn.waitForExistence(timeout: 5), "Mia column must exist")
        XCTAssertTrue(leoColumn.waitForExistence(timeout: 3), "Leo column must exist")

        // Mia should be to the left of Leo initially
        XCTAssertLessThan(
            miaColumn.frame.origin.x,
            leoColumn.frame.origin.x,
            "Mia column must appear before Leo column initially"
        )

        // Go back to parent management to reorder
        openParentManagement()

        // Drag Leo's reorder handle above Mia's
        let leoHandle = app.buttons[AX.ChildManagement.childReorderHandle("Leo")]
        let miaHandle = app.buttons[AX.ChildManagement.childReorderHandle("Mia")]
        XCTAssertTrue(leoHandle.waitForExistence(timeout: 3), "Leo reorder handle must exist")
        XCTAssertTrue(miaHandle.waitForExistence(timeout: 3), "Mia reorder handle must exist")

        leoHandle.press(forDuration: 0.5, thenDragTo: miaHandle)

        // Go back to routine view to verify new order
        dismissParentManagement()

        let miaColumnAfter = app.otherElements[AX.ChildRoutine.columnByName("Mia")]
        let leoColumnAfter = app.otherElements[AX.ChildRoutine.columnByName("Leo")]

        XCTAssertTrue(miaColumnAfter.waitForExistence(timeout: 5), "Mia column must exist after reorder")
        XCTAssertTrue(leoColumnAfter.waitForExistence(timeout: 3), "Leo column must exist after reorder")

        // Now Leo should be to the left of Mia
        XCTAssertLessThan(
            leoColumnAfter.frame.origin.x,
            miaColumnAfter.frame.origin.x,
            "Leo column must appear before Mia column after reorder"
        )
    }
}

// MARK: - Layout Tests

final class DynamicChildrenLayoutUITests: XCTestCase {

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

    private func addChild(name: String) {
        let addButton = app.buttons[AX.ChildManagement.addChildButton]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3), "Add Child button must exist")
        addButton.tap()

        let nameField = app.textFields[AX.ChildManagement.childNameField]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3), "Child name field must appear")
        nameField.tap()
        nameField.typeText(name)

        let saveButton = app.buttons[AX.ChildManagement.childFormSaveButton]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3), "Save button must be visible")
        saveButton.tap()
    }

    // MARK: - REQ-007 AC-7 / DSGN-005 DC-AC-02, DC-AC-03, DC-AC-04
    // 1-3 children display as columns.

    func testOneToThreeChildrenDisplayAsColumns() throws {
        // REQ-007 AC-7: Child-facing view shows all children (columns for <= 3).
        // DSGN-005 DC-AC-02: 1 child = single centred column.
        // DSGN-005 DC-AC-03: 2 children = two equal columns.
        // DSGN-005 DC-AC-04: 3 children = three equal columns.
        openParentManagement()

        // Add 3 children
        addChild(name: "Mia")
        addChild(name: "Leo")
        addChild(name: "Aino")
        dismissParentManagement()

        // All three columns must exist
        let miaColumn = app.otherElements[AX.ChildRoutine.columnByName("Mia")]
        let leoColumn = app.otherElements[AX.ChildRoutine.columnByName("Leo")]
        let ainoColumn = app.otherElements[AX.ChildRoutine.columnByName("Aino")]

        XCTAssertTrue(miaColumn.waitForExistence(timeout: 5), "Mia column must exist")
        XCTAssertTrue(leoColumn.waitForExistence(timeout: 3), "Leo column must exist")
        XCTAssertTrue(ainoColumn.waitForExistence(timeout: 3), "Aino column must exist")

        // All columns should be on the same vertical row (single-row layout)
        // Verify their Y positions are approximately equal (same row)
        let yTolerance: CGFloat = 50 // Allow some tolerance for layout differences
        XCTAssertEqual(
            miaColumn.frame.origin.y,
            leoColumn.frame.origin.y,
            accuracy: yTolerance,
            "With 3 children, all columns must be in the same row (similar Y position)"
        )
        XCTAssertEqual(
            leoColumn.frame.origin.y,
            ainoColumn.frame.origin.y,
            accuracy: yTolerance,
            "With 3 children, all columns must be in the same row (similar Y position)"
        )

        // Columns should be arranged left to right: Mia < Leo < Aino
        XCTAssertLessThan(miaColumn.frame.origin.x, leoColumn.frame.origin.x,
                          "Mia must be to the left of Leo")
        XCTAssertLessThan(leoColumn.frame.origin.x, ainoColumn.frame.origin.x,
                          "Leo must be to the left of Aino")

        // Columns should be approximately equal width
        let widthTolerance: CGFloat = 10
        XCTAssertEqual(
            miaColumn.frame.width,
            leoColumn.frame.width,
            accuracy: widthTolerance,
            "With 3 children, columns should have equal width"
        )
        XCTAssertEqual(
            leoColumn.frame.width,
            ainoColumn.frame.width,
            accuracy: widthTolerance,
            "With 3 children, columns should have equal width"
        )
    }

    // MARK: - REQ-007 AC-7 / DSGN-005 DC-AC-05, DC-AC-06, DC-AC-07
    // 4+ children display in scrollable/grid layout.

    func testFourPlusChildrenDisplayInGridLayout() throws {
        // REQ-007 AC-7: Child-facing view shows all children (scrollable for 4-6).
        // DSGN-005 DC-AC-05: 4 children = 2x2 grid layout.
        openParentManagement()

        // Add 4 children
        addChild(name: "Mia")
        addChild(name: "Leo")
        addChild(name: "Aino")
        addChild(name: "Elias")
        dismissParentManagement()

        // All four columns must exist and be hittable
        let columns = ["Mia", "Leo", "Aino", "Elias"].map {
            app.otherElements[AX.ChildRoutine.columnByName($0)]
        }

        for (i, column) in columns.enumerated() {
            XCTAssertTrue(
                column.waitForExistence(timeout: 5),
                "Child column \(i) must exist in 4-child grid layout"
            )
        }

        // With 4 children, we expect a 2-row layout:
        // Row 1: Mia, Leo (top)
        // Row 2: Aino, Elias (bottom)
        // OR 2x2 grid arrangement
        // Verify that not all columns are in the same row
        let topY = columns[0].frame.origin.y
        let hasMultipleRows = columns.contains { abs($0.frame.origin.y - topY) > 50 }
        XCTAssertTrue(
            hasMultipleRows,
            "With 4 children, layout must use multiple rows (grid), not a single row"
        )
    }

    func testSixChildrenDisplayInTwoByThreeGrid() throws {
        // REQ-007 AC-7: Child-facing view shows all children (scrollable for 4-6).
        // DSGN-005 DC-AC-07: 6 children = 2 rows of 3 columns each.
        openParentManagement()

        let childNames = ["Mia", "Leo", "Aino", "Elias", "Sofia", "Oliver"]
        for name in childNames {
            addChild(name: name)
        }
        dismissParentManagement()

        // All six columns must exist
        for name in childNames {
            let column = app.otherElements[AX.ChildRoutine.columnByName(name)]
            XCTAssertTrue(
                column.waitForExistence(timeout: 5),
                "Column for '\(name)' must exist in 6-child grid layout"
            )
        }

        // Verify 2-row layout: first 3 in row 1, last 3 in row 2
        let row1Columns = childNames[0..<3].map { app.otherElements[AX.ChildRoutine.columnByName($0)] }
        let row2Columns = childNames[3..<6].map { app.otherElements[AX.ChildRoutine.columnByName($0)] }

        let row1Y = row1Columns[0].frame.origin.y
        let row2Y = row2Columns[0].frame.origin.y

        // Row 1 columns should have similar Y
        for col in row1Columns {
            XCTAssertEqual(col.frame.origin.y, row1Y, accuracy: 50,
                           "Row 1 columns should be at the same vertical position")
        }

        // Row 2 columns should have similar Y
        for col in row2Columns {
            XCTAssertEqual(col.frame.origin.y, row2Y, accuracy: 50,
                           "Row 2 columns should be at the same vertical position")
        }

        // Row 2 should be below row 1
        XCTAssertGreaterThan(
            row2Y, row1Y + 50,
            "Row 2 must be significantly below row 1 in the grid layout"
        )
    }

    // MARK: - DSGN-005 DC-AC-01
    // First launch with no children shows empty state.

    func testFirstLaunchWithNoChildrenShowsEmptyState() throws {
        // DSGN-005 DC-AC-01: With 0 children, empty state view is shown.
        // Note: After REQ-007, the app no longer seeds fixed children.
        // A clean launch should show the empty state.

        // The in-memory store with --uitesting gives a clean state.
        // With dynamic children (REQ-007), no children are seeded.
        let emptyState = app.otherElements[AX.ChildManagement.emptyStateView]
        XCTAssertTrue(
            emptyState.waitForExistence(timeout: 5),
            "Empty state view must appear when no children exist on first launch"
        )

        let settingsButton = app.buttons[AX.ChildManagement.emptyStateSettingsButton]
        XCTAssertTrue(
            settingsButton.exists,
            "Empty state 'Open Settings' button must be visible"
        )
    }

    // MARK: - REQ-007 AC-8 / DSGN-005 DC-AC-08
    // Each child's name and avatar are displayed in routine view.

    func testChildNameAndAvatarDisplayedInRoutineView() throws {
        // REQ-007 AC-8: Each child's name and photo are displayed in the routine view.
        // DSGN-005 DC-AC-08: childName_<Name> and childAvatar_<Name> exist for each child.
        openParentManagement()
        addChild(name: "Mia")
        addChild(name: "Leo")
        dismissParentManagement()

        for name in ["Mia", "Leo"] {
            let nameLabel = app.staticTexts[AX.ChildRoutine.childNameLabel(name)]
            XCTAssertTrue(
                nameLabel.waitForExistence(timeout: 5),
                "Child name label '\(name)' must be displayed in routine view"
            )

            let avatar = app.images[AX.ChildRoutine.childAvatar(name)]
            XCTAssertTrue(
                avatar.waitForExistence(timeout: 3),
                "Child avatar for '\(name)' must be displayed in routine view"
            )
        }
    }
}
