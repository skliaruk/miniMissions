# REQ-005: iPad Layout and Accessibility

**Status:** Approved
**Priority:** Must
**Effort:** S

## Description

The app runs exclusively on iPad. The UI must be optimised for iPad landscape orientation and meet WCAG 2.2 AA accessibility requirements. The child-facing view must additionally accommodate the physical and cognitive abilities of children aged 2–6.

## User Story

As a parent, I want the app to work perfectly on our iPad and be accessible to all my children, including those with visual or motor differences.

## Details

### Platform
- **Target platform:** iPadOS 17+
- **Supported devices:** iPad mini, iPad (standard), iPad Air, iPad Pro (all screen sizes)
- **Primary orientation:** Landscape (locked)
- Portrait orientation is not supported

### Child-Facing Accessibility (ages 2–6)
- Minimum touch target size: **60×60pt** (exceeds standard WCAG 44pt for small motor skills)
- All tasks represented with **icons as primary content** — children who cannot read can use the app independently
- Font size minimum **24pt** for child-facing labels
- High contrast colours — minimum **4.5:1** for text, **3:1** for UI elements
- No time-limited interactions (no timeouts, no swipe gestures required)

### Standard WCAG 2.2 AA
- All interactive elements have VoiceOver accessibility labels and hints
- Colour is never the sole means of conveying information
- Dynamic Type supported — all text scales correctly
- Reduce Motion respected — no mandatory animations
- All images have meaningful alternative text descriptions

### Persistence
- Task completion state persists if the app is backgrounded and resumed
- Task completion state persists across app restarts until manually reset (REQ-004)
- Parent settings (task list, PIN) persist across app restarts using SwiftData

## Acceptance Criteria

1. App runs in landscape orientation on all supported iPad sizes without layout breakage
2. Portrait orientation is locked — rotating the device does not change layout
3. All child-facing touch targets are ≥ 60×60pt (verified via XCUITest frame)
4. All text in child-facing view is ≥ 24pt
5. Colour contrast ratios meet WCAG 2.2 AA (4.5:1 text, 3:1 UI)
6. All interactive elements have VoiceOver labels (verified via XCUITest accessibility)
7. Task completion state survives app backgrounding and foreground return
8. Task completion state survives app restart (until reset)
9. Parent settings survive app restart

## E2E Test Requirements

- Landscape lock: rotating device does not alter layout (XCUITest)
- Touch target sizes ≥ 60×60pt for all child-facing buttons (XCUITest frame assertions)
- VoiceOver labels present on all interactive elements (XCUITest accessibilityLabel)
- State persistence: complete a task, background app, relaunch, task still shows done (XCUITest)
- Settings persistence: add a task, relaunch app, task still exists (XCUITest)
