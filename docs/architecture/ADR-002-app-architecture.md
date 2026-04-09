# ADR-002: App Architecture Pattern and Structure

**Status:** Accepted
**Date:** 2026-03-26
**Deciders:** ARCH

## Context

The app has two clearly separated concerns:

1. **Child-facing Routine View** — read-heavy, animated, must respond instantly to taps, optimised for ages 2–6
2. **Parent Management View** — CRUD-heavy, adult-oriented, PIN-gated

An architecture pattern must be chosen that:
- Cleanly separates these two concerns
- Supports E2E testing without mocking (ADR-004)
- Keeps the codebase navigable for a small team (MDEV + QA)
- Works idiomatically with SwiftUI and SwiftData

## Decision

### Architecture Pattern: MVVM-Lite with `@Observable`

The app uses **MVVM-Lite**: SwiftUI views are backed by `@Observable` view models that own business logic and state transformations. SwiftData `@Query` properties are used directly in views where no transformation is needed. No additional architectural layer (TCA, VIPER, Clean Architecture) is introduced.

- Views are pure rendering and user interaction forwarding
- ViewModels contain: state that requires transformation, side-effect triggers (e.g. PIN validation logic, animation state), and formatted data
- SwiftData models are NOT used directly as view models — they are accessed via `@Query` in views or fetched by view models via `ModelContext`

### Navigation Model

The app uses a two-level navigation structure:

```
App Entry Point (TaskApp.swift)
│
├── [No PIN set] → PINSetupView (modal, blocks routine view)
│
└── ChildRoutineView (root, always landscape, fills screen)
        │
        └── [Gear icon tap] → PINGateView (sheet, full-screen cover)
                │
                └── [Correct PIN] → ParentManagementView (navigation stack)
                        │
                        ├── ChildTaskListEditorView (NavigationLink per child)
                        │       └── TaskEditorView (add/edit task)
                        └── PINChangeView
```

- `ChildRoutineView` is the **root view** — it is never popped from the stack
- Parent management is presented as a **`.fullScreenCover`** to visually separate the two modes
- Inside `ParentManagementView`, a `NavigationStack` with `NavigationLink` handles child-to-task-editor drill-down
- `PINSetupView` on first launch is presented as a `.fullScreenCover` over `ChildRoutineView` until PIN is set

### Folder Structure

```
TaskApp/
├── App/
│   ├── TaskApp.swift               # @main entry, ModelContainer setup
│   └── AppEnvironment.swift        # DI container (see ADR-004)
│
├── Features/
│   ├── ChildRoutine/
│   │   ├── ChildRoutineView.swift
│   │   ├── ChildColumnView.swift
│   │   ├── TaskRowView.swift
│   │   └── ChildRoutineViewModel.swift
│   │
│   ├── ParentManagement/
│   │   ├── ParentManagementView.swift
│   │   ├── ChildTaskListEditorView.swift
│   │   ├── TaskEditorView.swift
│   │   ├── ParentManagementViewModel.swift
│   │   └── TaskEditorViewModel.swift
│   │
│   ├── PINGate/
│   │   ├── PINGateView.swift
│   │   ├── PINSetupView.swift
│   │   ├── PINChangeView.swift
│   │   └── PINGateViewModel.swift
│   │
│   └── Shared/
│       ├── AnimationViews/
│       │   ├── StarAnimationView.swift
│       │   └── CelebrationAnimationView.swift
│       └── IconPickerView.swift
│
├── Models/
│   ├── Child.swift                 # SwiftData @Model
│   ├── Task.swift                  # SwiftData @Model
│   └── TaskCompletion.swift        # SwiftData @Model
│
├── Services/
│   ├── KeychainStore.swift         # PIN storage
│   ├── DailyResetService.swift     # Reset logic
│   └── SeedDataService.swift       # Seeds 3 fixed children on first launch
│
├── Resources/
│   ├── Assets.xcassets
│   └── BuiltInIcons/               # Built-in icon image set
│
└── Tests/
    ├── TaskAppTests/               # XCTest unit tests
    └── TaskAppUITests/             # XCUITest E2E tests
```

### Module Boundaries

**Child Routine Module** (read-only consumer):
- Reads `Child`, `Task`, `TaskCompletion` via `@Query`
- Writes only `TaskCompletion.isDone = true` (task tap)
- Has no access to PIN, task editing, or reset logic
- All state changes are one-directional: tap → set isDone → SwiftData persists → `@Query` updates view

**Parent Management Module** (full CRUD):
- Full read/write access to `Task` and `TaskCompletion` via `ModelContext`
- Calls `DailyResetService.resetAllTasks(context:)` for daily reset
- Calls `KeychainStore` for PIN read/write
- No UI interaction with children (the child view is hidden behind `.fullScreenCover`)

**PIN Gate Module** (security boundary):
- Reads PIN hash from `KeychainStore`
- Owns lockout countdown state (`PINGateViewModel`)
- On successful PIN validation, dismisses itself and presents `ParentManagementView`
- Never exposes the PIN hash to other modules

### View Model Responsibilities

| ViewModel | Owns |
|---|---|
| `ChildRoutineViewModel` | Per-child "all tasks done" computed state, animation trigger flags |
| `PINGateViewModel` | Attempt counter, lockout timer, PIN hash comparison |
| `ParentManagementViewModel` | Reset confirmation state, child list |
| `TaskEditorViewModel` | Task name validation (max 30 chars), icon selection state, save/delete |

### State Management Rules

1. **SwiftData is the single source of truth** for all persisted state (tasks, completion state, task order)
2. **`@State` / `@Observable`** owns transient UI state (animation flags, sheet presentation, lockout timer)
3. **No in-memory caches** — views always read from `@Query` or `ModelContext.fetch`
4. **No EnvironmentObject for data** — data flows through SwiftData's `@Environment(\.modelContext)` and `@Query`

## Rationale

### Why MVVM-Lite over TCA?

The Composable Architecture (TCA) provides excellent testability through pure reducers and effects, but introduces significant boilerplate (`Reducer`, `Store`, `Action` enums, `Effect` chaining) that exceeds the complexity of this app. The two primary concerns (child view and parent view) are nearly independent — there is no complex cross-feature state coordination that would justify TCA's overhead.

MVVM-Lite with `@Observable` and SwiftData `@Query` achieves the same reactive data flow with far less code surface. The app's testability is achieved through the `AppEnvironment` DI pattern (ADR-004), not through TCA's reducer isolation.

### Why `.fullScreenCover` for parent management?

Using `.fullScreenCover` (rather than `NavigationLink` or `sheet`) for the parent management view:
- Provides clear visual separation — no child-facing UI visible behind adult UI
- Matches the intent of the parental gate (REQ-003): the two modes feel like different apps
- Simplifies state: `ChildRoutineView` does not need to know anything about parent management state
- Prevents any animation from partially revealing child data while transitioning

### Why seed `Child` records rather than hard-code them in views?

While children are "fixed" (REQ-001 states names are not editable), storing them as SwiftData records rather than view constants means:
- Each `Task` has a proper SwiftData relationship to a `Child` record (required for `@Query` predicates)
- `DailyResetService` can reset by child without hard-coded child names
- XCUITest can verify child identity via accessibility identifiers derived from the model

### Alternatives Considered

| Alternative | Rejected Reason |
|---|---|
| TCA | Excessive boilerplate for app scope; see above |
| VIPER | Too many layers; this is a 2-screen app, not an enterprise system |
| `NavigationStack` for parent management (push) | Mixing child and parent UI in one stack risks accidental navigation; `.fullScreenCover` is cleaner |
| EnvironmentObject for shared data | SwiftData `@Query` + `ModelContext` is the idiomatic SwiftUI/SwiftData pattern |

## Consequences

**Positive:**
- Clear feature isolation means MDEV can implement `ChildRoutine` and `ParentManagement` features in parallel
- `@Query` provides automatic UI updates when SwiftData records change — no manual notification plumbing
- Folder structure by feature makes ownership obvious
- ViewModels are testable in unit tests (XCTest) without launching the full UI

**Negative:**
- MVVM-Lite has less formal structure than TCA; team must follow the defined state management rules to avoid state drift
- `@Observable` requires iOS 17 — enforced by our minimum OS (ADR-001)

## Acceptance Criteria Impact

| REQ | Criteria | Impact |
|---|---|---|
| REQ-001 | Routine view is first screen shown | `ChildRoutineView` is always root; PIN setup is an overlay |
| REQ-001 | All 3 children visible simultaneously | `ChildColumnView` × 3 in `HStack` fills landscape screen |
| REQ-003 | Parent entry not prominent | Small gear icon in corner of `ChildRoutineView`, no label |
| REQ-004 | Task list updates reflected immediately | SwiftData `@Query` reactive update handles this automatically |
| REQ-004 | Reset reflects immediately in routine view | `@Query` on `TaskCompletion` re-evaluates after `DailyResetService` deletes records |
