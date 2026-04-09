# DSGN-002: Morning Routine View (Child-Facing)

**Status:** Draft
**Date:** 2026-03-26
**REQ:** REQ-001, REQ-002, REQ-005

---

## Overview

The Morning Routine View is the primary screen of the app — the first thing displayed on launch and the interface children interact with independently. It solves the problem of children aged 2–6 needing to know and execute their morning routine without relying on parents to read tasks aloud or remember each step.

The design prioritises icon-first recognition, large touch targets, and immediate positive reinforcement. Children who cannot read must be able to use the app effectively through icons and visual feedback alone.

---

## User Flow

1. Parent opens app on iPad (landscape, mounted or propped on table)
2. Morning Routine View appears immediately — no splash delay > 1 second
3. All three children's columns are visible simultaneously, no scrolling required
4. Child approaches iPad, recognises their column by avatar and name
5. Child taps first task (large icon row) — visual done state + star animation plays
6. Child continues tapping tasks one by one
7. When final task is tapped — celebration animation plays in that child's column only
8. Other children's columns are unaffected during completion celebrations
9. Completed column remains on screen showing all tasks done + celebration state
10. Next morning: parent resets from parent management view (REQ-004)

---

## ASCII Wireframe — Morning Routine View (Landscape iPad)

```
+-------------------------------------------------------------------------------------------+
|  iPad Status Bar (time, battery — system, do not override)                                |
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|  [gear]                                                                                   |
|  (small, top-right corner, 44×44pt tap target, `color.text.secondary`)                   |
|                                                                                           |
|  +------------------------+  +------------------------+  +------------------------+       |
|  |   [avatar: child 1]    |  |   [avatar: child 2]    |  |   [avatar: child 3]    |       |
|  |      80×80pt           |  |      80×80pt           |  |      80×80pt           |       |
|  |                        |  |                        |  |                        |       |
|  |    CHILD NAME 1        |  |    CHILD NAME 2        |  |    CHILD NAME 3        |       |
|  |    32pt, SF Rounded    |  |    32pt, SF Rounded    |  |    32pt, SF Rounded    |       |
|  |    Bold                |  |    Bold                |  |    Bold                |       |
|  |                        |  |                        |  |                        |       |
|  | [●] 0 / N stars        |  | [●] 0 / N stars        |  | [●] 0 / N stars        |       |
|  | (progress dots)        |  | (progress dots)        |  | (progress dots)        |       |
|  |------------------------|  |------------------------|  |------------------------|       |
|  | [icon] Task Name     > |  | [icon] Task Name     > |  | [icon] Task Name     > |       |
|  |  60×60   24pt          |  |  60×60   24pt          |  |  60×60   24pt          |       |
|  |------------------------|  |------------------------|  |------------------------|       |
|  | [icon] Task Name     > |  | [icon] Task Name     > |  | [icon] Task Name  [✓] |       |
|  |  done: faded + check   |  |  done: faded + check   |  | done state shown here  |       |
|  |------------------------|  |------------------------|  |------------------------|       |
|  | [icon] Task Name     > |  | [icon] Task Name     > |  | [icon] Task Name     > |       |
|  |                        |  |                        |  |                        |       |
|  |------------------------|  |------------------------|  |------------------------|       |
|  | [icon] Task Name     > |  | [icon] Task Name     > |  | [icon] Task Name     > |       |
|  |                        |  |                        |  |                        |       |
|  +------------------------+  +------------------------+  +------------------------+       |
|                                                                                           |
+-------------------------------------------------------------------------------------------+
```

**Legend:**
- `[gear]` — parent settings entry point, `accessibilityIdentifier: "parentSettingsButton"`
- `[avatar]` — child avatar image, `accessibilityHidden: true` (name label provides identification)
- `[icon]` — task icon (SF Symbol or photo), 44×44pt icon inside 60×60pt container
- `[✓]` — `checkmark.circle.fill`, 28pt, `color.brand.green`
- Progress dots — filled/unfilled circles indicating task completion ratio

---

## Screen Components

### 2.1 App Background

- Fill: `color.background.primary`
- The background is full-bleed; child column cards sit on top with `shadow.card`

### 2.2 Parent Settings Entry Point (Gear Icon)

- Position: top-right corner of the screen, inside safe area
- Offset: 16pt from right safe area edge, 16pt from top safe area edge
- Icon: `gearshape.fill`, 20pt, `color.text.secondary`
- Touch target: 44×44pt (standard iOS minimum — this is parent-only, not child-facing)
- Background: none (transparent)
- `accessibilityLabel`: "Parent Settings"
- `accessibilityHint`: "Opens parent management. Requires PIN."
- `accessibilityIdentifier`: `"parentSettingsButton"`
- This button must NOT be prominent — no label, no colour emphasis

### 2.3 Child Column Card

Each child has one column card. Cards are equal width, side by side, no scrolling.

#### Layout:
- Width: `(safeAreaWidth - 96pt - 48pt) / 3` (see DSGN-001 §3.2)
- Height: fills available vertical space between top/bottom safe area insets minus `spacing.xxl` (48pt) each side
- Background: `color.background.card` with per-child tint (`color.child{N}.tint`)
- Border: 1pt `color.border.card`
- Corner radius: `radius.lg` (24pt)
- Shadow: `shadow.card`
- `accessibilityIdentifier`: `"childColumn_<name>"` (e.g. `"childColumn_Mia"`)
- `accessibilityLabel`: `"<Child Name>'s morning routine"`

#### Child Header Area (top of card):

```
+-----------------------------------------------+
|                                                |
|         [Avatar: 80×80pt, radius.avatar]       |
|                                                |
|         CHILD NAME                             |
|         type.child.title (32pt, SF Rounded)   |
|         color.text.childName                   |
|                                                |
|         [●●●○○]  Progress indicator           |
|         (filled dots = done tasks)             |
|                                                |
+-----------------------------------------------+
```

**Avatar:**
- Container: 80×80pt circle with `radius.avatar` (40pt = full circle)
- Border: 3pt solid `color.child{N}.accent`
- Content: child illustration/emoji or initials fallback
- `accessibilityHidden: true` (the child name label is the VoiceOver identifier)
- `accessibilityIdentifier`: `"childAvatar_<name>"`

**Child Name Label:**
- Font: `type.child.title` (32pt, SF Rounded Bold)
- Colour: `color.text.childName`
- Alignment: centre
- `accessibilityIdentifier`: `"childName_<name>"`
- `accessibilityLabel`: `"<Name>'s tasks"` (read as heading by VoiceOver)
- `accessibilityAddTraits: .isHeader`

**Progress Indicator:**
- A row of filled/unfilled circle dots, one per task
- Dot size: 12pt diameter, `spacing.xs` (8pt) gap between dots
- Filled dot: `color.child{N}.accent`
- Unfilled dot: `color.border.pinDot` (#AEAEB2)
- `accessibilityLabel`: `"<N> of <total> tasks complete"`
- `accessibilityIdentifier`: `"progressIndicator_<name>"`
- `accessibilityHidden: false` — read by VoiceOver as summary

**Divider:**
- 1pt horizontal line, `color.border.taskRow`, full card width, `spacing.sm` (12pt) above first task

### 2.4 Task Row

Each task in a child's list is represented as a task row. Rows are stacked vertically within the column card. The task list scrolls vertically within the card if tasks overflow the visible area (unlikely for typical 4–8 tasks but must handle gracefully).

#### Task Row — Incomplete State:

```
+-----------------------------------------------+
| [icon container 60×60pt]  Task Label      >   |
|  [icon 44×44pt inside]    24pt, Semibold       |
|  radius.md bg tint        color.text.taskLabel |
+-----------------------------------------------+
```

**Measurements:**
- Row minimum height: **72pt** (provides 6pt padding above/below the 60pt icon)
- Row horizontal padding: `spacing.md` (16pt) left and right
- Icon-to-label gap: `spacing.sm` (12pt)
- Row background: `color.background.taskIncomplete`
- Bottom border: 1pt `color.border.taskRow` (except last row in list)

**Icon Container:**
- Size: **60×60pt** (meets REQ-001 and REQ-005 minimum touch target)
- Background: `color.child{N}.tint` (tinted per child)
- Corner radius: `radius.md` (16pt)
- Icon: SF Symbol or custom photo, 44×44pt, `color.child{N}.accent`

**Task Label:**
- Font: `type.child.taskLabel` (24pt, SF Rounded Semibold)
- Colour: `color.text.taskLabel`
- Max lines: 2, truncation tail
- Minimum scale factor: 0.8 (floor at ~20pt for Dynamic Type AX5)

**Touch Target:**
- The entire row is the tap target, minimum height 72pt > 60pt requirement
- The tap area spans full card width for forgiving touch
- `accessibilityIdentifier`: `"task_<childName>_<taskName>"` (e.g. `"task_Mia_BrushTeeth"`)
- `accessibilityLabel`: `"<Task Name>"`
- `accessibilityHint`: `"Tap to mark as done"`
- `accessibilityValue`: `"not done"`
- `accessibilityTraits`: `.isButton`

#### Task Row — Done State:

```
+-----------------------------------------------+
| [icon 60×60pt, 60% opacity]  Task Label  [✓]  |
|                               24pt, faded      |
|  background: taskComplete                      |
+-----------------------------------------------+
```

**Visual changes from incomplete:**
- Row background: `color.background.taskComplete`
- Icon container opacity: 0.6
- Task label colour: `color.text.taskLabelDone`
- Right-side: `checkmark.circle.fill`, 28pt, `color.brand.green`
- Task label has strikethrough style: `.strikethrough(true, color: color.text.taskLabelDone)`

**Note on colour-only differentiation:** Done state is conveyed by ALL of: background change, icon opacity change, text colour change, text strikethrough, AND checkmark icon. This exceeds WCAG 2.2 SC 1.4.1 requirement that colour is not the sole means of differentiation.

**Accessibility update when done:**
- `accessibilityValue`: `"done"`
- `accessibilityHint`: `""` (no hint — tapping does nothing)
- `accessibilityTraits`: `.isButton` (maintained so VoiceOver announces it, but state conveys done)

### 2.5 Star Reward Animation

Triggered immediately when an incomplete task is tapped and transitions to done state.

#### Visual Description (Reduce Motion OFF):
1. Task row transitions to done state with scale spring: row briefly scales to 1.05 then settles at 1.0 (`easing.spring`, 300ms)
2. A gold star (`star.fill`, `color.brand.yellow`) appears at the centre of the icon, scale 0.1 → 1.8 → 1.0 (`easing.spring`, 400ms)
3. 4 additional smaller stars (24pt) burst outward from the tap point at 45°, 135°, 225°, 315° angles, travelling 40pt, fading from opacity 1.0 → 0 over 600ms (`easing.standard`)
4. All star particles removed from view after animation completes

#### Visual Description (Reduce Motion ON):
1. Task row background fades to `color.background.taskComplete` (150ms cross-fade, no motion)
2. `checkmark.circle.fill` fades in at 150ms
3. No stars, no scale changes, no particle movement

#### Implementation Notes:
- Star animation plays as an overlay on the task row (not inside the task row — stars can escape the row bounds)
- The overlay is a `ZStack` child above the task list, clipped to the column card bounds
- `accessibilityIdentifier` for star particle view: `"starRewardOverlay_<childName>"` (hidden from VoiceOver: `accessibilityHidden: true`)

### 2.6 Celebration State (All Tasks Done)

When the last incomplete task in a child's column is marked done, the celebration state activates for that column only.

#### Visual Description (Reduce Motion OFF):

**Phase 1 — Confetti burst (0–2000ms):**
- 20 confetti particles in `color.brand.yellow`, `color.child{N}.accent`, `#FF6B35`, `#00A878`, `#7B4FD4` rain down within the column card bounds
- Particles are 8pt × 4pt rectangles with random rotation
- Particles start above the card, fall and fade over 2000ms
- Loop: confetti repeats every 3 seconds while celebration is active

**Phase 2 — Persistent celebration banner (appears at 300ms, persists):**

```
+-----------------------------------------------+
|                                                |
|   [party.popper.fill 48pt  color.brand.yellow] |
|                                                |
|      All done!                                 |
|      type.child.celebration (36pt, Heavy)      |
|      color.text.childName                      |
|                                                |
|   ★ ★ ★ (3 animated pulsing stars)            |
|   star.fill 32pt  color.brand.yellow          |
|                                                |
+-----------------------------------------------+
```

- Banner background: `color.background.celebration` with `radius.xl` (32pt), centred over the task list area
- Banner overlays (does not replace) the task list — tasks remain visible below with reduced opacity (0.4)
- Column card shadow changes to `shadow.celebration` (yellow glow)

**Reduce Motion ON:**
- No confetti particles
- No pulsing stars
- Celebration banner appears instantly (cross-fade 150ms)
- Column card background changes to `color.background.celebration` (instant)

#### Celebration Accessibility:
- `accessibilityIdentifier`: `"celebrationView_<childName>"`
- `accessibilityLabel`: `"<Child Name> finished all tasks! Amazing!"`
- Posted as `UIAccessibility.post(notification: .announcement, argument: "<Name> finished all their tasks!")` when celebration activates

---

## Layout Constraints and Adaptive Behaviour

### Column Width Adaptive Rules:

| Safe-Area Width | Column Width (equal thirds, 96pt margins, 48pt gaps) |
|----------------|------------------------------------------------------|
| 1000pt (iPad mini) | ≈ 285pt |
| 1101pt (iPad mini 6 gen) | ≈ 318pt |
| 1148pt (iPad 10th gen / Air M2) | ≈ 334pt |
| 1162pt (iPad Pro 11") | ≈ 339pt |
| 1334pt (iPad Pro 13") | ≈ 397pt |

Minimum enforced column width: **280pt**. Below this, the app should not be reached as the minimum supported safe-area width for iPad landscape is ~944pt (iPad mini earlier gen); at 944pt columns would be ≈271pt, where 12pt side margins and 12pt gaps may be used instead to keep columns ≥ 280pt.

### Task List Scroll Behaviour:
- The task list within each column card scrolls vertically if needed
- Scroll indicators are hidden (`showsIndicators: false`) to keep the child UI clean
- Overscroll is disabled (`bounces: false`) to prevent accidental scroll confusion
- Maximum visible tasks without scroll: approximately 6 tasks at 72pt row height on a standard iPad in landscape

---

## Colour and Theme per Child

| Child Slot | Column Tint Token | Accent Token | Avatar Border | Icon Background |
|-----------|------------------|-------------|--------------|----------------|
| Child 1 | `color.child1.tint` | `color.child1.accent` (Purple `#7B4FD4`) | Purple | `color.child1.tint` |
| Child 2 | `color.child2.tint` | `color.child2.accent` (Orange `#FF6B35`) | Orange | `color.child2.tint` |
| Child 3 | `color.child3.tint` | `color.child3.accent` (Green `#00A878`) | Green | `color.child3.tint` |

---

## Accessibility Specification (WCAG 2.2 AA)

### VoiceOver Reading Order

VoiceOver reads left-to-right, top-to-bottom within each column, then moves to the next column. The reading order is:

1. "Parent Settings button" (top-right gear)
2. Column 1: "[Name]'s morning routine" (card header)
3. Column 1: "[Name]'s tasks. [N] of [total] complete."
4. Column 1: Task 1 name, "not done" / "done"
5. Column 1: Task 2 name... etc.
6. Column 2: "[Name]'s morning routine"
7. ... (same pattern)

To achieve column-based reading order (not row-based across all 3 columns), each column card must be an `accessibilityElement(children: .contain)` with sorted accessibility elements.

### Touch Target Verification

| Element | Visual Size | Tap Target | Minimum Required | Status |
|---------|------------|-----------|------------------|--------|
| Task row | 72pt × full width | 72pt × full card width | 60×60pt | PASS |
| Icon container | 60×60pt | 60×60pt (part of row tap) | 60×60pt | PASS |
| Parent gear | 20pt icon | 44×44pt | 44×44pt (parent) | PASS |
| Child column card | full column | not a tap target | — | N/A |

### Accessibility Identifiers (XCUITest Reference)

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| Parent settings gear button | `parentSettingsButton` |
| Child 1 column card | `childColumn_<Child1Name>` |
| Child 2 column card | `childColumn_<Child2Name>` |
| Child 3 column card | `childColumn_<Child3Name>` |
| Child N name label | `childName_<ChildName>` |
| Child N avatar | `childAvatar_<ChildName>` |
| Child N progress indicator | `progressIndicator_<ChildName>` |
| Task row (child N, task M) | `task_<ChildName>_<TaskName>` |
| Celebration view (child N) | `celebrationView_<ChildName>` |
| Star reward overlay (child N) | `starRewardOverlay_<ChildName>` |

Note: `<ChildName>` and `<TaskName>` use PascalCase, spaces removed. Example: task name "Brush Teeth" → `BrushTeeth`.

### Dynamic Type

- All child-facing text uses SF Rounded with SwiftUI text styles (`.largeTitle`, `.title2`) that scale automatically
- At AX5, task labels may use `minimumScaleFactor: 0.8` with a hard floor of 20pt — this is acceptable as the primary information is the icon
- Column headers (`type.child.title`, 32pt) must remain on one line; use `lineLimit(1)` with `minimumScaleFactor: 0.75`
- Icons do not scale with Dynamic Type — they remain 44×44pt at all type sizes

### Colour Blindness

The done/incomplete distinction is never conveyed by colour alone:
- Done: background changes + icon fades + strikethrough text + checkmark icon appears
- All three child column accent colours are distinguishable to protanopia, deuteranopia, and tritanopia users (purple, orange, green have sufficient luminance and hue differences across all common types)

### Switch Control / Full Keyboard Access

- Focus order: gear button, then Column 1 header, Column 1 tasks top-to-bottom, Column 2 header, Column 2 tasks, Column 3 header, Column 3 tasks
- Focus ring: 3pt `color.border.focus` ring, corner radius = element radius + 4pt
- Each task row is individually focusable and activatable via Switch Control

---

## iOS-Specific Considerations

### Safe Area Handling
- All content respects `safeAreaInsets` — column cards do not extend under the home indicator bar
- On iPad with Stage Manager (external display use cases): the layout remains locked landscape and does not attempt to use Stage Manager window resizing

### Orientation Lock
- The app sets `UIInterfaceOrientationMask.landscape` in `Info.plist`
- `UISupportedInterfaceOrientations~ipad` must include only `UIInterfaceOrientationLandscapeLeft` and `UIInterfaceOrientationLandscapeRight`

### Status Bar
- Style: `.darkContent` in light mode, `.lightContent` in dark mode (system handles this)
- Do not hide the status bar — time visibility is important context for children and parents

### Home Indicator
- `prefersHomeIndicatorAutoHidden` returns `false` — the home indicator must remain visible

### Haptics
- Task completion triggers a success haptic: `UIImpactFeedbackGenerator(style: .medium)`
- Celebration triggers: `UINotificationFeedbackGenerator().notificationOccurred(.success)`
- All haptics respect the system haptic setting (if user has disabled haptics, system ignores the call)

---

## Acceptance Criteria for Design

| ID | Criterion | `accessibilityIdentifier` / Method |
|----|-----------|-----------------------------------|
| MRV-AC-01 | App launches and Morning Routine View is the first visible screen within 1 second | XCUITest: `app.otherElements["childColumn_<Name>"].exists` immediately after launch |
| MRV-AC-02 | All 3 child columns are visible simultaneously without scrolling on all supported iPad sizes in landscape | XCUITest: all 3 `childColumn_*` elements `isHittable == true` |
| MRV-AC-03 | Each child column shows the child's name | XCUITest: `childName_<Name>.label == "<Name>'s tasks"` |
| MRV-AC-04 | Each task row shows an icon and a text label | XCUITest: `task_<Name>_<Task>` exists and has non-empty `label` |
| MRV-AC-05 | All task row touch targets are ≥ 60×60pt | XCUITest: `task_<Name>_<Task>.frame.height >= 60 && .frame.width >= 60` |
| MRV-AC-06 | Tapping an incomplete task changes `accessibilityValue` to "done" within 100ms | XCUITest: tap + assert `accessibilityValue == "done"` |
| MRV-AC-07 | Tapping a done task produces no state change | XCUITest: tap done task, assert `accessibilityValue` remains "done" |
| MRV-AC-08 | Celebration view appears when all tasks in one column are tapped | XCUITest: `celebrationView_<Name>.exists == true` after completing all tasks |
| MRV-AC-09 | Celebration view does NOT appear in other columns when one child completes | XCUITest: other `celebrationView_*` elements `exists == false` |
| MRV-AC-10 | With `--reduce-motion` launch argument, no animation elements appear (no star particles, no confetti) | XCUITest: `starRewardOverlay_<Name>` and `celebrationView_<Name>` have no animated child elements |
| MRV-AC-11 | Done state is visually distinct from incomplete state by more than colour alone | Design review: confirm strikethrough + checkmark + background change all present |
| MRV-AC-12 | VoiceOver announces each task with name and done/not-done state | XCUITest: `accessibilityLabel` and `accessibilityValue` assertions on task elements |
| MRV-AC-13 | Parent settings gear button has `accessibilityLabel == "Parent Settings"` | XCUITest: `app.buttons["parentSettingsButton"].label == "Parent Settings"` |
| MRV-AC-14 | Child column font size is ≥ 24pt at default Dynamic Type setting | XCUITest: font size assertion on `childTaskLabel_*` elements |
| MRV-AC-15 | Progress indicator updates correctly after each task is completed | XCUITest: `progressIndicator_<Name>.label` shows correct "N of total tasks complete" |
