# REQ-003: Parental Gate

**Status:** Approved
**Priority:** Must
**Effort:** S

## Description

Parent management features must be protected behind a parental gate so that children cannot accidentally access or modify settings. The gate must be simple enough for a parent to pass quickly but effectively block a 2–6 year old.

## User Story

As a parent, I want management features to be protected so that my children cannot change their task lists or reset routines by accident.

## Details

- A **parental gate** is required before entering any parent management screen
- Gate mechanism: a **4-digit PIN** set by the parent on first launch
- On first launch, the parent is prompted to set a PIN before anything else
- The PIN entry screen must:
  - Be clearly adult-oriented (no child-friendly visuals)
  - Show no hint of what is behind it to the child
  - Allow **3 failed attempts** before a 30-second lockout
- The gate is triggered by a **parent-only entry point** on the main screen (e.g. a small gear icon in a corner, not prominent)
- PIN can be changed from within the parent management screen (requires current PIN)
- There is no PIN recovery mechanism in this version (parent must delete and reinstall the app)

## Acceptance Criteria

1. On first launch, the app prompts the parent to set a 4-digit PIN before showing the routine view
2. The parent entry point is visible on the main screen but not prominent (small icon, not labeled with text)
3. Tapping the parent entry point shows the PIN entry screen
4. Entering the correct PIN navigates to the parent management screen
5. Entering an incorrect PIN shows an error and increments a failure counter
6. After 3 incorrect attempts, PIN entry is disabled for 30 seconds with a countdown shown
7. PIN can be changed from within parent management (requires entering current PIN first)

## E2E Test Requirements

- First-launch PIN setup flow completes and persists across app restarts (XCUITest)
- Correct PIN grants access to parent management (XCUITest)
- Incorrect PIN shows error and does not grant access (XCUITest)
- Three incorrect attempts trigger lockout with countdown (XCUITest)
- PIN change flow works correctly (XCUITest)
