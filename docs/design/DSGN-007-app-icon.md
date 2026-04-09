# DSGN-007: App Icon & Logo

**Status:** Draft
**Date:** 2026-04-09
**REQ:** REQ-001

---

## Overview

The app icon is the first impression of MiniMissions. It must communicate the core concept — children completing daily tasks and earning stars — at a glance. The icon needs to appeal to two audiences simultaneously: children (ages 4-10) who see it on the home screen and feel excited, and parents who need to trust it as a reliable tool. The tone is playful but competent, not cartoonish or babyish.

---

## 1. Concept Rationale

MiniMissions is built around a clear loop: tasks appear, children complete them, stars reward completion. The icon should encode this loop in a single static image. The name "MiniMissions" evokes small adventures — a sense of purpose and accomplishment scaled for children.

**Brand personality to convey:**
- Warmth and encouragement (not authority or pressure)
- Playful confidence (not silly or infantile)
- Clarity and simplicity (parents should understand the app's purpose instantly)
- Achievement and progress (the star reward mechanic is central)

---

## 2. Icon Candidates

### Candidate A: Star + Checkmark

**Description:** A five-pointed star (brand yellow `#FFCA28`) with rounded points, centred on a gradient purple background. A small, bold white checkmark sits inside the lower-centre area of the star, slightly offset downward. The star has a subtle warm glow (soft yellow-to-transparent radial shadow). The background is a diagonal gradient from `#7B4FD4` (top-left) to `#9B6FF4` (bottom-right).

**Strengths:**
- Directly references the app's core reward mechanic (star for completed tasks)
- The checkmark inside the star communicates "task done = reward" in one symbol
- Stars are universally understood by children as positive
- Simple silhouette reads well at all sizes

**Weaknesses:**
- Star-with-checkmark is a relatively common pattern in productivity apps
- Two symbols overlaid may become muddy at very small sizes (76pt)

### Candidate B: Shield / Badge

**Description:** A rounded shield or badge shape (like a merit badge or scout patch) in brand purple, with a star emblem in the centre. The shield has a subtle border or bevel. Background is warm cream or yellow.

**Strengths:**
- "Mission" theme aligns with badge/shield imagery
- Distinctive silhouette compared to typical app icons

**Weaknesses:**
- Shield/badge imagery skews older (scouting, military) — may feel authoritarian rather than encouraging for young children
- More complex shape competes with the rounded-square iOS container
- A shield inside a rounded square creates a "shape within a shape" that feels visually cluttered
- Does not directly reference the star reward mechanic that is central to the app experience
- Parents may associate it with security/protection apps rather than routine management

### Recommendation: Candidate A — Star + Checkmark

Candidate A wins because it directly encodes the app's core loop (complete task, earn star) in a single clear symbol. The star is the most emotionally resonant element in the app for children, and placing a checkmark inside it tells the story without words. The shield concept introduces unnecessary complexity and tonal ambiguity. At small sizes, the star silhouette remains immediately recognizable, whereas a badge shape loses its defining details.

---

## 3. Shape & Composition

### Container
- Apple's standard rounded-square (squircle) mask — do not add a custom border or shape inside. The OS applies the mask automatically; provide a full 1024x1024 square asset.

### Focal Element
- The star is centred both horizontally and vertically within the icon canvas
- Star size: approximately 60-65% of the icon width (visual weight should feel dominant but not cramped)
- Star proportions: 5-pointed, with slightly rounded tips (corner radius ~8% of star diameter) to match the app's rounded visual language
- The checkmark sits inside the star, vertically centred or slightly below centre, sized at approximately 30% of the star's width
- Checkmark stroke weight: bold (roughly 10-12% of star diameter) to remain legible at small sizes

### Background
- Full-bleed diagonal linear gradient from top-left to bottom-right
- Top-left: `#7B4FD4` (brand purple)
- Bottom-right: `#9B6FF4` (brand purple light variant, dark-mode value used here for vibrancy)
- The gradient adds depth and energy compared to a flat fill, while remaining subtle

### Glow Effect
- A soft radial glow behind the star, using `#FFCA28` at 20-30% opacity, extending approximately 10% beyond the star edges
- This creates a warm "shining" effect that makes the star feel alive and rewarding
- The glow must be subtle enough not to interfere with legibility

---

## 4. Color Palette

All colors are drawn from the DSGN-001 design system.

| Element | Hex Value | Token Reference |
|---------|-----------|-----------------|
| Star fill | `#FFCA28` | `color.brand.yellow` |
| Star border/depth line | `#F9A825` | `color.brand.yellowDark` |
| Checkmark | `#FFFFFF` | `color.text.onAccent` |
| Background gradient start | `#7B4FD4` | `color.brand.purple` |
| Background gradient end | `#9B6FF4` | (dark-mode purple, used here for gradient vibrancy) |
| Star glow | `#FFCA28` at 25% opacity | `color.brand.yellow` |

### Contrast Notes
- Yellow star (`#FFCA28`) against purple background (`#7B4FD4`): contrast ratio approximately **3.5:1** — meets the 3:1 requirement for non-text UI components (WCAG 2.2 SC 1.4.11). The star is a graphical object, not text.
- White checkmark (`#FFFFFF`) against yellow star (`#FFCA28`): contrast ratio approximately **1.7:1** — this is below 3:1 for non-text. To resolve this, the checkmark should have a thin `#F9A825` (yellowDark) outline or drop shadow (1pt, 50% opacity) to provide sufficient edge definition against the yellow fill. Alternatively, the checkmark can be rendered in `#7B4FD4` (brand purple) instead of white, yielding approximately **3.5:1** against the yellow — meeting the 3:1 threshold.
- **Recommended approach:** Use brand purple (`#7B4FD4`) for the checkmark instead of white. This ties the checkmark back to the background color, creates a visual "window" effect, and solves the contrast issue cleanly.

**Revised checkmark color:** `#7B4FD4` (brand purple)

---

## 5. Typography

**The app name "MiniMissions" does not appear inside the icon.**

Rationale:
- At 76pt (iPad @1x home screen), text would be illegible or require a font size so large it dominates the icon
- Apple HIG recommends against text in app icons unless the text IS the brand (e.g., "Fb")
- The app name appears below the icon on the home screen as the display name, set in the Xcode project's `CFBundleDisplayName`

**App Store display name:** `MiniMissions`

If a wordmark is ever needed for marketing materials (not the icon), use SF Rounded Bold at a comfortable size, with "Mini" in `#7B4FD4` and "Missions" in `#1C1C1E` (or reversed on dark backgrounds).

---

## 6. Size Variants & Legibility

### 1024 x 1024pt — App Store

The full-detail version. All elements are crisp:
- Star tips are clearly rounded
- Checkmark is distinct with visible stroke weight
- Gradient is smooth
- Glow effect is visible and warm
- The `#F9A825` border/depth on the star is visible as a subtle 3D accent (1-2pt line or bottom edge shadow)

### 180 x 180pt — iPad Home Screen @3x (60pt logical)

- Star remains clearly a 5-pointed star
- Checkmark is legible as a checkmark (bold stroke is critical here)
- Glow effect may be reduced or removed to avoid muddiness at this size
- Star depth line is no longer visible as a separate element — acceptable, the star reads as flat yellow

### 76 x 76pt — iPad Home Screen @1x

- Star reads as a bright yellow shape on purple — the silhouette does the work
- Checkmark is at its legibility limit — the bold stroke weight (10-12% of star diameter, so roughly 5pt at this size) keeps it recognizable
- Glow effect should be omitted at this size to avoid blur
- If the checkmark becomes unclear at this size during production testing, it may be simplified to two straight lines rather than a rounded check

### Production Guidance
- Create the icon at 1024x1024 and test down-scaled versions at all target sizes before finalizing
- Use Xcode's icon preview or a real iPad to verify legibility — simulator rendering can be misleading
- All size variants are generated from the single 1024x1024 asset (iOS handles scaling automatically since Xcode 15)

---

## 7. Dark Mode Variant

App icons on iOS do not change with system appearance — there is no automatic dark-mode icon swap. However, as of iOS 18, users can choose tinted or dark icon appearances from the home screen customization menu.

**Guidance for iOS 18 automatic tinting:**
- The icon should hold up well when iOS applies its automatic dark tint. Since the background is already a saturated purple (not white or light), the icon will not suffer from the common problem of dark-mode tint washing out a light background.
- The yellow star provides strong contrast against any tinted version of the purple background.
- No separate dark-mode asset is needed. If Apple introduces explicit dark-mode icon support in future iOS versions, a variant with background gradient `#1A1A2E` to `#252540` (DSGN-001 dark background tokens) and the star/checkmark unchanged would work well.

---

## 8. What to Avoid

| Pitfall | Why |
|---------|-----|
| Adding text or the app name inside the icon | Illegible at small sizes; redundant with home screen label |
| Using a white or light background | Gets lost on light home screens and in light-mode App Store; the purple background gives the icon presence and brand recognition |
| Making the star too detailed (facets, 3D shading, sparkle particles) | Details disappear at small sizes and the icon looks muddy; keep it flat or near-flat |
| Using a thin checkmark stroke | Disappears at 76pt; the checkmark must be bold |
| Adding a border or outline to the icon | iOS applies the squircle mask; adding your own border creates a visible double-edge |
| Making the design "too cute" (cartoon face, childish illustration) | Alienates parents and looks unprofessional in the App Store; the star is inherently child-friendly without needing cartoon treatment |
| Using gradients with too many color stops | Creates banding artifacts on some displays; stick to two-stop gradient |
| Placing elements too close to the icon edges | The squircle mask clips corners aggressively; keep all elements within the inner 80% of the canvas |
| Adding transparency or alpha channels | iOS app icons must be opaque; transparent areas render as black |

---

## Acceptance Criteria for Design

| ID | Criterion | Verification Method |
|----|-----------|-------------------|
| ICON-AC-01 | Icon asset is provided at 1024x1024pt, fully opaque, no alpha channel | Asset inspection |
| ICON-AC-02 | Star silhouette is recognizable at 76x76pt rendering | Visual test on physical iPad |
| ICON-AC-03 | Checkmark inside star is distinguishable at 180x180pt rendering | Visual test on physical iPad |
| ICON-AC-04 | Colors match specified hex values within tolerance (delta-E < 2) | Colour picker verification |
| ICON-AC-05 | No text appears inside the icon | Visual inspection |
| ICON-AC-06 | Star element stays within inner 80% of canvas (not clipped by squircle mask) | Overlay guide verification |
| ICON-AC-07 | Icon reads well on both light and dark iPad wallpapers | Screenshot test on device with varied wallpapers |
| ICON-AC-08 | Checkmark contrast against star fill meets 3:1 minimum for non-text UI | Contrast ratio tool measurement |
| ICON-AC-09 | `CFBundleDisplayName` is set to "MiniMissions" | Xcode project inspection |
| ICON-AC-10 | Icon does not use any transparency | Asset alpha channel inspection |
