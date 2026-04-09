# Localization (REQ-009)

## Implementation
- Three languages: English (en), Finnish (fi), Russian (ru)
- Localizable.strings files in `MiniMissions/Resources/{en,fi,ru}.lproj/`
- PBXVariantGroup `VG000001` added to pbxproj with file refs FA000040/41/42
- Build file AA000040 in Resources build phase
- knownRegions updated: en, fi, ru, Base
- CFBundleLocalizations added to Info.plist

## Pattern
- SwiftUI `Text("key")` auto-looks up Localizable.strings
- Non-Text contexts: `String(localized: "key")`
- Format strings: `String(format: String(localized: "key"), args...)`
- SeedDataService.defaultTopicName is now a computed property using `String(localized:)`

## Key prefixes
- routine.* — child routine view
- parent.* — parent home
- topics.* — topic management
- children.* — child management
- childForm.* — add/edit child sheet
- taskBank.* — task bank
- templateForm.* — add/edit template
- taskEditor.* — task editor
- bankSelector.* — bank selector sheet
- settings.* — settings section
- pin.* — PIN views/viewmodel
- celebration.* — celebration view
- accessibility.* — shared accessibility labels
- taskSheet.* — add/edit task sheet
- childTopicPicker.* — child topic picker
- seed.* — seed data
