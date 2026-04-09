# DSGN-003: Parent Management View

**Status:** Draft
**Date:** 2026-03-26
**REQ:** REQ-003, REQ-004, REQ-005

---

## Overview

The Parent Management View covers all screens accessible only to adults: PIN setup (first launch), PIN entry gate, the parent home screen, and the task editor. These screens solve the problem of parents needing to configure and maintain their children's task lists without risking children accidentally modifying them.

Parent-facing screens are deliberately functional and adult-oriented. They follow standard iOS HIG patterns without the child-friendly visual embellishments of the routine view. The visual language communicates "this is for grown-ups" — dark PIN screen, system-grey management screens, standard iOS controls.

---

## User Flow Overview

```
App First Launch
      |
      v
[First-Launch PIN Setup Screen]
      |
      v (PIN confirmed)
[Morning Routine View] <--- normal app entry point
      |
      | (tap gear icon)
      v
[PIN Entry Screen]
      |
      +-- wrong PIN (up to 3x) --> [Error state] --> [Lockout if 3 failures]
      |
      +-- correct PIN
      v
[Parent Home Screen]
      |
      +-- tap child name --> [Task Editor Screen for that child]
      |                              |
      |                    [Add Task Sheet]
      |                    [Edit Task Sheet]
      |                    [Delete Confirmation Alert]
      |                    [Reorder mode]
      |
      +-- tap "Reset Day" --> [Reset Confirmation Alert] --> reset all / cancel
      |
      +-- tap "Change PIN" --> [Current PIN entry] --> [New PIN setup]
      |
      +-- tap "Done" / back --> return to [Morning Routine View]
```

---

## Screen 1: First-Launch PIN Setup

### Purpose
Shown only once: on the very first app launch before the routine view is ever displayed. Forces the parent to establish a PIN before a child can interact with the app.

### ASCII Wireframe

```
+-------------------------------------------------------------------------------------------+
|                                                                        [Status Bar]        |
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|                                                                                           |
|                         +-------------------------------+                                 |
|                         |                               |                                 |
|                         |   Morning Routine             |                                 |
|                         |   Set up parental PIN         |                                 |
|                         |   34pt, SF Pro Bold           |                                 |
|                         |   color.text.pinDigit (white) |                                 |
|                         |                               |                                 |
|                         |   Create a 4-digit PIN to     |                                 |
|                         |   protect parent settings.    |                                 |
|                         |   17pt, SF Pro, white 80%     |                                 |
|                         |                               |                                 |
|                         |      ●  ●  ●  ●               |                                 |
|                         |   (PIN input dots, 20pt dia)  |                                 |
|                         |                               |                                 |
|                         |   +---+  +---+  +---+         |                                 |
|                         |   | 1 |  | 2 |  | 3 |         |                                 |
|                         |   +---+  +---+  +---+         |                                 |
|                         |   +---+  +---+  +---+         |                                 |
|                         |   | 4 |  | 5 |  | 6 |         |                                 |
|                         |   +---+  +---+  +---+         |                                 |
|                         |   +---+  +---+  +---+         |                                 |
|                         |   | 7 |  | 8 |  | 9 |         |                                 |
|                         |   +---+  +---+  +---+         |                                 |
|                         |          +---+                 |                                 |
|                         |          | 0 |                 |                                 |
|                         |          +---+                 |                                 |
|                         |                               |                                 |
|                         |  [Delete last digit button]   |                                 |
|                         |                               |                                 |
|                         +-------------------------------+                                 |
|                                                                                           |
|         Full screen background: color.background.pinScreen (#1A1A2E)                     |
|                                                                                           |
+-------------------------------------------------------------------------------------------+
```

### Layout Details

- Full-screen background: `color.background.pinScreen` (#1A1A2E) — dark, adult-oriented, same in both light and dark system modes
- The setup card is centred horizontally and vertically
- Card width: 400pt, card height: auto (content-driven, ~520pt)
- Card background: `rgba(255,255,255,0.06)` — subtle frosted card effect
- Card corner radius: `radius.xl` (32pt)
- No card border in setup mode (full attention to the content)

### Setup Flow — Two Steps:

**Step 1 — Enter new PIN:**
- Title: "Create your PIN"
- Subtitle: "Enter a 4-digit PIN to protect parent settings"
- 4 dots unfilled, fill as digits are entered

**Step 2 — Confirm new PIN:**
- Title: "Confirm your PIN"
- Subtitle: "Enter the same PIN again"
- If confirmation matches → PIN saved to Keychain → routine view launches
- If confirmation does not match → both inputs cleared, error message shown: "PINs didn't match. Try again." in `color.text.error`, 150ms shake animation on dots

---

## Screen 2: PIN Entry Screen

### Purpose
Shown every time the parent taps the gear icon on the routine view. Guards all parent management functionality.

### ASCII Wireframe

```
+-------------------------------------------------------------------------------------------+
|                                                                        [Status Bar]        |
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|  [xmark button, 44×44pt, top-left, color.text.secondary]                                 |
|                                                                                           |
|                         +-------------------------------+                                 |
|                         |                               |                                 |
|                         |   Parent Settings             |                                 |
|                         |   Enter your PIN              |                                 |
|                         |   28pt, SF Pro Bold, white    |                                 |
|                         |                               |                                 |
|                         |      ○  ○  ○  ○               |                                 |
|                         |   (empty PIN dots, 20pt dia)  |                                 |
|                         |                               |                                 |
|                         |   [Error message area]        |                                 |
|                         |   "Incorrect PIN (2/3)"       |                                 |
|                         |   color.text.error, 15pt      |                                 |
|                         |   (hidden when no error)      |                                 |
|                         |                               |                                 |
|                         |   [LOCKOUT STATE SHOWN HERE]  |                                 |
|                         |   "Try again in 0:28"         |                                 |
|                         |   color.brand.orange, 22pt    |                                 |
|                         |                               |                                 |
|                         |   +---+  +---+  +---+         |                                 |
|                         |   | 1 |  | 2 |  | 3 |         |                                 |
|                         |   +---+  +---+  +---+         |                                 |
|                         |   +---+  +---+  +---+         |                                 |
|                         |   | 4 |  | 5 |  | 6 |         |                                 |
|                         |   +---+  +---+  +---+         |                                 |
|                         |   +---+  +---+  +---+         |                                 |
|                         |   | 7 |  | 8 |  | 9 |         |                                 |
|                         |   +---+  +---+  +---+         |                                 |
|                         |          +---+                 |                                 |
|                         |          | 0 |  [delete]       |                                 |
|                         |          +---+                 |                                 |
|                         |                               |                                 |
|                         +-------------------------------+                                 |
|                                                                                           |
|         Full screen background: color.background.pinScreen (#1A1A2E)                     |
|                                                                                           |
+-------------------------------------------------------------------------------------------+
```

### PIN Keypad Component

- Keypad grid: 3 columns × 4 rows (digits 1–9, then 0 centred in bottom row)
- Each key button:
  - Size: **80×80pt** (meets 44pt minimum, visually comfortable for adults on iPad)
  - Background: `rgba(255,255,255,0.12)` default, `rgba(255,255,255,0.30)` pressed
  - Corner radius: `radius.full` (circle — since 80pt height = radius 40pt)
  - Font: `type.parent.pinDigit` (48pt, SF Pro Bold, `#FFFFFF`)
  - Gap between keys: `spacing.sm` (12pt) horizontal, `spacing.sm` (12pt) vertical
- Delete button:
  - Position: bottom-right of keypad (replaces a potential 4th key in bottom row)
  - Icon: `delete.left.fill`, 24pt, `#FFFFFF`
  - Size: 80×80pt
  - `accessibilityLabel`: "Delete"
  - `accessibilityIdentifier`: `"pinDeleteButton"`

### PIN Dot Display

- 4 dots in a horizontal row, `spacing.md` (16pt) gap between dots
- Unfilled dot: 20pt diameter circle, border 2pt `color.border.pinDot` (#AEAEB2), fill transparent
- Filled dot: 20pt diameter circle, fill `#FFFFFF`
- Dots animate on fill: scale 0.5 → 1.0 spring (80ms, `easing.springFirm`). Reduce Motion: instant fill.
- `accessibilityLabel`: "PIN entry: [N] of 4 digits entered"
- `accessibilityIdentifier`: `"pinDotDisplay"`

### Error and Lockout States

**Error (1 or 2 wrong attempts):**
- Dots shake horizontally (±6pt, 3 oscillations, 300ms, `easing.standard`). Reduce Motion: instant red tint on dots.
- Dots immediately clear after shake
- Error label appears: "Incorrect PIN ([N]/3 attempts)"
- `accessibilityIdentifier`: `"pinErrorLabel"`
- `accessibilityLabel`: "Incorrect PIN. [N] of 3 attempts used."
- VoiceOver posts announcement: `UIAccessibility.post(notification: .announcement, argument: "Incorrect PIN. [N] attempts remaining.")`

**Lockout (3 wrong attempts):**
- All keypad buttons disabled (opacity 0.3)
- Error label replaced with: "Too many attempts. Try again in 0:30"
- Countdown ticks down in real time: `type.parent.countdown` (22pt, `color.brand.orange`)
- `accessibilityIdentifier`: `"pinLockoutLabel"`
- `accessibilityLabel`: "PIN entry locked. Try again in [N] seconds."
- VoiceOver posts announcement on lockout start
- When countdown reaches 0: keypad re-enables, attempt counter resets, lockout label hidden

### Dismiss Behaviour
- The `xmark` button in the top-left dismisses the PIN screen and returns to the routine view without granting access
- `accessibilityLabel`: "Cancel"
- `accessibilityIdentifier`: `"pinCancelButton"`

---

## Screen 3: Parent Home Screen

### Purpose
The landing screen after correct PIN entry. Shows all three children for task management, provides the Reset Day action, and access to PIN change.

### ASCII Wireframe

```
+-------------------------------------------------------------------------------------------+
| < Done                               Parent Settings              [Reset Day]            |
|  (44pt tap target)                   (Navigation Title)           (button, red)          |
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|  +-------------------------------------------------------------------+                   |
|  |  Children                                                          |                   |
|  |-------------------------------------------------------------------|                   |
|  |  [child1.avatar 40pt]   Child 1 Name           [N tasks]  >       |                   |
|  |-------------------------------------------------------------------|                   |
|  |  [child2.avatar 40pt]   Child 2 Name           [N tasks]  >       |                   |
|  |-------------------------------------------------------------------|                   |
|  |  [child3.avatar 40pt]   Child 3 Name           [N tasks]  >       |                   |
|  +-------------------------------------------------------------------+                   |
|                                                                                           |
|  +-------------------------------------------------------------------+                   |
|  |  Settings                                                          |                   |
|  |-------------------------------------------------------------------|                   |
|  |  [lock.fill 18pt]  Change PIN                              >       |                   |
|  +-------------------------------------------------------------------+                   |
|                                                                                           |
|  Background: color.background.parentScreen (#F2F2F7 / #1C1C1E)                           |
|  Uses standard iOS grouped list style                                                    |
+-------------------------------------------------------------------------------------------+
```

### Layout Details

- Navigation: `NavigationStack` with large title style
- Title: "Parent Settings" (`type.parent.largeTitle`, 34pt)
- Background: `color.background.parentScreen` (iOS system grouped background — `Color(.systemGroupedBackground)`)
- Content: iOS-style grouped `List` with two sections

**Navigation Bar Buttons:**
- Left: "Done" (`type.parent.headline`, 17pt, `color.brand.purple`)
  - `accessibilityIdentifier`: `"parentDoneButton"`
  - `accessibilityLabel`: "Done — return to routine view"
  - Dismisses parent management and returns to routine view
- Right: "Reset Day" (`type.parent.headline`, 17pt, `color.brand.red`)
  - `accessibilityIdentifier`: `"resetDayButton"`
  - `accessibilityLabel`: "Reset Day"`
  - `accessibilityHint`: "Marks all tasks as incomplete for all children"

**Children Section:**

Each child row:
- Height: 56pt minimum (standard iOS list row)
- Left: child avatar thumbnail, 40pt circle, `color.child{N}.accent` border 2pt
- Centre-left: child name (`type.parent.headline`, `color.text.primary`)
- Centre-right: task count label, e.g. "5 tasks" (`type.parent.subhead`, `color.text.secondary`)
- Right: disclosure indicator `chevron.right`
- `accessibilityIdentifier`: `"childRow_<ChildName>"`
- `accessibilityLabel`: `"<Child Name>, [N] tasks"`
- `accessibilityHint`: "Opens task editor for [Child Name]"

**Settings Section:**

Change PIN row:
- Left: `lock.fill` 18pt, `color.brand.purple`
- Label: "Change PIN" (`type.parent.headline`)
- Disclosure indicator
- `accessibilityIdentifier`: `"changePINRow"`
- `accessibilityLabel`: "Change PIN"
- `accessibilityHint`: "Opens PIN change flow"

### Reset Day Action

Tapping "Reset Day" in the navigation bar shows a confirmation action sheet (`.confirmationDialog` in SwiftUI):

```
+-----------------------------------------------+
|                                               |
|   Reset all tasks?                            |
|   This will mark all tasks for all children   |
|   as incomplete. This cannot be undone.       |
|                                               |
|   [ Reset Day ]   <- destructive, red         |
|   [ Cancel ]      <- cancel                   |
|                                               |
+-----------------------------------------------+
```

- Alert title: "Reset all tasks?"
- Alert message: "This will mark all tasks for all children as incomplete. This cannot be undone."
- Destructive button: "Reset Day" (`color.brand.red`)
- Cancel button: "Cancel"
- `accessibilityIdentifier` for destructive button: `"resetDayConfirmButton"`
- `accessibilityIdentifier` for cancel button: `"resetDayCancelButton"`

---

## Screen 4: Task Editor Screen

### Purpose
Shown when a parent taps a child row. Displays that child's full task list with add, edit, delete, and reorder capabilities.

### ASCII Wireframe

```
+-------------------------------------------------------------------------------------------+
| < Parent Settings         Mia's Tasks                          [+ Add Task]               |
|                           (Navigation Title)                                              |
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|  +-------------------------------------------------------------------+                   |
|  |  ≡  [icon 44pt]   Brush Teeth                        [pencil]  |  |                   |
|  |  ≡  [icon 44pt]   Get Dressed                        [pencil]  |  |                   |
|  |  ≡  [icon 44pt]   Eat Breakfast                      [pencil]  |  |                   |
|  |  ≡  [icon 44pt]   Wash Hands                         [pencil]  |  |                   |
|  |  ≡  [icon 44pt]   Pack Backpack                      [pencil]  |  |                   |
|  +-------------------------------------------------------------------+                   |
|                                                                                           |
|  (Swipe left on a row to reveal Delete button)                                           |
|  (Tap pencil to open edit sheet)                                                         |
|  (Drag reorder handle ≡ to reorder)                                                      |
|                                                                                           |
|  Background: color.background.parentScreen                                               |
+-------------------------------------------------------------------------------------------+
```

### Layout Details

- Navigation: child `NavigationStack` pushed from parent home
- Title: "[Child Name]'s Tasks" (`type.parent.largeTitle`)
- Background: `color.background.parentScreen`

**Navigation Bar Buttons:**
- Left: Back button (system default, "Parent Settings" as back label)
- Right: "+ Add Task" or icon `plus` button
  - `accessibilityIdentifier`: `"addTaskButton"`
  - `accessibilityLabel`: "Add Task"
  - `accessibilityHint`: "Opens task creation form"

**Task List:**

Standard iOS editable `List` with swipe actions and drag-to-reorder.

Each task row:
- Height: 56pt minimum
- Left: reorder handle (`line.3.horizontal`, 18pt, `color.text.secondary`) — only visible in edit mode; always present as a drag handle when list is in reorder mode
- Left+1: task icon thumbnail, 44×44pt, corner radius `radius.md` (16pt), background `color.child{N}.tint`
- Centre: task name label (`type.parent.headline`, `color.text.primary`)
- Right: edit pencil button (`pencil`, 18pt, `color.brand.purple`), 44×44pt tap target
- Swipe left → reveals "Delete" action in `color.brand.red`

**Row accessibility:**
- `accessibilityIdentifier`: `"taskEditorRow_<TaskName>"`
- `accessibilityLabel`: `"<Task Name>"`
- `accessibilityHint`: "Swipe left to delete. Tap edit to change."

**Reorder handle:**
- `accessibilityIdentifier`: `"taskReorderHandle_<TaskName>"`
- `accessibilityLabel`: "Reorder [Task Name]"

**Edit button (per row):**
- `accessibilityIdentifier`: `"taskEditButton_<TaskName>"`
- `accessibilityLabel`: "Edit [Task Name]"`

**Swipe-left Delete action:**
- `accessibilityIdentifier`: `"taskDeleteAction_<TaskName>"`
- `accessibilityLabel`: "Delete [Task Name]"`
- Shows confirmation alert before deletion (see below)

### Task Changes Persist Immediately
- There is no Save button — all changes (add, edit, delete, reorder) take effect immediately via SwiftData
- The routine view is always in sync with the current data

---

## Sheet: Add / Edit Task

Presented as a `.sheet` (half-height modal on iPad) when the parent taps "+ Add Task" or the pencil icon on an existing task.

### ASCII Wireframe

```
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|  +-------------------------------------------------------------+                         |
|  | Cancel                  Add Task                      Save  |                         |
|  |-------------------------------------------------------------|                         |
|  |                                                             |                         |
|  |  Task Icon                                                  |                         |
|  |  +---------------------------+                             |                         |
|  |  | [icon 80×80pt]            |  [Change Icon button]       |                         |
|  |  |  selected icon preview    |  "Choose Icon"              |                         |
|  |  |  radius.md bg tint        |  (opens icon picker)        |                         |
|  |  +---------------------------+                             |                         |
|  |                                                             |                         |
|  |  Task Name                                                  |                         |
|  |  +-------------------------------------------------------+ |                         |
|  |  | Brush Teeth                               [14/30]     | |                         |
|  |  +-------------------------------------------------------+ |                         |
|  |  Text field, 17pt, max 30 chars, character counter        |                         |
|  |                                                             |                         |
|  +-------------------------------------------------------------+                         |
|                                                                                           |
+-------------------------------------------------------------------------------------------+
```

### Sheet Component Details

**Header:**
- Cancel button (left): dismisses sheet with no changes, `type.parent.headline`, `color.brand.purple`
  - `accessibilityIdentifier`: `"taskFormCancelButton"`
- Title: "Add Task" or "Edit Task" (`type.parent.headline` centre, system style)
- Save button (right): enabled only when task name is non-empty and an icon is selected
  - `type.parent.headline`, `color.brand.purple`
  - `accessibilityIdentifier`: `"taskFormSaveButton"`
  - `accessibilityLabel`: "Save task"

**Icon Picker Area:**
- Selected icon preview: 80×80pt container, `color.child{N}.tint` background, `radius.md`, shows chosen icon (SF Symbol or photo) at 56pt
- "Choose Icon" button below preview:
  - Opens a second sheet: Icon Picker (see below)
  - `accessibilityIdentifier`: `"chooseIconButton"`
  - `accessibilityLabel`: "Choose icon"`
  - `accessibilityHint`: "Opens icon library or photo picker"
- Default state (new task): shows `questionmark.circle.fill`, muted appearance, prompting selection
- An icon MUST be selected to enable Save

**Task Name Text Field:**
- Placeholder: "Task name"
- Max length: 30 characters, enforced in real time
- Character counter: shows "[current]/30" aligned right, `type.parent.caption` (13pt), `color.text.secondary`
- Counter turns `color.brand.red` when at 30 characters
- Keyboard: `.default` return key type `.done`
- `accessibilityIdentifier`: `"taskNameField"`
- `accessibilityLabel`: "Task name"
- `accessibilityHint`: "Maximum 30 characters"

---

## Sheet: Icon Picker

Presented from the Add/Edit Task sheet. Allows parents to browse built-in SF Symbol icons or select from the photo library.

### ASCII Wireframe

```
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|  +-------------------------------------------------------------+                         |
|  | Cancel                  Choose Icon                         |                         |
|  |-------------------------------------------------------------|                         |
|  |  [Search field: "Search icons..."]                          |                         |
|  |-------------------------------------------------------------|                         |
|  |  Built-in    |   Your Photos                                |                         |
|  |  (tab)       |   (tab)                                      |                         |
|  |-------------------------------------------------------------|                         |
|  |                                                             |                         |
|  |  Hygiene                                                    |                         |
|  |  [shower] [hands] [mouth] [comb] [toilet]                   |                         |
|  |  60×60pt  60×60pt  60×60pt  60×60pt  60×60pt               |                         |
|  |                                                             |                         |
|  |  Meals                                                      |                         |
|  |  [fork.knife]  [cup]  [takeout]                             |                         |
|  |                                                             |                         |
|  |  Dressing                                                   |                         |
|  |  [tshirt] [shoe] [backpack] [scarf]                         |                         |
|  |                                                             |                         |
|  |  (scroll for more categories)                               |                         |
|  +-------------------------------------------------------------+                         |
|                                                                                           |
+-------------------------------------------------------------------------------------------+
```

### Icon Picker Details

**Tabs:**
- "Built-in" tab: grid of SF Symbols from the built-in library (DSGN-001 §6.3)
- "Your Photos" tab: `PHPickerViewController` presentation for custom photos

**Built-in Icons Grid:**
- Icon cell: 60×60pt tap target, SF Symbol at 32pt inside 52×52pt container
- Category headers: `type.parent.subhead` (15pt), `color.text.secondary`, section label
- Selected icon shows `color.brand.purple` border 3pt and `color.brand.purpleLight` background
- `accessibilityIdentifier` per icon: `"iconPicker_<sfSymbolName>"` (e.g. `"iconPicker_shower.fill"`)
- `accessibilityLabel`: the display label (e.g. "Shower")

**Photo picker:**
- Launches `PHPickerViewController` with `filter: .images`, `selectionLimit: 1`
- Selected photo is cropped to square, stored in app data as compressed JPEG
- Photo thumbnail preview shown at 80×80pt with `radius.md` in the Add/Edit Task sheet

**Search:**
- Real-time filter of built-in icon display labels
- `accessibilityIdentifier`: `"iconSearchField"`

---

## Screen: Delete Task Confirmation

Shown as a `confirmationDialog` when the swipe-left Delete action is triggered.

```
+-----------------------------------------------+
|                                               |
|   Delete "Brush Teeth"?                       |
|   This task will be removed from Mia's        |
|   morning routine.                            |
|                                               |
|   [ Delete Task ]   <- destructive, red       |
|   [ Cancel ]        <- cancel                 |
|                                               |
+-----------------------------------------------+
```

- Title: `Delete "[Task Name]"?`
- Message: `This task will be removed from [Child Name]'s morning routine.`
- Destructive: "Delete Task" — `accessibilityIdentifier`: `"deleteTaskConfirmButton"`
- Cancel: "Cancel" — `accessibilityIdentifier`: `"deleteTaskCancelButton"`

---

## Screen: Change PIN Flow

Accessed via the Settings section on the Parent Home Screen. Uses the same PIN screen visual design (dark background, keypad) with a three-step flow:

**Step 1:** "Enter your current PIN" — validates against stored PIN
- On success: proceed to Step 2
- On failure: same error/lockout logic as PIN Entry Screen

**Step 2:** "Enter your new PIN" — 4 digits entered

**Step 3:** "Confirm your new PIN" — must match Step 2
- On match: save new PIN, show success toast "PIN changed", return to Parent Home
- On mismatch: clear both entries, show error, restart from Step 2

Success toast:
- `color.brand.green` background, white text "PIN changed successfully"
- Appears at top of screen, auto-dismisses after 2 seconds
- `accessibilityIdentifier`: `"pinChangedToast"`
- Posts VoiceOver announcement: "PIN changed successfully"

---

## Accessibility Specification (WCAG 2.2 AA)

### Touch Targets — Parent Screens

| Element | Minimum Visual Size | Touch Target | Status |
|---------|--------------------|--------------|----|
| PIN keypad button | 80×80pt | 80×80pt | PASS |
| PIN delete button | 80×80pt | 80×80pt | PASS |
| PIN cancel (xmark) | 20pt icon | 44×44pt | PASS |
| Navigation bar buttons | system height | 44×44pt | PASS |
| Child list row | 56pt × full width | 56pt × full width | PASS |
| Task editor row | 56pt × full width | 56pt × full width | PASS |
| Edit button (in row) | 18pt icon | 44×44pt | PASS |
| Icon picker cell | 60×60pt | 60×60pt | PASS |

### Accessibility Identifiers — Full Reference (XCUITest)

**PIN Setup / Entry:**

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| PIN cancel/close button | `pinCancelButton` |
| PIN dot display | `pinDotDisplay` |
| PIN key button (digit N) | `pinKey_<N>` (e.g. `pinKey_1`) |
| PIN delete button | `pinDeleteButton` |
| PIN error label | `pinErrorLabel` |
| PIN lockout countdown label | `pinLockoutLabel` |

**Parent Home Screen:**

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| Done / exit button | `parentDoneButton` |
| Reset Day nav bar button | `resetDayButton` |
| Reset Day confirm button (alert) | `resetDayConfirmButton` |
| Reset Day cancel button (alert) | `resetDayCancelButton` |
| Child row (N) | `childRow_<ChildName>` |
| Change PIN row | `changePINRow` |

**Task Editor:**

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| Add Task button | `addTaskButton` |
| Task editor row (task M) | `taskEditorRow_<TaskName>` |
| Task edit button (task M) | `taskEditButton_<TaskName>` |
| Task delete swipe action (task M) | `taskDeleteAction_<TaskName>` |
| Task reorder handle (task M) | `taskReorderHandle_<TaskName>` |
| Delete confirm button (alert) | `deleteTaskConfirmButton` |
| Delete cancel button (alert) | `deleteTaskCancelButton` |

**Add / Edit Task Sheet:**

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| Cancel button | `taskFormCancelButton` |
| Save button | `taskFormSaveButton` |
| Task name text field | `taskNameField` |
| Choose icon button | `chooseIconButton` |
| Icon picker search field | `iconSearchField` |
| Icon picker cell (symbol name) | `iconPicker_<sfSymbolName>` |
| PIN changed success toast | `pinChangedToast` |

### VoiceOver Reading Order — Parent Home Screen

1. Navigation back / Done button
2. Screen title "Parent Settings"
3. Reset Day button
4. "Children" section header
5. Child 1 row: "[Name], [N] tasks. Opens task editor."
6. Child 2 row
7. Child 3 row
8. "Settings" section header
9. Change PIN row

### VoiceOver — PIN Screen

The PIN screen must not announce digits as they are entered for security. Implementation:
- Each pin key tap: VoiceOver announces "●" (bullet/dot) not the digit value
- PIN dot display `accessibilityLabel` updates to "N of 4 digits entered" (never reveals which digits)
- Correct PIN entry: VoiceOver announces "PIN accepted" before screen transitions

### Keyboard / Switch Control Navigation Order

PIN screen:
1. Cancel button (top-left)
2. PIN digit keys: 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, Delete (reading order)

Parent Home:
1. Done button
2. Reset Day button
3. Child rows (1, 2, 3)
4. Change PIN row

Task Editor:
1. Back button
2. Add Task button
3. Task rows in list order (each row: reorder handle, icon, label, edit button)

### Colour in Parent Screens

Parent screens use iOS system colours (`Color(.label)`, `Color(.secondaryLabel)`, etc.) which automatically provide correct contrast in both light and dark modes. Custom colour tokens (brand purple for interactive elements, brand red for destructive) are verified per §1.4 of DSGN-001.

The PIN screen's fixed dark background is intentional and accessible — all text on it has been contrast-verified (see DSGN-001 §1.4).

---

## iOS-Specific Considerations

### Modal Presentation
- Add/Edit Task sheet uses `.presentationDetents([.medium, .large])` — starts at medium (half screen), user can pull to full if needed
- Icon Picker sheet uses `.presentationDetents([.large])` — always full height to show category grid

### Safe Area
- Parent screens are standard `NavigationStack` views — system handles safe area insets
- PIN screen: custom full-screen view, must manually account for top and bottom safe area insets. Keypad should not be obscured by home indicator. Add `padding(.bottom, safeAreaInsets.bottom)` to keypad.

### iPadOS Keyboard
- On iPad with external keyboard, the PIN screen must accept number input from the hardware keyboard
- Text fields in task editor support hardware keyboard fully
- Task name field: `submitLabel: .done`, dismiss keyboard on submit

### First Launch Detection
- PIN setup must be triggered before ANY other UI is shown
- Use `@AppStorage` or `UserDefaults` flag `hasPINBeenSet` — if false, show PIN setup
- PIN itself is stored in Keychain (not UserDefaults)

### Auto-Lock / Background Behaviour
- When the app enters background while the PIN screen is open, the PIN screen remains on foreground when the app is resumed (do not auto-dismiss to routine view)
- When the app enters background from the parent management screens, the PIN must be re-entered on foreground return (security — do not keep parent management accessible after backgrounding)
- Implementation: observe `UIApplication.willResignActiveNotification` and set a flag to require PIN re-entry

---

## Acceptance Criteria for Design

| ID | Criterion | `accessibilityIdentifier` / Method |
|----|-----------|-----------------------------------|
| PM-AC-01 | On first launch, PIN setup screen appears before routine view | XCUITest: `pinDotDisplay` visible on first launch |
| PM-AC-02 | PIN setup requires confirming PIN before saving | XCUITest: two-step flow — first entry, then confirm step |
| PM-AC-03 | Gear button on routine view is not prominently labelled — no text visible | Visual inspection + XCUITest: `parentSettingsButton` has no visible text sibling |
| PM-AC-04 | Tapping gear button shows PIN entry screen | XCUITest: `parentSettingsButton` tap → `pinDotDisplay.exists == true` |
| PM-AC-05 | Correct PIN entry navigates to parent home — `parentDoneButton` is visible | XCUITest: enter correct PIN → `parentDoneButton.exists == true` |
| PM-AC-06 | Incorrect PIN shows error label | XCUITest: enter wrong PIN → `pinErrorLabel.exists == true` |
| PM-AC-07 | Three consecutive incorrect PINs trigger 30-second lockout | XCUITest: 3 wrong PINs → `pinLockoutLabel.exists == true`, keypad buttons disabled |
| PM-AC-08 | All 3 children appear as rows in parent home | XCUITest: `childRow_<Name>` elements exist for all 3 children |
| PM-AC-09 | Tapping a child row opens task editor for that child | XCUITest: `childRow_<Name>` tap → `taskEditorRow_*` elements visible |
| PM-AC-10 | Add Task flow: task appears in routine view after save | XCUITest: save task in editor → `task_<Name>_<TaskName>` exists in routine view |
| PM-AC-11 | Edit Task: updated name appears in routine view | XCUITest: edit task → verify `accessibilityLabel` updated in routine view |
| PM-AC-12 | Delete Task requires confirmation | XCUITest: swipe delete → `deleteTaskConfirmButton.exists` before task is removed |
| PM-AC-13 | Cancelling delete leaves task intact | XCUITest: `deleteTaskCancelButton` tap → `taskEditorRow_<TaskName>.exists == true` |
| PM-AC-14 | Task reorder persists in routine view | XCUITest: reorder tasks, verify routine view shows new order |
| PM-AC-15 | Reset Day requires confirmation | XCUITest: `resetDayButton` tap → `resetDayConfirmButton.exists == true` |
| PM-AC-16 | Confirming Reset Day sets all tasks to incomplete | XCUITest: `resetDayConfirmButton` tap → all `task_*` elements have `accessibilityValue == "not done"` |
| PM-AC-17 | Cancelling Reset Day leaves task states unchanged | XCUITest: `resetDayCancelButton` tap → task states unchanged |
| PM-AC-18 | PIN screen does not announce digit values to VoiceOver | Manual VoiceOver test: confirm only "●" announced per key press |
| PM-AC-19 | PIN keypad buttons are ≥ 44×44pt | XCUITest: `pinKey_<N>.frame.width >= 44 && .height >= 44` (actual: 80pt) |
| PM-AC-20 | App requires PIN re-entry after being backgrounded from parent management | XCUITest: background + foreground app while on parent screen → `pinDotDisplay.exists == true` |
| PM-AC-21 | Task name field enforces 30-character maximum | XCUITest: type 35 chars → `taskNameField.value.count == 30` |
| PM-AC-22 | Save button is disabled when task name is empty or no icon is selected | XCUITest: empty form → `taskFormSaveButton.isEnabled == false` |
| PM-AC-23 | Change PIN flow requires current PIN before allowing new PIN entry | XCUITest: enter wrong current PIN in change flow → error, no access to new PIN step |
| PM-AC-24 | PIN change success shows toast notification | XCUITest: complete PIN change → `pinChangedToast.exists == true` |
