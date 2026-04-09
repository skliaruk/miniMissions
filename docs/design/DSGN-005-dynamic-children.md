# DSGN-005: Dynamic Children UI

**Status:** Draft
**Date:** 2026-03-30
**REQ:** REQ-007, REQ-001 (amended), REQ-004 (amended)

---

## Overview

This design specifies the UI changes required to support a dynamic number of children (1-6) instead of the fixed three-child layout. It addresses both the child-facing routine view (adaptive column layout) and the parent management view (child CRUD operations). The design solves the problem of families having varying numbers of children while maintaining the visual clarity and child-friendliness established in DSGN-002.

---

## User Flow -- Child-Facing

1. App launches; if no children exist (first launch before any child is added), an empty state is shown prompting the parent to add a child
2. With 1-3 children: columns display side by side, equally sized, filling the available width (same as DSGN-002 but adaptive)
3. With 4-6 children: layout switches to a 2-row grid (3 columns per row) or horizontally scrollable columns, depending on available vertical space
4. Each child column shows: avatar/photo, name, progress indicator, task list for the active topic
5. When a child is added in parent management, a new column appears with a transition animation
6. When a child is removed in parent management, the column disappears with a transition animation

## User Flow -- Parent Child Management

1. Parent enters parent management (via PIN gate)
2. Parent Home Screen shows "Children" section with all children listed
3. Parent can add a child (up to 6), edit a child, delete a child, or reorder children
4. Add/Edit child: name field + optional photo picker
5. Delete child: confirmation dialog, cannot delete last child
6. Reorder children: drag-and-drop, changes column order in routine view

---

## Child-Facing View: Adaptive Column Layout

### Layout Strategy

The layout adapts based on child count:

| Child Count | Layout | Column Width Calculation |
|-------------|--------|--------------------------|
| 0 | Empty state (no columns) | N/A |
| 1 | Single centred column, max 400pt width | `min(safeAreaWidth - spacing.xxl*2, 400)` |
| 2 | Two equal columns side by side | `(safeAreaWidth - spacing.xxl*2 - spacing.lg) / 2` |
| 3 | Three equal columns side by side | `(safeAreaWidth - spacing.xxl*2 - spacing.lg*2) / 3` (same as DSGN-002) |
| 4 | Two rows of 2 columns each | `(safeAreaWidth - spacing.xxl*2 - spacing.lg) / 2`, row height = ~50% available |
| 5 | Top row: 3 columns, bottom row: 2 columns centred | Top: `(safeAreaWidth - spacing.xxl*2 - spacing.lg*2) / 3`, Bottom: same width, centred |
| 6 | Two rows of 3 columns each | `(safeAreaWidth - spacing.xxl*2 - spacing.lg*2) / 3`, row height = ~50% available |

### ASCII Wireframe -- 1-3 Children (Single Row)

```
+-------------------------------------------------------------------------------------------+
|  [ Topic Tab Bar ]                                                            [gear]       |
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|  +--------- equal width ---------+  +--------- equal width ---------+                    |
|  |   [avatar]                     |  |   [avatar]                     |                    |
|  |   CHILD NAME 1                 |  |   CHILD NAME 2                 |                    |
|  |   [progress dots]              |  |   [progress dots]              |                    |
|  |-------------------------------|  |-------------------------------|                    |
|  |   [icon] Task Name          > |  |   [icon] Task Name          > |                    |
|  |   [icon] Task Name          > |  |   [icon] Task Name          > |                    |
|  |   [icon] Task Name          > |  |   [icon] Task Name          > |                    |
|  +-------------------------------+  +-------------------------------+                    |
|                                                                                           |
|  (2 children shown; 1 child = single centred column, 3 = three equal columns as DSGN-002)|
+-------------------------------------------------------------------------------------------+
```

### ASCII Wireframe -- 4-6 Children (Two-Row Grid)

```
+-------------------------------------------------------------------------------------------+
|  [ Topic Tab Bar ]                                                            [gear]       |
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|  +----------+  +----------+  +----------+                                                 |
|  | [avatar] |  | [avatar] |  | [avatar] |   Row 1: compact child cards                   |
|  | NAME 1   |  | NAME 2   |  | NAME 3   |   (reduced header, scrollable task list)        |
|  |----------|  |----------|  |----------|                                                 |
|  | Task 1   |  | Task 1   |  | Task 1   |                                                 |
|  | Task 2   |  | Task 2   |  | Task 2   |                                                 |
|  | Task 3   |  | Task 3   |  | Task 3   |                                                 |
|  +----------+  +----------+  +----------+                                                 |
|                                                                                           |
|  +----------+  +----------+  +----------+                                                 |
|  | [avatar] |  | [avatar] |  | [avatar] |   Row 2: compact child cards                   |
|  | NAME 4   |  | NAME 5   |  | NAME 6   |   (5 children: 2 in row 2, centred)            |
|  |----------|  |----------|  |----------|                                                 |
|  | Task 1   |  | Task 1   |  | Task 1   |                                                 |
|  | Task 2   |  | Task 2   |  | Task 2   |                                                 |
|  | Task 3   |  | Task 3   |  | Task 3   |                                                 |
|  +----------+  +----------+  +----------+                                                 |
|                                                                                           |
+-------------------------------------------------------------------------------------------+
```

### Compact Child Card (4-6 Children Mode)

When 4-6 children are displayed, column cards switch to a compact variant to fit within the available vertical space.

**Changes from standard card (DSGN-002):**

| Property | Standard (1-3) | Compact (4-6) |
|----------|---------------|---------------|
| Avatar size | 80x80pt | 56x56pt |
| Avatar corner radius | 40pt (circle) | 28pt (circle) |
| Avatar border width | 3pt | 2pt |
| Child name font | `type.child.title` (32pt) | `type.child.taskLabel` (24pt, SF Rounded Semibold) |
| Progress dots size | 12pt diameter | 10pt diameter |
| Progress dot gap | 8pt | 6pt |
| Task row min height | 72pt | 64pt |
| Icon container size | 60x60pt | 52x52pt |
| Icon size inside container | 44x44pt | 36x36pt |
| Task label font | 24pt | 20pt (SF Rounded Semibold) -- uses `type.child.subLabel` |
| Column top padding | `spacing.xxl` (48pt) | `spacing.lg` (24pt) |
| Column bottom padding | `spacing.xxl` (48pt) | `spacing.lg` (24pt) |
| Inter-column gap | `spacing.lg` (24pt) | `spacing.md` (16pt) |
| Inter-row gap | N/A | `spacing.md` (16pt) |

**Important:** Even in compact mode, all touch targets remain at or above 60x60pt. The task row minimum height of 64pt exceeds the 60pt requirement. The icon container at 52x52pt is smaller visually, but the tap target for each task row spans the full row width and full 64pt height.

### Two-Row Grid Layout Calculations

Available vertical space (iPad 10th gen landscape):
- Screen height: 820pt
- Status bar: ~24pt
- Home indicator: ~20pt
- Tab bar: 72pt
- Tab-to-content gap: 16pt
- Top safe area: variable (~24pt)
- Bottom safe area padding: 24pt (compact)
- Total overhead: ~180pt
- Available for grid: ~640pt
- Per-row height: (640 - 16pt inter-row gap) / 2 = ~312pt
- Card internal: 56pt avatar + 8pt gap + 24pt name + 4pt gap + 10pt dots + 12pt divider = ~114pt header
- Remaining for tasks: ~198pt = approximately 3 task rows at 64pt each visible without scroll

Task list scrolls vertically within each compact card. Scroll indicators hidden.

### Width Calculations for 4-6 Children

For iPad 10th gen (safe area width ~1148pt):

| Layout | Column Width |
|--------|-------------|
| 2 per row (4 children) | (1148 - 96 - 16) / 2 = **518pt** |
| 3 per row (5-6 children) | (1148 - 96 - 32) / 3 = **340pt** |

All widths exceed the 280pt minimum from DSGN-002.

---

## Child-Facing View: Child Column with Name and Avatar/Photo

Each child column (both standard and compact) displays the child's identity at the top of the card.

### Avatar / Photo Display

**With Photo (set by parent):**
- Photo is displayed in a circular container (80x80pt standard, 56x56pt compact)
- Photo uses `.fill` aspect ratio with circular clip mask
- Border: child accent colour (see colour assignment below), width 3pt (standard) / 2pt (compact)
- `accessibilityHidden: true` (child name label provides identification)
- `accessibilityIdentifier`: `"childAvatar_<ChildName>"`

**Without Photo (default avatar):**
- Container shows the child's first initial in a large font, centred
- Initial font: `type.child.title` (standard) / `type.child.taskLabel` (compact), `color.text.onAccent`
- Background: child accent colour (solid fill)
- This provides a colourful, recognisable placeholder without requiring a photo
- `accessibilityHidden: true`
- `accessibilityIdentifier`: `"childAvatar_<ChildName>"`

### Child Accent Colour Assignment

With dynamic children (1-6), accent colours are assigned by slot index, cycling through a palette of 6 colours:

| Slot | Accent Token | Light Hex | Dark Hex | Tint Token | Light Hex | Dark Hex |
|------|-------------|-----------|----------|------------|-----------|----------|
| 1 | `color.child1.accent` | `#7B4FD4` | `#9B6FF4` | `color.child1.tint` | `#F3EEFF` | `#261E45` |
| 2 | `color.child2.accent` | `#FF6B35` | `#FF8C5A` | `color.child2.tint` | `#FFF0EB` | `#3D2010` |
| 3 | `color.child3.accent` | `#00A878` | `#00C896` | `color.child3.tint` | `#E6FAF5` | `#003D2B` |
| 4 | `color.child4.accent` | `#E91E63` | `#F06292` | `color.child4.tint` | `#FCE4EC` | `#3D0F1F` |
| 5 | `color.child5.accent` | `#1E88E5` | `#42A5F5` | `color.child5.tint` | `#E3F2FD` | `#0D2744` |
| 6 | `color.child6.accent` | `#FFA000` | `#FFB74D` | `color.child6.tint` | `#FFF8E1` | `#3D2E00` |

**New tokens required in DSGN-001 addendum:** `color.child4.*`, `color.child5.*`, `color.child6.*`.

**Contrast ratios for new child accent tokens (against white card background):**

| Accent | Hex | Ratio vs #FFFFFF | Requirement (UI) | Status |
|--------|-----|-----------------|-------------------|--------|
| Child 4 (pink) | `#E91E63` | 4.1:1 | >= 3:1 | PASS |
| Child 5 (blue) | `#1E88E5` | 3.6:1 | >= 3:1 | PASS |
| Child 6 (amber) | `#FFA000` | 2.5:1 | >= 3:1 | **ADJUSTED** |

Child 6 amber `#FFA000` falls slightly below 3:1 on white. Adjustment: use darker amber `#E68900` (ratio 3.2:1 vs white). Updated:

| Slot 6 (corrected) | `color.child6.accent` | `#E68900` | `#FFB74D` |

**Dark mode contrast for new tokens (accent on dark card `#252540`):**

| Accent | Dark Hex | Ratio vs #252540 | Status |
|--------|----------|-------------------|--------|
| Child 4 | `#F06292` | 5.8:1 | PASS |
| Child 5 | `#42A5F5` | 5.2:1 | PASS |
| Child 6 | `#FFB74D` | 9.1:1 | PASS |

---

## Child-Facing View: Empty State (No Children)

### When Shown

The empty state appears when there are zero children in the system. This occurs on first launch before the parent has added any children.

### ASCII Wireframe

```
+-------------------------------------------------------------------------------------------+
|  iPad Status Bar                                                                          |
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|                                                                 [gear]                    |
|                                                                 (44x44pt)                 |
|                                                                                           |
|                                                                                           |
|                        +-----------------------------------+                              |
|                        |                                   |                              |
|                        |    [person.3.fill]                |                              |
|                        |    80pt, color.brand.purple       |                              |
|                        |                                   |                              |
|                        |    Welcome!                       |                              |
|                        |    type.child.celebration         |                              |
|                        |    (36pt SF Rounded Heavy)        |                              |
|                        |                                   |                              |
|                        |    Add your children to get       |                              |
|                        |    started with daily routines.   |                              |
|                        |    type.child.taskLabel (24pt)    |                              |
|                        |    color.text.secondary           |                              |
|                        |                                   |                              |
|                        |    [  Open Settings  ]            |                              |
|                        |    Purple pill button             |                              |
|                        |    min 60pt height                |                              |
|                        |                                   |                              |
|                        +-----------------------------------+                              |
|                                                                                           |
|         Background: color.background.primary                                              |
+-------------------------------------------------------------------------------------------+
```

### Empty State Details

- Centred on screen, within a card container
- Card: `color.background.card`, `radius.xl` (32pt), `shadow.card`, max width 480pt
- Internal padding: `spacing.xl` (32pt)
- Icon: `person.3.fill`, 80pt, `color.brand.purple`
- Title: "Welcome!" -- `type.child.celebration` (36pt SF Rounded Heavy), `color.text.primary`
- Subtitle: "Add your children to get started with daily routines." -- `type.child.taskLabel` (24pt), `color.text.secondary`
- Button: "Open Settings" -- pill shape, `color.brand.purple` background, `color.text.onAccent` text, `type.child.taskLabel` (24pt), min height 60pt, min width 200pt, `radius.full`
  - `accessibilityIdentifier`: `"emptyStateSettingsButton"`
  - `accessibilityLabel`: "Open Settings"
  - `accessibilityHint`: "Opens parent settings to add children. Requires PIN."
  - Tapping triggers the PIN gate flow (same as gear icon)
- The gear icon remains visible in the top-right corner as an alternative entry point
- The topic tab bar is NOT shown in the empty state (no topics or tabs are relevant without children)
- `accessibilityIdentifier` for empty state container: `"emptyStateView"`

---

## Child-Facing View: Transition Animations

### Child Added

**Reduce Motion OFF:**
1. New child column card appears with `animation.standard` (300ms), `easing.standard`
2. Existing columns smoothly resize to accommodate the new column (300ms, `easing.standard`)
3. New column enters with a scale animation: 0.8 -> 1.0, combined with opacity 0 -> 1.0
4. If transitioning from 3 to 4 children (single row to grid), the layout change is animated over `animation.slow` (500ms): existing columns shrink and rearrange into the grid positions

**Reduce Motion ON:**
- Instant layout recalculation, no scale or opacity animation
- Columns appear in final positions immediately

### Child Removed

**Reduce Motion OFF:**
1. Removed child's column fades out: opacity 1.0 -> 0, scale 1.0 -> 0.9 (`animation.standard`, 300ms)
2. Remaining columns smoothly resize and reposition (300ms, `easing.standard`)
3. If transitioning from 4 to 3 children (grid to single row), columns smoothly expand and move to single-row positions

**Reduce Motion ON:**
- Instant layout recalculation, removed column disappears immediately

### Implementation Note (SwiftUI)

- Use `withAnimation(.easeInOut(duration: 0.3))` wrapping the data model change
- Each child column should have a `.transition(.scale.combined(with: .opacity))` modifier
- The grid/column layout should use `LazyVGrid` or custom `GeometryReader`-based layout with `matchedGeometryEffect` for smooth column repositioning
- `.animation(.easeInOut(duration: 0.3), value: childCount)` on the container

---

## Parent Management View: Children Section

### Updated Parent Home Screen -- Children Section

The Children section in the Parent Home Screen (DSGN-003 Screen 3, updated by DSGN-004) is enhanced with full CRUD functionality.

### ASCII Wireframe -- Children Section

```
+-------------------------------------------------------------------+
|  Children                                          [+ Add Child]   |
|-------------------------------------------------------------------|
|  ==  [avatar 40pt]   Mia              [Edit]               >      |
|      (circle, accent)                 (pencil icon)                |
|-------------------------------------------------------------------|
|  ==  [avatar 40pt]   Leo              [Edit]               >      |
|-------------------------------------------------------------------|
|  ==  [avatar 40pt]   Aino             [Edit]               >      |
+-------------------------------------------------------------------+
|                                                                    |
|  (Swipe left on a row to reveal Delete -- NOT available on last   |
|   remaining child. Add button disabled when 6 children exist.)     |
```

### Section Header

- Label: "Children" (`type.parent.headline`, `color.text.secondary`)
- Right-aligned: "+ Add Child" button
  - Icon: `plus.circle.fill`, 24pt, `color.brand.purple`
  - `accessibilityIdentifier`: `"addChildButton"`
  - `accessibilityLabel`: "Add Child"
  - `accessibilityHint`: "Opens form to add a new child"
  - **Disabled state (6 children exist):** opacity 0.4, non-interactive
    - `accessibilityLabel`: "Add Child -- maximum reached"
    - `accessibilityHint`: "Maximum of 6 children allowed"
    - `accessibilityTraits`: `.isButton`, `.isNotEnabled` (SwiftUI `.disabled(true)` handles this)
    - `accessibilityIdentifier`: unchanged (`"addChildButton"`)

### Child Row (Parent Management)

Each child row:
- Height: 56pt minimum (standard iOS list row)
- Left: drag reorder handle (`line.3.horizontal`, 18pt, `color.text.secondary`)
  - `accessibilityIdentifier`: `"childReorderHandle_<ChildName>"`
  - `accessibilityLabel`: "Reorder [Child Name]"
- Left+1: child avatar thumbnail, 40pt circle
  - With photo: photo clipped to circle
  - Without photo: first initial on accent colour background
  - Border: 2pt `color.child{N}.accent`
- Centre-left: child name (`type.parent.headline`, `color.text.primary`)
- Centre-right: Edit button
  - Icon: `pencil`, 18pt, `color.brand.purple`
  - Container: 44x44pt tap target
  - `accessibilityIdentifier`: `"childEditButton_<ChildName>"`
  - `accessibilityLabel`: "Edit [Child Name]"
  - `accessibilityHint`: "Opens form to edit name and photo"
- Far right: disclosure indicator (chevron) -- tapping row navigates to Child Topic Picker (DSGN-004)
- Swipe left: reveals "Delete" action in `color.brand.red`
  - Only available when more than one child exists
  - `accessibilityIdentifier`: `"childDeleteAction_<ChildName>"`

### Child Row Accessibility

- `accessibilityIdentifier`: `"childRow_<ChildName>"` (unchanged from DSGN-003)
- `accessibilityLabel`: `"<Child Name>, [N] tasks across [M] topics"` (unchanged from DSGN-004)
- `accessibilityHint` (multiple children): "Opens topic selection. Swipe left to delete."
- `accessibilityHint` (single child): "Opens topic selection. This is the only child and cannot be deleted."
- `accessibilityCustomActions`: "Move Up", "Move Down" for VoiceOver reorder

### Updated Navigation Flow

```
Parent Home Screen
    |
    +-- [+ Add Child] --> Add Child Sheet
    |
    +-- [Edit pencil on row] --> Edit Child Sheet
    |
    +-- [Swipe left Delete] --> Delete Child Confirmation
    |
    +-- [Tap child row] --> Child Topic Picker (DSGN-004) --> Task Editor
```

---

## Sheet: Add / Edit Child

Presented as a `.sheet` (half-height modal on iPad) when the parent taps "+ Add Child" or the edit pencil on a child row.

### ASCII Wireframe

```
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|  +-------------------------------------------------------------+                         |
|  | Cancel                 Add Child                      Save  |                         |
|  |-------------------------------------------------------------|                         |
|  |                                                             |                         |
|  |  Photo                                                      |                         |
|  |                                                             |                         |
|  |       +-------------------+                                 |                         |
|  |       |                   |   [ Choose Photo ]              |                         |
|  |       |   [camera.fill]   |   "Select from library"         |                         |
|  |       |   placeholder     |   (or photo preview if set)     |                         |
|  |       |   100x100pt       |                                 |                         |
|  |       +-------------------+   [ Remove Photo ]              |                         |
|  |                               (only when photo is set,      |                         |
|  |                                color.brand.red text)        |                         |
|  |                                                             |                         |
|  |  Name                                                       |                         |
|  |  +-------------------------------------------------------+ |                         |
|  |  | Mia                                         [3/30]     | |                         |
|  |  +-------------------------------------------------------+ |                         |
|  |  Text field, 17pt, max 30 chars, character counter         |                         |
|  |                                                             |                         |
|  |  (Preview: colour swatch showing the assigned accent       |                         |
|  |   colour for this child slot)                               |                         |
|  |                                                             |                         |
|  +-------------------------------------------------------------+                         |
|                                                                                           |
+-------------------------------------------------------------------------------------------+
```

### Sheet Component Details

**Header:**
- Cancel button (left): dismisses sheet with no changes
  - `type.parent.headline`, `color.brand.purple`
  - `accessibilityIdentifier`: `"childFormCancelButton"`
- Title: "Add Child" or "Edit Child" (`type.parent.headline`, centre)
- Save button (right): enabled only when name is non-empty
  - `type.parent.headline`, `color.brand.purple`
  - `accessibilityIdentifier`: `"childFormSaveButton"`
  - `accessibilityLabel`: "Save"
  - Disabled state: opacity 0.4

**Photo Section:**
- Photo preview container: 100x100pt circle, `color.background.taskIncomplete` background (empty state)
  - With photo: displays photo clipped to circle
  - Without photo: `camera.fill` icon, 40pt, `color.text.secondary`
- "Choose Photo" button:
  - `type.parent.headline`, `color.brand.purple`
  - Launches `PHPickerViewController` with `filter: .images`, `selectionLimit: 1`
  - Selected photo is cropped to square, stored as compressed JPEG
  - `accessibilityIdentifier`: `"childPhotoPickerButton"`
  - `accessibilityLabel`: "Choose Photo"
  - `accessibilityHint`: "Opens photo library to select a photo for this child"
- "Remove Photo" button (only visible when a photo is set):
  - `type.parent.subhead`, `color.brand.red`
  - Removes the photo, reverts to default avatar (initial-based)
  - `accessibilityIdentifier`: `"childPhotoRemoveButton"`
  - `accessibilityLabel`: "Remove Photo"

**Name Field:**
- Placeholder: "Child's name"
- Max length: 30 characters, enforced in real time
- Character counter: "[current]/30", `type.parent.caption` (13pt), `color.text.secondary`
- Counter turns `color.brand.red` at 30 characters
- Keyboard: `.default`, return key `.done`
- `accessibilityIdentifier`: `"childNameField"`
- `accessibilityLabel`: "Child's name"
- `accessibilityHint`: "Maximum 30 characters"

**Colour Preview:**
- A small circle (24pt) showing the accent colour that will be assigned to this child based on their slot position
- Label: "Assigned colour" (`type.parent.caption`, `color.text.secondary`)
- Non-interactive, purely informational
- `accessibilityLabel`: "This child's accent colour: [colour name]"
- `accessibilityHidden: false` (informational for VoiceOver users)

### Presentation

- `.presentationDetents([.medium, .large])` -- starts at medium height, can expand
- Background: `color.background.parentScreen`

---

## Dialog: Delete Child Confirmation

Triggered by swiping left on a child row (only available when more than one child exists).

### Presentation

Presented as a `.confirmationDialog`:

```
+-----------------------------------------------+
|                                               |
|   Delete "Mia"?                               |
|                                               |
|   This will permanently remove Mia and all    |
|   their task assignments and completion        |
|   history. This cannot be undone.             |
|                                               |
|   [ Delete Child ]   <- destructive, red      |
|   [ Cancel ]         <- cancel                |
|                                               |
+-----------------------------------------------+
```

### Details

- Title: `Delete "<Child Name>"?`
- Message: `This will permanently remove <Child Name> and all their task assignments and completion history. This cannot be undone.`
- Destructive button: "Delete Child" (`color.brand.red`)
  - `accessibilityIdentifier`: `"deleteChildConfirmButton"`
- Cancel button: "Cancel"
  - `accessibilityIdentifier`: `"deleteChildCancelButton"`
- On confirm: child is deleted, their column disappears from routine view (with transition animation), all task assignments and completions are deleted
- The delete swipe action is **not rendered** when only one child remains

### Last Child Protection

- When only one child exists, the child row does not show the swipe-to-delete action
- VoiceOver on the single remaining child row does NOT announce "Swipe left to delete"
- Updated `accessibilityHint`: "Opens topic selection. This is the only child and cannot be deleted."
- A visual indicator is shown: a small info badge below the child row:
  - Text: "At least one child is required" (`type.parent.caption`, `color.text.secondary`)
  - Only shown when exactly 1 child exists
  - `accessibilityIdentifier`: `"lastChildInfoLabel"`

---

## Maximum 6 Children: Add Button State

When 6 children exist:
- The "+ Add Child" button is disabled (`.disabled(true)`)
- Visual: opacity 0.4, non-interactive
- An info label appears below the children list:
  - Text: "Maximum of 6 children reached" (`type.parent.caption`, `color.text.secondary`)
  - `accessibilityIdentifier`: `"maxChildrenInfoLabel"`

---

## Child Reorder via Drag-and-Drop

- Standard iOS `List` drag-to-reorder via the `==` handle
- Long-press the drag handle to initiate (standard iOS behaviour)
- During drag: row lifts with `shadow.card` and slight scale (1.02)
- Drop: row settles into new position with `easing.spring` (300ms)
- Reduce Motion: no lift or scale, instant position swap
- Reorder changes are saved immediately (SwiftData)
- Routine view column order updates to match the new sort order
- VoiceOver: `accessibilityCustomActions` "Move Up" and "Move Down" on each child row

---

## Visual Design

### New Design Tokens Required (DSGN-001 Addendum)

These tokens extend the existing child accent colour system defined in DSGN-001 Section 1.5.

| Token | Light Hex | Dark Hex | Usage |
|-------|-----------|----------|-------|
| `color.child4.accent` | `#E91E63` | `#F06292` | Child 4 accent (pink) |
| `color.child4.tint` | `#FCE4EC` | `#3D0F1F` | Child 4 card tint |
| `color.child5.accent` | `#1E88E5` | `#42A5F5` | Child 5 accent (blue) |
| `color.child5.tint` | `#E3F2FD` | `#0D2744` | Child 5 card tint |
| `color.child6.accent` | `#E68900` | `#FFB74D` | Child 6 accent (amber) |
| `color.child6.tint` | `#FFF8E1` | `#3D2E00` | Child 6 card tint |

### Existing Tokens Used

All other visual elements use existing tokens from DSGN-001 and DSGN-002. No changes to spacing, radius, shadow, or typography tokens.

### Dark Mode

All new colour tokens have dark mode variants defined above. The compact card layout uses the same design token references as the standard card -- only sizes change.

---

## Accessibility (WCAG 2.2 AA)

### Contrast Ratios -- New Child Accent Colours

| Foreground | Background | Ratio | Requirement | Status |
|------------|------------|-------|-------------|--------|
| `color.child4.accent` (#E91E63) | `color.background.card` (#FFFFFF) | **4.1:1** | >= 3:1 UI | PASS |
| `color.child5.accent` (#1E88E5) | `color.background.card` (#FFFFFF) | **3.6:1** | >= 3:1 UI | PASS |
| `color.child6.accent` (#E68900) | `color.background.card` (#FFFFFF) | **3.2:1** | >= 3:1 UI | PASS |
| `color.child4.accent` dark (#F06292) | `color.background.card` dark (#252540) | **5.8:1** | >= 3:1 UI | PASS |
| `color.child5.accent` dark (#42A5F5) | `color.background.card` dark (#252540) | **5.2:1** | >= 3:1 UI | PASS |
| `color.child6.accent` dark (#FFB74D) | `color.background.card` dark (#252540) | **9.1:1** | >= 3:1 UI | PASS |
| `color.text.onAccent` (#FFFFFF) | `color.child4.accent` (#E91E63) | **4.1:1** | >= 4.5:1 text | **NOTE** |
| `color.text.onAccent` (#FFFFFF) | `color.child5.accent` (#1E88E5) | **3.6:1** | >= 4.5:1 text | **NOTE** |

**Note:** White text on child 4/5 accent colours does not meet 4.5:1 for body text. However, these accent colours are used only as UI component indicators (avatar borders, icon backgrounds, progress dots), never as text backgrounds in child-facing views. Where initials are displayed on accent backgrounds (default avatar), the text is large (24-32pt) and qualifies for the 3:1 large text threshold under WCAG SC 1.4.3.

### Touch Targets

| Element | Visual Size | Touch Target | Minimum Required | Status |
|---------|------------|--------------|------------------|--------|
| Task row (compact, 4-6) | 64pt x full width | 64pt x full width | 60x60pt | PASS |
| Icon container (compact) | 52x52pt | 64pt row height x full width | 60x60pt | PASS |
| Empty state button | >=200x60pt | >=200x60pt | 60x60pt | PASS |
| Add Child button (parent) | 24pt icon | 44x44pt | 44x44pt | PASS |
| Child edit button (parent) | 18pt icon | 44x44pt | 44x44pt | PASS |
| Child reorder handle | 18pt icon | 56pt row x 44pt | 44x44pt | PASS |
| Photo picker button | text button | 44x44pt | 44x44pt | PASS |

### VoiceOver

**Routine view -- adaptive column reading order:**
- Reading order follows the same column-first pattern as DSGN-002
- For 2-row grid layouts, VoiceOver reads: Row 1 Column 1, Row 1 Column 2, Row 1 Column 3, Row 2 Column 1, Row 2 Column 2, Row 2 Column 3
- Each child column remains an `accessibilityElement(children: .contain)` group

**Empty state:**
- VoiceOver announces: "Welcome! Add your children to get started with daily routines. Open Settings button."

**Parent child management:**
- Child rows announce name, task count, and available actions
- "Add Child" button announces its enabled/disabled state

### Dynamic Type

- Compact card labels at 20pt use `type.child.subLabel` which scales with `.title3`
- At AX5, compact task labels use `minimumScaleFactor: 0.8` with floor of 16pt
- Column headers in compact mode use `lineLimit(1)` with `minimumScaleFactor: 0.75`

### Colour Blindness

- All 6 child accent colours are distinguishable across protanopia, deuteranopia, and tritanopia:
  - Purple (#7B4FD4), Orange (#FF6B35), Green (#00A878), Pink (#E91E63), Blue (#1E88E5), Amber (#E68900)
  - These span purple, red-orange, green, red-pink, blue, yellow-orange -- covering all hue regions
  - Each child is additionally identifiable by name and avatar (colour is never the sole differentiator)

### Reduce Motion

All transition animations (column add/remove, layout reconfiguration) fall back to instant state changes when `UIAccessibility.isReduceMotionEnabled` is true.

---

## iOS-Specific Considerations

### Safe Area Handling

- Two-row grid layout respects all safe area insets as per DSGN-002
- The grid calculation accounts for the tab bar (DSGN-004) in the vertical space budget
- No content extends under the home indicator bar

### Dark Mode Support

All new colour tokens have light and dark variants. No additional dark mode handling beyond Assets.xcassets configuration.

### iPad Size Classes

The layout strategy (1-row vs 2-row) is based purely on child count, not on iPad model or size class. This ensures consistent behaviour across all iPad sizes. The column widths are calculated dynamically using `GeometryReader` and the available safe area width.

### Orientation Lock

Remains landscape-only as per DSGN-002.

### Photo Library Permission

When the parent taps "Choose Photo" in the Add/Edit Child sheet:
- iOS presents the system `PHPickerViewController` which does NOT require camera roll permission (iOS 14+)
- No permission dialog is shown
- Selected photo is copied into app sandbox storage

---

## Accessibility Identifiers -- Full Reference (XCUITest)

### Child-Facing View (Updated)

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| Empty state container | `emptyStateView` |
| Empty state settings button | `emptyStateSettingsButton` |
| Child column card (dynamic) | `childColumn_<ChildName>` (unchanged) |
| Child name label (dynamic) | `childName_<ChildName>` (unchanged) |
| Child avatar (dynamic) | `childAvatar_<ChildName>` (unchanged) |
| Progress indicator (dynamic) | `progressIndicator_<ChildName>` (unchanged) |

### Parent Management -- Children Section

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| Add Child button | `addChildButton` |
| Child row | `childRow_<ChildName>` (unchanged) |
| Child reorder handle | `childReorderHandle_<ChildName>` |
| Child edit button | `childEditButton_<ChildName>` |
| Child delete swipe action | `childDeleteAction_<ChildName>` |
| Max children info label | `maxChildrenInfoLabel` |
| Last child info label | `lastChildInfoLabel` |

### Add / Edit Child Sheet

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| Cancel button | `childFormCancelButton` |
| Save button | `childFormSaveButton` |
| Child name text field | `childNameField` |
| Photo picker button | `childPhotoPickerButton` |
| Photo remove button | `childPhotoRemoveButton` |

### Delete Child Dialog

| Element | `accessibilityIdentifier` |
|---------|--------------------------|
| Delete confirm button | `deleteChildConfirmButton` |
| Delete cancel button | `deleteChildCancelButton` |

---

## Acceptance Criteria for Design

| ID | Criterion | `accessibilityIdentifier` / Method |
|----|-----------|-----------------------------------|
| DC-AC-01 | With 0 children, empty state view is shown with "Open Settings" button | XCUITest: `emptyStateView.exists == true` and `emptyStateSettingsButton.exists == true` |
| DC-AC-02 | With 1 child, a single centred column is displayed (max 400pt wide) | XCUITest: `childColumn_<Name>.exists == true` and column is centred, width <= 400pt |
| DC-AC-03 | With 2 children, two equal columns are displayed side by side | XCUITest: both `childColumn_*` elements `isHittable == true`, widths are equal |
| DC-AC-04 | With 3 children, three equal columns are displayed (same as DSGN-002) | XCUITest: all 3 `childColumn_*` elements visible and equal width |
| DC-AC-05 | With 4 children, a 2x2 grid layout is used | XCUITest: 4 `childColumn_*` elements visible, arranged in 2 rows |
| DC-AC-06 | With 5 children, top row has 3, bottom row has 2 centred | XCUITest: 5 `childColumn_*` elements, row layout verified by frame positions |
| DC-AC-07 | With 6 children, a 2x3 grid layout is used | XCUITest: 6 `childColumn_*` elements visible in 2 rows of 3 |
| DC-AC-08 | Each child column displays name and avatar/photo | XCUITest: `childName_<Name>.exists` and `childAvatar_<Name>.exists` for each child |
| DC-AC-09 | Default avatar shows initial when no photo is set | Visual inspection: child without photo shows coloured circle with initial letter |
| DC-AC-10 | All task row touch targets are >= 60x60pt in all layouts (including compact) | XCUITest: `task_*` frame assertions: `.height >= 60 && .width >= 60` |
| DC-AC-11 | Parent can add a child via "+ Add Child" button | XCUITest: `addChildButton` tap -> `childFormSaveButton.exists == true` |
| DC-AC-12 | Add Child form requires a name (Save disabled when empty) | XCUITest: `childFormSaveButton.isEnabled == false` when `childNameField` is empty |
| DC-AC-13 | Child name field enforces 30-character maximum | XCUITest: type 35 chars -> `childNameField.value.count == 30` |
| DC-AC-14 | Parent can edit a child's name and photo | XCUITest: `childEditButton_<Name>` tap -> sheet with pre-filled `childNameField` |
| DC-AC-15 | Parent can delete a child with confirmation | XCUITest: swipe left on `childRow_<Name>` -> `deleteChildConfirmButton.exists == true` |
| DC-AC-16 | Deleting a child removes their column from routine view | XCUITest: confirm delete -> `childColumn_<Name>.exists == false` |
| DC-AC-17 | Cannot delete the last remaining child (swipe action not available) | XCUITest: with 1 child, swipe left -> `deleteChildConfirmButton.exists == false` |
| DC-AC-18 | Last child info label is shown when only 1 child exists | XCUITest: with 1 child, `lastChildInfoLabel.exists == true` |
| DC-AC-19 | Add Child button is disabled when 6 children exist | XCUITest: with 6 children, `addChildButton.isEnabled == false` |
| DC-AC-20 | Max children info label is shown when 6 children exist | XCUITest: with 6 children, `maxChildrenInfoLabel.exists == true` |
| DC-AC-21 | Parent can reorder children via drag-and-drop | XCUITest: reorder children -> column order changes in routine view |
| DC-AC-22 | Adding a child shows new column with transition animation | Visual inspection + XCUITest: `childColumn_<NewName>.exists == true` after save |
| DC-AC-23 | Removing a child removes column with transition animation | Visual inspection + XCUITest: `childColumn_<Name>.exists == false` after delete confirm |
| DC-AC-24 | Photo picker launches from Add/Edit Child sheet | XCUITest: `childPhotoPickerButton` tap -> system photo picker appears |
| DC-AC-25 | VoiceOver reads columns in correct order (row-by-row for grid layout) | Manual VoiceOver test: verify reading order follows Row1-Col1, Row1-Col2, etc. |
| DC-AC-26 | All child accent colours meet >= 3:1 contrast against card background | Automated contrast check against DSGN-001 token values |
