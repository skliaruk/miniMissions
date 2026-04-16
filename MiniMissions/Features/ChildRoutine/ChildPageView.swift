// ChildPageView.swift
// Single child page for iPhone horizontal pager.
// Shows one child's tasks in a vertical scrollable list.
// See DSGN-008 Section 3.1 for design specification.

import SwiftUI
import SwiftData

struct ChildPageView: View {
    let child: Child
    let childIndex: Int
    let topic: Topic?
    let completions: [TaskCompletion]
    let viewModel: ChildRoutineViewModel

    @Environment(\.modelContext) private var modelContext

    private var sortedAssignments: [TaskAssignment] {
        guard let topic else {
            return child.assignments.sorted { $0.sortOrder < $1.sortOrder }
        }
        let topicID = topic.id
        return child.assignments
            .filter { $0.topic.id == topicID }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private var completedCount: Int {
        viewModel.completedAssignmentCount(assignments: sortedAssignments, completions: completions)
    }

    private var isAllDone: Bool {
        viewModel.allAssignmentsDone(assignments: sortedAssignments, completions: completions)
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack {
                VStack(spacing: 0) {
                    childHeader(width: width)
                        .padding(.top, Spacing.md)
                        .padding(.bottom, Spacing.sm)

                    if sortedAssignments.isEmpty {
                        Spacer()
                        Text("routine.noTasksYet")
                            .font(.childSubLabel)
                            .foregroundColor(.textSecondary)
                            .padding()
                        Spacer()
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: 0) {
                                ForEach(Array(sortedAssignments.enumerated()), id: \.element.id) { idx, assignment in
                                    TaskRowView(
                                        assignment: assignment,
                                        childIndex: childIndex,
                                        taskIndex: idx,
                                        completions: completions,
                                        viewModel: viewModel
                                    )
                                    if idx < sortedAssignments.count - 1 {
                                        Divider()
                                            .background(Color.borderTaskRow)
                                    }
                                }
                            }
                            .padding(.horizontal, CompactDesignTokens.screenPadding(for: width))
                        }
                        .scrollBounceBehavior(.basedOnSize)
                    }
                }

                if isAllDone {
                    CelebrationView(
                        childIndex: childIndex,
                        childName: child.name
                    )
                    .accessibilityIdentifier(AX.ChildRoutine.celebrationView(childIndex))
                    .accessibilityLabel(String(format: String(localized: "accessibility.childColumn.allDone"), child.name))
                }
            }
            .background(Color.childTint(sortOrder: childIndex).opacity(0.08))
            .accessibilityIdentifier(AX.ChildRoutine.columnByName(child.name))
            .accessibilityElement(children: .contain)
        }
    }

    // MARK: - Child Header

    private func childHeader(width: CGFloat) -> some View {
        VStack(spacing: Spacing.xxs) {
            childAvatar(width: width)
                .padding(.bottom, Spacing.xs)

            Text(child.name)
                .font(CompactDesignTokens.childTitleFont(for: width))
                .foregroundColor(.textChildName)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier(AX.ChildRoutine.childNameLabel(child.name))
                .accessibilityLabel(String(format: String(localized: "accessibility.childColumn.tasks"), child.name))
                .accessibilityAddTraits(.isHeader)

            CompactProgressDotsView(
                total: sortedAssignments.count,
                completed: completedCount,
                accentColor: Color.childAccent(sortOrder: childIndex)
            )
            .accessibilityIdentifier(AX.ChildRoutine.progressIndicator(child.name))
            .accessibilityLabel(String(format: String(localized: "accessibility.childColumn.progress"), completedCount, sortedAssignments.count))
            .padding(.top, Spacing.xxs)
        }
        .padding(.horizontal, CompactDesignTokens.screenPadding(for: width))
    }

    // MARK: - Avatar

    private func childAvatar(width: CGFloat) -> some View {
        let size = CompactDesignTokens.avatarSize(for: width)
        return Group {
            if let avatarData = child.avatarImageData,
               let uiImage = UIImage(data: avatarData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.childAccent(sortOrder: childIndex), lineWidth: 3))
                    .accessibilityIdentifier(AX.ChildRoutine.childAvatar(child.name))
                    .accessibilityLabel(String(format: String(localized: "accessibility.childColumn.avatar"), child.name))
            } else {
                ZStack {
                    Circle()
                        .fill(Color.childTint(sortOrder: childIndex))
                    Text(String(child.name.prefix(1)))
                        .font(.system(size: CompactDesignTokens.avatarInitialFontSize(for: width), weight: .bold, design: .rounded))
                        .foregroundColor(Color.childAccent(sortOrder: childIndex))
                        .accessibilityHidden(true)
                }
                .frame(width: size, height: size)
                .overlay(Circle().stroke(Color.childAccent(sortOrder: childIndex), lineWidth: 3))
                .accessibilityIdentifier(AX.ChildRoutine.childAvatar(child.name))
                .accessibilityLabel(String(format: String(localized: "accessibility.childColumn.avatar"), child.name))
                .accessibilityAddTraits(.isImage)
            }
        }
    }
}

// MARK: - Compact Progress Dots View

struct CompactProgressDotsView: View {
    let total: Int
    let completed: Int
    let accentColor: Color

    var body: some View {
        HStack(spacing: CompactDesignTokens.progressDotSpacing) {
            ForEach(0..<max(total, 0), id: \.self) { index in
                Circle()
                    .fill(index < completed ? accentColor : Color.borderPINDot)
                    .frame(width: CompactDesignTokens.progressDotSize,
                           height: CompactDesignTokens.progressDotSize)
            }
        }
        .accessibilityElement(children: .ignore)
    }
}
