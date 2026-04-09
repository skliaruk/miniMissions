// DesignTokens.swift
// Design system tokens per DSGN-001.
// Color assets defined in Assets.xcassets.

import SwiftUI

// MARK: - Spacing

enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Radius

enum Radius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let full: CGFloat = 9999
    static let avatar: CGFloat = 40
}

// MARK: - Color Tokens

extension Color {
    // Background
    static let backgroundPrimary = Color("background.primary")
    static let backgroundCard = Color("background.card")
    static let backgroundTaskIncomplete = Color("background.taskIncomplete")
    static let backgroundTaskComplete = Color("background.taskComplete")
    static let backgroundCelebration = Color("background.celebration")
    static let backgroundParentScreen = Color(UIColor.systemGroupedBackground)
    static let backgroundPINScreen = Color("background.pinScreen")

    // Brand
    static let brandPurple = Color("brand.purple")
    static let brandPurpleLight = Color("brand.purpleLight")
    static let brandYellow = Color("brand.yellow")
    static let brandYellowDark = Color("brand.yellowDark")
    static let brandGreen = Color("brand.green")
    static let brandRed = Color("brand.red")
    static let brandOrange = Color("brand.orange")

    // Text
    static let textPrimary = Color("text.primary")
    static let textSecondary = Color("text.secondary")
    static let textOnAccent = Color.white
    static let textChildName = Color("text.childName")
    static let textTaskLabel = Color("text.taskLabel")
    static let textTaskLabelDone = Color("text.taskLabelDone")
    static let textPINDigit = Color.white
    static let textError = Color("text.error")

    // Border
    static let borderCard = Color("border.card")
    static let borderTaskRow = Color("border.taskRow")
    static let borderFocus = Color("border.focus")
    static let borderPINDot = Color("border.pinDot")
    static let borderPINDotFilled = Color.white

    // Child column accents
    static let child1Accent = Color("child1.accent")
    static let child1Tint = Color("child1.tint")
    static let child2Accent = Color("child2.accent")
    static let child2Tint = Color("child2.tint")
    static let child3Accent = Color("child3.accent")
    static let child3Tint = Color("child3.tint")
    static let child4Accent = Color("child4.accent")
    static let child4Tint = Color("child4.tint")
    static let child5Accent = Color("child5.accent")
    static let child5Tint = Color("child5.tint")
    static let child6Accent = Color("child6.accent")
    static let child6Tint = Color("child6.tint")

    // MARK: - Child theme helpers

    static func childAccent(sortOrder: Int) -> Color {
        switch sortOrder {
        case 0: return .child1Accent
        case 1: return .child2Accent
        case 2: return .child3Accent
        case 3: return .child4Accent
        case 4: return .child5Accent
        case 5: return .child6Accent
        default: return .brandPurple
        }
    }

    static func childTint(sortOrder: Int) -> Color {
        switch sortOrder {
        case 0: return .child1Tint
        case 1: return .child2Tint
        case 2: return .child3Tint
        case 3: return .child4Tint
        case 4: return .child5Tint
        case 5: return .child6Tint
        default: return .brandPurpleLight
        }
    }
}

// MARK: - Typography

extension Font {
    // Child-facing
    static let childTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let childTaskLabel = Font.system(.title2, design: .rounded).weight(.semibold)
    static let childCelebration = Font.system(.largeTitle, design: .rounded).weight(.heavy)
    static let childSubLabel = Font.system(.title3, design: .rounded)

    // Parent-facing
    static let parentLargeTitle = Font.system(.largeTitle).weight(.bold)
    static let parentTitle = Font.system(.title).weight(.bold)
    static let parentHeadline = Font.system(.headline).weight(.semibold)
    static let parentBody = Font.system(.body)
    static let parentSubhead = Font.system(.subheadline)
    static let parentCaption = Font.system(.caption)
    static let parentPINDigit = Font.system(size: 48, weight: .bold, design: .default)
    static let parentCountdown = Font.system(.title2).weight(.semibold)
}
