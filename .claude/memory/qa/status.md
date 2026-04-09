# QA Memory - Test Coverage Status

## Last Updated: 2026-04-09

## Test Files

| File | Target | Test Count | Status |
|------|--------|-----------|--------|
| RoutineViewUITests.swift | UITests | 14 | Existing |
| ParentalGateUITests.swift | UITests | TBD | Existing |
| ParentManagementUITests.swift | UITests | 12 | Existing |
| AccessibilityUITests.swift | UITests | TBD | Existing |
| TopicCategoriesUITests.swift | UITests | TBD | Existing |
| DynamicChildrenUITests.swift | UITests | 10 | Red (not in pbxproj) |
| TaskBankUITests.swift | UITests | 24 | Red (TDD Red Phase) |
| DailyResetUITests.swift | UITests | 3 | Red (TDD Red Phase) |
| CopyTasksUITests.swift | UITests | 5 | Red (TDD Red Phase) |
| PINServiceTests.swift | UnitTests | TBD | Existing |
| SeedDataServiceTests.swift | UnitTests | TBD | Existing |

## REQ: Automatic Daily Reset Tests (DailyResetUITests.swift)

### Class: DailyResetUITests (3 tests)
- testDailyResetClearsCompletionsOnNewDay — completes a task, relaunches with --resetDateYesterday, verifies task is cleared
- testDailyResetDoesNotClearOnSameDay — completes a task, backgrounds/foregrounds on same day, verifies task stays done
- testDailyResetRunsOnFirstLaunch — fresh launch with no stored date, verifies all tasks are in "not done" state

### Infrastructure changes
- AppLauncher.swift: added `launchWithResetDateYesterday()` method
- AppEnvironment.swift: added `resetDateYesterday: Bool` property and `--resetDateYesterday` argument parsing
- MorningRoutineApp.swift: added `--resetDateYesterday` handling in init() to set UserDefaults lastDailyResetDate to yesterday
- project.pbxproj: added DailyResetUITests.swift with FC000012 / AC000012

## REQ-008 Task Bank Tests (TaskBankUITests.swift)

### Class 1: TaskBankCRUDUITests (8 tests)
- testTaskBankSectionVisibleOnParentHome (TB-AC-01)
- testEmptyTaskBankShowsPlaceholder (TB-AC-22)
- testCreateTaskTemplate (TB-AC-02)
- testTemplateNameMaxThirtyChars (TB-AC-03)
- testSaveButtonDisabledWhenNameEmpty (TB-AC-04)
- testEditTaskTemplate (TB-AC-05)
- testDeleteTaskTemplateWithConfirmation (TB-AC-07)
- testDeleteTemplateRemovesItFromBank (TB-AC-08 partial)

### Class 2: TaskBankAssignmentUITests (10 tests)
- testTaskEditorShowsAddFromBankButton (TB-AC-09)
- testEmptyTaskEditorShowsPlaceholder (TB-AC-23)
- testAssignTemplateToChild (TB-AC-10, TB-AC-13)
- testBankSelectorShowsAllTemplates (TB-AC-10)
- testAlreadyAssignedTemplateShowsAssignedBadge (TB-AC-11)
- testMultiSelectTemplatesForAssignment (TB-AC-12)
- testUnassignTemplateFromChild (TB-AC-14)
- testUnassignDoesNotDeleteFromBank (TB-AC-15)
- testBankSelectorSearchFiltersTemplates (TB-AC-24)
- testCreateNewTemplateFromBankSelector (TB-AC-25)

### Class 3: TaskBankRoutineViewUITests (6 tests)
- testAssignedTaskAppearsInRoutineView (AC-10)
- testEditingTemplateUpdatesRoutineView (TB-AC-06)
- testDeletingTemplateRemovesFromRoutineView (TB-AC-08)
- testSameTemplateTwoChildren (TB-AC-18)
- testCompletionIndependentPerChild (TB-AC-20)
- testSameTemplateInTwoTopics (TB-AC-19)

## Copy Tasks Feature Tests (CopyTasksUITests.swift)

### Class: CopyTasksUITests (5 tests)
- testCopyButtonVisibleWhenOtherChildrenHaveTasks — AC1: Copy button visible when other children have tasks in same topic
- testCopyButtonHiddenWhenNoOtherChildrenHaveTasks — AC2: Copy button hidden when no other children have tasks
- testCopyingBringsAllTemplatesFromSourceChild — AC3: All templates from source child copied to target
- testAlreadyAssignedTemplatesAreNotDuplicated — AC4: Already-assigned templates skipped during copy
- testCopyingDoesNotRemoveTasksFromSourceChild — AC5: Source child's tasks remain after copy

### Infrastructure changes
- AccessibilityIdentifiers.swift: added copyFromButton, copySourceChildRow(_:), copySourceConfirmButton, copySourceCancelButton in AX.TaskAssignment
- project.pbxproj: added CopyTasksUITests.swift with FC000013 / AC000013

## Known Issues

- DynamicChildrenUITests.swift exists on disk but is NOT in the pbxproj file.
  It is not compiled or run. Needs to be added to the Xcode project.

## Build Status

- DailyResetUITests.swift: BUILD SUCCEEDED (compiles, tests expected to pass if implementation exists)
- TaskBankUITests.swift: BUILD SUCCEEDED (compiles, tests will fail at runtime - TDD Red)
- CopyTasksUITests.swift: BUILD SUCCEEDED (compiles, tests will fail at runtime - TDD Red)
