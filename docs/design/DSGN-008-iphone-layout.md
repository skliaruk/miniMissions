# DSGN-008: iPhone Layout Adaptation

**Status:** Draft
**Date:** 2026-04-15
**REQ:** REQ-001, REQ-002, REQ-003, REQ-004, REQ-005

## Overview

The existing MiniMissions app is iPad-only, landscape-locked, with side-by-side child columns. This document defines how the app adapts to iPhone form factors (portrait-only). The core challenge: iPhone screens are too narrow for multi-column child layouts and too small for the 60pt child-facing touch targets at iPad scale. This design preserves the child-friendly, large-target philosophy while fitting into a single-column, vertically-scrollable paradigm.

**Key principle:** One child visible at a time. Swipe horizontally between children (paged).

---

## 1. Orientation & Device Targets

| Property | Value |
|----------|-------|
| Orientation | **Portrait only** (locked) |
| Minimum device | iPhone SE 3rd gen (375 x 667pt) |
| Primary target | iPhone 14/15/16 (390 x 844pt) |
| Large target | iPhone 14/15/16 Plus/Pro Max (430 x 932pt) |

**Rationale for portrait-only:**
- Children use the app one-handed or flat on a table
- Portrait is the natural iPhone grip
- Eliminates layout complexity for a child audience
- Matches iPad decision of locking orientation

---

## 2. Navigation Structure

### 2.1 iPad vs iPhone Comparison

| Aspect | iPad | iPhone |
|--------|------|--------|
| Child display | Side-by-side columns (1-6) | One child at a time, horizontal paging |
| Topic navigation | Horizontal pill tab bar at top | Same concept, scrollable pill bar |
| Parent entry | Gear icon inside topic tab bar | Gear icon in top-right (NavigationStack toolbar) |
| Parent management | Full-screen NavigationStack + List | Same (NavigationStack + List, full-screen cover) |
| PIN entry | Full-screen cover | Same |
| Paywall | Sheet (.large) | Same |

### 2.2 iPhone Navigation Hierarchy

```
ContentRootView
  |
  +-- ChildRoutineView (main screen)
  |     |-- NavigationStack (for toolbar)
  |     |-- Topic tab bar (top, horizontal scroll)
  |     |-- Child pager (TabView with .page style)
  |     |     +-- ChildPageView (one per child)
  |     |           +-- Avatar + name header
  |     |           +-- Progress indicator
  |     |           +-- Task list (vertical scroll)
  |     +-- Page indicator dots (bottom)
  |
  +-- PINSetupView (fullScreenCover)
  +-- PINEntryView (fullScreenCover)
  +-- ParentHomeView (fullScreenCover)
        +-- NavigationStack + List (same as iPad)
```

**No TabBar is used.** The app has a single primary screen (child tasks). A TabBar would add unnecessary complexity for a toddler-facing app. Parent management remains behind the PIN-gated gear icon.

---

## 3. Screen Designs

### 3.1 Child Task List View (Main Screen)

This is the primary screen. One child's tasks fill the viewport. Horizontal swipe moves to the next child.

```
+------------------------------------------+
|  [Morning]  [After daycare]    [Gear]    |  <-- topic pills + settings
+------------------------------------------+
|                                          |
|              ( Avatar )                  |  <-- 64pt circle
|              Child Name                  |  <-- childTitle (28pt rounded)
|            * * * o o o                   |  <-- progress dots
|                                          |
|  +--------------------------------------+|
|  | [Icon]  Brush Teeth                  ||  <-- task row
|  +--------------------------------------+|
|  | [Icon]  Get Dressed             [ok] ||  <-- completed task
|  +--------------------------------------+|
|  | [Icon]  Pack Backpack                ||
|  +--------------------------------------+|
|  | [Icon]  Eat Breakfast                ||
|  +--------------------------------------+|
|  | [Icon]  Put On Shoes                 ||
|  +--------------------------------------+|
|                                          |
|                                          |
|              o  *  o                     |  <-- page dots (child indicator)
+------------------------------------------+
```

#### 3.1.1 Layout Specifications

| Element | iPhone SE (375pt) | iPhone 15 (390pt) | iPhone Plus (430pt) |
|---------|-------------------|-------------------|---------------------|
| Screen horizontal padding | 16pt | 16pt | 20pt |
| Topic tab bar height | 56pt | 56pt | 56pt |
| Topic pill min size | 64x48pt | 80x48pt | 80x48pt |
| Avatar diameter | 56pt | 64pt | 72pt |
| Child name font | 24pt rounded bold | 28pt rounded bold | 28pt rounded bold |
| Task row min height | 64pt | 72pt | 72pt |
| Task icon container | 48x48pt | 56x56pt | 60x60pt |
| Task label font | 20pt rounded semibold | 22pt rounded semibold | 24pt rounded semibold |
| Page indicator area | 32pt | 32pt | 32pt |

**Adaptive sizing strategy:** Use `@Environment(\.horizontalSizeClass)` to detect compact vs regular. All iPhone models are compact. Within compact, use `GeometryReader` to scale elements proportionally.

#### 3.1.2 Topic Tab Bar (iPhone)

The topic tab bar sits at the top inside a `NavigationStack` toolbar area or directly below the safe area. It scrolls horizontally when topics overflow.

```
+------------------------------------------+
| [Morning]  [After daycare]  [Evening]  * |
+------------------------------------------+
                                         ^
                                    gear icon (44x44pt)
```

- Pills: `color.brand.purpleLight` inactive, `color.brand.purple` active (same as iPad)
- Minimum pill size: 64x48pt (iPhone SE), 80x48pt (standard+)
- Font: `type.child.taskLabel` scaled down to 18pt on SE, 20pt on standard
- Gear icon: 44x44pt touch target, right-aligned, separated by `Spacer()`
- The tab bar has no card background on iPhone (saves vertical space). Instead, a thin 1pt `color.border.taskRow` separator sits below it.

#### 3.1.3 Child Pager

Implemented as `TabView` with `.tabViewStyle(.page(indexDisplayMode: .never))`. Custom page dots are rendered below the task list.

- Swipe gesture: standard iOS paging physics
- Page transition: horizontal slide (same direction-aware behaviour as iPad topic transition per DSGN-004)
- Reduce Motion: crossfade instead of slide
- Current child index stored in `@State` and bound to TabView selection
- If only 1 child: pager still wraps content but page dots are hidden

#### 3.1.4 Task Row (iPhone)

The task row is adapted from the iPad's `TaskRowView` but uses compact dimensions.

```
+--------------------------------------------------+
|  +--------+                                      |
|  | [Icon] |  Task Label Text         [Checkmark] |
|  | 48x48  |                          (28pt, if   |
|  +--------+                           done)      |
|                                                  |
+--------------------------------------------------+
   ^-- 12pt      ^-- 12pt gap             ^-- 16pt
   padding                                padding
```

| Property | iPhone Value | iPad Value |
|----------|-------------|------------|
| Row min height | 64pt | 72pt |
| Icon container | 48x48pt (SE) / 56x56pt (standard) | 60x60pt |
| Icon symbol size | 20pt (SE) / 22pt (standard) | 24pt |
| Label font | 20pt (SE) / 22pt (standard) rounded semibold | 24pt rounded semibold |
| Internal horizontal padding | 12pt | 16pt |
| Checkmark size | 24pt | 28pt |
| Row background | Same tokens as iPad | Same |

**Touch target compliance:** The full row is the tap target (minimum 64pt tall, full width). This exceeds the 44x44pt WCAG minimum.

#### 3.1.5 Child Header (iPhone)

```
         ( Avatar )          <-- 56-72pt depending on device
         Child Name          <-- 24-28pt SF Rounded bold
        * * * o o o          <-- progress dots (10pt diameter)
```

- Avatar: smaller than iPad (iPad: 80pt). iPhone SE: 56pt, standard: 64pt, Plus: 72pt
- Name: `type.child.title` scaled to fit. iPhone SE: 24pt, standard: 28pt
- Progress dots: 10pt diameter (iPad: 12pt), 6pt spacing
- The header is NOT scrollable; it sits above the task ScrollView as a fixed element
- Vertical spacing: 8pt between avatar and name, 4pt between name and dots, 12pt between dots and first task row

#### 3.1.6 Page Indicator Dots

Custom page dots at the bottom of the screen, above the home indicator safe area.

```
          o  *  o
```

- Active dot: 10pt filled circle in the current child's accent colour
- Inactive dot: 8pt filled circle in `color.border.pinDot`
- Spacing: 8pt between dots
- Area height: 32pt (centred vertically)
- Tapping a dot does NOT navigate (children are too young for precise dot targets)
- Hidden when only 1 child

### 3.2 Multi-Child Support

**Strategy: Horizontal paging (not tabs, not list).**

Rationale:
- Children understand "swipe to see brother/sister"
- Tabs require reading names; swipe is more intuitive for age 2-6
- A single column uses the full width, maintaining large touch targets
- Page dots provide a visual cue of position without requiring interaction

**Parent can set child order** in the parent management view (drag-and-drop reorder). The pager respects `child.sortOrder`.

**Remembering last-viewed child:** The app stores the last-viewed child index in `@AppStorage("lastViewedChildIndex")` and restores on launch.

### 3.3 Task Completion Interaction

Identical to iPad with minor sizing adjustments:

1. Child taps the full task row (not just the icon or checkmark)
2. Haptic feedback: `UIImpactFeedbackGenerator(style: .medium)`
3. Row background transitions from `taskIncomplete` to `taskComplete`
4. Checkmark (24pt on iPhone) fades in on the trailing edge
5. Star burst animation plays (scaled down 80% from iPad)
6. Text gets strikethrough and colour changes to `textTaskLabelDone`
7. When all tasks done: `CelebrationView` overlay fills the pager page

**Reduce Motion:** Same as iPad (DSGN-001 Section 7.3). Instant fill, no star burst, celebration is instant tint.

### 3.4 Celebration View (iPhone)

The celebration overlay fills the child's page within the pager. On iPhone it covers the task list area but NOT the topic tab bar or page indicator.

```
+------------------------------------------+
|  [Morning]  [After daycare]    [Gear]    |  <-- still visible
+------------------------------------------+
|                                          |
|           ~~~~~~~~~~~~~~~~               |
|          ~ PARTY POPPER  ~               |
|          ~               ~               |
|          ~  All Done!    ~               |
|          ~               ~               |
|          ~  * * *        ~               |
|           ~~~~~~~~~~~~~~~~               |
|                                          |
|              o  *  o                     |  <-- still visible
+------------------------------------------+
```

- Confetti particle count reduced from 20 to 12 on iPhone (performance)
- Star pulsing animation unchanged

### 3.5 Parent Management Flow

The parent management flow is **unchanged from iPad**. It already uses `NavigationStack` + `List` with `.insetGrouped` style, which adapts naturally to iPhone.

#### 3.5.1 Entry Flow

```
[Gear icon tap] --> [PIN Entry (fullScreenCover)]
                          |
                    [Correct PIN]
                          |
                    [ParentHomeView (fullScreenCover)]
                          |
              +-----------+-----------+
              |           |           |
          [Topics]   [Task Bank]  [Children]
              |           |           |
         [Add/Edit]  [Add/Edit]  [Child Topic Picker]
                                      |
                                 [Task Editor]
```

#### 3.5.2 ParentHomeView on iPhone

The existing `ParentHomeView` already works on iPhone because it uses:
- `NavigationStack` (adapts to compact width)
- `.listStyle(.insetGrouped)` (standard iPhone list style)
- Standard toolbar items
- Sheets for add/edit forms

**No layout changes needed.** The sections (Topics, Task Bank, Children, Settings) display in a single scrollable list, which is the native iPhone pattern.

#### 3.5.3 Add/Edit Child Sheet

Same as iPad. The sheet uses `.presentationDetents([.medium, .large])` on iPhone for a more natural feel (iPad always uses `.large`).

#### 3.5.4 Task Editor View

Same as iPad. `NavigationStack` + `List` with "Add from Bank" button, assignment rows with swipe-to-remove. No layout changes.

### 3.6 Paywall Screen

The existing `PaywallView` already works on iPhone. It uses:
- `ScrollView` with `VStack`
- Standard padding (32pt horizontal)
- Capsule-shaped purchase button (full width minus padding)
- `.presentationDetents([.large])`

**One adjustment:** On iPhone SE, reduce the icon from 72pt to 56pt and top padding from 32pt to 20pt to prevent the purchase button from being pushed below the fold.

```
+------------------------------------------+
|  [Not now]                               |
|                                          |
|          ( Star icon 56pt )              |
|                                          |
|          MiniMissions Premium            |
|         Unlock all task groups           |
|                                          |
|    [inf]  Unlimited topics               |
|    [chk]  One-time purchase              |
|    [ppl]  Family sharing                 |
|                                          |
|   +----------------------------------+   |
|   |     Unlock for $X.XX             |   |
|   +----------------------------------+   |
|                                          |
|         Restore purchase                 |
+------------------------------------------+
```

### 3.7 PIN Entry & Setup (iPhone)

The existing `PINEntryView` and `PINSetupView` use a fixed dark background with centred content. They work on iPhone with no structural changes.

**Minor adjustments:**
- PIN digit font: 40pt (iPad: 48pt)
- Keypad button size: 72x72pt (iPad: 80x80pt if applicable)
- The keypad grid should fit comfortably in the lower half of iPhone SE's 667pt height

### 3.8 Empty State View (No Children)

Identical to iPad but constrained to screen width:

```
+------------------------------------------+
|                                [Gear]    |
|                                          |
|          ( person.3.fill 64pt )          |
|                                          |
|            Welcome to                    |
|           MiniMissions!                  |
|                                          |
|     Open Settings to add your            |
|     first child                          |
|                                          |
|     +----------------------------+       |
|     |    Open Settings           |       |
|     +----------------------------+       |
|                                          |
+------------------------------------------+
```

- Card max width: removed (fills screen with padding)
- Icon size reduced to 64pt (iPad: 80pt)
- Horizontal padding: 24pt

---

## 4. Adaptive Layout Strategy

### 4.1 Size Class Detection

The app uses `horizontalSizeClass` to switch between iPhone and iPad layouts:

```swift
@Environment(\.horizontalSizeClass) private var sizeClass

var body: some View {
    if sizeClass == .compact {
        iPhoneLayout  // paged single-child view
    } else {
        iPadLayout    // existing multi-column view
    }
}
```

This approach means:
- iPhone always gets compact layout (portrait locked)
- iPad always gets regular layout (landscape locked)
- iPad Split View / Slide Over: falls back to compact (iPhone) layout, which is acceptable

### 4.2 New Design Tokens (iPhone-specific)

These tokens supplement DSGN-001. They are **only used when `horizontalSizeClass == .compact`**.

| Token | Value | Usage |
|-------|-------|-------|
| `spacing.iphone.screenPadding` | 16pt | Left/right screen margin |
| `spacing.iphone.screenPaddingLarge` | 20pt | Left/right margin on Plus/Max devices |
| `type.iphone.childTitle` | 24-28pt | Child name (scales with device width) |
| `type.iphone.taskLabel` | 20-24pt | Task label (scales with device width) |
| `size.iphone.avatar` | 56-72pt | Avatar diameter (scales with device width) |
| `size.iphone.taskIcon` | 48-56pt | Task icon container (scales with device width) |
| `size.iphone.taskRowMinHeight` | 64pt | Minimum task row height |
| `size.iphone.topicPillMinHeight` | 48pt | Topic pill minimum height |
| `size.iphone.pageIndicatorHeight` | 32pt | Page indicator area |

**Scaling rule:** For values that vary by device, use a linear interpolation based on screen width:
- 375pt (SE) = minimum value
- 430pt (Plus) = maximum value
- Intermediate widths interpolate linearly

### 4.3 New Typography Tokens (Compact)

| Token | Base Size | SwiftUI Style | Weight | Design | Usage |
|-------|-----------|--------------|--------|--------|-------|
| `type.compact.childTitle` | 26pt | `.title` | Bold | Rounded | Child name header |
| `type.compact.taskLabel` | 21pt | `.title3` | Semibold | Rounded | Task label text |
| `type.compact.celebration` | 30pt | `.title` | Heavy | Rounded | Celebration message |
| `type.compact.subLabel` | 17pt | `.body` | Regular | Rounded | Supporting labels |
| `type.compact.topicTab` | 18pt | `.callout` | Semibold | Rounded | Topic pill text |

**Note:** The minimum text size in child-facing compact views is **17pt**, which is lower than the iPad minimum of 24pt. This is acceptable because:
1. iPhone is held closer to the face than iPad (typical viewing distance ~25cm vs ~40cm)
2. 17pt is only used for non-critical secondary text (`subLabel`)
3. All primary interactive text (task labels, child names) remains >= 20pt
4. Dynamic Type scaling still applies

---

## 5. Differences from iPad Version

### 5.1 What Changes

| Area | iPad | iPhone |
|------|------|--------|
| Orientation | Landscape locked | Portrait locked |
| Child display | Multi-column (1-6 columns) | Single-child paged view |
| Navigation between children | All visible simultaneously | Horizontal swipe + page dots |
| Topic tab bar background | Card with shadow | Flat with bottom separator |
| Avatar size | 80pt | 56-72pt (device-dependent) |
| Task icon container | 60x60pt | 48-56pt (device-dependent) |
| Task row height | 72pt | 64pt minimum |
| Task label font | 24pt | 20-24pt (device-dependent) |
| Child name font | 32pt | 24-28pt (device-dependent) |
| Screen margins | 48pt (xxl) | 16-20pt |
| Celebration confetti | 20 particles | 12 particles |
| Column card styling | Rounded card with shadow | No card wrapper (full-width page) |
| Child column tint | Card background tint | Page background tint (subtle) |
| Compact grid (4-6 children) | 2-row grid | Paged (all children accessible via swipe) |

### 5.2 What Stays the Same

- Design tokens (colours, brand identity, accent colours per child)
- Task completion interaction (tap row, haptic, star burst, checkmark)
- Celebration overlay (all-done)
- PIN entry/setup flow
- Parent management (NavigationStack + List)
- Paywall screen
- Topic tab bar concept (horizontal pills)
- Accessibility identifiers (same AX constants)
- Dark mode support
- Reduce Motion support
- VoiceOver labels and hints
- Data model (shared between iPhone and iPad)

---

## 6. Accessibility (WCAG 2.2 AA)

### 6.1 Colour Contrast

All contrast ratios from DSGN-001 remain valid. No new colour tokens are introduced (only sizing tokens change). Light and dark mode contrast compliance is unchanged.

### 6.2 Touch Target Sizes

| Element | iPhone Size | Minimum Required | Status |
|---------|-------------|-----------------|--------|
| Task row (full width tap) | 64pt height x full width | 44x44pt | PASS |
| Topic pill | 64x48pt minimum | 44x44pt | PASS |
| Gear icon | 44x44pt | 44x44pt | PASS |
| Page indicator dot | Non-interactive | N/A | N/A |
| Task icon container | 48x48pt minimum | 44x44pt | PASS |
| PIN keypad button | 72x72pt | 44x44pt | PASS |
| Checkmark (non-interactive, decorative) | N/A | N/A | N/A |

### 6.3 VoiceOver

All existing VoiceOver labels and hints from the iPad version carry over unchanged. Additional considerations for iPhone:

- **Child pager:** `accessibilityScrollAction` must be implemented so VoiceOver users can navigate between children with three-finger swipe
- **Page indicator:** Accessible as a single element: "Child 2 of 3, [Child Name]"
- **Topic tab bar:** Each pill is a button with `.isSelected` trait for the active topic (same as iPad)

### 6.4 Dynamic Type

All text scales with Dynamic Type. At AX5 (largest accessibility size):
- Task labels may need `minimumScaleFactor: 0.8` with two-line truncation
- Child name uses single line with `minimumScaleFactor: 0.7`
- Topic pills expand vertically to accommodate larger text (no horizontal truncation)
- The task list becomes scrollable (which it already is)

### 6.5 Reduce Motion

Same as iPad (DSGN-001 Section 7.3). The pager swipe animation respects `UIAccessibility.isReduceMotionEnabled` by using crossfade instead of slide.

### 6.6 Focus Order (VoiceOver / Switch Control)

1. Topic tab bar (left to right: each topic pill, then gear icon)
2. Child name header (marked `.isHeader`)
3. Progress indicator (single element, descriptive label)
4. Task rows (top to bottom)
5. Page indicator (single element)

After the last task row, VoiceOver wraps to the next page (next child) on three-finger swipe right, or back to topic tab bar on three-finger swipe up.

---

## 7. iOS-Specific Considerations

### 7.1 Safe Area Handling

- **Top:** Topic tab bar sits below the status bar safe area (no extension under Dynamic Island / notch)
- **Bottom:** Page indicator sits above the home indicator safe area
- **Left/Right:** Content respects horizontal safe area (relevant for landscape if ever unlocked, but currently portrait-locked)
- All padding uses `safeAreaInsets` plus design tokens, never hardcoded absolute positions

### 7.2 Dark Mode

Fully supported using the same DSGN-001 token pairs. No iPhone-specific dark mode adjustments needed.

### 7.3 iOS HIG Alignment

| HIG Guideline | Compliance |
|---------------|------------|
| Navigation: use NavigationStack | Yes (parent management) |
| Sheets: half-height detent where appropriate | Yes (add/edit sheets use `.medium` + `.large`) |
| Toolbars: standard placement | Yes (Done, Reset All in toolbar) |
| Page control for horizontal paging | Custom page dots (not UIPageControl, for child-friendly sizing) |
| Large Title in navigation | Yes (parent management) |
| System colours for parent UI | Yes (`UIColor.systemGroupedBackground`) |
| Haptics | Yes (task completion, PIN entry) |

### 7.4 Performance

- Pager pre-loads adjacent child pages (default `TabView` behaviour)
- Confetti particle count reduced to 12 (from 20) on iPhone
- Star burst animation reuses the same `StarBurstView` at 80% scale
- No performance concerns expected on iPhone 11+ (minimum deployment target)

---

## 8. Implementation Notes for MDEV

### 8.1 Branching Strategy

The iPhone layout is an **additive change**. The existing iPad views remain untouched. New files:

| File | Purpose |
|------|---------|
| `ChildRoutineView+Compact.swift` | iPhone-specific child routine layout (extension or extracted view) |
| `ChildPageView.swift` | Single child page within the pager |
| `CompactDesignTokens.swift` | iPhone-specific sizing tokens |

Alternatively, the existing `ChildRoutineView` can use `if sizeClass == .compact` branching internally. The architect should decide the preferred approach.

### 8.2 Shared Components

These components work on both iPad and iPhone without modification:
- `TaskRowView` (accepts size parameters from parent)
- `CelebrationView` (fills container)
- `StarBurstView` (scales to container)
- `ProgressDotsView` (adapts to dot count)
- All parent management views
- PIN views
- PaywallView

### 8.3 Data Sharing

iPhone and iPad share the same SwiftData model container. If the app were to run as a universal binary, both layouts access the same data. No model changes are needed.

---

## 9. Acceptance Criteria for Design

| ID | Criterion | Verification Method |
|----|-----------|-------------------|
| IP-AC-01 | App displays in portrait-only orientation on all iPhone models | XCUITest: verify `UIInterfaceOrientationMask` |
| IP-AC-02 | Single child fills the screen width (no side-by-side columns on iPhone) | XCUITest: verify child page frame equals screen width minus padding |
| IP-AC-03 | Horizontal swipe navigates between children with paging behaviour | XCUITest: swipe left, verify different child name appears |
| IP-AC-04 | Page indicator dots match the number of children | XCUITest: count page dots == child count |
| IP-AC-05 | Page indicator is hidden when only 1 child exists | XCUITest: verify page dots not present with 1 child |
| IP-AC-06 | Topic tab bar scrolls horizontally when topics overflow screen width | XCUITest: add 4+ topics, verify last topic is reachable by scroll |
| IP-AC-07 | All task row touch targets are >= 44pt in both dimensions | XCUITest: assert `frame.height >= 44` on every task button |
| IP-AC-08 | All topic pill touch targets are >= 44pt in both dimensions | XCUITest: assert pill frame dimensions |
| IP-AC-09 | Gear icon touch target is 44x44pt | XCUITest: assert gear button frame |
| IP-AC-10 | Task completion interaction works (tap -> checkmark + haptic + star) | XCUITest: tap task, verify checkmark appears and value changes to "done" |
| IP-AC-11 | Celebration overlay appears when all tasks are completed | XCUITest: complete all tasks, verify celebration view exists |
| IP-AC-12 | Parent management opens after correct PIN entry | XCUITest: tap gear, enter PIN, verify ParentHomeView appears |
| IP-AC-13 | VoiceOver can navigate between children via accessibilityScrollAction | Accessibility audit: 3-finger swipe navigates pages |
| IP-AC-14 | All text scales with Dynamic Type from xSmall to AX5 | XCUITest: launch with `.largeContentSizeCategory`, verify no truncation of primary labels |
| IP-AC-15 | Reduce Motion: pager uses crossfade, no star burst animation | XCUITest: launch with reduce motion argument, verify animation states |
| IP-AC-16 | Dark mode renders correctly (no invisible text, no broken backgrounds) | XCUITest: launch in dark mode, snapshot comparison |
| IP-AC-17 | iPhone SE (375pt width) displays all elements without horizontal clipping | XCUITest on SE simulator: verify no element exceeds screen bounds |
| IP-AC-18 | Last-viewed child is restored on app relaunch | XCUITest: view child 2, relaunch, verify child 2 is displayed |
| IP-AC-19 | Paywall displays correctly on iPhone SE without purchase button below fold | Manual verification on SE simulator |
| IP-AC-20 | Parent management list sections (Topics, Task Bank, Children, Settings) are all visible and scrollable | XCUITest: verify all section headers exist |
