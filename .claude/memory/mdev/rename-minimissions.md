# Rename: MorningRoutine -> MiniMissions

## Date: 2026-04-09

## Summary
App renamed from MorningRoutine to MiniMissions. All internal references updated.

## Changes Made
- Source folders: MorningRoutine/ -> MiniMissions/, MorningRoutineTests/ -> MiniMissionsTests/, MorningRoutineUITests/ -> MiniMissionsUITests/
- Xcode project: MorningRoutine.xcodeproj -> MiniMissions.xcodeproj
- Scheme: MorningRoutine.xcscheme -> MiniMissions.xcscheme
- App entry: MorningRoutineApp.swift -> MiniMissionsApp.swift (struct MiniMissionsApp)
- project.pbxproj: all references updated
- Swift source files: @testable import, comments updated
- Localizable.strings: header comments updated
- MDEV memory files: path references updated
- Bundle identifiers (already done before): fi.minimissions.app, fi.minimissions.app.tests, fi.minimissions.app.uitests
- Info.plist CFBundleDisplayName (already done before): MiniMissions

## Note
- docs/ files NOT updated (PO responsibility)
- .claude/memory/qa/status.md still has old references (QA responsibility)
