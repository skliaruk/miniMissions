// AppLauncher.swift
// Convenience helpers for launching XCUIApplication with standard test configurations.
// Source of truth: ADR-004 §2 Launch Arguments Contract and §6 AppLauncher Helper.
//
// All tests must launch the app through one of these methods — never configure
// launchArguments inline in test methods.

import XCTest

// MARK: - Test constants

/// Shared constants for PIN-gate tests.
/// The hash value is pre-computed from SHA-256("taskapp.pin.salt.v1" + "1234").
/// Final value must be filled in at implementation time — see ADR-004 §2.
enum TestConstants {
    /// PIN "1234" hashed with the fixed app salt ("taskapp.pin.salt.v1").
    /// Computed at runtime by PINHashHelper to ensure it always matches PINService.hash().
    static let pin1234Hash = PINHashHelper.pin1234Hash

    /// The plain-text PIN corresponding to pin1234Hash.
    static let testPIN = "1234"

    /// A PIN that is definitively wrong — used for negative PIN tests.
    static let wrongPIN = "9999"

    /// An alternative wrong PIN distinct from wrongPIN — used for lockout tests.
    static let wrongPIN2 = "8888"

    /// Another wrong PIN — used for the third lockout attempt.
    static let wrongPIN3 = "7777"
}

// MARK: - AppLauncher

/// Namespace for XCUIApplication launch helpers.
/// Each static method configures and launches the app in a specific test environment
/// according to the launch argument contract in ADR-004 §2.
struct AppLauncher {

    /// Locale arguments used in every launch so that localised strings (e.g. the seeded
    /// "Aamu" topic name) match what the tests expect.
    private static let localeArgs: [String] = [
        "-AppleLanguages", "(fi)",
        "-AppleLocale", "fi_FI"
    ]

    // MARK: Standard configurations

    /// Launches the app in the standard clean-slate test environment.
    ///
    /// Launch arguments applied:
    /// - `--uitesting`:       in-memory SwiftData store (clean per launch)
    /// - `--skip-pin-setup`:  bypasses first-launch PIN setup screen
    ///
    /// Use this for all non-PIN tests. The app opens directly to `ChildRoutineView`.
    ///
    /// - Returns: The launched `XCUIApplication` instance.
    @discardableResult
    static func launchClean() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = AppLauncher.localeArgs + ["--uitesting", "--skip-pin-setup"]
        app.launch()
        return app
    }

    /// Launches the app with a pre-populated Keychain PIN hash.
    ///
    /// Launch arguments applied:
    /// - `--uitesting`:                in-memory SwiftData store (clean per launch)
    /// - `--preset-pin-hash <hash>`:   pre-populates Keychain with the given hash
    ///
    /// Use this for PIN gate tests where a known PIN must already exist.
    /// The app opens to `ChildRoutineView` — the PIN gate is triggered by tapping the gear icon.
    ///
    /// - Parameter hash: SHA-256 hex string for the desired PIN. Defaults to `TestConstants.pin1234Hash`.
    /// - Returns: The launched `XCUIApplication` instance.
    @discardableResult
    static func launchWithPIN(_ hash: String = TestConstants.pin1234Hash) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = AppLauncher.localeArgs + ["--uitesting", "--skip-pin-setup", "--preset-pin-hash", hash]
        app.launch()
        return app
    }

    /// Launches the app in Reduce Motion mode.
    ///
    /// Launch arguments applied:
    /// - `--uitesting`:        in-memory SwiftData store (clean per launch)
    /// - `--skip-pin-setup`:   bypasses first-launch PIN setup screen
    /// - `--reduce-motion`:    sets `AppEnvironment.reduceMotion = true` (REQ-002, REQ-005)
    ///
    /// Use this to verify that animation elements are absent and static alternatives are shown.
    ///
    /// - Returns: The launched `XCUIApplication` instance.
    @discardableResult
    static func launchWithReduceMotion() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = AppLauncher.localeArgs + ["--uitesting", "--skip-pin-setup", "--reduce-motion"]
        app.launch()
        return app
    }

    /// Launches the app simulating a true first launch (no PIN set, no --skip-pin-setup).
    ///
    /// Launch arguments applied:
    /// - `--uitesting`: in-memory SwiftData store (clean per launch); Keychain has no PIN hash
    ///
    /// The app will show the PIN setup screen before the routine view.
    /// Use this exclusively for first-launch PIN setup tests (REQ-003 AC-1).
    ///
    /// - Returns: The launched `XCUIApplication` instance.
    @discardableResult
    static func launchFirstLaunch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = AppLauncher.localeArgs + ["--uitesting", "--clear-keychain"]
        // Intentionally no --skip-pin-setup and no --preset-pin-hash so that
        // ContentRootView detects no PIN in Keychain and shows PINSetupView.
        app.launch()
        return app
    }

    // MARK: - Daily reset configurations

    /// Launches the app with `lastDailyResetDate` forced to yesterday.
    ///
    /// Launch arguments applied:
    /// - `--uitesting`:             in-memory SwiftData store (clean per launch)
    /// - `--skip-pin-setup`:        bypasses first-launch PIN setup screen
    /// - `--resetDateYesterday`:    sets UserDefaults "lastDailyResetDate" to yesterday,
    ///                              causing `performDailyResetIfNeeded()` to trigger on .active
    ///
    /// Use this to test that daily reset clears all task completions when the date has changed.
    ///
    /// - Returns: The launched `XCUIApplication` instance.
    @discardableResult
    static func launchWithResetDateYesterday() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = AppLauncher.localeArgs + ["--uitesting", "--skip-pin-setup", "--resetDateYesterday"]
        app.launch()
        return app
    }

    // MARK: - State persistence configurations

    /// Launches the app WITHOUT the in-memory store flag so that real on-disk
    /// SwiftData persistence is used. Required for state-persistence tests in REQ-005.
    ///
    /// WARNING: Do NOT use this for tests that require a clean state — use `launchClean()` instead.
    /// Tests using this method are responsible for cleaning up any data they write.
    ///
    /// Launch arguments applied:
    /// - `--skip-pin-setup`: bypasses PIN setup so the routine view is shown directly
    ///
    /// - Returns: The launched `XCUIApplication` instance.
    @discardableResult
    static func launchWithPersistence() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = AppLauncher.localeArgs + ["--skip-pin-setup"]
        // Intentionally NO --uitesting so the real on-disk store is used.
        app.launch()
        return app
    }

    /// Launches the app with real on-disk persistence and a pre-set PIN hash.
    /// Used for persistence tests that also require parent management access.
    ///
    /// - Parameter hash: SHA-256 hex string for the desired PIN.
    /// - Returns: The launched `XCUIApplication` instance.
    @discardableResult
    static func launchWithPersistenceAndPIN(_ hash: String = TestConstants.pin1234Hash) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = AppLauncher.localeArgs + ["--preset-pin-hash", hash]
        // Intentionally NO --uitesting so the real on-disk store is used.
        app.launch()
        return app
    }
}

// MARK: - XCUIApplication convenience extensions

extension XCUIApplication {

    /// Terminates the app (if running) and re-launches with the same arguments.
    func relaunch() {
        terminate()
        launch()
    }
}

// MARK: - XCUIElement helpers

extension XCUIElement {

    /// Asserts that the element's touch target meets the minimum size requirement.
    ///
    /// - Parameter minimumPts: Minimum dimension in points (both width and height).
    ///   For child-facing elements this is 60pt (REQ-001, REQ-005).
    ///   For parent-facing elements the standard iOS minimum of 44pt applies.
    func assertMinTouchTarget(_ minimumPts: CGFloat,
                               file: StaticString = #file,
                               line: UInt = #line) {
        let elementFrame = frame
        XCTAssertGreaterThanOrEqual(
            elementFrame.width,
            minimumPts,
            "Element '\(identifier)' width \(elementFrame.width)pt is below minimum \(minimumPts)pt",
            file: file,
            line: line
        )
        XCTAssertGreaterThanOrEqual(
            elementFrame.height,
            minimumPts,
            "Element '\(identifier)' height \(elementFrame.height)pt is below minimum \(minimumPts)pt",
            file: file,
            line: line
        )
    }

    /// Waits for the element to exist and asserts it does, failing with a clear message if not.
    @discardableResult
    func assertExists(timeout: TimeInterval = 5,
                      file: StaticString = #file,
                      line: UInt = #line) -> XCUIElement {
        XCTAssertTrue(
            waitForExistence(timeout: timeout),
            "Expected element '\(identifier)' to exist within \(timeout)s",
            file: file,
            line: line
        )
        return self
    }

    /// Returns true if the element's accessibility value equals the given string.
    func hasAccessibilityValue(_ value: String) -> Bool {
        return (self.value as? String) == value
    }
}

// MARK: - XCUIApplication row element helpers

extension XCUIApplication {

    /// Finds a tappable row element by accessibility identifier, searching across
    /// cells, buttons, and generic descendants. SwiftUI List rows may render as
    /// Cell or Button depending on the element type (NavigationLink vs plain row)
    /// and iOS version. This helper abstracts over those differences.
    ///
    /// Supports `waitForExistence`, `tap()`, and all other XCUIElement APIs.
    func row(_ identifier: String) -> XCUIElement {
        // Use descendants(matching: .any) which finds the element regardless
        // of its type (Cell, Button, Other, etc.). firstMatch avoids ambiguity
        // when SwiftUI applies the identifier to both a container and its child.
        return descendants(matching: .any).matching(identifier: identifier).firstMatch
    }
}
