# iPhone Layout Implementation (DSGN-008)

## Date: 2026-04-15

## What was done
- Added iPhone portrait support alongside existing iPad landscape layout
- Used `horizontalSizeClass == .compact` in ContentRootView to switch between layouts
- iPad views remain completely untouched

## New files
- `MiniMissions/DesignSystem/CompactDesignTokens.swift` - iPhone-specific sizing with lerp scaling (375pt-430pt)
- `MiniMissions/Features/ChildRoutine/ChildPageView.swift` - Single child page for iPhone pager
- `MiniMissions/Features/ChildRoutine/ChildRoutineCompactView.swift` - iPhone main screen with TabView pager

## Modified files
- `MiniMissions/Resources/Info.plist` - Added `UISupportedInterfaceOrientations` with portrait for iPhone
- `MiniMissions/App/ContentRootView.swift` - Added sizeClass branching
- `MiniMissions.xcodeproj/project.pbxproj` - Added new files, changed TARGETED_DEVICE_FAMILY from 2 to "1,2"

## Architecture decisions
- ChildRoutineCompactView uses same @Query patterns as iPad ChildRoutineView
- Reuses TaskRowView directly (it already works at any width)
- Uses @AppStorage("lastViewedChildIndex") for child persistence
- TabView(.page) for child horizontal paging with custom page indicator dots
- CompactProgressDotsView separate from iPad ProgressDotsView (different sizing)

## Key patterns
- CompactDesignTokens uses UIScreen.main.bounds.width for lerp calculations
- Same accessibility identifiers as iPad (AX.ChildRoutine.*)
- NavigationStack wraps compact view for toolbar gear icon placement
