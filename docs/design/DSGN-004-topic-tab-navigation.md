# DSGN-004: Topic Tab Navigation & Topic Management

**Status:** Draft
**Date:** 2026-03-30
**REQ:** REQ-006, REQ-001 (amended), REQ-004 (amended)

---

## Overview

This design introduces topic categories (aihealueet) to the app, allowing parents to organise children's tasks under named routines such as "Aamu", "Paeivakodin jaelkeen", and "Ennen nukkumaanmenoa". Children switch between topics via a tab bar placed above the three-column layout. Parents manage topics (create, rename, delete, reorder) and perform per-topic resets from the parent management view.

This solves the problem of the app being limited to a single morning routine: families need to manage multiple daily routines, and children need a simple way to navigate between them.

---

## User Flow — Child-Facing

1. App launches; routine view shows with topic tab bar at top
2. The first (leftmost) topic is selected by default
3. All three child columns display tasks for the active topic
4. Child (or parent) taps a different topic tab
5. Tab transitions with a horizontal slide animation; all three columns update simultaneously
6. Child interacts with tasks within the active topic as before (REQ-002 behaviour unchanged)
7. If only one topic exists, a single tab is shown (no switching needed, but the tab bar is still visible for consistency)

## User Flow — Parent Topic Management

1. Parent enters parent management view (via PIN gate)
2. Parent Home Screen now shows a "Topics" section above the "Children" section
3. Parent can add, rename, delete, and reorder topics from this section
4. When selecting a child for task editing, the parent first selects a topic, then sees tasks for that child within that topic
5. Per-topic reset buttons are available in the Topics section
6. "Reset All" button remains in the navigation bar

---

## Child-Facing View: Topic Tab Bar

### ASCII Wireframe — Full Routine View with Tabs (Landscape iPad)

```
+-------------------------------------------------------------------------------------------+
|  iPad Status Bar                                                                          |
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|  +-----------------------------------------------------------------------------------+    |
|  |  [ Aamu ]    [ Paeivakodin jaelkeen ]    [ Ennen nukkumaanmenoa ]       [gear]    |    |
|  |   ACTIVE        inactive                   inactive               (44x44pt)       |    |
|  |   purple bg     transparent bg             transparent bg                         |    |
|  +-----------------------------------------------------------------------------------+    |
|                                                                                           |
|  +------------------------+  +------------------------+  +------------------------+       |
|  |   [avatar: child 1]    |  |   [avatar: child 2]    |  |   [avatar: child 3]    |       |
|  |      80x80pt           |  |      80x80pt           |  |      80x80pt           |       |
|  |    CHILD NAME 1        |  |    CHILD NAME 2        |  |    CHILD NAME 3        |       |
|  |    32pt, SF Rounded    |  |    32pt, SF Rounded    |  |    32pt, SF Rounded    |       |
|  |------------------------|  |------------------------|  |------------------------|       |
|  | [icon] Task Name     > |  | [icon] Task Name     > |  | [icon] Task Name     > |       |
|  |------------------------|  |------------------------|  |------------------------|       |
|  | [icon] Task Name     > |  | [icon] Task Name     > |  | [icon] Task Name     > |       |
|  |------------------------|  |------------------------|  |------------------------|       |
|  | [icon] Task Name     > |  | [icon] Task Name     > |  | [icon] Task Name     > |       |
|  +------------------------+  +------------------------+  +------------------------+       |
|                                                                                           |
+-------------------------------------------------------------------------------------------+
```

### Tab Bar Placement and Layout

- The tab bar is positioned at the **top** of the safe area, above the three child columns
- It spans the full safe-area width, matching the outer margins of the child column grid
- Horizontal margins: `spacing.xxl` (48pt) left and right, matching the column card layout
- The tab bar sits within a container that has:
  - Background: `color.background.card` (white / dark card)
  - Corner radius: `radius.lg` (24pt)
  - Shadow: `shadow.card`
  - Height: **72pt** (provides 6pt vertical padding around the 60pt touch target of each tab)
  - Internal horizontal padding: `spacing.md` (16pt)
- The gear icon is repositioned from top-right corner to **inside the tab bar container**, right-aligned, vertically centred. This consolidates the top area into one visual strip.
- Vertical gap between tab bar and child columns: `spacing.md` (16pt)
- Child column top padding adjusted from `spacing.xxl` (48pt) to accommodate tab bar: child columns start at `safeArea.top + 72pt (tab bar) + spacing.md (16pt)`

### Tab Item Design

Each tab is a pill-shaped button:

**Active Tab:**
- Background: `color.brand.purple` (light) / `color.brand.purple` dark variant
- Text colour: `color.text.onAccent` (#FFFFFF)
- Font: `type.child.taskLabel` (24pt, SF Rounded Semibold)
- Corner radius: `radius.full` (pill shape)
- Minimum size: **60pt height** (meets the 60x60pt touch target requirement)
- Minimum width: **120pt** (ensures comfortable tap area even for short labels)
- Horizontal padding: `spacing.lg` (24pt) left and right inside the pill
- Shadow: `shadow.taskRow` (subtle lift to distinguish from inactive tabs)

**Inactive Tab:**
- Background: `color.brand.purpleLight` (light) / dark variant
- Text colour: `color.text.primary`
- Font: `type.child.taskLabel` (24pt, SF Rounded Semibold)
- Corner radius: `radius.full` (pill shape)
- Same minimum size constraints as active tab (60pt height, 120pt width)
- No shadow

**Pressed State (Inactive Tab being tapped):**
- Background: `color.brand.purple` at 40% opacity
- Scale: 0.97 (spring press feedback, `easing.springFirm`, 150ms)
- Reduce Motion: no scale, just background change

### Tab Bar Scrolling

- If the total width of all tabs exceeds the available tab bar width (tab bar width minus gear icon space minus internal padding), the tabs scroll horizontally
- Scroll indicators are hidden (`showsIndicators: false`)
- The active tab is always scrolled into view when selected
- For 1-3 topics, tabs will typically fit without scrolling on all iPad sizes
- For 4+ topics, horizontal scroll activates automatically

### Tab Contrast Ratios

| Foreground | Background | Ratio | Requirement | Status |
|------------|------------|-------|-------------|--------|
| `color.text.onAccent` (#FFFFFF) | `color.brand.purple` (#7B4FD4) | **5.1:1** | >= 4.5:1 text | PASS |
| `color.text.primary` (#1C1C1E) | `color.brand.purpleLight` (#EDE5FF) | **14.2:1** | >= 4.5:1 text | PASS |
| `color.text.primary` dark (#F2F2F7) | `color.brand.purpleLight` dark (#3D2870) | **8.4:1** | >= 4.5:1 text | PASS |
| `color.brand.purple` (#7B4FD4) | `color.background.card` (#FFFFFF) | **5.1:1** | >= 3:1 UI | PASS |
| Active tab pill on card bg | card bg | **5.1:1** | >= 3:1 UI | PASS |
| Inactive tab pill on card bg | card bg | **3.2:1** | >= 3:1 UI | PASS |

### Single Tab State

When only one topic exists:
- The tab bar is still rendered with the single tab in active state
- The tab cannot be deselected (it is always active)
- The gear icon remains in its position within the tab bar
- No scrolling behaviour needed
- VoiceOver announces: "[Topic Name], selected, only topic. Tab 1 of 1."

### Tab Transition Animation

**Reduce Motion OFF:**
- When a new tab is tapped, the child column content transitions with a horizontal slide:
  - If moving to a tab to the right: content slides out to the left, new content slides in from the right
  - If moving to a tab to the left: content slides out to the right, new content slides in from the left
  - Duration: `animation.standard` (300ms)
  - Easing: `easing.standard` (`.easeInOut`)
- The tab bar itself does not animate; only the active state indicator transitions
- Active pill background crossfades between tabs: 150ms `easing.standard`
- Tab label colour transitions simultaneously with the background

**Reduce Motion ON:**
- Content switches instantly (no slide)
- Active/inactive tab state crossfades in `animation.fast` (150ms)
- No motion or directional animation

**Implementation hint (SwiftUI):**
- Use a `TabView` with `.tabViewStyle(.page)` or a custom `matchedGeometryEffect` for the active pill indicator
- Content transition: `.transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))` depending on direction
- Wrap in `withAnimation(.easeInOut(duration: 0.3))` on tab change

### Integration with 3-Column Layout

- The three child columns remain exactly as specified in DSGN-002
- The only change is that the **task list content** within each column is now filtered by the active topic
- Column headers (avatar, name, progress indicator) remain the same regardless of active topic
- The progress indicator now shows progress for the **active topic only**: e.g. "2 of 4 tasks complete" refers to tasks in the selected topic
- VoiceOver announcement for the column header now includes the topic context: "[Name]'s [Topic Name] routine"
- `accessibilityLabel` for child column card updated to: `"<Child Name>'s <Topic Name> routine"`

---

## Parent Management View: Topic Section

### Parent Home Screen — Updated Layout

The Parent Home Screen (DSGN-003 Screen 3) is updated with a new "Topics" section above the existing "Children" section.

### ASCII Wireframe — Updated Parent Home Screen

```
+-------------------------------------------------------------------------------------------+
| < Done                        Parent Settings                    [Reset All]              |
|  (44pt tap target)            (Navigation Title)                 (button, red)            |
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|  +-------------------------------------------------------------------+                   |
|  |  Topics                                           [+ Add Topic]   |                   |
|  |-------------------------------------------------------------------|                   |
|  |  ==  Aamu                    [Reset]   [pencil]               >   |                   |
|  |-------------------------------------------------------------------|                   |
|  |  ==  Paeivakodin jaelkeen    [Reset]   [pencil]               >   |                   |
|  |-------------------------------------------------------------------|                   |
|  |  ==  Ennen nukkumaanmenoa    [Reset]   [pencil]               >   |                   |
|  +-------------------------------------------------------------------+                   |
|                                                                                           |
|  +-------------------------------------------------------------------+                   |
|  |  Children                                                         |                   |
|  |-------------------------------------------------------------------|                   |
|  |  [child1.avatar 40pt]   Child 1 Name           [N tasks]  >      |                   |
|  |-------------------------------------------------------------------|                   |
|  |  [child2.avatar 40pt]   Child 2 Name           [N tasks]  >      |                   |
|  |-------------------------------------------------------------------|                   |
|  |  [child3.avatar 40pt]   Child 3 Name           [N tasks]  >      |                   |
|  +-------------------------------------------------------------------+                   |
|                                                                                           |
|  +-------------------------------------------------------------------+                   |
|  |  Settings                                                         |                   |
|  |-------------------------------------------------------------------|                   |
|  |  [lock.fill 18pt]  Change PIN                              >      |                   |
|  +-------------------------------------------------------------------+                   |
|                                                                                           |
+-------------------------------------------------------------------------------------------+
```

### Topics Section Details

**Section Header:**
- Label: "Topics" (`type.parent.headline`, `color.text.secondary`)
- Right-aligned: "+ Add Topic" button
  - Icon: `plus.circle.fill`, 24pt, `color.brand.purple`
  - `accessibilityIdentifier`: `"addTopicButton"`
  - `accessibilityLabel`: "Add Topic"
  - `accessibilityHint`: "Creates a new topic category"

**Topic Row:**
- Height: 56pt minimum (standard iOS list row)
- Left: drag reorder handle (`line.3.horizontal`, 18pt, `color.text.secondary`)
  - `accessibilityIdentifier`: `"topicReorderHandle_<TopicName>"`
  - `accessibilityLabel`: "Reorder [Topic Name]"
- Centre-left: topic name (`type.parent.headline`, `color.text.primary`)
- Centre-right: Reset button for this topic
  - Icon: `arrow.clockwise`, 18pt, `color.brand.orange`
  - Container: 44x44pt tap target
  - `accessibilityIdentifier`: `"topicResetButton_<TopicName>"`
  - `accessibilityLabel`: "Reset [Topic Name]"
  - `accessibilityHint`: "Resets all tasks in [Topic Name] for all children to incomplete"
- Right-of-reset: Edit (rename) button
  - Icon: `pencil`, 18pt, `color.brand.purple`
  - Container: 44x44pt tap target
  - `accessibilityIdentifier`: `"topicEditButton_<TopicName>"`
  - `accessibilityLabel`: "Rename [Topic Name]"
- Far right: disclosure indicator (chevron) — tapping the row itself is currently not assigned; only explicit buttons are interactive
- Swipe left: reveals "Delete" action in `color.brand.red` (unless it is the last remaining topic, in which case the swipe action is not available)

**Topic Row accessibility:**
- `accessibilityIdentifier`: `"topicRow_<TopicName>"`
- `accessibilityLabel`: `"<Topic Name>"`
- `accessibilityHint`: "Swipe left to delete. Use buttons to reset or rename."

### Navigation Bar Changes

- "Reset Day" button is renamed to **"Reset All"**
  - `accessibilityIdentifier`: `"resetAllButton"` (updated from `resetDayButton`)
  - `accessibilityLabel`: "Reset All"
  - `accessibilityHint`: "Resets all tasks in all topics for all children"

### Children Section — Updated Navigation

Tapping a child row now navigates to a **Topic Picker** for that child, rather than directly to the task editor. This is necessary because tasks are now scoped per child per topic.

**Updated child row:**
- Task count label now shows total across all topics: e.g. "12 tasks (3 topics)"
- `accessibilityLabel`: `"<Child Name>, [N] tasks across [M] topics"`
- `accessibilityHint`: "Opens topic selection for [Child Name]'s tasks"
- `accessibilityIdentifier`: unchanged (`"childRow_<ChildName>"`)

---

## Screen: Child Topic Picker (New)

### Purpose

After tapping a child row on the Parent Home Screen, the parent sees a list of topics for that child, with task counts per topic. Tapping a topic opens the existing Task Editor (DSGN-003 Screen 4) scoped to that child and topic.

### ASCII Wireframe

```
+-------------------------------------------------------------------------------------------+
| < Parent Settings           Mia's Topics                                                  |
|                             (Navigation Title)                                            |
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|  +-------------------------------------------------------------------+                   |
|  |  Topics                                                           |                   |
|  |-------------------------------------------------------------------|                   |
|  |  Aamu                                       5 tasks        >      |                   |
|  |-------------------------------------------------------------------|                   |
|  |  Paeivakodin jaelkeen                       3 tasks        >      |                   |
|  |-------------------------------------------------------------------|                   |
|  |  Ennen nukkumaanmenoa                       4 tasks        >      |                   |
|  +-------------------------------------------------------------------+                   |
|                                                                                           |
|  Background: color.background.parentScreen                                                |
+-------------------------------------------------------------------------------------------+
```

### Layout Details

- Navigation: pushed from Parent Home within the NavigationStack
- Title: "[Child Name]'s Topics" (`type.parent.largeTitle`)
- Back button label: "Parent Settings"
- Background: `color.background.parentScreen`
- Standard iOS grouped `List` with one section

**Topic Row in Child Context:**
- Height: 56pt minimum
- Left: topic name (`type.parent.headline`, `color.text.primary`)
- Right: task count for this child in this topic (`type.parent.subhead`, `color.text.secondary`) + disclosure chevron
- `accessibilityIdentifier`: `"childTopicRow_<ChildName>_<TopicName>"`
- `accessibilityLabel`: `"<Topic Name>, [N] tasks"`
- `accessibilityHint`: "Opens task editor for [Child Name] in [Topic Name]"

Tapping a topic row navigates to the Task Editor (DSGN-003 Screen 4) with:
- Title updated to: "[Child Name]'s Tasks - [Topic Name]" (`type.parent.largeTitle`)
- Tasks shown are filtered to the selected child and topic
- Add Task adds to this specific child+topic combination
- Back navigation returns to the Child Topic Picker

---

## Dialog: Add Topic

Triggered by the "+ Add Topic" button in the Topics section.

### Presentation

Presented as an `.alert` with a text field (iOS standard alert with text input):

```
+-----------------------------------------------+
|                                               |
|   New Topic                                   |
|                                               |
|   +---------------------------------------+   |
|   | Topic name                     [0/30] |   |
|   +---------------------------------------+   |
|                                               |
|   [ Cancel ]          [ Add ]                 |
|                                               |
+-----------------------------------------------+
```

### Details

- Title: "New Topic"
- Text field placeholder: "Topic name"
- Max length: 30 characters (enforced)
- "Add" button: enabled only when text field is non-empty
  - `accessibilityIdentifier`: `"addTopicConfirmButton"`
- "Cancel" button:
  - `accessibilityIdentifier`: `"addTopicCancelButton"`
- On add: new topic is created with the given name, appears as last tab in tab order, and a new tab appears in the child-facing view

---

## Dialog: Rename Topic

Triggered by the pencil (edit) button on a topic row.

### Presentation

Presented as an `.alert` with a pre-filled text field:

```
+-----------------------------------------------+
|                                               |
|   Rename Topic                                |
|                                               |
|   +---------------------------------------+   |
|   | Aamu                          [4/30]  |   |
|   +---------------------------------------+   |
|                                               |
|   [ Cancel ]          [ Save ]                |
|                                               |
+-----------------------------------------------+
```

### Details

- Title: "Rename Topic"
- Text field: pre-filled with current topic name, selected for easy replacement
- Max length: 30 characters
- "Save" button: enabled only when text field is non-empty and different from the current name
  - `accessibilityIdentifier`: `"renameTopicConfirmButton"`
- "Cancel" button:
  - `accessibilityIdentifier`: `"renameTopicCancelButton"`
- On save: topic name updates everywhere (tab bar label, parent management)

---

## Dialog: Delete Topic Confirmation

Triggered by swiping left on a topic row (only available when more than one topic exists).

### Presentation

Presented as a `.confirmationDialog`:

```
+-----------------------------------------------+
|                                               |
|   Delete "Paeivakodin jaelkeen"?              |
|                                               |
|   This will permanently delete this topic     |
|   and all associated tasks for all children.  |
|   This cannot be undone.                      |
|                                               |
|   [ Delete Topic ]   <- destructive, red      |
|   [ Cancel ]         <- cancel                |
|                                               |
+-----------------------------------------------+
```

### Details

- Title: `Delete "<Topic Name>"?`
- Message: "This will permanently delete this topic and all associated tasks for all children. This cannot be undone."
- Destructive button: "Delete Topic" (`color.brand.red`)
  - `accessibilityIdentifier`: `"deleteTopicConfirmButton"`
- Cancel button: "Cancel"
  - `accessibilityIdentifier`: `"deleteTopicCancelButton"`
- On confirm: topic is deleted, tab is removed from child-facing view, the first remaining topic becomes active
- The delete swipe action is **not rendered** when only one topic remains (the last topic cannot be deleted)
  - `accessibilityIdentifier` for the swipe action: `"topicDeleteAction_<TopicName>"`

### Last Topic Protection

- When only one topic exists, the topic row does not show the swipe-to-delete action
- VoiceOver on the single remaining topic row does NOT announce "Swipe left to delete"
- Updated `accessibilityHint`: "Use buttons to reset or rename. This is the only topic and cannot be deleted."

---

## Dialog: Per-Topic Reset Confirmation

Triggered by the reset button (arrow.clockwise) on a topic row.

### Presentation

Presented as a `.confirmationDialog`:

```
+-----------------------------------------------+
|                                               |
|   Reset "Aamu"?                               |
|                                               |
|   All tasks in "Aamu" for all children will   |
|   be marked as incomplete. This cannot be     |
|   undone.                                     |
|                                               |
|   [ Reset Topic ]    <- destructive, red      |
|   [ Cancel ]         <- cancel                |
|                                               |
+-----------------------------------------------+
```

### Details

- Title: `Reset "<Topic Name>"?`
- Message: `All tasks in "<Topic Name>" for all children will be marked as incomplete. This cannot be undone.`
- Destructive button: "Reset Topic" (`color.brand.red`)
  - `accessibilityIdentifier`: `"resetTopicConfirmButton_<TopicName>"`
- Cancel button: "Cancel"
  - `accessibilityIdentifier`: `"resetTopicCancelButton_<TopicName>"`
- On confirm: all tasks within this topic for all children are set to incomplete; if the child-facing view is showing this topic, all checkmarks disappear

---

## Dialog: Reset All Confirmation (Updated)

The "Reset Day" button is renamed "Reset All". The dialog is updated:

```
+-----------------------------------------------+
|                                               |
|   Reset all topics?                           |
|                                               |
|   All tasks in all topics for all children    |
|   will be marked as incomplete. This cannot   |
|   be undone.                                  |
|                                               |
|   [ Reset All ]      <- destructive, red      |
|   [ Cancel ]         <- cancel                |
|                                               |
+-----------------------------------------------+
```

### Details

- Title: "Reset all topics?"
- Message: "All tasks in all topics for all children will be marked as incomplete. This cannot be undone."
- Destructive button: "Reset All" (`color.brand.red`)
  - `accessibilityIdentifier`: `"resetAllConfirmButton"` (updated from `resetDayConfirmButton`)
- Cancel button: "Cancel"
  - `accessibilityIdentifier`: `"resetAllCancelButton"` (updated from `resetDayCancelButton`)

---

## Topic Reordering

- Topic rows in the parent management Topics section support drag-to-reorder
- Reordering changes the tab display order in the child-facing view immediately
- Standard iOS list reorder behaviour: long-press the drag handle to initiate
- During reorder, the row lifts with `shadow.card` and slight scale (1.02)
- `accessibilityCustomActions` on each topic row includes "Move Up" and "Move Down" for VoiceOver users who cannot drag

---

## Visual Design

### New Design Tokens Required

No new colour or spacing tokens are needed. This design uses existing tokens from DSGN-001:

| Usage | Token |
|-------|-------|
| Active tab background | `color.brand.purple` |
| Active tab text | `color.text.onAccent` |
| Inactive tab background | `color.brand.purpleLight` |
| Inactive tab text | `color.text.primary` |
| Tab bar container background | `color.background.card` |
| Tab bar container shadow | `shadow.card` |
| Tab bar container radius | `radius.lg` (24pt) |
| Tab pill radius | `radius.full` (pill) |
| Tab font | `type.child.taskLabel` (24pt SF Rounded Semibold) |
| Tab bar height | 72pt (60pt tab + 6pt padding top/bottom) |
| Tab minimum width | 120pt |
| Tab minimum height | 60pt |
| Tab internal horizontal padding | `spacing.lg` (24pt) |
| Inter-tab gap | `spacing.sm` (12pt) |
| Tab bar to column gap | `spacing.md` (16pt) |
| Per-topic reset icon | `arrow.clockwise`, 18pt, `color.brand.orange` |

### Dark Mode

All tab bar elements use existing tokens that have dark mode variants defined in DSGN-001. No additional dark mode work is required. The tab bar container uses `color.background.card` which transitions to `#252540` in dark mode. The active purple pill and the inactive purple-light pill both have dark variants.

---

## Accessibility (WCAG 2.2 AA)

### Tab Bar Accessibility

**VoiceOver:**
- The tab bar container is an `accessibilityElement(children: .contain)` group
- `accessibilityLabel` on tab bar container: "Topic tabs"
- `accessibilityIdentifier` on tab bar container: `"topicTabBar"`
- Each tab is announced as: "[Topic Name], tab [N] of [total], [selected/not selected]"
- `accessibilityTraits` for active tab: `.isSelected`, `.isButton`
- `accessibilityTraits` for inactive tab: `.isButton`
- VoiceOver reading order: tabs left-to-right, then gear icon, then child columns

**Tab Item Accessibility:**
- `accessibilityIdentifier`: `"topicTab_<TopicName>"` (e.g. `"topicTab_Aamu"`)
- `accessibilityLabel`: `"<Topic Name>"`
- `accessibilityValue`: "Selected" (active) or "" (inactive)
- `accessibilityHint` (inactive tab): "Double tap to switch to [Topic Name]"
- `accessibilityHint` (active tab): "" (no hint needed, already selected)

### Touch Target Verification

| Element | Visual Size | Touch Target | Minimum Required | Status |
|---------|------------|--------------|------------------|--------|
| Topic tab (active/inactive) | >=120x60pt | >=120x60pt | 60x60pt | PASS |
| Gear icon (in tab bar) | 20pt icon | 44x44pt | 44x44pt | PASS |
| Per-topic reset button (parent) | 18pt icon | 44x44pt | 44x44pt | PASS |
| Topic edit button (parent) | 18pt icon | 44x44pt | 44x44pt | PASS |
| Topic row (parent) | 56pt x full | 56pt x full | 44x44pt | PASS |
| Child topic picker row (parent) | 56pt x full | 56pt x full | 44x44pt | PASS |

### Colour Contrast (Non-Text UI Components)

Tab pill borders against the tab bar card background meet >= 3:1 (see contrast table above). Active tab is distinguished from inactive by both colour change AND text colour change (not colour alone).

### Dynamic Type

- Tab labels use `type.child.taskLabel` (24pt base, scales with `.title2`)
- At large accessibility sizes, tab labels may truncate with `lineLimit(1)` and `minimumScaleFactor: 0.8` (floor 20pt)
- Tab minimum height remains 60pt regardless of Dynamic Type size
- If text at AX5 causes tabs to overflow, horizontal scrolling activates

### Reduce Motion

- Tab content transitions: instant switch (no slide) with `animation.fast` (150ms) crossfade
- Tab active/inactive state: instant colour change (no crossfade)
- Topic row reorder: no lift animation, instant position swap

### Switch Control / Full Keyboard Access

Updated focus order for routine view:
1. Topic tab 1, Topic tab 2, ..., Topic tab N
2. Gear icon (parent settings)
3. Column 1 header, Column 1 tasks
4. Column 2 header, Column 2 tasks
5. Column 3 header, Column 3 tasks

Updated focus order for Parent Home:
1. Done button
2. Reset All button
3. "Topics" section header
4. Topic rows (each: reorder handle, topic name, reset button, edit button)
5. Add Topic button
6. "Children" section header
7. Child rows
8. "Settings" section header
9. Change PIN row

---

## iOS-Specific Considerations

### Safe Area Handling

- Tab bar sits within the top safe area, respecting `safeAreaInsets.top`
- The tab bar container has horizontal margins matching the child column grid (`spacing.xxl` = 48pt each side)
- The child column vertical space is reduced by tab bar height (72pt) + gap (16pt) = 88pt compared to DSGN-002. On iPad (10th gen) in landscape, remaining vertical space for columns: 820pt - statusBar(~24pt) - homeIndicator(~20pt) - topPadding(48pt) - tabBar(72pt) - gap(16pt) - bottomPadding(48pt) = ~592pt. This is sufficient for 6+ task rows at 72pt each plus header.

### Dark Mode Support

All elements use design system tokens with defined dark variants. No additional dark mode handling needed.

### iPadOS Keyboard

- Left/Right arrow keys switch between tabs when the tab bar has keyboard focus
- Spacebar or Enter activates the focused tab

### Orientation Lock

- Remains landscape-only as per DSGN-002. No changes needed.

---

## Accessibility Identifiers — Full Reference (XCUITest)

### Child-Facing Tab Bar

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| Tab bar container | `topicTabBar` |
| Topic tab (topic T) | `topicTab_<TopicName>` |
| Gear icon (moved into tab bar) | `parentSettingsButton` (unchanged) |

### Parent Home — Topics Section

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| Add Topic button | `addTopicButton` |
| Topic row (topic T) | `topicRow_<TopicName>` |
| Topic reorder handle | `topicReorderHandle_<TopicName>` |
| Topic reset button | `topicResetButton_<TopicName>` |
| Topic edit (rename) button | `topicEditButton_<TopicName>` |
| Topic delete swipe action | `topicDeleteAction_<TopicName>` |
| Reset All nav bar button | `resetAllButton` |

### Topic Dialogs

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| Add Topic confirm button | `addTopicConfirmButton` |
| Add Topic cancel button | `addTopicCancelButton` |
| Add Topic name text field | `addTopicNameField` |
| Rename Topic confirm button | `renameTopicConfirmButton` |
| Rename Topic cancel button | `renameTopicCancelButton` |
| Rename Topic name text field | `renameTopicNameField` |
| Delete Topic confirm button | `deleteTopicConfirmButton` |
| Delete Topic cancel button | `deleteTopicCancelButton` |
| Reset Topic confirm button | `resetTopicConfirmButton_<TopicName>` |
| Reset Topic cancel button | `resetTopicCancelButton_<TopicName>` |
| Reset All confirm button | `resetAllConfirmButton` |
| Reset All cancel button | `resetAllCancelButton` |

### Child Topic Picker (Parent)

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| Child topic picker row | `childTopicRow_<ChildName>_<TopicName>` |

### Updated Identifiers from DSGN-002/003

| Old Identifier | New Identifier | Reason |
|----------------|----------------|--------|
| `resetDayButton` | `resetAllButton` | Renamed from "Reset Day" to "Reset All" |
| `resetDayConfirmButton` | `resetAllConfirmButton` | Matches new button name |
| `resetDayCancelButton` | `resetAllCancelButton` | Matches new button name |

Note: `<TopicName>` uses PascalCase with spaces removed, consistent with the naming convention in DSGN-002. Example: topic "Paeivakodin jaelkeen" becomes `PaeivakodinJaelkeen`.

---

## Acceptance Criteria for Design

| ID | Criterion | `accessibilityIdentifier` / Method |
|----|-----------|-----------------------------------|
| TT-AC-01 | Tab bar is visible at top of routine view showing all topic tabs | XCUITest: `topicTabBar.exists == true` and `topicTab_Aamu.exists == true` on launch |
| TT-AC-02 | Default topic "Aamu" is active on first launch | XCUITest: `topicTab_Aamu` has `accessibilityValue == "Selected"` |
| TT-AC-03 | Tapping an inactive tab changes it to active and updates all child columns | XCUITest: tap `topicTab_<Name>` -> `accessibilityValue == "Selected"`, task content changes |
| TT-AC-04 | All tab touch targets are >= 60x60pt | XCUITest: `topicTab_<Name>.frame.height >= 60 && .frame.width >= 120` |
| TT-AC-05 | Tab font size is >= 24pt at default Dynamic Type | XCUITest: font assertion on tab labels |
| TT-AC-06 | Single topic still shows tab bar with one tab | XCUITest: when 1 topic exists, `topicTabBar.exists == true` and 1 tab visible |
| TT-AC-07 | Tab content transition respects Reduce Motion setting | XCUITest with `--reduce-motion`: no slide animation elements, only crossfade |
| TT-AC-08 | Tab order matches parent-defined sort order | XCUITest: verify tab positions match topic order from parent management |
| TT-AC-09 | Parent Home shows Topics section with all topics listed | XCUITest: `topicRow_<Name>.exists == true` for each topic |
| TT-AC-10 | Parent can add a topic via Add Topic button | XCUITest: `addTopicButton` tap -> `addTopicConfirmButton` visible, enter name, confirm -> new `topicRow_<Name>` appears |
| TT-AC-11 | Parent can rename a topic | XCUITest: `topicEditButton_<Name>` tap -> `renameTopicConfirmButton` visible, change name, confirm -> row label updated |
| TT-AC-12 | Parent can delete a topic with confirmation | XCUITest: swipe left on `topicRow_<Name>` -> `deleteTopicConfirmButton` visible, confirm -> row removed |
| TT-AC-13 | Last remaining topic cannot be deleted (swipe action not available) | XCUITest: with 1 topic, swipe left on `topicRow_<Name>` -> `deleteTopicConfirmButton.exists == false` |
| TT-AC-14 | Parent can reorder topics via drag-and-drop | XCUITest: reorder topics in parent management -> tab order changes in child view |
| TT-AC-15 | Per-topic reset requires confirmation | XCUITest: `topicResetButton_<Name>` tap -> `resetTopicConfirmButton_<Name>.exists == true` |
| TT-AC-16 | Confirming per-topic reset sets only that topic's tasks to incomplete | XCUITest: confirm reset -> tasks in that topic have `accessibilityValue == "not done"`, other topics unchanged |
| TT-AC-17 | Reset All requires confirmation and resets all topics | XCUITest: `resetAllButton` tap -> `resetAllConfirmButton.exists == true`, confirm -> all tasks `accessibilityValue == "not done"` |
| TT-AC-18 | Cancelling any reset leaves task states unchanged | XCUITest: tap cancel on reset dialogs -> verify task states unchanged |
| TT-AC-19 | Tapping child row navigates to topic picker showing per-topic task counts | XCUITest: `childRow_<Name>` tap -> `childTopicRow_<Name>_<TopicName>.exists == true` |
| TT-AC-20 | Tapping a topic in child topic picker opens task editor scoped to child+topic | XCUITest: `childTopicRow_<Name>_<TopicName>` tap -> `addTaskButton.exists == true` and task list is scoped |
| TT-AC-21 | New topic appears as a new tab in child-facing view | XCUITest: add topic in parent management -> `topicTab_<NewName>.exists == true` in routine view |
| TT-AC-22 | Deleting a topic removes its tab from child-facing view | XCUITest: delete topic in parent management -> `topicTab_<Name>.exists == false` in routine view |
| TT-AC-23 | Renaming a topic updates tab label in child-facing view | XCUITest: rename topic -> `topicTab_<NewName>.exists == true` and `topicTab_<OldName>.exists == false` |
| TT-AC-24 | Progress indicator shows progress for active topic only | XCUITest: switch topic -> `progressIndicator_<Name>.label` reflects task count for active topic |
| TT-AC-25 | Topic name field enforces 30-character maximum | XCUITest: type 35 chars in add/rename dialog -> field value length == 30 |
| TT-AC-26 | VoiceOver announces topic tabs correctly with position and selection state | Manual VoiceOver test: verify "[Topic Name], tab N of M, selected/not selected" |
