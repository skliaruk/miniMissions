# ADR-006: Dynamic Children and Task Bank

**Status:** Proposed
**Date:** 2026-03-30
**Deciders:** ARCH

## Context

Two related features require significant data model changes that affect each other and must be designed together:

### Feature 1: Dynamic Children (REQ-007)

The current model seeds three fixed children ("Sara", "Samuel", "Ben") via `SeedDataService`. REQ-007 requires parents to add, edit, delete, and reorder children dynamically (1-6 children). Child names are now editable, and children can have photos from the device photo library. The fixed seeding approach must be removed.

### Feature 2: Task Bank (REQ-008)

The current model stores tasks per-child (`Task` belongs to one `Child` and one `Topic`). REQ-008 introduces a global **task bank** where parents create task definitions once and assign them to multiple children. This requires splitting the current `Task` entity into two concepts: a global `TaskTemplate` (the definition) and a `TaskAssignment` (the link between a template, a child, and a topic). `TaskCompletion` must reference `TaskAssignment` instead of `Task`.

### Why one ADR?

These features are designed together because:
1. Both fundamentally change the data model (entities, relationships, delete rules)
2. The schema migration must handle both changes atomically (v2 to v3)
3. `SeedDataService` changes for dynamic children intersect with `SeedDataService` changes for the task bank
4. `ResetService` must be updated for `TaskAssignment`-based completions, not `Task`-based
5. The `Child` entity's relationship changes from `tasks: [Task]` to `assignments: [TaskAssignment]`

## Decision

### Removed Entity: `Task`

The `Task` entity (ADR-003, updated in ADR-005) is **removed**. Its responsibilities are split between `TaskTemplate` and `TaskAssignment`. All code referencing `Task` must be updated.

### New Entity: `TaskTemplate`

A `TaskTemplate` is a global task definition that lives in the task bank. It is not owned by any child or topic.

```swift
@Model
final class TaskTemplate {
    @Attribute(.unique) var id: UUID
    var name: String              // Max 30 characters (enforced in ViewModel)
    var iconIdentifier: String    // SF Symbol name or "custom:<UUID>" per ADR-003 icon scheme

    @Relationship(deleteRule: .cascade, inverse: \TaskAssignment.taskTemplate)
    var assignments: [TaskAssignment]

    init(id: UUID = UUID(), name: String, iconIdentifier: String) {
        self.id = id
        self.name = name
        self.iconIdentifier = iconIdentifier
        self.assignments = []
    }
}
```

**Key properties:**
- `name` max 30 characters, enforced at the ViewModel layer (same pattern as current `Task.name`)
- `iconIdentifier` uses the same icon scheme defined in ADR-003 (SF Symbol names or `"custom:<UUID>"` for photo library icons)
- Delete rule is `.cascade` -- deleting a `TaskTemplate` deletes all its `TaskAssignment` records, which cascade-deletes their `TaskCompletion` records

### New Entity: `TaskAssignment`

A `TaskAssignment` links a `TaskTemplate` to a specific `Child` within a specific `Topic`. Each assignment has its own sort order and completion state.

```swift
@Model
final class TaskAssignment {
    @Attribute(.unique) var id: UUID
    var sortOrder: Int            // Display order within a (child, topic) pair
    var child: Child              // Owning child (non-optional)
    var topic: Topic              // Owning topic (non-optional)
    var taskTemplate: TaskTemplate // The template this assignment references (non-optional)

    @Relationship(deleteRule: .cascade, inverse: \TaskCompletion.assignment)
    var completions: [TaskCompletion]

    init(
        id: UUID = UUID(),
        sortOrder: Int,
        child: Child,
        topic: Topic,
        taskTemplate: TaskTemplate
    ) {
        self.id = id
        self.sortOrder = sortOrder
        self.child = child
        self.topic = topic
        self.taskTemplate = taskTemplate
        self.completions = []
    }
}
```

**Key properties:**
- `sortOrder` is per (child, topic) pair -- each child has their own independent task order within each topic
- All three relationships (`child`, `topic`, `taskTemplate`) are non-optional -- an assignment always links exactly one template to one child in one topic
- The same `TaskTemplate` can be assigned to the same child in multiple topics (e.g., "Brush teeth" in both "Aamu" and "Ilta")
- The same `TaskTemplate` can be assigned to multiple children within the same topic
- A **uniqueness constraint** on the combination (child, topic, taskTemplate) is enforced at the ViewModel layer (not at the SwiftData schema level, because SwiftData does not support composite unique constraints). The ViewModel must check for existing assignments before creating a new one.

### Updated Entity: `Child`

`Child` gains the ability to be dynamically created, edited, and deleted. The `tasks` relationship is replaced by `assignments`.

```swift
@Model
final class Child {
    @Attribute(.unique) var id: UUID
    var name: String              // Editable, max 30 characters (enforced in ViewModel)
    var sortOrder: Int            // Determines column/list order
    var avatarImageData: Data?    // Photo from device library; nil = default avatar illustration

    @Relationship(deleteRule: .cascade, inverse: \TaskAssignment.child)
    var assignments: [TaskAssignment]

    init(id: UUID = UUID(), name: String, sortOrder: Int) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
        self.avatarImageData = nil
        self.assignments = []
    }
}
```

**Changes from current (v2):**
- `tasks: [Task]` relationship replaced by `assignments: [TaskAssignment]`
- `name` is now editable by the parent (previously fixed by `SeedDataService`)
- No other field changes -- `avatarImageData` already existed in v2

### Updated Entity: `Topic`

`Topic`'s relationship changes from `tasks: [Task]` to `assignments: [TaskAssignment]`.

```swift
@Model
final class Topic {
    @Attribute(.unique) var id: UUID
    var name: String              // Max 30 characters (enforced in ViewModel)
    var sortOrder: Int            // Determines tab display order

    @Relationship(deleteRule: .cascade, inverse: \TaskAssignment.topic)
    var assignments: [TaskAssignment]

    init(id: UUID = UUID(), name: String, sortOrder: Int) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
        self.assignments = []
    }
}
```

**Changes from current (v2):**
- `tasks: [Task]` relationship replaced by `assignments: [TaskAssignment]`
- Cascade delete now deletes `TaskAssignment` records (which cascade to `TaskCompletion`)

### Updated Entity: `TaskCompletion`

`TaskCompletion` now references `TaskAssignment` instead of `Task`.

```swift
@Model
final class TaskCompletion {
    @Attribute(.unique) var id: UUID
    var assignment: TaskAssignment  // The assignment this completion belongs to (was: task: Task)
    var completedAt: Date
    var isDone: Bool

    init(id: UUID = UUID(), assignment: TaskAssignment, isDone: Bool = true) {
        self.id = id
        self.assignment = assignment
        self.completedAt = Date()
        self.isDone = isDone
    }
}
```

**Changes from current (v2):**
- `task: Task` replaced by `assignment: TaskAssignment`
- All other fields unchanged

### Updated Entity Relationship Diagram

```
TaskTemplate (0..n, global task bank)
  |
  | 1
  |
  | inf
  |
TaskAssignment (0..n per child per topic)
  |         |         |
  | inf     | inf     | 1
  |         |         |
Child     Topic     TaskCompletion (0..1 per assignment)
(1..6)    (1..n)
```

Simplified view:

```
TaskTemplate ──┐
               |
Child ─────────┤ (all three own TaskAssignment)
               |
Topic ─────────┘
               |
               v
         TaskAssignment (belongs to 1 Child + 1 Topic + 1 TaskTemplate)
               |
               v
         TaskCompletion (0..1 per TaskAssignment)
```

### Delete Rules Summary

| Parent Entity | Relationship | Delete Rule | Effect |
|---|---|---|---|
| `TaskTemplate` | `assignments` | `.cascade` | Deleting a template removes all assignments across all children/topics, cascading to completions |
| `Child` | `assignments` | `.cascade` | Deleting a child removes all their assignments across all topics, cascading to completions |
| `Topic` | `assignments` | `.cascade` | Deleting a topic removes all assignments within it for all children, cascading to completions |
| `TaskAssignment` | `completions` | `.cascade` | Deleting an assignment removes its completion record |

### Child CRUD Operations

#### `ChildManagementService`

A new service handles child CRUD with validation:

```swift
struct ChildManagementService {
    static let maxChildren = 6
    static let maxNameLength = 30

    /// Add a new child. Returns nil if max children reached.
    static func addChild(
        name: String,
        avatarImageData: Data? = nil,
        context: ModelContext
    ) -> Child? {
        let descriptor = FetchDescriptor<Child>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count < maxChildren else { return nil }

        let trimmedName = String(name.prefix(maxNameLength))
        let nextSortOrder = count  // New child goes to the end
        let child = Child(name: trimmedName, sortOrder: nextSortOrder)
        child.avatarImageData = avatarImageData
        context.insert(child)
        try? context.save()
        return child
    }

    /// Edit a child's name and/or photo.
    static func editChild(
        _ child: Child,
        name: String? = nil,
        avatarImageData: Data?? = nil,  // nil = no change, .some(nil) = clear photo, .some(data) = set photo
        context: ModelContext
    ) {
        if let name = name {
            child.name = String(name.prefix(maxNameLength))
        }
        if let photoChange = avatarImageData {
            child.avatarImageData = photoChange
        }
        try? context.save()
    }

    /// Delete a child. Returns false if it is the last child (cannot delete).
    static func deleteChild(_ child: Child, context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Child>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count > 1 else { return false }

        context.delete(child)  // Cascade deletes all assignments and completions
        try? context.save()
        return true
    }

    /// Reorder children by updating sortOrder values.
    static func reorderChildren(_ children: [Child], context: ModelContext) {
        for (index, child) in children.enumerated() {
            child.sortOrder = index
        }
        try? context.save()
    }

    /// Check if more children can be added.
    static func canAddChild(context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Child>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        return count < maxChildren
    }

    /// Check if the given child can be deleted (not the last one).
    static func canDeleteChild(context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Child>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        return count > 1
    }
}
```

#### Photo Handling

Child photos come from the device photo library via `PhotosPicker` (PhotosUI framework, available since iOS 16). The selected image is:
1. Loaded as `Data` via `PhotosPickerItem.loadTransferable(type: Data.self)`
2. Resized to a maximum of 200x200pt thumbnail (to keep SwiftData storage reasonable)
3. Stored as `child.avatarImageData`

Photo resizing logic belongs in a utility (`ImageResizer`) or in the ViewModel that handles photo selection. The `Child` entity stores only the final compressed `Data`.

```swift
// In ChildEditorViewModel or similar
import PhotosUI

func processSelectedPhoto(_ item: PhotosPickerItem?) async {
    guard let item = item,
          let data = try? await item.loadTransferable(type: Data.self),
          let uiImage = UIImage(data: data) else {
        return
    }
    let thumbnail = uiImage.preparingThumbnail(of: CGSize(width: 200, height: 200))
    selectedAvatarData = thumbnail?.jpegData(compressionQuality: 0.8)
}
```

### Task Bank CRUD Operations

#### `TaskBankService`

A new service handles task template and assignment CRUD:

```swift
struct TaskBankService {
    static let maxNameLength = 30

    // MARK: - TaskTemplate CRUD

    /// Create a new task template in the bank.
    static func createTemplate(
        name: String,
        iconIdentifier: String,
        context: ModelContext
    ) -> TaskTemplate {
        let trimmedName = String(name.prefix(maxNameLength))
        let template = TaskTemplate(name: trimmedName, iconIdentifier: iconIdentifier)
        context.insert(template)
        try? context.save()
        return template
    }

    /// Edit a task template. Changes are reflected in all assignments automatically
    /// because assignments reference the template via relationship.
    static func editTemplate(
        _ template: TaskTemplate,
        name: String? = nil,
        iconIdentifier: String? = nil,
        context: ModelContext
    ) {
        if let name = name {
            template.name = String(name.prefix(maxNameLength))
        }
        if let icon = iconIdentifier {
            template.iconIdentifier = icon
        }
        try? context.save()
    }

    /// Delete a task template. Cascades to all assignments and their completions.
    static func deleteTemplate(_ template: TaskTemplate, context: ModelContext) {
        context.delete(template)
        try? context.save()
    }

    // MARK: - TaskAssignment CRUD

    /// Assign a template to a child within a topic. Returns nil if already assigned.
    static func assignTemplate(
        _ template: TaskTemplate,
        to child: Child,
        in topic: Topic,
        context: ModelContext
    ) -> TaskAssignment? {
        // Check for duplicate assignment
        let existingAssignments = child.assignments.filter {
            $0.topic.id == topic.id && $0.taskTemplate.id == template.id
        }
        guard existingAssignments.isEmpty else { return nil }

        // Calculate next sort order within (child, topic)
        let topicAssignments = child.assignments.filter { $0.topic.id == topic.id }
        let nextSortOrder = (topicAssignments.map(\.sortOrder).max() ?? -1) + 1

        let assignment = TaskAssignment(
            sortOrder: nextSortOrder,
            child: child,
            topic: topic,
            taskTemplate: template
        )
        context.insert(assignment)
        try? context.save()
        return assignment
    }

    /// Unassign a template from a child/topic. Does NOT delete the template.
    static func removeAssignment(_ assignment: TaskAssignment, context: ModelContext) {
        context.delete(assignment)  // Cascade deletes completions for this assignment
        try? context.save()
    }

    /// Reorder assignments for a specific child within a specific topic.
    static func reorderAssignments(_ assignments: [TaskAssignment], context: ModelContext) {
        for (index, assignment) in assignments.enumerated() {
            assignment.sortOrder = index
        }
        try? context.save()
    }

    /// Fetch all templates in the bank (for display in the task bank UI).
    static func allTemplates(context: ModelContext) -> [TaskTemplate] {
        let descriptor = FetchDescriptor<TaskTemplate>(
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// Fetch assignments for a specific child in a specific topic.
    static func assignments(for child: Child, in topic: Topic) -> [TaskAssignment] {
        child.assignments
            .filter { $0.topic.id == topic.id }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
}
```

### Updated `ResetService`

`ResetService` now works with `TaskAssignment` completions instead of `Task` completions. The structure is similar but traverses `Topic.assignments` instead of `Topic.tasks`.

```swift
struct ResetService {
    /// Reset completions for all assignments within a specific topic (all children).
    static func resetTopic(_ topic: Topic, context: ModelContext) throws {
        for assignment in topic.assignments {
            for completion in assignment.completions {
                context.delete(completion)
            }
        }
        try context.save()
    }

    /// Reset completions for ALL assignments across ALL topics (all children).
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

### Updated `SeedDataService`

The seed service no longer seeds fixed children or fixed tasks. It seeds only:
1. A default topic "Aamu" (unchanged from ADR-005)
2. One default child "Lapsi 1" (so the app is usable immediately)

No default task templates or assignments are seeded -- the parent creates these.

```swift
struct SeedDataService {
    static let defaultTopicName = "Aamu"
    static let defaultChildName = "Lapsi 1"

    static func seedIfNeeded(context: ModelContext) {
        let childDescriptor = FetchDescriptor<Child>()
        let existingChildren = (try? context.fetch(childDescriptor)) ?? []
        guard existingChildren.isEmpty else { return }

        // 1. Seed the default topic (if none exist)
        let topicDescriptor = FetchDescriptor<Topic>()
        let existingTopics = (try? context.fetch(topicDescriptor)) ?? []
        if existingTopics.isEmpty {
            let defaultTopic = Topic(name: defaultTopicName, sortOrder: 0)
            context.insert(defaultTopic)
        }

        // 2. Seed one default child
        let defaultChild = Child(name: defaultChildName, sortOrder: 0)
        context.insert(defaultChild)

        try? context.save()
    }
}
```

**Why seed one default child?** REQ-007 states the app can either launch with no children (requiring the parent to add one before using the routine view) or launch with one default child "Lapsi 1". Seeding one child avoids an empty-state UX problem where the child routine view has nothing to show. The parent can rename, delete (after adding another), or keep this default child.

**Why no default task templates?** REQ-008 establishes the task bank as a parent-managed concept. Seeding predefined templates would impose assumptions about which tasks families need. The parent creates their own templates from scratch. This is consistent with the shift from a prescriptive model (fixed children, fixed tasks) to a flexible model (dynamic children, task bank).

### Updated `ModelContainer` Setup

The schema must include the new entities and remove `Task`:

```swift
// In MorningRoutineApp.swift init()
let schema = Schema([
    Child.self,
    TaskTemplate.self,
    TaskAssignment.self,
    TaskCompletion.self,
    Topic.self
])
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

### Updated `ChildRoutineViewModel`

The ViewModel is updated to work with `TaskAssignment` instead of `Task`:

```swift
@Observable
final class ChildRoutineViewModel {
    var celebratingChildIndex: Int? = nil
    var showingStarBurst: [String: Bool] = [:]

    func completeTask(_ assignment: TaskAssignment, completions: [TaskCompletion], context: ModelContext) {
        guard !isDone(assignment: assignment, completions: completions) else { return }

        let completion = TaskCompletion(assignment: assignment, isDone: true)
        context.insert(completion)
        try? context.save()
    }

    func isDone(assignment: TaskAssignment, completions: [TaskCompletion]) -> Bool {
        completions.contains { $0.assignment.id == assignment.id && $0.isDone }
    }

    func allDone(assignments: [TaskAssignment], completions: [TaskCompletion]) -> Bool {
        guard !assignments.isEmpty else { return false }
        return assignments.allSatisfy { isDone(assignment: $0, completions: completions) }
    }

    func completedCount(assignments: [TaskAssignment], completions: [TaskCompletion]) -> Int {
        assignments.filter { isDone(assignment: $0, completions: completions) }.count
    }
}
```

### Task Completion Write Path (Updated)

When a child taps a task in the routine view:

1. `TaskRowView` calls `ChildRoutineViewModel.completeTask(_ assignment:completions:context:)`
2. ViewModel checks: does a `TaskCompletion` with `assignment.id` already exist with `isDone == true`? If yes, do nothing
3. If no: insert a new `TaskCompletion(assignment: assignment, isDone: true)` and call `context.save()`
4. `@Query` on `TaskCompletion` triggers SwiftUI re-render
5. `TaskRowView` displays the template's name and icon from `assignment.taskTemplate.name` and `assignment.taskTemplate.iconIdentifier`

### Query Patterns

#### Fetching assignments for a specific child and topic (child routine view)

```swift
// Using relationship traversal (preferred)
func assignments(for child: Child, in topic: Topic) -> [TaskAssignment] {
    child.assignments
        .filter { $0.topic.id == topic.id }
        .sorted { $0.sortOrder < $1.sortOrder }
}
```

Or using `@Query` with `FetchDescriptor`:

```swift
func assignments(for child: Child, in topic: Topic, context: ModelContext) -> [TaskAssignment] {
    let childID = child.id
    let topicID = topic.id
    let descriptor = FetchDescriptor<TaskAssignment>(
        predicate: #Predicate<TaskAssignment> { assignment in
            assignment.child.id == childID && assignment.topic.id == topicID
        },
        sortBy: [SortDescriptor(\.sortOrder)]
    )
    return (try? context.fetch(descriptor)) ?? []
}
```

**Note:** The relationship traversal approach is preferred to avoid potential `#Predicate` issues with nested relationship paths (same concern noted in ADR-005).

#### Fetching all task templates (for the task bank view)

```swift
@Query(sort: \TaskTemplate.name) private var templates: [TaskTemplate]
```

#### Displaying task name and icon from an assignment

```swift
// In TaskRowView or similar
let name = assignment.taskTemplate.name
let icon = assignment.taskTemplate.iconIdentifier
```

Because `TaskAssignment.taskTemplate` is a SwiftData relationship, changes to the template's `name` or `iconIdentifier` are automatically reflected in all views that access the assignment.

#### Checking if a template is assigned to a specific child/topic

```swift
func isAssigned(_ template: TaskTemplate, to child: Child, in topic: Topic) -> Bool {
    child.assignments.contains {
        $0.topic.id == topic.id && $0.taskTemplate.id == template.id
    }
}
```

### Schema Migration: v2 to v3

The migration from v2 (Child, Task, Topic, TaskCompletion) to v3 (Child, TaskTemplate, TaskAssignment, Topic, TaskCompletion) is a **custom migration** because:

1. A new entity (`TaskTemplate`) must be created
2. A new entity (`TaskAssignment`) must be created
3. An existing entity (`Task`) must be split into template + assignment records
4. `TaskCompletion` must reference `TaskAssignment` instead of `Task`
5. `Child` and `Topic` relationships change from `Task` to `TaskAssignment`
6. The `Task` entity is removed after data migration

#### Schema Versions

```swift
// MorningRoutineSchemaV1 — already exists from ADR-005
// MorningRoutineSchemaV2 — already exists from ADR-005

enum MorningRoutineSchemaV3: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(3, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Child.self, TaskTemplate.self, TaskAssignment.self, TaskCompletion.self, Topic.self]
    }

    @Model final class Child {
        @Attribute(.unique) var id: UUID
        var name: String
        var sortOrder: Int
        var avatarImageData: Data?
        @Relationship(deleteRule: .cascade, inverse: \TaskAssignment.child)
        var assignments: [TaskAssignment]
        init(id: UUID = UUID(), name: String, sortOrder: Int) {
            self.id = id; self.name = name; self.sortOrder = sortOrder
            self.avatarImageData = nil; self.assignments = []
        }
    }

    @Model final class TaskTemplate {
        @Attribute(.unique) var id: UUID
        var name: String
        var iconIdentifier: String
        @Relationship(deleteRule: .cascade, inverse: \TaskAssignment.taskTemplate)
        var assignments: [TaskAssignment]
        init(id: UUID = UUID(), name: String, iconIdentifier: String) {
            self.id = id; self.name = name; self.iconIdentifier = iconIdentifier
            self.assignments = []
        }
    }

    @Model final class TaskAssignment {
        @Attribute(.unique) var id: UUID
        var sortOrder: Int
        var child: Child
        var topic: Topic
        var taskTemplate: TaskTemplate
        @Relationship(deleteRule: .cascade, inverse: \TaskCompletion.assignment)
        var completions: [TaskCompletion]
        init(id: UUID = UUID(), sortOrder: Int, child: Child, topic: Topic, taskTemplate: TaskTemplate) {
            self.id = id; self.sortOrder = sortOrder; self.child = child
            self.topic = topic; self.taskTemplate = taskTemplate; self.completions = []
        }
    }

    @Model final class TaskCompletion {
        @Attribute(.unique) var id: UUID
        var assignment: TaskAssignment
        var completedAt: Date
        var isDone: Bool
        init(id: UUID = UUID(), assignment: TaskAssignment, isDone: Bool = true) {
            self.id = id; self.assignment = assignment
            self.completedAt = Date(); self.isDone = isDone
        }
    }

    @Model final class Topic {
        @Attribute(.unique) var id: UUID
        var name: String
        var sortOrder: Int
        @Relationship(deleteRule: .cascade, inverse: \TaskAssignment.topic)
        var assignments: [TaskAssignment]
        init(id: UUID = UUID(), name: String, sortOrder: Int) {
            self.id = id; self.name = name; self.sortOrder = sortOrder
            self.assignments = []
        }
    }
}
```

#### Migration Plan

```swift
enum MorningRoutineMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [MorningRoutineSchemaV1.self, MorningRoutineSchemaV2.self, MorningRoutineSchemaV3.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2, migrateV2toV3]
    }

    // V1 -> V2: already defined in ADR-005 (adds Topic entity, Task.topic relationship)
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: MorningRoutineSchemaV1.self,
        toVersion: MorningRoutineSchemaV2.self,
        willMigrate: nil,
        didMigrate: { context in
            // (existing migration from ADR-005 — creates "Aamu" topic, assigns tasks to it)
            let defaultTopic = MorningRoutineSchemaV2.Topic(name: "Aamu", sortOrder: 0)
            context.insert(defaultTopic)
            let taskDescriptor = FetchDescriptor<MorningRoutineSchemaV2.Task>()
            let existingTasks = (try? context.fetch(taskDescriptor)) ?? []
            for task in existingTasks {
                task.topic = defaultTopic
            }
            try? context.save()
        }
    )

    // V2 -> V3: Split Task into TaskTemplate + TaskAssignment, update TaskCompletion
    static let migrateV2toV3 = MigrationStage.custom(
        fromVersion: MorningRoutineSchemaV2.self,
        toVersion: MorningRoutineSchemaV3.self,
        willMigrate: nil,
        didMigrate: { context in
            // Step 1: Read all existing v2 Task records before they are removed.
            // After the schema transition to v3, the Task table data should still be
            // accessible via a raw fetch or intermediate schema. However, because
            // SwiftData custom migrations execute AFTER the schema has been updated,
            // we use the v3 schema types.
            //
            // IMPORTANT: The actual implementation strategy depends on SwiftData's
            // migration behaviour. Two approaches are documented:
            //
            // Approach A (preferred): If SwiftData preserves the old Task table data
            // in a staging area accessible during didMigrate, read from it directly.
            //
            // Approach B (practical fallback): Since SwiftData custom migrations can
            // be unreliable with entity renames and removals, the MDEV should consider
            // a two-step migration:
            //   - V2 -> V2.5: Add TaskTemplate, TaskAssignment entities alongside Task.
            //     In didMigrate, create templates and assignments from existing tasks.
            //   - V2.5 -> V3: Remove Task entity (now that data has been migrated).
            //
            // The conceptual migration logic for both approaches is the same:

            // 1. Deduplicate tasks by (name, iconIdentifier) to create TaskTemplates.
            //    Two tasks with the same name and icon across different children become
            //    one template.
            //
            // 2. For each original Task record, create a TaskAssignment linking the
            //    template to the task's child and topic, preserving sortOrder.
            //
            // 3. For each original TaskCompletion, re-link it to the corresponding
            //    TaskAssignment (matching by the original task's child + topic + template).

            // Pseudocode (MDEV to implement with actual SwiftData migration API):
            //
            // var templateCache: [String: TaskTemplate] = [:]  // key = "name|icon"
            // var taskToAssignment: [UUID: TaskAssignment] = [:]  // old task ID -> new assignment
            //
            // for task in existingV2Tasks {
            //     let key = "\(task.name)|\(task.iconIdentifier)"
            //     let template = templateCache[key] ?? {
            //         let t = TaskTemplate(name: task.name, iconIdentifier: task.iconIdentifier)
            //         context.insert(t)
            //         templateCache[key] = t
            //         return t
            //     }()
            //
            //     let assignment = TaskAssignment(
            //         sortOrder: task.sortOrder,
            //         child: task.child,
            //         topic: task.topic,
            //         taskTemplate: template
            //     )
            //     context.insert(assignment)
            //     taskToAssignment[task.id] = assignment
            // }
            //
            // for completion in existingV2Completions {
            //     if let assignment = taskToAssignment[completion.task.id] {
            //         completion.assignment = assignment
            //     }
            // }
            //
            // try? context.save()

            try? context.save()
        }
    )
}
```

**Key migration considerations:**

1. **Non-destructive:** All existing data is preserved. Each unique (name, icon) combination becomes one `TaskTemplate`. Each task becomes a `TaskAssignment` pointing to the appropriate template.

2. **Deduplication logic:** If child A and child B both have a task named "Brush Teeth" with icon "mouth.fill", they share one `TaskTemplate`. This is the core concept of the task bank -- identical tasks become one template with multiple assignments.

3. **Completion preservation:** Existing `TaskCompletion` records are re-linked from the old `Task` to the new `TaskAssignment`. No completion state is lost.

4. **Fixed children remain:** The migration does NOT delete existing children. The three seeded children from v2 remain intact. They are now editable, can be renamed, and new children can be added (up to 6). The `SeedDataService` check for `existingChildren.isEmpty` prevents re-seeding.

5. **Two-step migration option:** Because SwiftData's custom migration behaviour with entity removal can be unpredictable, MDEV may implement this as two separate migration stages (V2 -> V2.5 -> V3) to ensure the old `Task` data is fully migrated before the entity is removed. This is documented as Approach B above.

6. **Fresh installs:** For new installations (no existing database), no migration runs. `SeedDataService` seeds the default topic and one default child.

7. **UI test isolation:** UI tests use `--uitesting` (in-memory store), so migration never runs during tests. `SeedDataService` seeds fresh data each test run.

### Updated `AppEnvironment`

A new launch argument `--seed-children` is added for UI tests that need a specific number of children pre-seeded:

```swift
struct AppEnvironment {
    var useInMemoryStore: Bool = false
    var skipPINSetup: Bool = false
    var presetPINHash: String? = nil
    var reduceMotion: Bool = false
    var fixedDate: Date? = nil
    var seedChildCount: Int? = nil    // NEW: if set, seed this many children for testing

    static let live = AppEnvironment()

    static func fromLaunchArguments(_ args: [String]) -> AppEnvironment {
        var env = AppEnvironment()
        if args.contains("--uitesting") {
            env.useInMemoryStore = true
        }
        if args.contains("--skip-pin-setup") {
            env.skipPINSetup = true
        }
        if args.contains("--reduce-motion") {
            env.reduceMotion = true
        }
        if let pinIndex = args.firstIndex(of: "--preset-pin-hash"),
           args.indices.contains(pinIndex + 1) {
            env.presetPINHash = args[pinIndex + 1]
        }
        if let seedIndex = args.firstIndex(of: "--seed-children"),
           args.indices.contains(seedIndex + 1),
           let count = Int(args[seedIndex + 1]) {
            env.seedChildCount = count
        }
        return env
    }
}
```

#### Updated `SeedDataService` for Test Seeding

When `seedChildCount` is provided (UI test mode), the service seeds that many children with predictable names:

```swift
struct SeedDataService {
    static let defaultTopicName = "Aamu"
    static let defaultChildName = "Lapsi 1"

    static func seedIfNeeded(context: ModelContext, environment: AppEnvironment = .live) {
        let childDescriptor = FetchDescriptor<Child>()
        let existingChildren = (try? context.fetch(childDescriptor)) ?? []
        guard existingChildren.isEmpty else { return }

        // 1. Seed the default topic (if none exist)
        let topicDescriptor = FetchDescriptor<Topic>()
        let existingTopics = (try? context.fetch(topicDescriptor)) ?? []
        if existingTopics.isEmpty {
            let defaultTopic = Topic(name: defaultTopicName, sortOrder: 0)
            context.insert(defaultTopic)
        }

        // 2. Seed children
        if let testCount = environment.seedChildCount {
            // UI test mode: seed N children with predictable names
            for i in 0..<min(testCount, ChildManagementService.maxChildren) {
                let child = Child(name: "Lapsi \(i + 1)", sortOrder: i)
                context.insert(child)
            }
        } else {
            // Production: seed one default child
            let defaultChild = Child(name: defaultChildName, sortOrder: 0)
            context.insert(defaultChild)
        }

        try? context.save()
    }
}
```

Updated call site in `MorningRoutineApp.swift`:

```swift
SeedDataService.seedIfNeeded(context: container.mainContext, environment: env)
```

### Updated Accessibility Identifiers

New identifiers for child management and task bank UI elements:

```swift
enum AX {
    // ... existing enums ...

    // MARK: - Child Management (REQ-007)

    enum ChildManagement {
        /// The "+ Add Child" button in parent management.
        static let addChildButton = "addChildButton"

        /// A child row in the child management list, identified by child name.
        static func childRow(_ name: String) -> String { "childMgmt_childRow_\(name)" }

        /// Edit button on a child row, identified by child name.
        static func editChildButton(_ name: String) -> String { "childMgmt_editButton_\(name)" }

        /// Delete button on a child row, identified by child name.
        static func deleteChildButton(_ name: String) -> String { "childMgmt_deleteButton_\(name)" }

        /// Reorder drag handle on a child row, identified by child name.
        static func reorderHandle(_ name: String) -> String { "childMgmt_reorderHandle_\(name)" }

        /// Confirm button in the delete child confirmation dialog.
        static let deleteConfirmButton = "childMgmt_deleteConfirmButton"

        /// Cancel button in the delete child confirmation dialog.
        static let deleteCancelButton = "childMgmt_deleteCancelButton"
    }

    // MARK: - Child Editor Sheet (REQ-007)

    enum ChildEditor {
        /// Root of the add/edit child sheet.
        static let root = "childEditor_root"

        /// Child name text field.
        static let nameField = "childEditor_nameField"

        /// Photo picker button / avatar area.
        static let photoButton = "childEditor_photoButton"

        /// Save button in the child editor sheet.
        static let saveButton = "childEditor_saveButton"

        /// Cancel button in the child editor sheet.
        static let cancelButton = "childEditor_cancelButton"

        /// Remove photo button (visible when a photo is set).
        static let removePhotoButton = "childEditor_removePhotoButton"
    }

    // MARK: - Task Bank (REQ-008)

    enum TaskBank {
        /// The task bank section/view in parent management.
        static let root = "taskBank_root"

        /// The "+ Create Task" button to add a new template to the bank.
        static let createTemplateButton = "taskBank_createButton"

        /// A template row in the task bank list, identified by template name.
        static func templateRow(_ name: String) -> String { "taskBank_templateRow_\(name)" }

        /// Edit button on a template row, identified by template name.
        static func editTemplateButton(_ name: String) -> String { "taskBank_editButton_\(name)" }

        /// Delete button on a template row, identified by template name.
        static func deleteTemplateButton(_ name: String) -> String { "taskBank_deleteButton_\(name)" }

        /// Confirm button in the delete template confirmation dialog.
        static let deleteConfirmButton = "taskBank_deleteConfirmButton"

        /// Cancel button in the delete template confirmation dialog.
        static let deleteCancelButton = "taskBank_deleteCancelButton"
    }

    // MARK: - Task Template Editor Sheet (REQ-008)

    enum TemplateEditor {
        /// Root of the add/edit template sheet.
        static let root = "templateEditor_root"

        /// Template name text field.
        static let nameField = "templateEditor_nameField"

        /// Icon picker / "Choose Icon" button.
        static let chooseIconButton = "templateEditor_chooseIconButton"

        /// Save button in the template editor sheet.
        static let saveButton = "templateEditor_saveButton"

        /// Cancel button in the template editor sheet.
        static let cancelButton = "templateEditor_cancelButton"
    }

    // MARK: - Task Assignment (REQ-008)

    enum TaskAssignmentUI {
        /// The "Add from Bank" button in a child's topic task list.
        static let addFromBankButton = "assignment_addFromBankButton"

        /// A template row in the "Add from Bank" picker, identified by template name.
        static func bankPickerRow(_ name: String) -> String { "assignment_bankPickerRow_\(name)" }

        /// Checkmark on an already-assigned template in the bank picker.
        static func bankPickerCheck(_ name: String) -> String { "assignment_bankPickerCheck_\(name)" }

        /// Remove assignment swipe action on an assigned task row.
        static func removeAssignmentAction(_ name: String) -> String { "assignment_removeAction_\(name)" }

        /// Confirm button in the remove assignment confirmation dialog.
        static let removeConfirmButton = "assignment_removeConfirmButton"

        /// Cancel button in the remove assignment confirmation dialog.
        static let removeCancelButton = "assignment_removeCancelButton"

        /// Reorder drag handle on an assigned task row.
        static func reorderHandle(_ name: String) -> String { "assignment_reorderHandle_\(name)" }
    }
}
```

### Updated `AX.ChildNames`

The fixed child names section is removed since children are now dynamic. For UI tests, child names are predictable based on the `--seed-children` argument ("Lapsi 1", "Lapsi 2", etc.).

```swift
enum AX {
    // REMOVED: enum ChildNames — children are now dynamic (REQ-007)
    // UI tests use --seed-children N to create predictable children named "Lapsi 1" .. "Lapsi N"

    enum TestChildNames {
        static func childName(_ index: Int) -> String { "Lapsi \(index + 1)" }
    }
}
```

### Updated Navigation Model

The parent management view gains new sections for child management and task bank:

```
ParentManagementView (navigation stack)
    |
    |- Children Section
    |   |- Child rows (reorderable, swipe-to-delete)
    |   |- "+ Add Child" button
    |   |- [Tap child row] -> ChildEditorSheet (edit name, photo)
    |
    |- Task Bank Section
    |   |- Template rows (name + icon)
    |   |- "+ Create Task" button
    |   |- [Tap template] -> TemplateEditorSheet (edit name, icon)
    |
    |- Topics Section (unchanged from ADR-005)
    |   |- Topic rows (reorderable, swipe-to-delete)
    |   |- "+ Add Topic" button
    |
    |- Child Task Assignment View
    |   |- [Tap child row -> topic] -> Assignment list for that child+topic
    |   |- "Add from Bank" button -> Bank picker (select templates to assign)
    |   |- Swipe-to-remove assignment
    |   |- Reorder assignments
    |
    |- Settings Section
        |- Change PIN
        |- Reset All
```

### Updated Folder Structure

```
MorningRoutine/
|-- Models/
|   |-- Child.swift                  # UPDATED: assignments relationship, editable name
|   |-- TaskTemplate.swift           # NEW: global task definition
|   |-- TaskAssignment.swift         # NEW: links template to child+topic
|   |-- TaskCompletion.swift         # UPDATED: references TaskAssignment
|   |-- Topic.swift                  # UPDATED: assignments relationship
|   +-- SchemaVersions.swift         # UPDATED: adds V3 schema + migration
|
|-- Services/
|   |-- ChildManagementService.swift # NEW: child CRUD + validation
|   |-- TaskBankService.swift        # NEW: template + assignment CRUD
|   |-- ResetService.swift           # UPDATED: works with TaskAssignment
|   |-- SeedDataService.swift        # UPDATED: seeds 1 default child + topic only
|   |-- KeychainStore.swift
|   +-- PINService.swift
|
|-- Features/
|   |-- ChildRoutine/
|   |   |-- ChildRoutineView.swift       # UPDATED: dynamic child count, assignments
|   |   |-- ChildColumnView.swift        # UPDATED: reads from assignments
|   |   |-- TaskRowView.swift            # UPDATED: reads template name/icon from assignment
|   |   +-- ChildRoutineViewModel.swift  # UPDATED: works with TaskAssignment
|   |
|   |-- ParentManagement/
|   |   |-- ParentHomeView.swift             # UPDATED: children section, task bank section
|   |   |-- ChildEditorSheet.swift           # NEW: add/edit child name + photo
|   |   |-- TaskBankView.swift               # NEW: list of task templates
|   |   |-- TemplateEditorSheet.swift        # NEW: add/edit task template
|   |   |-- ChildTaskAssignmentView.swift    # NEW: assign/remove templates for a child+topic
|   |   |-- BankPickerSheet.swift            # NEW: select templates to assign from bank
|   |   |-- ParentManagementViewModel.swift  # UPDATED
|   |   +-- ...
```

### Impact on Existing ADRs

| ADR | Impact |
|---|---|
| ADR-001 | **No change.** Tech stack remains the same. `PhotosUI` framework is already available on iPadOS 17 (no new dependency). |
| ADR-002 | **Minor update.** Navigation model gains new screens in parent management (child editor, task bank, assignment view). Module boundaries: Child Routine module now reads `TaskAssignment` and `TaskTemplate` (via assignment relationship) instead of `Task`. Parent Management module gains full CRUD for `Child`, `TaskTemplate`, and `TaskAssignment`. |
| ADR-003 | **Superseded partially.** `Task` entity is replaced by `TaskTemplate` + `TaskAssignment`. `Child` entity is no longer seeded as fixed. `SeedDataService` changes. `TaskCompletion` references `TaskAssignment`. PIN storage (Keychain) unchanged. Schema migration path extended to V3. The `DailyResetService` (already renamed to `ResetService` in ADR-005) is updated for assignment-based completions. |
| ADR-004 | **Extended.** New launch argument `--seed-children N` for test seeding. New accessibility identifiers for child management, task bank, template editor, and assignment UI. `AppLauncher` helper gains new convenience methods. `SeedDataService` accepts `AppEnvironment` parameter. |
| ADR-005 | **Superseded partially.** `Topic.tasks` relationship replaced by `Topic.assignments`. `ResetService` traverses `topic.assignments` instead of `topic.tasks`. Migration plan extended with V3 stage. Default task seeding removed (no more `defaultTasks` array). |

## Rationale

### Why replace `Task` with `TaskTemplate` + `TaskAssignment` instead of adding a `template` field to `Task`?

The task bank concept fundamentally changes the ownership model. Currently, a `Task` is owned by one `Child` and one `Topic`. With the task bank, the task definition (name, icon) is global and shared across children. Adding a `templateName` field to `Task` would require manual synchronization when renaming -- changing the name would require updating every `Task` record that shares that template name. A separate `TaskTemplate` entity provides:

- Automatic propagation: editing `template.name` is reflected in all assignments via the relationship
- Clean deletion: deleting a template cascades to all assignments
- Single source of truth: the template is the authoritative definition; assignments are lightweight links

### Why a separate `TaskAssignment` entity instead of a many-to-many `TaskTemplate` <-> `Child` relationship?

SwiftData does not natively support many-to-many relationships with additional attributes (sortOrder, topic). A direct many-to-many between `TaskTemplate` and `Child` cannot carry the `topic` and `sortOrder` context. The `TaskAssignment` join entity explicitly models the three-way relationship (template + child + topic) with its own attributes and completion records.

### Why enforce uniqueness (child, topic, template) at the ViewModel layer?

SwiftData does not support composite unique constraints across multiple relationship properties. Enforcing uniqueness at the schema level is not possible. The ViewModel checks for existing assignments before creating new ones, which is sufficient for a single-device, single-user app where concurrent write conflicts cannot occur.

### Why seed one default child instead of zero?

Launching with zero children would show an empty routine view, which is a poor first-run experience. Seeding "Lapsi 1" as a default child ensures the routine view has at least one column immediately. The parent can rename this child and add more. If the parent adds a second child, they can then delete "Lapsi 1" if desired. This matches the REQ-007 option: "app launches with one default child named 'Lapsi 1'".

### Why no default task templates are seeded?

The task bank is a parent-controlled concept (REQ-008). Pre-seeding templates would impose assumptions about families' routines. Different families have different tasks. Starting with an empty bank gives the parent full control and avoids confusion about where the pre-seeded tasks came from.

### Why add `--seed-children` launch argument?

UI tests need deterministic child counts. Since children are now dynamic (not fixed at 3), tests that verify layout for 1, 3, 4, or 6 children need a way to control the initial count. The `--seed-children N` argument seeds N predictable children ("Lapsi 1" through "Lapsi N") at launch, keeping tests isolated and reproducible.

### Alternatives Considered

| Alternative | Rejected Reason |
|---|---|
| Keep `Task` entity and add `templateId` field | No referential integrity; renames require batch updates; no cascade delete |
| Many-to-many `TaskTemplate` <-> `Child` | Cannot carry per-assignment attributes (sortOrder, topic, completion) |
| Schema-level composite unique constraint | Not supported by SwiftData for relationship properties |
| Seed 3 default children (backward compatible) | Contradicts REQ-007 which moves away from fixed children |
| Seed default task templates | Prescriptive; contradicts task bank philosophy of parent control |
| Lightweight migration V2->V3 | Cannot handle entity split (Task -> TaskTemplate + TaskAssignment) or relationship re-pointing |

## Consequences

**Positive:**
- Task definitions are truly shared -- editing once updates everywhere automatically via SwiftData relationships
- Dynamic children (1-6) with full CRUD gives families flexibility
- Clean separation of concerns: `TaskTemplate` (what), `TaskAssignment` (who + where), `TaskCompletion` (done state)
- Cascade delete rules ensure no orphaned records when deleting templates, children, or topics
- Photo handling uses `PhotosUI`'s `PhotosPicker` -- no third-party dependencies (consistent with ADR-001)
- UI tests remain mock-free; `--seed-children` provides deterministic test state

**Negative:**
- Schema migration V2->V3 is complex -- entity split with relationship re-pointing may require a two-step migration (V2->V2.5->V3) if SwiftData cannot handle it in one step
- More entities (5 vs. 3 in V1) increase model surface area
- All existing views, ViewModels, and tests that reference `Task` must be updated to use `TaskTemplate`/`TaskAssignment`
- `SeedDataService` now depends on `AppEnvironment` parameter for test seeding, adding a cross-cutting concern
- Composite uniqueness constraint (child + topic + template) is enforced only at the ViewModel layer -- a bug in the ViewModel could create duplicate assignments

## Acceptance Criteria Impact

### REQ-007 (Dynamic Children)

| AC | Implementation |
|---|---|
| 1. Add child with name (max 30) and optional photo | `ChildManagementService.addChild()` + `ChildEditorSheet` with `PhotosPicker` |
| 2. Edit child's name and photo | `ChildManagementService.editChild()` + `ChildEditorSheet` in edit mode |
| 3. Delete child with confirmation, cascade delete | `ChildManagementService.deleteChild()` + `.cascade` on `Child.assignments` |
| 4. Cannot delete last child | `ChildManagementService.canDeleteChild()` checks `count > 1` |
| 5. Max 6 children, add button disabled | `ChildManagementService.canAddChild()` checks `count < 6` |
| 6. Reorder children via drag-and-drop | `ChildManagementService.reorderChildren()` updates `sortOrder` |
| 7. Layout adapts (columns for 1-3, scrollable for 4-6) | View reads `@Query(sort: \Child.sortOrder)` and switches layout |
| 8. Name and photo displayed in routine view | `ChildColumnView` reads `child.name` and `child.avatarImageData` |
| 9. Deleting child removes column immediately | `.cascade` delete + `@Query` reactive update |
| 10. Adding child adds column immediately | `context.insert` + `@Query` reactive update |

### REQ-008 (Task Bank)

| AC | Implementation |
|---|---|
| 1. Create template with name (max 30) and icon | `TaskBankService.createTemplate()` + `TemplateEditorSheet` |
| 2. Edit template, changes reflected everywhere | `TaskBankService.editTemplate()` -- relationship propagation |
| 3. Delete template with confirmation, cascade | `TaskBankService.deleteTemplate()` + `.cascade` on `TaskTemplate.assignments` |
| 4. Assign template to child within topic | `TaskBankService.assignTemplate()` + `BankPickerSheet` |
| 5. Unassign template from child/topic | `TaskBankService.removeAssignment()` -- does not delete template |
| 6. Template assigned to multiple children | `assignTemplate()` called per child; each creates a `TaskAssignment` |
| 7. Template in same child, multiple topics | `assignTemplate()` with different `topic` parameter; uniqueness check per (child, topic, template) |
| 8. Independent completion state per child | `TaskCompletion` references `TaskAssignment` (unique per child+topic+template) |
| 9. Sort order per child per topic | `TaskAssignment.sortOrder` + `reorderAssignments()` |
| 10. Routine view shows correct name, icon, completion | `TaskRowView` reads `assignment.taskTemplate.name`, `assignment.taskTemplate.iconIdentifier` |
| 11. Editing template updates all displays | SwiftData relationship -- `template.name` change triggers `@Query` re-evaluation |
