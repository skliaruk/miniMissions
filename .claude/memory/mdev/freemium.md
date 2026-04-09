# REQ-010 Freemium Implementation Notes

## Files Created
- `MiniMissions/Services/StoreService.swift` — StoreKit 2 singleton, `@Observable`, handles purchase/restore
- `MiniMissions/Features/Paywall/PaywallView.swift` — Paywall sheet with benefits, purchase, restore
- `MiniMissions/Resources/Products.storekit` — StoreKit configuration for testing

## Files Modified
- `MiniMissions/Features/ParentManagement/ParentHomeView.swift` — Added paywall gate on "+Add Topic" when topics.count >= 1 and not premium; added restore purchase in settings
- All three Localizable.strings (en/fi/ru) — Added paywall.* and settings.restorePurchase keys
- `MiniMissions.xcodeproj/project.pbxproj` — Added new files to project

## Key Patterns
- `Swift.Task` must be used instead of `Task` because the project has a SwiftData model named `Task` that shadows it
- `StoreService` uses `@Observable` (not ObservableObject) and is accessed as `@State private var store = StoreService.shared`
- The paywall gate only fires on the ADD action — existing topics are never blocked (AC-9)
- Product ID: `com.morningroutine.premium` (non-consumable)
- IDs used in pbxproj: FA000043-FA000045, AA000043-AA000045, GR000003D
