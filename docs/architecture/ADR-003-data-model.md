# ADR-003: Data Model

**Status:** Accepted
**Date:** 2026-03-26
**Deciders:** ARCH

## Context

The app requires persistent storage for:
1. Three fixed children (names, avatars)
2. Per-child ordered task lists (name, icon, sort order)
3. Daily task completion state (done/not done, per task, per day)
4. A 4-digit PIN for the parental gate

All storage is local — no backend, no sync. REQ-005 explicitly mandates SwiftData. The daily reset (REQ-004) must clear all completion states for a new day. Task completion state must survive app backgrounding and restarts until manually reset (REQ-005).

## Decision

### SwiftData Entities

#### `Child`

```swift
@Model
final class Child {
    @Attribute(.unique) var id: UUID
    var name: String               // Fixed: "Child 1", "Child 2", "Child 3" — see note below
    var sortOrder: Int             // Determines column order (0, 1, 2)
    var avatarImageData: Data?     // Optional custom photo; nil = use built-in illustration

    @Relationship(deleteRule: .cascade, inverse: \Task.child)
    var tasks: [Task]

    init(id: UUID = UUID(), name: String, sortOrder: Int) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
        self.avatarImageData = nil
        self.tasks = []
    }
}
```

**Note on fixed children:** REQ-001 states child names are fixed and not editable. However, they are seeded as `Child` SwiftData records on first launch (by `SeedDataService`) so that `Task` records can have a proper foreign-key relationship. The name values are defined as constants in `SeedDataService` — the parent management UI does not expose a name-edit field. Should names ever need to be made editable in a future version, the model supports it without schema migration.

#### `Task`

```swift
@Model
final class Task {
    @Attribute(.unique) var id: UUID
    var name: String               // Max 30 characters (enforced in TaskEditorViewModel)
    var iconIdentifier: String     // Either a built-in icon name (SF Symbol or asset name)
                                   // or a special prefix "custom:<UUID>" referencing CustomIconStore
    var sortOrder: Int             // Determines display order within a child's column
    var child: Child               // Owning child (non-optional, always assigned)

    @Relationship(deleteRule: .cascade, inverse: \TaskCompletion.task)
    var completions: [TaskCompletion]

    init(id: UUID = UUID(), name: String, iconIdentifier: String, sortOrder: Int, child: Child) {
        self.id = id
        self.name = name
        self.iconIdentifier = iconIdentifier
        self.sortOrder = sortOrder
        self.child = child
        self.completions = []
    }
}
```

**Icon identifier scheme:**
- Built-in library icons: plain string matching an asset name in `BuiltInIcons/` (e.g. `"icon_brush_teeth"`)
- Custom photo icons chosen from photo library: `"custom:<UUID>"` where `<UUID>` maps to a file saved in the app's Documents directory by `CustomIconStore`
- SF Symbols are not used for task icons — custom asset illustrations are used to ensure visual consistency across all iPad sizes and to support the child-friendly aesthetic (REQ-005)

#### `TaskCompletion`

```swift
@Model
final class TaskCompletion {
    @Attribute(.unique) var id: UUID
    var task: Task                 // The task this completion record belongs to
    var completedAt: Date          // Timestamp of completion (used to verify same-day state)
    var isDone: Bool               // True = task completed for the current day

    init(id: UUID = UUID(), task: Task, isDone: Bool = false) {
        self.id = id
        self.task = task
        self.completedAt = Date()
        self.isDone = isDone
    }
}
```

**Design choice — one `TaskCompletion` record per task per session:**
Rather than one `TaskCompletion` per task per calendar day (which would accumulate history), the model maintains at most one `TaskCompletion` per task. `DailyResetService` deletes all `TaskCompletion` records. This keeps the data model simple and avoids unbounded growth. If completion history is needed in a future version, this can be revisited with a schema migration.

### PIN Storage

The PIN is **not stored in SwiftData**. It is stored in Keychain via `KeychainStore`:

```
Keychain item:
  service: "com.taskapp.pin"
  account: "parentPin"
  value:   SHA-256(appSalt + pin) as hex string
```

`KeychainStore` exposes:
```swift
protocol KeychainStoreProtocol {
    func savePINHash(_ hash: String) throws
    func loadPINHash() throws -> String?
    func deletePINHash() throws
}
```

The `protocol` exists to support the test environment (ADR-004) — in UI tests, a known PIN hash is injected via `AppEnvironment`.

### Entity Relationships Diagram

```
Child (3 records, seeded once)
  │ 1
  │ ∞
  Task (0..n per child)
    │ 1
    │ 0..1
    TaskCompletion (0 or 1 per task; 0 = not started or reset, 1 = done today)
```

All delete rules are `.cascade`: deleting a `Child` deletes its `Task` records; deleting a `Task` deletes its `TaskCompletion` record.

### Persistence Strategy

#### ModelContainer Setup

```swift
// In TaskApp.swift @main
let schema = Schema([Child.self, Task.self, TaskCompletion.self])
let modelConfiguration = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: AppEnvironment.current.useInMemoryStore,
    allowsSave: true
)
let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
```

The `AppEnvironment.current.useInMemoryStore` flag is `true` when the `--uitesting` launch argument is present (ADR-004). This gives UI tests a clean, isolated store per test run.

#### Seeding Fixed Children

`SeedDataService.seedIfNeeded(context: ModelContext)` is called once at app launch:

```swift
struct SeedDataService {
    static let fixedChildren: [(name: String, sortOrder: Int)] = [
        ("Mia", 0),
        ("Noah", 1),
        ("Ella", 2)
    ]

    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Child>()
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }
        for (name, order) in fixedChildren {
            context.insert(Child(name: name, sortOrder: order))
        }
        try? context.save()
    }
}
```

The child names in `fixedChildren` are the only place names are defined. The parent management UI never offers a field to edit them.

### Daily Reset

`DailyResetService.resetAllTasks(context:)` implements the reset operation required by REQ-004:

```swift
struct DailyResetService {
    static func resetAllTasks(context: ModelContext) throws {
        let descriptor = FetchDescriptor<TaskCompletion>()
        let allCompletions = try context.fetch(descriptor)
        for completion in allCompletions {
            context.delete(completion)
        }
        try context.save()
    }
}
```

After this call:
- All `TaskCompletion` records are deleted
- `@Query` observing `TaskCompletion` in `ChildRoutineView` receives an empty result
- Each `TaskRowView` renders its task as incomplete (no matching `TaskCompletion` with `isDone == true`)

The routine view determines a task's done state by:
```swift
// In ChildRoutineView / ChildRoutineViewModel
func isDone(task: Task, completions: [TaskCompletion]) -> Bool {
    completions.contains { $0.task.id == task.id && $0.isDone }
}
```

The `@Query` for `TaskCompletion` uses no date predicate — all records in the store represent the current day's state. The store is clean after every reset.

### Task Completion Write Path

When a child taps a task in `TaskRowView`:

1. `TaskRowView` calls `ChildRoutineViewModel.completeTask(_ task: Task, context: ModelContext)`
2. ViewModel checks: does a `TaskCompletion` with `task.id` already exist with `isDone == true`? If yes, do nothing (REQ-002: tapping done task has no effect)
3. If no: insert a new `TaskCompletion(task: task, isDone: true)` and call `context.save()`
4. `@Query` on `TaskCompletion` in `ChildRoutineView` triggers a SwiftUI re-render
5. `TaskRowView` transitions to done visual state; star animation plays

### Schema Migration Strategy

SwiftData schema versioning uses `VersionedSchema` and `SchemaMigrationPlan`. For this initial version (`v1`), no migration plan is needed. Future schema changes must define a `MigrationStage` from `v1`.

## Rationale

### Why one `TaskCompletion` record per task (not per day)?

Accumulating daily history would require date-based predicates throughout the codebase. For this version (REQ-002: "stars are visual only — no persistent star collection"), history has zero value. A single record per task that is deleted on reset is the simplest correct model.

### Why store `TaskCompletion` in SwiftData rather than `UserDefaults`?

REQ-005 requires task completion state to survive app restarts. SwiftData handles this automatically and integrates with `@Query` for reactive UI updates. `UserDefaults` does not support relational queries and would require manual observation.

### Why store child avatar as `Data?` rather than a file path?

Small avatar images (typically 100×100pt thumbnails) stored as `Data` in SwiftData avoid file management complexity. The `avatarImageData` field is optional; if nil, the view renders a built-in illustration. For custom icons (task icons from photo library), a file path approach via `CustomIconStore` is used instead, because task icons may be larger and numerous.

### Why Keychain for PIN rather than SwiftData?

Keychain is the correct store for security-sensitive values on Apple platforms. SwiftData stores are not encrypted by default. Even though a 4-digit PIN is weak security, storing it hashed in Keychain establishes the correct security pattern and prevents the PIN from appearing in SwiftData database files accessible via device backup tools.

### Alternatives Considered

| Alternative | Rejected Reason |
|---|---|
| One `TaskCompletion` per task per calendar day | Unbounded history growth; no feature value in v1 |
| `UserDefaults` for completion state | No relational query support; manual observation required |
| Storing PIN in SwiftData | Incorrect security practice; Keychain is the right store |
| File-based storage for all data (JSON) | No reactive update support; requires manual notification; more code than SwiftData |

## Consequences

**Positive:**
- Simple, flat model — three entities with clear single-direction relationships
- `@Query` on `TaskCompletion` drives all reactive UI state for the child view
- Daily reset is a single `context.delete` loop — atomic and instant
- In-memory store flag supports clean UI test isolation (ADR-004)

**Negative:**
- No completion history — future analytics would require a schema migration
- Custom icon files (Documents directory) are outside SwiftData and require manual lifecycle management in `CustomIconStore` (delete file when task deleted)

## Acceptance Criteria Impact

| REQ | Criteria | Impact |
|---|---|---|
| REQ-002 | Tapping done task has no effect | `ViewModel.completeTask` checks for existing `TaskCompletion` before inserting |
| REQ-004 | Reset sets all tasks to incomplete | `DailyResetService.resetAllTasks` deletes all `TaskCompletion` records |
| REQ-004 | Changes reflected immediately in routine view | `@Query` reactive update triggers re-render without manual refresh |
| REQ-005 | Completion state persists across restarts | SwiftData persists `TaskCompletion` records to disk automatically |
| REQ-005 | Parent settings persist | `Task` and `Child` records stored in SwiftData persist across restarts |
| REQ-003 | PIN persists across restarts | Keychain persistence survives app restart (not app delete) |
