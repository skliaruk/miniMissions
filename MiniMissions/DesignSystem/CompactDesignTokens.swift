// CompactDesignTokens.swift
// iPhone-specific sizing tokens that scale linearly based on screen width.
// See DSGN-008 Section 4.2 for specification.
// Range: 375pt (iPhone SE) -> 430pt (iPhone Plus/Max).
// Width is passed in from GeometryReader — no UIScreen dependency.

import SwiftUI

enum CompactDesignTokens {

    // MARK: - Screen width reference points

    static let minWidth: CGFloat = 375
    static let maxWidth: CGFloat = 430

    private static func t(for width: CGFloat) -> CGFloat {
        let clamped = min(max(width, minWidth), maxWidth)
        return (clamped - minWidth) / (maxWidth - minWidth)
    }

    private static func lerp(_ min: CGFloat, _ max: CGFloat, width: CGFloat) -> CGFloat {
        min + (max - min) * t(for: width)
    }

    // MARK: - Sizes

    /// Avatar diameter: 56pt (SE) to 72pt (Plus).
    static func avatarSize(for width: CGFloat) -> CGFloat { lerp(56, 72, width: width) }

    /// Task icon container: 48pt (SE) to 56pt (Plus).
    static func taskIconSize(for width: CGFloat) -> CGFloat { lerp(48, 56, width: width) }

    /// Task icon symbol size: 20pt (SE) to 22pt (Plus).
    static func taskIconSymbolSize(for width: CGFloat) -> CGFloat { lerp(20, 22, width: width) }

    /// Task row minimum height.
    static let taskRowMinHeight: CGFloat = 64

    /// Topic pill minimum height.
    static let topicPillMinHeight: CGFloat = 48

    /// Page indicator area height.
    static let pageIndicatorHeight: CGFloat = 32

    // MARK: - Spacing

    /// Screen horizontal padding: 16pt (SE/standard) to 20pt (Plus).
    static func screenPadding(for width: CGFloat) -> CGFloat { width >= 420 ? 20 : 16 }

    // MARK: - Font sizes

    /// Task label font size: 20pt (SE) to 24pt (Plus).
    static func taskLabelFontSize(for width: CGFloat) -> CGFloat { lerp(20, 24, width: width) }

    /// Child title font size: 24pt (SE) to 28pt (Plus).
    static func childTitleFontSize(for width: CGFloat) -> CGFloat { lerp(24, 28, width: width) }

    /// Topic tab font size: 18pt (SE) to 20pt (Plus).
    static func topicTabFontSize(for width: CGFloat) -> CGFloat { lerp(18, 20, width: width) }

    /// Avatar initial letter font size (scaled proportionally to avatar).
    static func avatarInitialFontSize(for width: CGFloat) -> CGFloat { avatarSize(for: width) * 0.45 }

    // MARK: - Fonts (convenience)

    static func childTitleFont(for width: CGFloat) -> Font {
        Font.system(size: childTitleFontSize(for: width), weight: .bold, design: .rounded)
    }

    static func taskLabelFont(for width: CGFloat) -> Font {
        Font.system(size: taskLabelFontSize(for: width), weight: .semibold, design: .rounded)
    }

    static func topicTabFont(for width: CGFloat) -> Font {
        Font.system(size: topicTabFontSize(for: width), weight: .semibold, design: .rounded)
    }

    // MARK: - Progress dots

    /// Progress dot diameter (iPhone).
    static let progressDotSize: CGFloat = 10

    /// Progress dot spacing.
    static let progressDotSpacing: CGFloat = 6

    // MARK: - Page indicator dots

    /// Active page dot diameter.
    static let activePageDotSize: CGFloat = 10

    /// Inactive page dot diameter.
    static let inactivePageDotSize: CGFloat = 8

    /// Page dot spacing.
    static let pageDotSpacing: CGFloat = 8
}
