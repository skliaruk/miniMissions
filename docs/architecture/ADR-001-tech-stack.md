# ADR-001: Tech Stack

**Status:** Accepted
**Date:** 2026-03-26
**Deciders:** ARCH

## Context

The app is a fully local, no-backend iPad application. It must run on iPadOS 17+ in landscape orientation and serve two distinct user groups: children aged 2–6 (child-facing morning routine view) and their parents (management view). The REQ documents explicitly mention SwiftData for persistence (REQ-005). The choice of language, UI framework, and persistence layer defines every downstream implementation decision.

## Decision

| Layer | Choice |
|---|---|
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Persistence | SwiftData |
| Secure Storage | Keychain Services (via a thin wrapper) |
| Animation | SwiftUI built-in + `withAnimation` / `TimelineView` |
| Minimum OS | iPadOS 17.0 |
| Xcode | 15.0+ |
| Testing | XCTest (unit) + XCUITest (E2E) |
| Supported Devices | iPad mini (6th gen+), iPad (10th gen+), iPad Air (5th gen+), iPad Pro (all sizes supporting iPadOS 17) |
| Orientation | Landscape only — enforced via `Info.plist` supported interface orientations |

No third-party dependencies are introduced. The entire app is built with Apple-first frameworks.

### Orientation Lock

`Info.plist` key `UISupportedInterfaceOrientations~ipad` is set to `[UIInterfaceOrientationLandscapeLeft, UIInterfaceOrientationLandscapeRight]` only. Portrait is excluded. No code-level orientation handling is required beyond this.

### Secure Storage for PIN

The 4-digit PIN (REQ-003) must survive app restarts but must not be stored in SwiftData in plaintext. A thin `KeychainStore` wrapper around `Security.framework` is used to read/write the PIN hash. The PIN is stored as a SHA-256 hash with a fixed app-specific salt.

### Minimum OS Rationale

iPadOS 17 is required because:
- SwiftData (introduced in iOS 17) is explicitly referenced in REQ-005
- The `@Observable` macro (Swift 5.9 / Xcode 15) is required for the chosen architecture (ADR-002)
- `@Environment(\.modelContext)` SwiftData injection pattern is available from iPadOS 17

## Rationale

### Why SwiftUI over UIKit?

SwiftUI on iPadOS 17 provides all primitives needed: `LazyVGrid`, `ScrollView`, state management via `@State` / `@Observable`, animation with `withAnimation`, and accessibility modifiers. UIKit would add boilerplate with no benefit for this app's complexity level. SwiftUI's declarative model also reduces the gap between design and implementation, which is important given that target users require large touch targets and high-contrast visuals.

### Why SwiftData over Core Data?

REQ-005 explicitly states "parent settings persist using SwiftData". SwiftData is the modern successor to Core Data on Apple platforms, available since iOS 17. It integrates natively with SwiftUI via `@Query` and `@Environment(\.modelContext)`, reducing boilerplate significantly over Core Data's `NSFetchRequest`/`NSManagedObjectContext` pattern.

### Why no third-party dependencies?

The app is fully local with a small, well-defined scope. All required functionality (UI, persistence, animation, accessibility, Keychain) is available in Apple frameworks. Introducing third-party packages would add: supply-chain risk, update maintenance burden, and App Store compliance complexity — none of which are justified for a family-use-only local app.

### Alternatives Considered

| Alternative | Rejected Reason |
|---|---|
| UIKit | Unnecessary complexity; SwiftUI sufficient |
| Core Data | SwiftData is the explicit requirement (REQ-005) and simpler for this scope |
| UserDefaults for PIN | Not suitable for security-sensitive values; Keychain is the correct store |
| React Native / Flutter | Cross-platform overhead with no benefit; app is iPad-only |
| TCA / Composable Architecture | Overkill for scope; see ADR-002 |

## Consequences

**Positive:**
- No external dependencies to manage or audit
- SwiftData + SwiftUI integration is frictionless; `@Query` provides reactive task list updates without manual observation
- iPadOS 17 minimum allows use of all modern APIs without compatibility shims
- Full Apple toolchain means straightforward XCUITest E2E coverage

**Negative:**
- Minimum iPadOS 17 excludes older iPads (iPad 9th gen and earlier cannot run iPadOS 17). This is acceptable per the stated requirement of iPadOS 17+.
- SwiftData is a relatively young framework; edge-case bugs may require workarounds. Mitigation: keep SwiftData models simple and avoid complex relationships.

## Acceptance Criteria Impact

| REQ | Criteria | Impact |
|---|---|---|
| REQ-005 | Task completion state persists | SwiftData `TaskCompletion` entity handles this |
| REQ-005 | Parent settings persist using SwiftData | Directly satisfied by tech stack choice |
| REQ-003 | PIN persists across app restarts | Keychain storage satisfies this |
| REQ-001 | App launches without splash delay > 1 second | SwiftData in-process store has negligible startup cost |
| REQ-005 | Landscape lock | `Info.plist` orientation restriction satisfies this |
