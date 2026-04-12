# QA Memory - Test Coverage Status

## Last Updated: 2026-04-10

## Test Count Summary

| Target | Count |
|--------|-------|
| MiniMissionsUITests (UI/E2E) | ~122 |
| MiniMissionsTests (Unit) | 6 |
| **Total** | **~128** |
| Unit test ratio | ~4.7% (limit: 25%) -- OK |

## Build Status

TEST BUILD SUCCEEDED (2026-04-10) after fixing all broken tests.

## Fixes Applied (2026-04-10 session 2)

### Category 1: VoiceOver label language mismatch
AppLauncher forces Finnish locale (`-AppleLanguages fi`), so all accessibility labels are in Finnish.
Updated all hardcoded English label comparisons in tests:
- "Parent Settings" -> "Vanhempien asetukset" (RoutineViewUITests, AccessibilityUITests)
- "<Name>'s tasks" -> "<Name>:n tehtavat" (RoutineViewUITests, AccessibilityUITests)
- `.contains("task")` -> `.contains("tehtava") || .contains("valmis")` (AccessibilityUITests progress indicator)

### Category 2: Keychain pollution for first-launch tests
Added `--clear-keychain` launch argument support:
- AppEnvironment.swift: added `clearKeychain: Bool` property and parser
- MiniMissionsApp.swift: calls `KeychainStore.shared.deletePINHash()` when `clearKeychain == true`
- AppLauncher.launchFirstLaunch(): includes `--clear-keychain` in launch arguments
- ParentalGateUITests: changed `routineRoot.exists` -> `routineRoot.isHittable` assertions (ChildRoutineView always exists behind fullScreenCover)

### Category 3: Tab bar and routine view require children
TopicTabBarUITests was using `launchClean()` which has no children (empty state, no tab bar).
- Changed setUp to use `launchWithPIN()` and add a child via `addChildViaParentManagement(name:)`
- Added `addChildViaParentManagement` helper method to TopicTabBarUITests
- Fixed `addTopicViaParentManagement` to not re-launch app (would lose in-memory children)

### Category 4: UI structure identifier mismatch
App's AccessibilityIdentifiers.swift used plain names (e.g. "addTopicButton") while tests expected prefixed names (e.g. "parentMgmt_addTopicButton").
Updated app's TopicManagement identifiers to match test expectations:
- addTopicButton, addTopicConfirmButton, addTopicCancelButton, addTopicNameField
- renameTopicConfirmButton, renameTopicCancelButton, renameTopicNameField
- deleteTopicConfirmButton, deleteTopicCancelButton
- resetAllButton, resetAllConfirmButton, resetAllCancelButton

### Spot-check results (all passed)
- MiniMissionsUITests/RoutineViewUITests/testParentEntryButtonHasVoiceOverLabel -- PASSED
- MiniMissionsUITests/ParentalGateUITests/testFirstLaunchShowsPINSetupScreen -- PASSED
- MiniMissionsUITests/TopicTabBarUITests/testTabBarIsVisibleOnLaunch -- PASSED
- MiniMissionsUITests/TaskBankCRUDUITests/testTaskBankSectionVisibleOnParentHome -- PASSED

## Test Files

| File | Target | Status |
|------|--------|--------|
| RoutineViewUITests.swift | UITests | FIXED -- Finnish locale labels |
| ParentalGateUITests.swift | UITests | FIXED -- clear-keychain + isHittable assertions |
| ParentManagementUITests.swift | UITests | OK |
| AccessibilityUITests.swift | UITests | FIXED -- Finnish locale labels |
| TopicCategoriesUITests.swift | UITests | FIXED -- TopicTabBarUITests adds child in setUp |
| DynamicChildrenUITests.swift | UITests | OK |
| TaskBankUITests.swift | UITests | FIXED -- identifier mismatch resolved |
| DailyResetUITests.swift | UITests | OK |
| CopyTasksUITests.swift | UITests | OK |
| PINServiceTests.swift | UnitTests | OK |
| SeedDataServiceTests.swift | UnitTests | OK |

## Known Issues (remaining)

1. **AX.ChildNames is stale** -- references old fixed children; could be removed or repurposed
2. **REQ-009 (Localization) has 0 tests**
3. **REQ-010 (Freemium) has 0 tests**

## Missing Test Coverage

| REQ | Missing |
|-----|---------|
| REQ-002 AC-2 | Star animation existence test |
| REQ-002 AC-7 | Done vs not-done visual distinction (non-color) |
| REQ-008 AC-9 | Per-child-per-topic sort order test |
| REQ-009 (Localization) | All ACs (1-6) |
| REQ-010 (Freemium) | All ACs (1-9) |
