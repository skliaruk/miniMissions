# ADR-004: Testability and E2E Test Architecture

**Status:** Accepted
**Date:** 2026-03-26
**Deciders:** ARCH

## Context

All five REQ documents specify XCUITest E2E test requirements. The QA agent must be able to write and run these tests:
- Without mocking app internals
- Against a real, running app process
- With a reproducible, isolated state per test
- Verifying real SwiftData persistence, real PIN gate behaviour, and real animation state

The architecture must support this from day one. Testability is not an afterthought.

Key testing challenges:
1. SwiftData store must start clean for each test (no leftover data from previous tests)
2. PIN gate must be bypassable for tests that do not target PIN functionality
3. First-launch PIN setup flow must be skippable or triggerable on demand
4. Reduce Motion state must be controllable per test (REQ-002, REQ-005)
5. Accessibility identifiers must be consistent and complete to make XCUITest queries reliable

## Decision

### 1. Dependency Injection via `AppEnvironment`

The app uses a value-type `AppEnvironment` struct injected into the SwiftUI environment at the root. All environment-dependent behaviour is driven by this struct.

```swift
struct AppEnvironment {
    var useInMemoryStore: Bool = false
    var skipPINSetup: Bool = false
    var presetPINHash: String? = nil    // If set, KeychainStore is pre-populated with this hash
    var reduceMotion: Bool = false      // Overrides UIAccessibility.isReduceMotionEnabled
    var fixedDate: Date? = nil          // Reserved for future date-dependent tests

    static let live = AppEnvironment()

    static func fromLaunchArguments(_ args: [String]) -> AppEnvironment {
        var env = AppEnvironment()
        if args.contains("--uitesting") {
            env.useInMemoryStore = true
        }
        if args.contains("--skip-pin-setup") {
            env.skipPINSetup = true
        }
        if args.contains("--reduce-motion") {
            env.reduceMotion = true
        }
        if let pinIndex = args.firstIndex(of: "--preset-pin-hash"),
           args.indices.contains(pinIndex + 1) {
            env.presetPINHash = args[pinIndex + 1]
        }
        return env
    }
}
```

#### SwiftUI Environment Key

```swift
private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue = AppEnvironment.live
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
```

#### Injection in `TaskApp.swift`

```swift
@main
struct TaskApp: App {
    private let environment = AppEnvironment.fromLaunchArguments(
        ProcessInfo.processInfo.arguments
    )

    var body: some Scene {
        WindowGroup {
            ContentRootView()
                .environment(\.appEnvironment, environment)
                .modelContainer(makeContainer(environment: environment))
        }
    }

    private func makeContainer(environment: AppEnvironment) -> ModelContainer {
        let schema = Schema([Child.self, Task.self, TaskCompletion.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: environment.useInMemoryStore
        )
        let container = try! ModelContainer(for: schema, configurations: [config])
        SeedDataService.seedIfNeeded(context: container.mainContext)
        if let hash = environment.presetPINHash {
            try? KeychainStore.shared.savePINHash(hash)
        }
        return container
    }
}
```

### 2. Launch Arguments Contract

The following launch arguments are the **official test interface** between QA (XCUITest) and the app. QA must not rely on any other mechanism.

| Launch Argument | Effect |
|---|---|
| `--uitesting` | Uses in-memory SwiftData store (clean per launch); no data persists between test methods |
| `--skip-pin-setup` | Suppresses first-launch PIN setup screen; app goes directly to `ChildRoutineView` |
| `--preset-pin-hash <hash>` | Pre-populates Keychain with this hash so PIN gate tests start with a known PIN |
| `--reduce-motion` | Sets `AppEnvironment.reduceMotion = true`; all views read this instead of `UIAccessibility.isReduceMotionEnabled` |

#### Usage in XCUITest

```swift
// XCUITest example — standard setup
let app = XCUIApplication()
app.launchArguments = ["--uitesting", "--skip-pin-setup"]
app.launch()

// XCUITest example — PIN gate tests
let app = XCUIApplication()
let knownPINHash = SHA256.hash("app-salt-1234") // same salt as production
app.launchArguments = ["--uitesting", "--preset-pin-hash", knownPINHash]
app.launch()

// XCUITest example — Reduce Motion
let app = XCUIApplication()
app.launchArguments = ["--uitesting", "--skip-pin-setup", "--reduce-motion"]
app.launch()
```

**IMPORTANT — PIN hash constant for tests:**
The SHA-256 hash of PIN `"1234"` with the fixed app salt (`"taskapp.pin.salt.v1"`) must be documented as a test constant in `TaskAppUITests/TestConstants.swift`:

```swift
// TestConstants.swift
enum TestConstants {
    /// PIN "1234" hashed with app salt — use with --preset-pin-hash for PIN gate tests
    static let pin1234Hash = "..." // pre-computed value documented at implementation time
    static let testPIN = "1234"
}
```

### 3. `ContentRootView` — PIN Setup Gate

`ContentRootView` wraps `ChildRoutineView` and handles first-launch PIN setup:

```swift
struct ContentRootView: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @State private var isPINSetupRequired = false

    var body: some View {
        ChildRoutineView()
            .fullScreenCover(isPresented: $isPINSetupRequired) {
                PINSetupView()
            }
            .onAppear {
                guard !appEnvironment.skipPINSetup else { return }
                isPINSetupRequired = KeychainStore.shared.loadPINHash() == nil
            }
    }
}
```

When `--skip-pin-setup` is passed, `isPINSetupRequired` stays `false` and the routine view is shown directly. This is the mechanism that allows all non-PIN tests to bypass the setup flow.

### 4. Accessibility Identifier Strategy

All XCUITest queries use `accessibilityIdentifier` values. Identifiers follow a **module-prefix dot-notation** scheme:

#### Scheme

```
<module>_<component>[_<qualifier>]
```

- `module`: short name of the feature (`childRoutine`, `parentMgmt`, `pinGate`, `taskEditor`)
- `component`: the UI element type or purpose (`column`, `taskRow`, `completeButton`, etc.)
- `qualifier`: disambiguator when there are multiple instances (`childIndex`, `taskName`, etc.)

#### Child Routine View

| Element | Accessibility Identifier |
|---|---|
| Root container | `childRoutine_root` |
| Child column (index 0–2) | `childRoutine_column_0`, `childRoutine_column_1`, `childRoutine_column_2` |
| Child name label (index 0–2) | `childRoutine_childName_0`, `childRoutine_childName_1`, `childRoutine_childName_2` |
| Task row (childIndex, taskIndex) | `childRoutine_taskRow_<childIndex>_<taskIndex>` |
| Task completion button | `childRoutine_taskButton_<childIndex>_<taskIndex>` |
| Parent entry gear button | `childRoutine_parentEntryButton` |
| Celebration view (per child) | `childRoutine_celebrationView_<childIndex>` |
| Star animation view | `childRoutine_starAnimation_<childIndex>_<taskIndex>` |

#### PIN Gate View

| Element | Accessibility Identifier |
|---|---|
| PIN entry view root | `pinGate_root` |
| PIN digit field | `pinGate_digitField_<0-3>` |
| Submit button | `pinGate_submitButton` |
| Error message | `pinGate_errorMessage` |
| Lockout countdown label | `pinGate_lockoutCountdown` |
| PIN setup root | `pinSetup_root` |
| PIN setup confirm button | `pinSetup_confirmButton` |

#### Parent Management View

| Element | Accessibility Identifier |
|---|---|
| Root container | `parentMgmt_root` |
| Child row (index 0–2) | `parentMgmt_childRow_0`, `parentMgmt_childRow_1`, `parentMgmt_childRow_2` |
| Reset day button | `parentMgmt_resetDayButton` |
| Reset confirmation button | `parentMgmt_resetConfirmButton` |
| Reset cancel button | `parentMgmt_resetCancelButton` |
| Add task button | `parentMgmt_addTaskButton` |
| Task row in editor | `parentMgmt_taskEditorRow_<taskIndex>` |
| Delete task button | `parentMgmt_deleteTaskButton_<taskIndex>` |
| Delete confirm button | `parentMgmt_deleteConfirmButton` |
| Task name field | `taskEditor_nameField` |
| Save / done button | `taskEditor_saveButton` |
| Change PIN button | `parentMgmt_changePINButton` |

#### Setting Accessibility Identifiers in Code

Identifiers are set via `.accessibilityIdentifier(_:)` modifier in SwiftUI:

```swift
// Example in ChildColumnView
VStack {
    // ...
}
.accessibilityIdentifier("childRoutine_column_\(child.sortOrder)")
```

For dynamic identifiers (child index, task index), the index is always the `sortOrder` from the SwiftData model — this ensures XCUITest queries are stable and order-independent.

### 5. Reduce Motion in Views

All views read motion preference from `AppEnvironment` rather than directly from `UIAccessibility`:

```swift
struct StarAnimationView: View {
    @Environment(\.appEnvironment) private var appEnvironment

    var body: some View {
        if appEnvironment.reduceMotion {
            // Static highlight — no motion
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .accessibilityIdentifier("childRoutine_starAnimation_\(childIndex)_\(taskIndex)")
                // Note: when reduceMotion is true, the animation container is NOT rendered
                // XCUITest verifies absence of animation element via --reduce-motion flag
        } else {
            // Full star animation
            StarBurstAnimationView(...)
                .accessibilityIdentifier("childRoutine_starAnimation_\(childIndex)_\(taskIndex)")
        }
    }
}
```

**XCUITest pattern for Reduce Motion assertion:**
```swift
// Verify animation element is absent under reduce motion
XCTAssertFalse(app.otherElements["childRoutine_starBurstAnimation"].exists)
```

The static highlight uses a different identifier suffix (`starAnimation`) than the motion version (`starBurstAnimation`), allowing XCUITest to assert presence/absence of each independently.

### 6. Test Target Structure

```
TaskAppUITests/
├── TestConstants.swift           # Known PIN hashes, shared constants
├── Helpers/
│   ├── AppLauncher.swift         # Convenience wrappers for app.launchArguments combos
│   └── XCUIElement+Helpers.swift # waitForExistence, assertMinTouchTarget(60), etc.
├── ChildRoutineTests.swift       # REQ-001, REQ-002 E2E tests
├── PINGateTests.swift            # REQ-003 E2E tests
├── ParentManagementTests.swift   # REQ-004 E2E tests
└── AccessibilityTests.swift      # REQ-005 accessibility and layout tests
```

#### `AppLauncher` Helper

```swift
struct AppLauncher {
    static func launchStandard() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--skip-pin-setup"]
        app.launch()
        return app
    }

    static func launchWithPIN(_ pin: String = TestConstants.testPIN) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--preset-pin-hash", TestConstants.pin1234Hash]
        app.launch()
        return app
    }

    static func launchReducedMotion() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--skip-pin-setup", "--reduce-motion"]
        app.launch()
        return app
    }

    static func launchFirstLaunch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]  // No --skip-pin-setup, no --preset-pin-hash
        app.launch()
        return app
    }
}
```

### 7. No Mocks Required — Design Justification

The architecture achieves full E2E test coverage without mocking because:

1. **In-memory SwiftData store** (`--uitesting`) gives each test a clean database without needing a mock database layer
2. **`--preset-pin-hash`** injects a known PIN into the real Keychain, so PIN gate tests use the real `KeychainStore` implementation
3. **`--skip-pin-setup`** skips the first-launch flow by controlling the real app state, not replacing it with a mock
4. **`--reduce-motion`** controls real view rendering decisions, not injected fake accessibility state
5. **`SeedDataService`** ensures a predictable baseline data state after every clean launch (3 children, no tasks by default)

There is no protocol-swapping, no fake service injection, and no stub data files. Tests exercise the real code path from UI tap to SwiftData persistence and back.

## Rationale

### Why launch arguments instead of test-only URL schemes or XPC?

Launch arguments are the simplest, most maintainable test-environment mechanism in iOS E2E testing. They are:
- Visible in the XCUITest target without any special entitlements
- Documented in one place (`AppEnvironment.fromLaunchArguments`)
- Zero-overhead in production (non-`--uitesting` builds use `AppEnvironment.live`)
- Standard practice on the Apple platform (Apple's own guidelines recommend this pattern)

### Why not `@testable import` and unit-test the views?

Unit tests with `@testable import` test logic in isolation but do not verify the end-to-end behaviour described in the REQ acceptance criteria. XCUITest exercises the real binary, real SwiftData, real layout, and real accessibility tree — which is what the REQ E2E test requirements specify. Unit tests complement XCUITest for logic-heavy ViewModels but cannot replace it.

### Why accessibility identifiers rather than accessibility labels for test queries?

Accessibility labels are user-visible and subject to localisation, Dynamic Type, and VoiceOver customisation. Accessibility identifiers are developer-only, never shown to users, and stable across localisation and accessibility settings. Querying by identifier makes tests robust.

### Alternatives Considered

| Alternative | Rejected Reason |
|---|---|
| Mock services via protocol injection | Adds abstraction layers not needed for production; tests the mock, not the real system |
| Separate test scheme with different source files | Risk of test-only code diverging from production code; harder to maintain |
| XCTest `setUp` via URL scheme | Requires additional app handling code; launch arguments are simpler and standard |
| Snapshot testing | Does not verify interactive behaviour (task tap → state change); supplements but does not replace XCUITest |

## Consequences

**Positive:**
- QA can write tests before MDEV implements views — just agree on accessibility identifiers from this document
- No mocking means bugs in the real code path are caught, not hidden
- `AppLauncher` helper eliminates boilerplate from every test method
- Clean in-memory store per test ensures test isolation without test ordering dependencies

**Negative:**
- XCUITest is slower than unit tests — full app launch per test method
- `--preset-pin-hash` writes to the real Keychain on the test device; tests must use a well-known PIN to avoid Keychain pollution (mitigated: `--uitesting` flag should trigger Keychain cleanup in `AppEnvironment` setup)
- Accessibility identifier maintenance: if a view is restructured, identifiers may need updating (mitigated: centralise identifier strings in a `AccessibilityIdentifiers.swift` constants file)

### `AccessibilityIdentifiers.swift` — Centralised Constants

To prevent identifier drift between implementation and tests, all identifiers are defined in a single file shared by both the app target and the UI test target:

```swift
// AccessibilityIdentifiers.swift — included in BOTH app target and UITest target
enum AX {
    enum ChildRoutine {
        static let root = "childRoutine_root"
        static func column(_ index: Int) -> String { "childRoutine_column_\(index)" }
        static func childName(_ index: Int) -> String { "childRoutine_childName_\(index)" }
        static func taskRow(_ childIndex: Int, _ taskIndex: Int) -> String {
            "childRoutine_taskRow_\(childIndex)_\(taskIndex)"
        }
        static func taskButton(_ childIndex: Int, _ taskIndex: Int) -> String {
            "childRoutine_taskButton_\(childIndex)_\(taskIndex)"
        }
        static let parentEntryButton = "childRoutine_parentEntryButton"
        static func celebrationView(_ childIndex: Int) -> String {
            "childRoutine_celebrationView_\(childIndex)"
        }
    }

    enum PINGate {
        static let root = "pinGate_root"
        static func digitField(_ index: Int) -> String { "pinGate_digitField_\(index)" }
        static let submitButton = "pinGate_submitButton"
        static let errorMessage = "pinGate_errorMessage"
        static let lockoutCountdown = "pinGate_lockoutCountdown"
        static let setupRoot = "pinSetup_root"
        static let setupConfirmButton = "pinSetup_confirmButton"
    }

    enum ParentManagement {
        static let root = "parentMgmt_root"
        static func childRow(_ index: Int) -> String { "parentMgmt_childRow_\(index)" }
        static let resetDayButton = "parentMgmt_resetDayButton"
        static let resetConfirmButton = "parentMgmt_resetConfirmButton"
        static let resetCancelButton = "parentMgmt_resetCancelButton"
        static let addTaskButton = "parentMgmt_addTaskButton"
        static func taskEditorRow(_ index: Int) -> String { "parentMgmt_taskEditorRow_\(index)" }
        static func deleteTaskButton(_ index: Int) -> String {
            "parentMgmt_deleteTaskButton_\(index)"
        }
        static let deleteConfirmButton = "parentMgmt_deleteConfirmButton"
        static let changePINButton = "parentMgmt_changePINButton"
    }

    enum TaskEditor {
        static let nameField = "taskEditor_nameField"
        static let saveButton = "taskEditor_saveButton"
    }
}
```

This file is added to both the `TaskApp` target and the `TaskAppUITests` target in Xcode. The app sets identifiers using `AX.ChildRoutine.column(child.sortOrder)` and tests query using the same expression.

## Acceptance Criteria Impact

| REQ | Criteria | Testability Mechanism |
|---|---|---|
| REQ-001 | Routine view is first screen | `AppLauncher.launchStandard()` → assert `childRoutine_root` exists |
| REQ-001 | All 3 columns present | Assert `childRoutine_column_0`, `_1`, `_2` exist |
| REQ-001 | Touch targets ≥ 60pt | `XCUIElement+Helpers.assertMinTouchTarget(60)` on task buttons |
| REQ-002 | Task tap → done state | Tap `taskButton`, assert accessibility value changes to "completed" |
| REQ-002 | Done task not re-tappable | Tap again, assert no state change |
| REQ-002 | Celebration on all done | Tap all task buttons, assert `celebrationView_N` exists |
| REQ-002 | Reduce Motion removes animation | `AppLauncher.launchReducedMotion()` → assert burst element absent |
| REQ-003 | First-launch PIN setup | `AppLauncher.launchFirstLaunch()` → assert `pinSetup_root` exists |
| REQ-003 | Correct PIN grants access | `AppLauncher.launchWithPIN()` → enter "1234" → assert `parentMgmt_root` |
| REQ-003 | Wrong PIN shows error | Enter wrong PIN → assert `pinGate_errorMessage` |
| REQ-003 | 3 wrong PINs → lockout | Enter wrong PIN ×3 → assert `pinGate_lockoutCountdown` |
| REQ-004 | Add task appears in routine view | Add task in parent mgmt → navigate back → assert task row exists |
| REQ-004 | Reset day clears all tasks | Tap some tasks done → reset → assert no task button has "completed" state |
| REQ-005 | State persists across restart | Complete task → relaunch with same store → task still done |
| REQ-005 | VoiceOver labels present | Assert `accessibilityLabel` non-empty on all interactive elements |
