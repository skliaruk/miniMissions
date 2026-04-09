// ParentalGateUITests.swift
// XCUITest suite for the Parental Gate (PIN setup and PIN entry).
//
// REQ coverage: REQ-003
// DSGN coverage: DSGN-003 acceptance criteria PM-AC-01 through PM-AC-07, PM-AC-19, PM-AC-23, PM-AC-24
//
// TDD Red Phase: All tests below compile but WILL FAIL because no implementation exists yet.
// These tests constitute the specification that MDEV must satisfy.

import XCTest

final class ParentalGateUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    // MARK: - PIN Entry Helpers

    /// Enters a 4-digit PIN via the keypad buttons identified by pinKey_<N>.
    private func enterPIN(_ pin: String) {
        for character in pin {
            guard let digit = Int(String(character)) else { continue }
            let key = app.buttons[AX.PINGate.key(digit)]
            XCTAssertTrue(
                key.waitForExistence(timeout: 3),
                "PIN keypad button '\(AX.PINGate.key(digit))' must exist"
            )
            key.tap()
        }
    }

    // MARK: - REQ-003 AC-1 / DSGN-003 PM-AC-01
    // On first launch, the app prompts the parent to set a 4-digit PIN.

    func testFirstLaunchShowsPINSetupScreen() throws {
        // REQ-003 AC-1: On first launch, app prompts parent to set PIN before showing routine view.
        // DSGN-003 PM-AC-01: pinDotDisplay visible on first launch (no --skip-pin-setup, no preset hash).
        app = AppLauncher.launchFirstLaunch()

        // PIN setup root must appear as the first screen
        let pinSetupRoot = app.otherElements[AX.PINGate.setupRoot]
        XCTAssertTrue(
            pinSetupRoot.waitForExistence(timeout: 3),
            "PIN setup screen root '\(AX.PINGate.setupRoot)' must be visible on first launch"
        )

        // PIN dot display must be visible
        let dotDisplay = app.otherElements[AX.PINGate.dotDisplay]
        XCTAssertTrue(
            dotDisplay.waitForExistence(timeout: 3),
            "PIN dot display '\(AX.PINGate.dotDisplay)' must be visible on first launch"
        )

        // Routine view must NOT be visible yet
        let routineRoot = app.otherElements[AX.ChildRoutine.root]
        XCTAssertFalse(
            routineRoot.exists,
            "Routine view must NOT be shown until PIN setup is complete"
        )
    }

    func testFirstLaunchDoesNotShowRoutineViewBeforePINSetup() throws {
        // REQ-003 AC-1: PIN setup must occur before routine view is accessible.
        app = AppLauncher.launchFirstLaunch()

        // Routine view root must not be accessible during PIN setup
        let routineRoot = app.otherElements[AX.ChildRoutine.root]
        XCTAssertFalse(
            routineRoot.waitForExistence(timeout: 1.0),
            "Routine view must not appear before PIN setup is complete"
        )
    }

    // MARK: - REQ-003 AC-1 (PIN setup completion) / DSGN-003 PM-AC-02
    // PIN setup completes and routine view appears.

    func testPINSetupCompletionNavigatesToRoutineView() throws {
        // REQ-003 AC-1: First-launch PIN setup flow completes and persists across app restarts.
        // DSGN-003 PM-AC-02: Two-step setup — enter PIN, confirm same PIN → routine view shown.
        app = AppLauncher.launchFirstLaunch()

        // Verify setup screen is showing
        XCTAssertTrue(
            app.otherElements[AX.PINGate.setupRoot].waitForExistence(timeout: 3),
            "PIN setup root must be shown on first launch"
        )

        // Step 1: Enter PIN "1234"
        enterPIN(TestConstants.testPIN)

        // After entering 4 digits the app should auto-advance to confirmation step.
        // Confirm button may appear, or digits may be sufficient to auto-advance.
        let setupConfirmButton = app.buttons[AX.PINGate.setupConfirmButton]
        if setupConfirmButton.waitForExistence(timeout: 2) {
            setupConfirmButton.tap()
        }

        // Step 2: Confirm the same PIN
        enterPIN(TestConstants.testPIN)

        // Confirm again if button is shown for step 2
        if setupConfirmButton.waitForExistence(timeout: 2) {
            setupConfirmButton.tap()
        }

        // Routine view must now be shown
        let routineRoot = app.otherElements[AX.ChildRoutine.root]
        XCTAssertTrue(
            routineRoot.waitForExistence(timeout: 5),
            "Routine view must appear after PIN setup is successfully completed"
        )
    }

    func testPINSetupWithMismatchedConfirmationShowsError() throws {
        // DSGN-003 PM-AC-02: If confirmation PIN does not match, error is shown and flow resets.
        app = AppLauncher.launchFirstLaunch()

        XCTAssertTrue(
            app.otherElements[AX.PINGate.setupRoot].waitForExistence(timeout: 3),
            "PIN setup root must be shown"
        )

        // Step 1: Enter PIN "1234"
        enterPIN(TestConstants.testPIN)

        let setupConfirmButton = app.buttons[AX.PINGate.setupConfirmButton]
        if setupConfirmButton.waitForExistence(timeout: 2) {
            setupConfirmButton.tap()
        }

        // Step 2: Enter a DIFFERENT PIN "9999"
        enterPIN(TestConstants.wrongPIN)

        if setupConfirmButton.waitForExistence(timeout: 2) {
            setupConfirmButton.tap()
        }

        // Error must be shown — PINs didn't match
        let errorMessage = app.staticTexts[AX.PINGate.errorMessage]
        let errorLabel = app.staticTexts[AX.PINGate.errorLabel]

        let errorVisible = errorMessage.waitForExistence(timeout: 3) ||
                           errorLabel.waitForExistence(timeout: 1)
        XCTAssertTrue(
            errorVisible,
            "An error must be displayed when the PIN confirmation does not match the first entry"
        )

        // Routine view must NOT appear
        XCTAssertFalse(
            app.otherElements[AX.ChildRoutine.root].exists,
            "Routine view must not appear after a PIN confirmation mismatch"
        )
    }

    // MARK: - REQ-003 AC-2 / DSGN-003 PM-AC-03
    // Parent entry point is visible on main screen but not prominent.

    func testParentEntryPointExistsOnRoutineView() throws {
        // REQ-003 AC-2: Parent entry point is visible but not prominent (small icon, no label).
        // DSGN-003 PM-AC-03: parentSettingsButton exists; no visible text sibling.
        app = AppLauncher.launchClean()

        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        XCTAssertTrue(
            gearButton.waitForExistence(timeout: 5),
            "Parent settings gear button '\(AX.ChildRoutine.parentSettingsButton)' must exist on routine view"
        )
        XCTAssertTrue(
            gearButton.isHittable,
            "Parent settings gear button must be hittable (visible and not obscured)"
        )
    }

    // MARK: - REQ-003 AC-3 / DSGN-003 PM-AC-04
    // Tapping the parent entry point shows the PIN entry screen.

    func testTappingGearButtonShowsPINEntryScreen() throws {
        // REQ-003 AC-3: Tapping parent entry point shows PIN entry screen.
        // DSGN-003 PM-AC-04: parentSettingsButton tap → pinDotDisplay.exists == true
        app = AppLauncher.launchWithPIN()

        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        XCTAssertTrue(
            gearButton.waitForExistence(timeout: 5),
            "Parent settings gear button must exist before tapping"
        )

        gearButton.tap()

        // PIN dot display must appear
        let dotDisplay = app.otherElements[AX.PINGate.dotDisplay]
        XCTAssertTrue(
            dotDisplay.waitForExistence(timeout: 3),
            "PIN dot display '\(AX.PINGate.dotDisplay)' must appear after tapping the gear button"
        )
    }

    // MARK: - REQ-003 AC-4 / DSGN-003 PM-AC-05
    // Correct PIN grants access to parent management.

    func testCorrectPINGrantsAccessToParentManagement() throws {
        // REQ-003 AC-4: Entering the correct PIN navigates to the parent management screen.
        // DSGN-003 PM-AC-05: enter correct PIN → parentDoneButton.exists == true
        app = AppLauncher.launchWithPIN()

        // Open PIN gate
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        gearButton.waitForExistence(timeout: 5)
        gearButton.tap()

        // Wait for PIN entry screen
        XCTAssertTrue(
            app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3),
            "PIN entry screen must appear after tapping gear button"
        )

        // Enter correct PIN
        enterPIN(TestConstants.testPIN)

        // Parent management must now be visible
        let parentRoot = app.otherElements[AX.ParentManagement.root]
        let doneButton = app.buttons[AX.ParentManagement.doneButton]

        let accessGranted = parentRoot.waitForExistence(timeout: 5) ||
                            doneButton.waitForExistence(timeout: 5)
        XCTAssertTrue(
            accessGranted,
            "Parent management screen must appear after entering correct PIN '\(TestConstants.testPIN)'"
        )
    }

    // MARK: - REQ-003 AC-5 / DSGN-003 PM-AC-06
    // Incorrect PIN shows error, does not navigate.

    func testIncorrectPINShowsErrorAndDoesNotNavigate() throws {
        // REQ-003 AC-5: Entering an incorrect PIN shows an error and increments failure counter.
        // DSGN-003 PM-AC-06: enter wrong PIN → pinErrorLabel.exists == true
        app = AppLauncher.launchWithPIN()

        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        gearButton.waitForExistence(timeout: 5)
        gearButton.tap()

        XCTAssertTrue(
            app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3),
            "PIN entry screen must appear"
        )

        // Enter wrong PIN
        enterPIN(TestConstants.wrongPIN)

        // Error label must appear
        let errorLabel = app.staticTexts[AX.PINGate.errorLabel]
        XCTAssertTrue(
            errorLabel.waitForExistence(timeout: 3),
            "Error label '\(AX.PINGate.errorLabel)' must appear after entering incorrect PIN"
        )

        // Parent management must NOT be shown
        XCTAssertFalse(
            app.otherElements[AX.ParentManagement.root].exists,
            "Parent management must NOT appear after entering an incorrect PIN"
        )

        // PIN dot display must still be visible (user still on PIN screen)
        XCTAssertTrue(
            app.otherElements[AX.PINGate.dotDisplay].exists,
            "PIN dot display must remain visible after an incorrect PIN attempt"
        )
    }

    func testIncorrectPINErrorLabelMentionsAttemptsRemaining() throws {
        // REQ-003 AC-5: Error increments failure counter.
        // DSGN-003 §2: Error label shows "Incorrect PIN ([N]/3 attempts)"
        app = AppLauncher.launchWithPIN()

        app.buttons[AX.ChildRoutine.parentSettingsButton].tap()
        app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3)

        enterPIN(TestConstants.wrongPIN)

        let errorLabel = app.staticTexts[AX.PINGate.errorLabel]
        XCTAssertTrue(
            errorLabel.waitForExistence(timeout: 3),
            "Error label must appear after wrong PIN"
        )
        // Label must contain attempt count information
        XCTAssertFalse(
            errorLabel.label.isEmpty,
            "Error label must contain text indicating the number of attempts (e.g. '1/3 attempts')"
        )
    }

    // MARK: - REQ-003 AC-6 / DSGN-003 PM-AC-07
    // Three incorrect attempts trigger lockout with countdown.

    func testThreeIncorrectPINAttemptsTriggerLockout() throws {
        // REQ-003 AC-6: After 3 incorrect attempts, PIN entry is disabled for 30 seconds with countdown.
        // DSGN-003 PM-AC-07: 3 wrong PINs → pinLockoutLabel.exists == true, keypad buttons disabled.
        app = AppLauncher.launchWithPIN()

        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        gearButton.waitForExistence(timeout: 5)
        gearButton.tap()
        app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3)

        // Attempt 1 — wrong PIN
        enterPIN(TestConstants.wrongPIN)
        app.staticTexts[AX.PINGate.errorLabel].waitForExistence(timeout: 2)

        // Attempt 2 — wrong PIN
        enterPIN(TestConstants.wrongPIN2)
        app.staticTexts[AX.PINGate.errorLabel].waitForExistence(timeout: 2)

        // Attempt 3 — wrong PIN (triggers lockout)
        enterPIN(TestConstants.wrongPIN3)

        // Lockout countdown label must appear
        let lockoutLabel = app.staticTexts[AX.PINGate.lockoutLabel]
        XCTAssertTrue(
            lockoutLabel.waitForExistence(timeout: 3),
            "Lockout label '\(AX.PINGate.lockoutLabel)' must appear after 3 consecutive wrong PIN attempts"
        )

        // Keypad buttons must be disabled during lockout
        let key1 = app.buttons[AX.PINGate.key(1)]
        if key1.exists {
            XCTAssertFalse(
                key1.isEnabled,
                "PIN keypad button '1' must be disabled during lockout period"
            )
        }
    }

    func testLockoutCountdownLabelIsVisible() throws {
        // REQ-003 AC-6: Lockout shows a 30-second countdown.
        // DSGN-003 §2: "Too many attempts. Try again in 0:30" with countdown.
        app = AppLauncher.launchWithPIN()

        app.buttons[AX.ChildRoutine.parentSettingsButton].tap()
        app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3)

        enterPIN(TestConstants.wrongPIN)
        app.staticTexts[AX.PINGate.errorLabel].waitForExistence(timeout: 2)
        enterPIN(TestConstants.wrongPIN2)
        app.staticTexts[AX.PINGate.errorLabel].waitForExistence(timeout: 2)
        enterPIN(TestConstants.wrongPIN3)

        let lockoutLabel = app.staticTexts[AX.PINGate.lockoutLabel]
        XCTAssertTrue(
            lockoutLabel.waitForExistence(timeout: 3),
            "Lockout label must appear after 3 wrong PIN attempts"
        )
        // Label must contain countdown text (non-empty)
        XCTAssertFalse(
            lockoutLabel.label.isEmpty,
            "Lockout label must contain a countdown timer value"
        )
    }

    // MARK: - REQ-003 AC-7 / DSGN-003 PM-AC-23, PM-AC-24
    // PIN change flow works correctly.

    func testChangePINFlowRequiresCurrentPINFirst() throws {
        // REQ-003 AC-7: PIN can be changed from within parent management (requires current PIN first).
        // DSGN-003 PM-AC-23: entering wrong current PIN in change flow → error, no access to new PIN step.
        app = AppLauncher.launchWithPIN()

        // Enter parent management with correct PIN
        let gearButton = app.buttons[AX.ChildRoutine.parentSettingsButton]
        gearButton.waitForExistence(timeout: 5)
        gearButton.tap()
        app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3)
        enterPIN(TestConstants.testPIN)

        // Parent management must be visible
        XCTAssertTrue(
            app.otherElements[AX.ParentManagement.root].waitForExistence(timeout: 5),
            "Parent management root must be visible after correct PIN"
        )

        // Tap "Change PIN" row
        let changePINRow = app.buttons[AX.ParentManagement.changePINRow]
        let changePINButton = app.buttons[AX.ParentManagement.changePINButton]
        let changePINElement = changePINRow.exists ? changePINRow : changePINButton

        XCTAssertTrue(
            changePINElement.waitForExistence(timeout: 3),
            "Change PIN option must be accessible in parent management"
        )
        changePINElement.tap()

        // Change PIN flow must show current PIN entry first
        XCTAssertTrue(
            app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3),
            "Change PIN flow must show PIN entry (current PIN required) before allowing new PIN entry"
        )

        // Enter WRONG current PIN — must show error and not advance to new PIN step
        enterPIN(TestConstants.wrongPIN)

        let errorLabel = app.staticTexts[AX.PINGate.errorLabel]
        XCTAssertTrue(
            errorLabel.waitForExistence(timeout: 3),
            "Error must be shown when wrong current PIN is entered in the change PIN flow"
        )
    }

    func testChangePINFlowWithCorrectCurrentPINShowsNewPINEntry() throws {
        // REQ-003 AC-7: Correct current PIN allows setting new PIN.
        // DSGN-003 PM-AC-24: complete PIN change → pinChangedToast.exists == true
        app = AppLauncher.launchWithPIN()

        // Enter parent management
        app.buttons[AX.ChildRoutine.parentSettingsButton].tap()
        app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3)
        enterPIN(TestConstants.testPIN)
        app.otherElements[AX.ParentManagement.root].waitForExistence(timeout: 5)

        // Navigate to change PIN
        let changePINRow = app.buttons[AX.ParentManagement.changePINRow]
        let changePINButton = app.buttons[AX.ParentManagement.changePINButton]
        let changePINElement = changePINRow.exists ? changePINRow : changePINButton
        changePINElement.waitForExistence(timeout: 3)
        changePINElement.tap()

        app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3)

        // Enter correct current PIN "1234"
        enterPIN(TestConstants.testPIN)

        // App must now show new PIN entry step (dot display resets to empty)
        // Enter new PIN "5678"
        let newPIN = "5678"
        enterPIN(newPIN)

        // Confirm new PIN "5678"
        enterPIN(newPIN)

        // Success toast must appear
        let toast = app.otherElements[AX.TaskEditor.pinChangedToast]
        XCTAssertTrue(
            toast.waitForExistence(timeout: 5),
            "PIN changed success toast '\(AX.TaskEditor.pinChangedToast)' must appear after successful PIN change"
        )
    }

    // MARK: - DSGN-003 PM-AC-19
    // PIN keypad buttons are >= 44x44pt touch targets.

    func testPINKeypadButtonsMeetMinimumTouchTargetSize() throws {
        // DSGN-003 PM-AC-19: pinKey_<N>.frame.width >= 44 && height >= 44 (actual: 80pt per DSGN-003).
        // Standard iOS minimum for parent-facing elements is 44pt; keypad actual size is 80pt.
        app = AppLauncher.launchWithPIN()

        app.buttons[AX.ChildRoutine.parentSettingsButton].tap()
        XCTAssertTrue(
            app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3),
            "PIN entry screen must appear before checking keypad touch targets"
        )

        for digit in 0...9 {
            let key = app.buttons[AX.PINGate.key(digit)]
            if key.exists {
                key.assertMinTouchTarget(44) // WCAG minimum; keypad should be 80pt
            }
        }
    }

    // MARK: - PIN screen dismiss

    func testPINCancelButtonDismissesPINScreenWithoutAccess() throws {
        // DSGN-003 §2: xmark button dismisses PIN screen and returns to routine view.
        app = AppLauncher.launchWithPIN()

        app.buttons[AX.ChildRoutine.parentSettingsButton].tap()
        XCTAssertTrue(
            app.otherElements[AX.PINGate.dotDisplay].waitForExistence(timeout: 3),
            "PIN entry screen must appear"
        )

        let cancelButton = app.buttons[AX.PINGate.cancelButton]
        XCTAssertTrue(
            cancelButton.waitForExistence(timeout: 3),
            "Cancel (xmark) button '\(AX.PINGate.cancelButton)' must exist on PIN entry screen"
        )
        cancelButton.tap()

        // Must return to routine view without granting access
        XCTAssertTrue(
            app.otherElements[AX.ChildRoutine.root].waitForExistence(timeout: 3),
            "Routine view must be shown after cancelling PIN entry"
        )
        XCTAssertFalse(
            app.otherElements[AX.ParentManagement.root].exists,
            "Parent management must NOT be accessible after cancelling PIN entry"
        )
    }
}
