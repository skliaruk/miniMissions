# ADR-005: Topic Categories Data Model

**Status:** Proposed
**Date:** 2026-03-30
**Deciders:** ARCH

## Context

REQ-006 introduces topic categories (aihealueet) that organize tasks into named groups such as "Aamu" (Morning), "Paeivakodin jaelkeen" (After daycare), and "Ennen nukkumaanmenoa" (Before bedtime). This requires:

1. A new `Topic` entity to represent each category
2. A relationship from `Task` to `Topic` (each task belongs to one topic AND one child)
3. Per-topic reset logic — the current `DailyResetService.resetAllTasks` deletes all `TaskCompletion` records globally; REQ-006 requires resetting completions within a single topic only, plus a "reset all" option
4. Seeding a default "Aamu" topic on first launch
5. Schema migration from v1 (no topics) to v2 (topics required)

Topics are **global** — the same topics appear for all children. However, tasks within a topic are **per-child** — each child has their own independent task list within each topic. This means the `Task` entity has two owning relationships: one to `Child` and one to `Topic`.

## Decision

### New Entity: `Topic`

```swift
@Model
final class Topic {
    @Attribute(.unique) var id: UUID
    var name: String              // Max 30 characters (enforced in UI/ViewModel)
    var sortOrder: Int            // Determines tab display order

    @Relationship(deleteRule: .cascade, inverse: \Task.topic)
    var tasks: [Task]

    init(id: UUID = UUID(), name: String, sortOrder: Int) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
        self.tasks = []
    }
}
```

**Constraints:**
- `name` max length of 30 characters is enforced in the ViewModel layer (same pattern as `Task.name` — see ADR-003)
- `sortOrder` determines tab order in the child-facing view; parent can reorder via drag-and-drop
- Delete rule is `.cascade` — deleting a topic deletes all tasks (and their completions) within it for all children

### Updated Entity: `Task`

`Task` gains a non-optional `topic` relationship. Each task now belongs to exactly one `Child` and exactly one `Topic`.

```swift
@Model
final class Task {
    @Attribute(.unique) var id: UUID
    var name: String
    var iconIdentifier: String
    var sortOrder: Int            // Display order within a child's column for a given topic
    var child: Child              // Owning child (non-optional)
    var topic: Topic              // Owning topic (non-optional) — NEW in v2

    @Relationship(deleteRule: .cascade, inverse: \TaskCompletion.task)
    var completions: [TaskCompletion]

    init(id: UUID = UUID(), name: String, iconIdentifier: String, sortOrder: Int, child: Child, topic: Topic) {
        self.id = id
        self.name = name
        self.iconIdentifier = iconIdentifier
        self.sortOrder = sortOrder
        self.child = child
        self.topic = topic
        self.completions = []
    }
}
```

**Changes from v1:**
- Added `var topic: Topic` — non-optional relationship
- `init` now requires a `topic` parameter
- `sortOrder` semantics clarified: order is within a (child, topic) pair, not just within a child

### Unchanged Entity: `TaskCompletion`

`TaskCompletion` requires no schema changes. It already links to `Task` via `task` relationship. Since `Task` now links to `Topic`, completions can be queried by topic through the `Task` relationship: `completion.task.topic`.

```swift
// No changes to TaskCompletion entity
@Model
final class TaskCompletion {
    @Attribute(.unique) var id: UUID
    var task: Task
    var completedAt: Date
    var isDone: Bool

    init(id: UUID = UUID(), task: Task, isDone: Bool = true) {
        self.id = id
        self.task = task
        self.completedAt = Date()
        self.isDone = isDone
    }
}
```

### Unchanged Entity: `Child`

`Child` requires no schema changes. Its `tasks` relationship already captures all tasks belonging to that child. The topic dimension is modeled through `Task.topic`, not through `Child`.

### Updated Entity Relationship Diagram

```
Topic (1..n, at least 1 must exist)
  |
  | 1         (global — same topics for all children)
  |
  | ∞
  |
Child (3 records, seeded once)────────Task (0..n per child per topic)
  |  1                                  |
  |                                     | 1
  | ∞                                   |
  Task ─────────────────────────────    | 0..1
       (each task belongs to              TaskCompletion
        exactly 1 Child AND
        exactly 1 Topic)
```

Simplified view:

```
Topic ──┐
        │ (both own Task)
Child ──┘
        │
        ▼
      Task (belongs to 1 Child + 1 Topic)
        │
        ▼
      TaskCompletion (0..1 per Task)
```

All delete rules remain `.cascade`:
- Deleting a `Topic` deletes all `Task` records in that topic (for all children), which cascades to their `TaskCompletion` records
- Deleting a `Child` deletes all `Task` records for that child (across all topics), which cascades to their `TaskCompletion` records
- Deleting a `Task` deletes its `TaskCompletion` record

### Updated `DailyResetService` — Per-Topic Reset

The service is renamed to `ResetService` (the "Daily" prefix no longer reflects the semantics since resets are now per-topic, not per-day) and gains two methods:

```swift
struct ResetService {
    /// Reset completions for all tasks within a specific topic (all children)
    static func resetTopic(_ topic: Topic, context: ModelContext) throws {
        let topicID = topic.id
        let descriptor = FetchDescriptor<TaskCompletion>(
            predicate: #Predicate<TaskCompletion> { completion in
                completion.task.topic.id == topicID
            }
        )
        let completions = try context.fetch(descriptor)
        for completion in completions {
            context.delete(completion)
        }
        try context.save()
    }

    /// Reset completions for ALL tasks across ALL topics (all children)
    static func resetAll(context: ModelContext) throws {
        let descriptor = FetchDescriptor<TaskCompletion>()
        let allCompletions = try context.fetch(descriptor)
        for completion in allCompletions {
            context.delete(completion)
        }
        try context.save()
    }
}
```

**Important note on `#Predicate` with relationships:** SwiftData's `#Predicate` supports keypath traversal through relationships (e.g., `completion.task.topic.id`). This was verified as supported in SwiftData on iPadOS 17+. If this predicate fails at runtime due to a SwiftData limitation with nested relationship traversal in `#Predicate`, the fallback approach is to fetch all completions and filter in memory:

```swift
// Fallback if #Predicate with nested relationship traversal is not supported
static func resetTopic(_ topic: Topic, context: ModelContext) throws {
    let descriptor = FetchDescriptor<TaskCompletion>()
    let allCompletions = try context.fetch(descriptor)
    let topicCompletions = allCompletions.filter { $0.task.topic.id == topic.id }
    for completion in topicCompletions {
        context.delete(completion)
    }
    try context.save()
}
```

An alternative approach using the `Topic.tasks` relationship avoids the predicate issue entirely:

```swift
// Alternative: traverse from Topic -> Tasks -> Completions
static func resetTopic(_ topic: Topic, context: ModelContext) throws {
    for task in topic.tasks {
        for completion in task.completions {
            context.delete(completion)
        }
    }
    try context.save()
}
```

MDEV should use whichever approach works correctly at implementation time. The alternative (traversing relationships) is the recommended first choice as it avoids `#Predicate` complexity entirely.

### Updated `SeedDataService`

`SeedDataService` now seeds a default "Aamu" topic in addition to the three children. All default tasks are assigned to this topic.

```swift
struct SeedDataService {
    static let fixedChildren: [(name: String, sortOrder: Int)] = [
        ("Sara", 0),
        ("Samuel", 1),
        ("Ben", 2)
    ]

    static let defaultTopicName = "Aamu"

    static let defaultTasks: [(childIndex: Int, name: String, icon: String, sortOrder: Int)] = [
        (0, "Brush Teeth", "mouth.fill", 0),
        (0, "Get Dressed", "tshirt.fill", 1),
        (0, "Eat Breakfast", "fork.knife", 2),
        (1, "Brush Teeth", "mouth.fill", 0),
        (1, "Get Dressed", "tshirt.fill", 1),
        (1, "Pack Backpack", "backpack.fill", 2),
        (2, "Brush Teeth", "mouth.fill", 0),
        (2, "Wash Hands", "hands.sparkles.fill", 1),
        (2, "Eat Breakfast", "fork.knife", 2),
    ]

    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Child>()
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        // 1. Seed the default topic
        let defaultTopic = Topic(name: defaultTopicName, sortOrder: 0)
        context.insert(defaultTopic)

        // 2. Seed children
        var createdChildren: [Child] = []
        for (name, order) in fixedChildren {
            let child = Child(name: name, sortOrder: order)
            context.insert(child)
            createdChildren.append(child)
        }
        try? context.save()

        // 3. Seed default tasks — all assigned to the default topic
        for taskDef in defaultTasks {
            guard taskDef.childIndex < createdChildren.count else { continue }
            let child = createdChildren[taskDef.childIndex]
            let task = Task(
                name: taskDef.name,
                iconIdentifier: taskDef.icon,
                sortOrder: taskDef.sortOrder,
                child: child,
                topic: defaultTopic  // NEW: assign to default topic
            )
            context.insert(task)
        }
        try? context.save()
    }
}
```

### Updated `ModelContainer` Setup

The schema must include the new `Topic` entity:

```swift
// In MorningRoutineApp.swift init()
let schema = Schema([Child.self, Task.self, TaskCompletion.self, Topic.self])
let config = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: env.useInMemoryStore
)
let container = try! ModelContainer(
    for: schema,
    migrationPlan: MorningRoutineMigrationPlan.self,
    configurations: [config]
)
```

### Schema Migration Strategy: v1 to v2

SwiftData uses `VersionedSchema` and `SchemaMigrationPlan` for schema evolution. The migration from v1 (no `Topic` entity) to v2 (with `Topic` entity and `Task.topic` relationship) is a **custom migration** because:

1. A new entity (`Topic`) must be created
2. An existing entity (`Task`) gains a new non-optional relationship (`topic`)
3. Existing `Task` records must be assigned to a default topic

#### Schema Versions

```swift
enum MorningRoutineSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Child.self, Task.self, TaskCompletion.self]
    }

    // V1 models defined here (copies of original entities)
    @Model final class Child { /* ... v1 fields ... */ }
    @Model final class Task { /* ... v1 fields — no topic ... */ }
    @Model final class TaskCompletion { /* ... v1 fields ... */ }
}

enum MorningRoutineSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Child.self, Task.self, TaskCompletion.self, Topic.self]
    }

    // V2 models — current production entities including Topic
    @Model final class Child { /* ... same as v1 ... */ }
    @Model final class Task { /* ... v2 with topic relationship ... */ }
    @Model final class TaskCompletion { /* ... same as v1 ... */ }
    @Model final class Topic { /* ... new entity ... */ }
}
```

#### Migration Plan

```swift
enum MorningRoutineMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [MorningRoutineSchemaV1.self, MorningRoutineSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: MorningRoutineSchemaV1.self,
        toVersion: MorningRoutineSchemaV2.self,
        willMigrate: nil,
        didMigrate: { context in
            // After schema migration creates the new Topic table and adds
            // the topic column to Task, populate the default topic and
            // assign all existing tasks to it.

            // 1. Create default "Aamu" topic
            let defaultTopic = MorningRoutineSchemaV2.Topic(
                name: "Aamu",
                sortOrder: 0
            )
            context.insert(defaultTopic)

            // 2. Assign all existing tasks to the default topic
            let taskDescriptor = FetchDescriptor<MorningRoutineSchemaV2.Task>()
            let existingTasks = (try? context.fetch(taskDescriptor)) ?? []
            for task in existingTasks {
                task.topic = defaultTopic
            }

            try? context.save()
        }
    )
}
```

**Key migration considerations:**

1. **Non-destructive:** No data is lost. All existing tasks are preserved and assigned to the new default "Aamu" topic.
2. **Idempotent seed check:** After migration, `SeedDataService.seedIfNeeded` will find existing `Child` records and skip seeding. The migration's `didMigrate` block is the only place that creates the default topic for existing users.
3. **Fresh installs:** For new installations (no existing database), no migration runs. `SeedDataService.seedIfNeeded` handles initial topic + children + tasks seeding.
4. **UI test isolation:** UI tests use `--uitesting` (in-memory store), so migration never runs during tests. `SeedDataService` seeds the default topic fresh each test run.

### Query Patterns

#### Fetching tasks for a specific child and topic (child routine view)

```swift
// In ChildRoutineView or ChildRoutineViewModel
func tasks(for child: Child, in topic: Topic) -> [Task] {
    let childID = child.id
    let topicID = topic.id
    let descriptor = FetchDescriptor<Task>(
        predicate: #Predicate<Task> { task in
            task.child.id == childID && task.topic.id == topicID
        },
        sortBy: [SortDescriptor(\.sortOrder)]
    )
    return (try? context.fetch(descriptor)) ?? []
}
```

Or using `@Query` with dynamic filtering in SwiftUI:

```swift
// Filter from topic.tasks relationship
let tasksForChild = topic.tasks
    .filter { $0.child.id == child.id }
    .sorted { $0.sortOrder < $1.sortOrder }
```

#### Fetching all topics (for tab bar)

```swift
@Query(sort: \Topic.sortOrder) private var topics: [Topic]
```

#### Minimum topic constraint (cannot delete last topic)

```swift
// In ParentManagementViewModel
func canDeleteTopic(context: ModelContext) -> Bool {
    let descriptor = FetchDescriptor<Topic>()
    let count = (try? context.fetchCount(descriptor)) ?? 0
    return count > 1
}
```

### Updated Accessibility Identifiers

New identifiers for topic-related UI elements (to be added to `AccessibilityIdentifiers.swift`):

```swift
enum AX {
    // ... existing enums ...

    enum TopicTab {
        static func tab(_ topicIndex: Int) -> String {
            "childRoutine_topicTab_\(topicIndex)"
        }
        static func tabLabel(_ topicIndex: Int) -> String {
            "childRoutine_topicTabLabel_\(topicIndex)"
        }
    }

    enum ParentManagement {
        // ... existing identifiers ...

        // Topic management
        static let addTopicButton = "parentMgmt_addTopicButton"
        static let topicNameField = "parentMgmt_topicNameField"
        static func topicRow(_ index: Int) -> String {
            "parentMgmt_topicRow_\(index)"
        }
        static func deleteTopicButton(_ index: Int) -> String {
            "parentMgmt_deleteTopicButton_\(index)"
        }
        static func renameTopicButton(_ index: Int) -> String {
            "parentMgmt_renameTopicButton_\(index)"
        }
        static func resetTopicButton(_ index: Int) -> String {
            "parentMgmt_resetTopicButton_\(index)"
        }
        static let resetAllButton = "parentMgmt_resetAllButton"
        static let resetTopicConfirmButton = "parentMgmt_resetTopicConfirmButton"
        static let deleteTopicConfirmButton = "parentMgmt_deleteTopicConfirmButton"
    }
}
```

### Updated Folder Structure

```
MorningRoutine/
├── Models/
│   ├── Child.swift
│   ├── Task.swift              # Updated: + topic relationship
│   ├── TaskCompletion.swift
│   ├── Topic.swift             # NEW
│   └── SchemaVersions.swift    # NEW: VersionedSchema + MigrationPlan
│
├── Services/
│   ├── ResetService.swift      # RENAMED from DailyResetService.swift; + resetTopic
│   ├── SeedDataService.swift   # Updated: seeds default "Aamu" topic
│   ├── KeychainStore.swift
│   └── PINService.swift
```

### Task Addition Flow (Updated)

When a parent adds a task in the parent management view, the task must be assigned to both a child AND the currently selected topic:

```swift
// In TaskEditorViewModel or AddEditTaskSheet
func addTask(name: String, iconIdentifier: String, child: Child, topic: Topic, context: ModelContext) {
    let existingTasks = child.tasks.filter { $0.topic.id == topic.id }
    let nextSortOrder = (existingTasks.map(\.sortOrder).max() ?? -1) + 1
    let task = Task(
        name: name,
        iconIdentifier: iconIdentifier,
        sortOrder: nextSortOrder,
        child: child,
        topic: topic
    )
    context.insert(task)
    try? context.save()
}
```

## Rationale

### Why a separate `Topic` entity rather than a `topicName` string on `Task`?

A separate entity ensures:
- Topic rename updates all tasks atomically (via the relationship)
- Sort order for tabs is stored once, not repeated per task
- Cascade delete of a topic correctly removes all associated tasks
- The "at least 1 topic" constraint can be enforced by counting `Topic` records

A string field on `Task` would require manual synchronization of name changes, manual cleanup on "delete", and no clean way to maintain tab sort order.

### Why non-optional `Task.topic` relationship?

Every task must belong to a topic. An optional relationship would allow orphaned tasks that appear in no tab, violating the REQ-006 requirement that tasks are organized by topic. The migration assigns all pre-existing tasks to the default "Aamu" topic, so no task is ever without a topic.

### Why rename `DailyResetService` to `ResetService`?

The service no longer performs only "daily" resets. It now supports per-topic reset and reset-all. The name `ResetService` accurately reflects the expanded scope. The old `resetAllTasks` method is preserved as `resetAll` for backward compatibility with existing reset-all behavior.

### Why custom migration instead of lightweight migration?

A lightweight migration cannot assign a default value for a new non-optional relationship. The `didMigrate` callback is needed to:
1. Create the default `Topic` record
2. Assign all existing `Task` records to that topic

Without the custom migration step, SwiftData would fail to create the `Task.topic` non-optional relationship because there is no `Topic` record to reference.

### Alternatives Considered

| Alternative | Rejected Reason |
|---|---|
| `topicName: String` on `Task` | No referential integrity; rename/delete/reorder requires manual sync |
| Optional `Task.topic` relationship | Allows orphaned tasks; every code path must handle nil topic |
| Many-to-many `Task` <-> `Topic` | Over-engineering; a task belongs to exactly one topic per REQ-006 |
| Separate `ChildTopic` join table | Unnecessary; topics are global, only tasks are per-child |
| Lightweight migration with default value | SwiftData does not support default relationship values in lightweight migration |

## Consequences

**Positive:**
- Clean relational model: `Topic` is a first-class entity with proper cascade deletes
- Per-topic reset is a simple relationship traversal — no complex queries
- Tab order is a single `@Query(sort: \Topic.sortOrder)` — no post-fetch sorting
- Migration is non-destructive — existing users keep all their data, tasks appear under "Aamu"
- UI tests are unaffected — in-memory store seeds fresh data including the default topic

**Negative:**
- Schema migration adds complexity — `VersionedSchema` and `SchemaMigrationPlan` must be maintained for all future versions
- `Task.init` now requires a `topic` parameter — all existing call sites (SeedDataService, AddEditTaskSheet, UI tests that create tasks) must be updated
- `#Predicate` with nested relationship traversal (`completion.task.topic.id`) may have SwiftData limitations — fallback approaches are documented above
- The rename from `DailyResetService` to `ResetService` requires updating all call sites

## Acceptance Criteria Impact

| REQ-006 AC | Implementation |
|---|---|
| 1. Default topic "Aamu" exists on first launch | `SeedDataService` seeds `Topic(name: "Aamu", sortOrder: 0)` |
| 2. Child-facing view shows tabs for each topic | `@Query(sort: \Topic.sortOrder)` populates tab bar |
| 3. Tapping a tab switches all child columns | ViewModel updates `selectedTopic`; view re-queries tasks for new topic |
| 4. Active tab is visually distinct | UI concern — handled by UXUI/MDEV (not data model) |
| 5. Tab touch targets >= 60pt | UI concern — handled by UXUI/MDEV |
| 6. Parent can add topic (max 30 chars) | `Topic.name` validated at ViewModel layer; insert into context |
| 7. Parent can rename topic | Update `topic.name`; cascade via relationship updates all task views |
| 8. Delete topic deletes associated tasks | `.cascade` delete rule on `Topic.tasks` relationship |
| 9. Cannot delete last topic | `canDeleteTopic()` checks `fetchCount > 1` |
| 10. Reorder topics via drag-and-drop | Update `topic.sortOrder` values; `@Query` re-sorts tabs |
| 11. Each child has independent tasks per topic | `Task` belongs to both `Child` and `Topic` — unique per (child, topic) pair |
| 12. Per-topic reset | `ResetService.resetTopic(_:context:)` deletes completions for tasks in that topic |
| 13. Reset all | `ResetService.resetAll(context:)` deletes all completions |
| 14. Both resets require confirmation | UI concern — handled by MDEV (confirmation dialog before calling service) |
| 15. Tab order matches sort order | `@Query(sort: \Topic.sortOrder)` ensures correct ordering |
