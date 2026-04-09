# ARCH Memory

## Session: 2026-03-26 — Initial Architecture Design

### Project Summary
iPad-only (iPadOS 17+) morning routine app for children aged 2–6 and their parents.
- 3 fixed children, landscape-locked, no backend
- Child view: tasks with icons, star rewards, celebration animation
- Parent view: PIN-gated task CRUD, daily reset

### Key Constraints Discovered
- SwiftData explicitly required by REQ-005 (parent settings persistence)
- No backend — fully local
- 3 children are fixed (not editable), only tasks per child are managed
- iPadOS 17+ minimum — SwiftData and new SwiftUI APIs fully available
- Landscape locked — orientation support is simple
- PIN has no recovery mechanism (delete/reinstall)
- Task completion state is NOT persisted in SwiftData — it is a transient daily state stored in SwiftData (resets each day)
- Stars are visual only — no persistent score

### Architecture Decisions Made
1. **ADR-001**: Swift 5.9+, SwiftUI, SwiftData, iPadOS 17+, Xcode 15+
2. **ADR-002**: MVVM-lite (ObservableObject / @Observable), no TCA. Two NavigationStack layers — ChildRoutineView (root) and ParentManagementView (modal/sheet). Folder structure by feature.
3. **ADR-003**: SwiftData entities: Child (fixed seed), Task (name, iconIdentifier, sortOrder), TaskCompletion (date, isDone). Daily reset = delete TaskCompletion records for today. PINStore via Keychain wrapper.
4. **ADR-004**: Dependency injection via AppEnvironment struct injected through SwiftUI environment. Launch arguments: --uitesting, --reset-state, --skip-pin-setup, --reduce-motion. Accessibility identifiers: systematic prefix scheme (childRoutine_*, parentMgmt_*, pinGate_*).

### Open Questions
- `#Predicate` with nested relationship traversal (e.g., `completion.task.topic.id`) may not work reliably in SwiftData on iPadOS 17. MDEV should test and use the relationship-traversal fallback documented in ADR-005 if needed.

### Interface Contracts Communicated
- See ADR-002 for module boundaries
- See ADR-003 for data model API
- See ADR-004 for test environment contract
- See ADR-005 for Topic entity, updated Task relationship, ResetService API, migration plan

## Session: 2026-03-30 — Topic Categories (REQ-006)

### Decisions Made
5. **ADR-005**: New `Topic` entity (id, name max 30, sortOrder). `Task` gains non-optional `topic` relationship. `DailyResetService` renamed to `ResetService` with `resetTopic(_:context:)` and `resetAll(context:)`. Default "Aamu" topic seeded on first launch. Schema migration v1->v2 via custom `MigrationStage.custom` with `didMigrate` to create default topic and assign existing tasks. New accessibility identifiers for topic tabs and parent topic management.

### Key Design Choices
- Topic is a separate entity (not a string on Task) for referential integrity
- Task.topic is non-optional — every task must belong to a topic
- Migration creates "Aamu" topic and assigns all existing tasks to it
- ResetService traverses Topic.tasks relationship (avoids #Predicate nested relationship issues)
- ModelContainer schema now includes Topic.self
- SeedDataService seeds Topic before children/tasks

## Session: 2026-03-30 — Dynamic Children + Task Bank (REQ-007, REQ-008)

### Decisions Made
6. **ADR-006**: Combined ADR for dynamic children and task bank. Major data model overhaul:
   - `Task` entity REMOVED, replaced by `TaskTemplate` (global definition) + `TaskAssignment` (child+topic link)
   - `TaskCompletion` now references `TaskAssignment` instead of `Task`
   - `Child` entity: no longer seeded as fixed; name is editable; relationship changes from `tasks: [Task]` to `assignments: [TaskAssignment]`
   - `Topic` relationship changes from `tasks: [Task]` to `assignments: [TaskAssignment]`
   - New services: `ChildManagementService` (CRUD, max 6, min 1), `TaskBankService` (template + assignment CRUD)
   - `SeedDataService` now seeds only 1 default child "Lapsi 1" + default topic "Aamu", no tasks
   - `ResetService` updated to traverse `topic.assignments` instead of `topic.tasks`
   - Schema migration V2->V3 (custom, potentially two-step V2->V2.5->V3 if SwiftData can't handle entity removal in one stage)
   - New launch argument `--seed-children N` for UI test predictable child seeding
   - Composite uniqueness (child+topic+template) enforced at ViewModel layer (SwiftData lacks composite unique constraints on relationships)
   - New accessibility identifiers: AX.ChildManagement, AX.ChildEditor, AX.TaskBank, AX.TemplateEditor, AX.TaskAssignmentUI
   - AX.ChildNames removed (children are dynamic); replaced by AX.TestChildNames

### Key Design Choices
- TaskTemplate is a separate entity from TaskAssignment (not a template field on Task) for referential integrity and automatic relationship-based propagation
- TaskAssignment is a join entity modeling the three-way relationship (template+child+topic) with its own sortOrder and completions
- Seed one default child instead of zero (better first-run UX)
- No default task templates seeded (parent creates their own — task bank philosophy)
- Photo handling via PhotosUI PhotosPicker, stored as Data in Child.avatarImageData (200x200 thumbnail)
- Two-step migration option documented for MDEV if SwiftData can't handle entity removal in one custom migration stage

### Impact on Previous ADRs
- ADR-003: Partially superseded (Task entity removed, Child no longer fixed, SeedDataService changed)
- ADR-005: Partially superseded (Topic.tasks -> Topic.assignments, ResetService updated, migration extended)
- ADR-004: Extended (new launch arg, new AX identifiers)

### Open Questions
- SwiftData migration V2->V3 with entity removal: may need two-step approach. MDEV to test and decide.
- #Predicate with nested relationship traversal remains a concern (relationship traversal preferred over #Predicate)
