# Topic Categories Implementation (REQ-006)

## Date: 2026-03-30

## Architecture
- New `Topic` SwiftData model: id (UUID), name (String), sortOrder (Int), cascade delete to tasks
- `Task.topic` added as non-optional relationship (Task belongs to Child AND Topic)
- `ResetService` replaces `DailyResetService` with `resetTopic(_:context:)` and `resetAll(context:)`
- `DailyResetService` kept as legacy wrapper delegating to `ResetService`
- `SeedDataService` seeds default "Aamu" topic with sortOrder 0

## Key Files Created/Modified
- Created: `MiniMissions/Models/Topic.swift`
- Created: `MiniMissions/Services/ResetService.swift`
- Created: `MiniMissions/Features/ParentManagement/ChildTopicPickerView.swift`
- Modified: `MiniMissions/Models/Task.swift` (added topic relationship)
- Modified: `MiniMissions/App/MiniMissionsApp.swift` (Topic in schema)
- Modified: `MiniMissions/Services/SeedDataService.swift` (seeds Aamu topic)
- Modified: `MiniMissions/Features/ChildRoutine/ChildRoutineView.swift` (topic tab bar)
- Modified: `MiniMissions/Features/ChildRoutine/ChildColumnView.swift` (filter by topic)
- Modified: `MiniMissions/Features/ParentManagement/ParentHomeView.swift` (topic CRUD, reset, navigation)
- Modified: `MiniMissions/Features/ParentManagement/TaskEditorView.swift` (scoped to child+topic)
- Modified: `MiniMissions/Features/ParentManagement/AddEditTaskSheet.swift` (topic param)

## UI Pattern Notes
- Topic tab bar: HStack of pill-shaped Buttons inside ScrollView, inside card container
- Active tab: brandPurple bg, textOnAccent fg, accessibilityValue "Selected"
- Inactive tab: brandPurpleLight bg, textPrimary fg
- Min touch target: 60pt height, 120pt width per DSGN-004
- Tab bar container: 72pt height, Radius.lg corners, card bg + shadow
- Gear button moved inside tab bar (right-aligned)
- Parent home: Topics section with reorder, reset, rename, add, delete
- Child row now navigates to ChildTopicPickerView then TaskEditorView (child+topic scoped)

## Accessibility Identifiers
- Tab bar: AX.TopicTab.tabBar ("topicTabBar")
- Tab: AX.TopicTab.tab(name) ("topicTab_<Name>")
- Topic management: AX.TopicManagement.* (see AccessibilityIdentifiers.swift)

## Child Names (Cyrillic)
- Child 0: "Сара"
- Child 1: "Самуил"
- Child 2: "Бен"

## Build
- iPad simulator: "iPad Air 11-inch (M4)"
- Build destination for CLI: `platform=iOS Simulator,name=iPad Air 11-inch (M4)`
