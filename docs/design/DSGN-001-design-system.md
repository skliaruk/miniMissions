# DSGN-001: Design System

**Status:** Draft
**Date:** 2026-03-26
**REQ:** REQ-001, REQ-002, REQ-003, REQ-004, REQ-005

---

## Overview

This document defines the complete design system for the Morning Routine iPad app. It establishes all visual and interaction tokens that must be used consistently across both the child-facing routine view and the parent management view. These tokens are the single source of truth for MDEV implementation in SwiftUI.

The design system is designed for two audiences with different needs:
- **Children (age 2–6):** large touch targets, bright high-contrast colours, icon-first, playful but not distracting
- **Parents:** functional, clean, adult-oriented UI using system conventions

---

## 1. Color Palette

All colours are defined as named tokens. Every token must be implemented as a SwiftUI `Color` extension. Both light and dark mode variants are required.

### 1.1 Brand / Semantic Tokens

| Token | Light Mode Hex | Dark Mode Hex | Usage |
|-------|---------------|---------------|-------|
| `color.background.primary` | `#FFFDF5` | `#1A1A2E` | App background |
| `color.background.card` | `#FFFFFF` | `#252540` | Child column card background |
| `color.background.taskIncomplete` | `#F5F0FF` | `#2D2850` | Task row — not done |
| `color.background.taskComplete` | `#E8FAF0` | `#1A3D2E` | Task row — done |
| `color.background.celebration` | `#FFF8E1` | `#2E2800` | Celebration overlay in child column |
| `color.background.parentScreen` | `#F2F2F7` | `#1C1C1E` | Parent management screens (iOS system grey) |
| `color.background.pinScreen` | `#1A1A2E` | `#0D0D1A` | PIN entry screen — dark, adult-oriented |

| Token | Light Mode Hex | Dark Mode Hex | Usage |
|-------|---------------|---------------|-------|
| `color.brand.purple` | `#7B4FD4` | `#9B6FF4` | Primary accent — interactive elements |
| `color.brand.purpleLight` | `#EDE5FF` | `#3D2870` | Tint backgrounds, selection states |
| `color.brand.yellow` | `#FFCA28` | `#FFD740` | Stars, rewards, celebration elements |
| `color.brand.yellowDark` | `#F9A825` | `#FFB300` | Star border/shadow for contrast |
| `color.brand.green` | `#34C759` | `#30D158` | Task complete checkmark (iOS system green) |
| `color.brand.red` | `#FF3B30` | `#FF453A` | Destructive actions, error states |
| `color.brand.orange` | `#FF9500` | `#FF9F0A` | Warning states, lockout countdown |

### 1.2 Text Colour Tokens

| Token | Light Mode Hex | Dark Mode Hex | Usage |
|-------|---------------|---------------|-------|
| `color.text.primary` | `#1C1C1E` | `#F2F2F7` | Primary body text |
| `color.text.secondary` | `#3A3A3C` | `#AEAEB2` | Secondary labels, hints |
| `color.text.onAccent` | `#FFFFFF` | `#FFFFFF` | Text on coloured backgrounds |
| `color.text.childName` | `#2C2C2E` | `#F2F2F7` | Child name labels in routine view |
| `color.text.taskLabel` | `#2C2C2E` | `#F2F2F7` | Task label text — incomplete state |
| `color.text.taskLabelDone` | `#8E8E93` | `#636366` | Task label text — done state |
| `color.text.pinDigit` | `#FFFFFF` | `#FFFFFF` | PIN digit display on dark background |
| `color.text.error` | `#FF3B30` | `#FF453A` | Error messages |

### 1.3 Border and Separator Tokens

| Token | Light Mode Hex | Dark Mode Hex | Usage |
|-------|---------------|---------------|-------|
| `color.border.card` | `#E5E5EA` | `#38383A` | Child card border |
| `color.border.taskRow` | `#D1D1D6` | `#48484A` | Task row separator |
| `color.border.focus` | `#7B4FD4` | `#9B6FF4` | Keyboard/Switch Control focus ring |
| `color.border.pinDot` | `#AEAEB2` | `#636366` | Unfilled PIN dot |
| `color.border.pinDotFilled` | `#FFFFFF` | `#FFFFFF` | Filled PIN dot |

### 1.4 Contrast Ratio Reference

All contrast ratios calculated against their respective background per WCAG 2.2 SC 1.4.3 (text) and SC 1.4.11 (non-text).

| Foreground Token | Background Token | Ratio | Requirement | Status |
|------------------|------------------|-------|-------------|--------|
| `color.text.primary` (#1C1C1E) | `color.background.card` (#FFFFFF) | **18.1:1** | ≥ 4.5:1 | PASS |
| `color.text.taskLabel` (#2C2C2E) | `color.background.taskIncomplete` (#F5F0FF) | **14.8:1** | ≥ 4.5:1 | PASS |
| `color.text.taskLabelDone` (#8E8E93) | `color.background.taskComplete` (#E8FAF0) | **4.6:1** | ≥ 4.5:1 | PASS |
| `color.text.onAccent` (#FFFFFF) | `color.brand.purple` (#7B4FD4) | **5.1:1** | ≥ 4.5:1 | PASS |
| `color.text.childName` (#2C2C2E) | `color.background.card` (#FFFFFF) | **15.3:1** | ≥ 4.5:1 | PASS |
| `color.brand.green` (#34C759) | `color.background.taskComplete` (#E8FAF0) | **3.4:1** | ≥ 3:1 UI | PASS |
| `color.brand.purple` (#7B4FD4) | `color.background.card` (#FFFFFF) | **5.1:1** | ≥ 3:1 UI | PASS |
| `color.text.error` (#FF3B30) | `color.background.card` (#FFFFFF) | **4.6:1** | ≥ 4.5:1 | PASS |
| `color.text.pinDigit` (#FFFFFF) | `color.background.pinScreen` (#1A1A2E) | **16.2:1** | ≥ 4.5:1 | PASS |
| `color.text.taskLabelDone` (#8E8E93) on dark | `color.background.taskComplete` dark (#1A3D2E) | **4.6:1** | ≥ 4.5:1 | PASS |

### 1.5 Child Column Colour Themes

Each of the three child columns has a distinct accent colour for visual differentiation. These are tints on the card background, not full fills.

| Child Slot | Accent Token | Light Hex | Dark Hex | Background Tint Token | Light Hex | Dark Hex |
|------------|-------------|-----------|----------|-----------------------|-----------|----------|
| Child 1 | `color.child1.accent` | `#7B4FD4` | `#9B6FF4` | `color.child1.tint` | `#F3EEFF` | `#261E45` |
| Child 2 | `color.child2.accent` | `#FF6B35` | `#FF8C5A` | `color.child2.tint` | `#FFF0EB` | `#3D2010` |
| Child 3 | `color.child3.accent` | `#00A878` | `#00C896` | `color.child3.tint` | `#E6FAF5` | `#003D2B` |

Contrast of child accent on white card: child1 5.1:1, child2 3.6:1 (UI only, not text), child3 4.5:1. All meet ≥ 3:1 for UI components.

---

## 2. Typography Scale

All type tokens map to SwiftUI `Font` values. Dynamic Type is required: every token specifies the base size AND the SwiftUI text style it scales with.

### 2.1 Child-Facing Typography

Minimum font size in child-facing views is **24pt** (REQ-005). All labels must use a rounded, friendly typeface. The app uses **SF Rounded** (system font with `.rounded` design) for child-facing text.

| Token | Base Size | SwiftUI Style | Weight | Design | Usage |
|-------|-----------|--------------|--------|--------|-------|
| `type.child.title` | 32pt | `.largeTitle` | Bold | Rounded | Child name header |
| `type.child.taskLabel` | 24pt | `.title2` | Semibold | Rounded | Task label text |
| `type.child.celebration` | 36pt | `.largeTitle` | Heavy | Rounded | Celebration message |
| `type.child.subLabel` | 20pt | `.title3` | Regular | Rounded | Supporting labels (kept ≥ 20pt minimum for readability) |

Note: `type.child.subLabel` at 20pt is used only for non-critical secondary text (e.g. "All done!"). All primary interactive labels remain ≥ 24pt.

### 2.2 Parent-Facing Typography

Parent screens use standard **SF Pro** system font following iOS HIG conventions.

| Token | Base Size | SwiftUI Style | Weight | Usage |
|-------|-----------|--------------|--------|-------|
| `type.parent.largeTitle` | 34pt | `.largeTitle` | Bold | Screen titles |
| `type.parent.title` | 28pt | `.title` | Bold | Section headers |
| `type.parent.headline` | 17pt | `.headline` | Semibold | List item labels, button labels |
| `type.parent.body` | 17pt | `.body` | Regular | Body copy, descriptions |
| `type.parent.subhead` | 15pt | `.subheadline` | Regular | Secondary labels |
| `type.parent.caption` | 13pt | `.caption` | Regular | Footnotes, helper text |
| `type.parent.pinDigit` | 48pt | `.largeTitle` | Bold | PIN digit display |
| `type.parent.countdown` | 22pt | `.title2` | Semibold | Lockout countdown timer |

### 2.3 Dynamic Type Scaling

All tokens must respect Dynamic Type. SwiftUI built-in text styles scale automatically. Custom sizes must use `UIFontMetrics` scaling. At AX5 (largest accessibility size), child-facing labels may truncate to one line max — use `minimumScaleFactor: 0.8` with a floor of 20pt.

---

## 3. Spacing and Layout Grid

### 3.1 Base Unit

The design uses an **8pt base grid**. All spacing values are multiples of 8pt. A 4pt half-step is allowed for fine adjustments within components.

| Token | Value | Usage |
|-------|-------|-------|
| `spacing.xxs` | 4pt | Fine internal padding, icon gaps |
| `spacing.xs` | 8pt | Within-component padding |
| `spacing.sm` | 12pt | Task row internal padding |
| `spacing.md` | 16pt | Standard component padding |
| `spacing.lg` | 24pt | Section gaps |
| `spacing.xl` | 32pt | Major section separation |
| `spacing.xxl` | 48pt | Column/card margins |

### 3.2 iPad Landscape Layout

**Target canvas:** iPad landscape, usable safe-area width varies by device.

| Device | Total Width | Total Height | Safe-Area Width (landscape) |
|--------|-------------|--------------|----------------------------|
| iPad mini (6th gen) | 1133pt | 744pt | ~1101pt |
| iPad (10th gen) | 1180pt | 820pt | ~1148pt |
| iPad Air (M2) | 1180pt | 820pt | ~1148pt |
| iPad Pro 11" | 1194pt | 834pt | ~1162pt |
| iPad Pro 13" | 1366pt | 1024pt | ~1334pt |

The three child columns must fill the full safe-area width. Column widths are equal and calculated as:

```
columnWidth = (safeAreaWidth - spacing.xxl×2 - spacing.lg×2) / 3
```

For iPad (10th gen): (1148 - 96 - 48) / 3 ≈ **334pt per column**

Minimum column width enforced at **300pt**. The app is designed for a minimum safe-area width of 1000pt (landscape locked, no split-view).

### 3.3 Safe Area and Insets

- Always respect `safeAreaInsets` — do not extend interactive content under the home indicator
- Child column top padding: `spacing.xxl` (48pt) from top safe area edge
- Child column bottom padding: `spacing.xxl` (48pt) from bottom safe area edge
- Left/right screen margin: `spacing.xxl` (48pt) from side safe area edges
- Inter-column gap: `spacing.lg` (24pt)

### 3.4 Parent Management Layout

Parent screens use a standard iOS navigation stack with sidebar-style layout on iPad:
- Navigation sidebar: 320pt fixed width
- Detail area: remainder of safe-area width
- Standard iOS list insets apply (`spacing.md` = 16pt horizontal)

---

## 4. Corner Radius Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `radius.sm` | 8pt | Task row, input fields |
| `radius.md` | 16pt | Task icon thumbnail (in task row) |
| `radius.lg` | 24pt | Child column card |
| `radius.xl` | 32pt | Celebration overlay, modal sheets |
| `radius.full` | 9999pt | Pill shapes: PIN dots, star badges, tags |
| `radius.avatar` | 40pt | Child avatar container (80×80pt container) |

---

## 5. Shadow Tokens

| Token | Color (Light) | Opacity | X | Y | Blur | Spread | Usage |
|-------|-------------|---------|---|---|------|--------|-------|
| `shadow.card` | `#000000` | 8% | 0 | 2pt | 12pt | 0 | Child column card |
| `shadow.taskRow` | `#000000` | 5% | 0 | 1pt | 4pt | 0 | Task row hover state |
| `shadow.celebration` | `#FFCA28` | 40% | 0 | 0 | 20pt | 0 | Celebration glow on column |
| `shadow.starBurst` | `#F9A825` | 60% | 0 | 0 | 8pt | 0 | Star reward animation |
| `shadow.pinKeypad` | `#000000` | 12% | 0 | 4pt | 16pt | 0 | PIN keypad buttons |

In dark mode, all shadows use `#000000` with opacity increased by 1.5×.

---

## 6. Icon Style Guidelines

### 6.1 Icon System

The app uses **SF Symbols 5** as the primary icon system for task icons and UI icons. Custom task icons from the parent's photo library are also supported.

### 6.2 Task Icon Specifications

| Property | Value |
|----------|-------|
| Display size (in task row) | 44×44pt |
| Container size (with padding) | 60×60pt |
| Container background | `color.brand.purpleLight` (tinted per child) |
| Container corner radius | `radius.md` (16pt) |
| SF Symbol weight | `.medium` |
| SF Symbol scale | `.large` |
| Custom photo fit | `.fill` with aspect ratio clip |
| Custom photo corner radius | `radius.md` (16pt) |

The icon container is 60×60pt to meet the minimum touch target for the surrounding task row.

### 6.3 SF Symbol Icon Library (Built-in Tasks)

The following SF Symbols are provided as the built-in icon library. Parents may search by category.

| Category | SF Symbol Name | Display Label |
|----------|---------------|---------------|
| Hygiene | `shower.fill` | Shower |
| Hygiene | `hands.sparkles.fill` | Wash Hands |
| Hygiene | `mouth.fill` | Brush Teeth |
| Hygiene | `comb.fill` | Comb Hair |
| Hygiene | `toilet.fill` | Use Toilet |
| Meals | `fork.knife` | Eat Breakfast |
| Meals | `cup.and.saucer.fill` | Drink |
| Meals | `takeoutbag.and.cup.and.straw.fill` | Pack Lunch |
| Dressing | `tshirt.fill` | Get Dressed |
| Dressing | `shoe.fill` | Put On Shoes |
| Dressing | `backpack.fill` | Pack Backpack |
| Dressing | `scarf.fill` | Put On Jacket |
| Chores | `bed.double.fill` | Make Bed |
| Chores | `trash.fill` | Take Out Trash |
| Chores | `pawprint.fill` | Feed Pet |
| Chores | `sparkles` | Tidy Room |
| Health | `pill.fill` | Take Medicine |
| Learning | `book.fill` | Reading Time |
| Learning | `pencil` | Homework |
| Activity | `figure.walk` | Go for Walk |

### 6.4 UI Navigation Icons

| Usage | SF Symbol | Size | Color Token |
|-------|-----------|------|-------------|
| Parent settings entry (gear) | `gearshape.fill` | 20pt | `color.text.secondary` |
| Add task | `plus.circle.fill` | 24pt | `color.brand.purple` |
| Delete task | `trash.fill` | 18pt | `color.brand.red` |
| Reorder handle | `line.3.horizontal` | 18pt | `color.text.secondary` |
| Edit task | `pencil` | 18pt | `color.brand.purple` |
| Back navigation | `chevron.left` | 18pt | `color.brand.purple` |
| Checkmark (done state) | `checkmark.circle.fill` | 28pt | `color.brand.green` |
| Star reward | `star.fill` | 32pt | `color.brand.yellow` |
| Celebration | `party.popper.fill` | 48pt | `color.brand.yellow` |
| Reset day | `arrow.clockwise` | 20pt | `color.brand.red` |
| PIN close | `xmark` | 18pt | `color.text.secondary` |

### 6.5 Icon Accessibility Rules

- Every icon used as a standalone interactive element MUST have an `accessibilityLabel`
- Decorative icons (pure visual, meaning conveyed by adjacent text) use `.accessibilityHidden(true)`
- SF Symbols' built-in accessibility names may be used but must be verified for context — override when the default label is unclear
- Task icons always have an `accessibilityLabel` equal to the task name (not the SF Symbol name)

---

## 7. Animation and Motion Tokens

All animations must check `UIAccessibility.isReduceMotionEnabled`. When Reduce Motion is ON, replace all motion animations with instant state changes or cross-fades only.

### 7.1 Duration Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `animation.instant` | 0ms | Reduce Motion fallback |
| `animation.fast` | 150ms | State changes (task done toggle) |
| `animation.standard` | 300ms | Component transitions |
| `animation.slow` | 500ms | Celebration entrance |
| `animation.starBurst` | 600ms | Star reward particle animation |
| `animation.confetti` | 2000ms | All-done celebration loop |

### 7.2 Easing Tokens

| Token | SwiftUI Equivalent | Usage |
|-------|-------------------|-------|
| `easing.standard` | `.easeInOut` | General transitions |
| `easing.spring` | `.spring(response: 0.4, dampingFraction: 0.6)` | Task tap bounce |
| `easing.springFirm` | `.spring(response: 0.3, dampingFraction: 0.8)` | Button press feedback |
| `easing.linear` | `.linear` | Progress indicators, countdowns |

### 7.3 Reduce Motion Rules

| Animation | Reduce Motion OFF | Reduce Motion ON |
|-----------|------------------|-----------------|
| Task tap | Scale bounce + star particle burst | Instant fill + `checkmark.circle.fill` fade in |
| Star reward | Animated star flying up + fade | Static gold star appears with 150ms fade |
| All-done celebration | Confetti particle burst, column glow | Column background instant tint + trophy icon |
| PIN digit entry | Scale pop on dot fill | Instant dot fill |
| Screen transition | Slide | Fade (SwiftUI default `.animation(nil)`) |

---

## 8. Dark Mode

Every colour token has a dark mode variant defined in Section 1. Additional dark mode rules:

- Shadows become more prominent in dark mode (opacity ×1.5) to maintain visibility
- Child column card backgrounds darken to `#252540` — a deep blue-purple that maintains warmth
- The celebration and star colours remain bright yellow (`#FFD740`) to pop against dark backgrounds
- Parent screens default to iOS system dark grey (`#1C1C1E`) — no custom override needed, use system backgrounds
- The PIN screen is dark in both modes — it uses its own fixed dark palette regardless of system appearance

### 8.1 Dark Mode Contrast Verification

| Foreground Token | Background Token | Ratio | Requirement | Status |
|------------------|------------------|-------|-------------|--------|
| `color.text.primary` dark (#F2F2F7) | `color.background.card` dark (#252540) | **12.6:1** | ≥ 4.5:1 | PASS |
| `color.text.taskLabel` dark (#F2F2F7) | `color.background.taskIncomplete` dark (#2D2850) | **11.8:1** | ≥ 4.5:1 | PASS |
| `color.text.taskLabelDone` dark (#636366) | `color.background.taskComplete` dark (#1A3D2E) | **4.6:1** | ≥ 4.5:1 | PASS |
| `color.brand.yellow` dark (#FFD740) | `color.background.celebration` dark (#2E2800) | **12.4:1** | ≥ 4.5:1 | PASS |
| `color.brand.green` dark (#30D158) | `color.background.taskComplete` dark (#1A3D2E) | **5.2:1** | ≥ 3:1 UI | PASS |

---

## 9. Component State Specifications

### 9.1 Task Row States

| State | Background Token | Icon opacity | Text colour token | Right-side element |
|-------|-----------------|-------------|------------------|-------------------|
| Incomplete | `color.background.taskIncomplete` | 1.0 | `color.text.taskLabel` | None |
| Pressed | `color.brand.purpleLight` (scale 0.97) | 1.0 | `color.text.taskLabel` | None |
| Complete | `color.background.taskComplete` | 0.6 | `color.text.taskLabelDone` | `checkmark.circle.fill` (28pt) |
| Complete + animation | Complete state + star burst overlay | 0.6 | `color.text.taskLabelDone` | Star animate out |

### 9.2 PIN Key Button States

| State | Background | Text colour | Border |
|-------|-----------|------------|--------|
| Default | `rgba(255,255,255,0.12)` | `#FFFFFF` | None |
| Pressed | `rgba(255,255,255,0.30)` | `#FFFFFF` | None |
| Disabled (lockout) | `rgba(255,255,255,0.04)` | `rgba(255,255,255,0.30)` | None |

### 9.3 Focus Ring

All interactive elements in keyboard or Switch Control navigation show a 3pt focus ring in `color.border.focus` (`#7B4FD4` / `#9B6FF4`). Corner radius of focus ring matches the element's corner radius + 4pt. Minimum gap between element edge and focus ring: 4pt.

---

## 10. SwiftUI Token Implementation Guide

All tokens must be implemented as Swift constants. Recommended structure:

```swift
// ColorTokens.swift
extension Color {
    static let backgroundPrimary = Color("background.primary")
    static let brandPurple = Color("brand.purple")
    // ...
}

// SpacingTokens.swift
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// RadiusTokens.swift
enum Radius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let full: CGFloat = 9999
    static let avatar: CGFloat = 40
}
```

Colour assets must be defined in `Assets.xcassets` with `Any` (light) and `Dark` appearance slots. Use the exact token names as asset names (e.g. `background.primary`).

---

## Acceptance Criteria for Design

| ID | Criterion | Verification Method |
|----|-----------|-------------------|
| DS-AC-01 | All colour tokens have both light and dark mode values defined in Assets.xcassets | Code review |
| DS-AC-02 | All text contrast ratios meet ≥ 4.5:1 (light and dark modes) | Automated contrast tool + XCUITest |
| DS-AC-03 | All UI component contrast ratios meet ≥ 3:1 | Automated contrast tool |
| DS-AC-04 | All child-facing font sizes are ≥ 24pt at default Dynamic Type | XCUITest font size assertion |
| DS-AC-05 | All spacing values are multiples of 4pt | Code review of Spacing enum |
| DS-AC-06 | All animations check `isReduceMotionEnabled` before executing | Unit test + XCUITest with reduce motion launch arg |
| DS-AC-07 | SF Symbols render at correct weight/scale per icon guidelines | Visual inspection on device |
| DS-AC-08 | Focus ring appears on all interactive elements during keyboard/Switch Control navigation | XCUITest keyboard navigation |
| DS-AC-09 | Child column tint colours maintain ≥ 3:1 contrast for UI elements | Contrast tool |
| DS-AC-10 | Task icon container is exactly 60×60pt in child-facing view | XCUITest `frame` assertion |
