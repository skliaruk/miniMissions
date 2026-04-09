# REQ-009: Localization (Finnish, English, Russian)

**Status:** Approved
**Priority:** Must
**Effort:** M

## Description

The app must support three languages: Finnish (fi), English (en), and Russian (ru). The device language setting controls which language is displayed. All user-visible strings must be localized — no hardcoded text.

## User Story

As a parent, I want the app to display in my device language so I can use it comfortably in Finnish, English, or Russian.

## Details

- **Finnish (fi)** — primary language, default fallback
- **English (en)** — secondary language
- **Russian (ru)** — tertiary language

All user-visible strings must use `String(localized:)` or `NSLocalizedString`. This includes:
- Navigation titles and button labels
- Section headers and empty state messages
- Alert and confirmation dialog titles and messages
- Accessibility labels and hints
- Seeded default topic name ("Aamu" / "Morning" / "Утро")
- Error messages and info labels

## Acceptance Criteria

1. When device language is Finnish, all UI text appears in Finnish
2. When device language is English, all UI text appears in English
3. When device language is Russian, all UI text appears in Russian
4. Default topic seeded on first launch uses the localized name for the current language
5. No hardcoded user-visible strings remain in Swift source files
6. Xcode project includes fi, en, ru localizations for Localizable.strings

## Out of Scope

- Right-to-left layout (Russian uses LTR)
- Locale-specific date/number formatting (not used in current UI)
- App Store metadata localization
