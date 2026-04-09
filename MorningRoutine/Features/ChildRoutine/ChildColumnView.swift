// ChildColumnView.swift
// One child's column card — header + task list filtered by active topic.
// See DSGN-002, DSGN-004, DSGN-006 for design specification.

import SwiftUI
import SwiftData

struct ChildColumnView: View {
    let child: Child
    let topic: Topic?
    let completions: [TaskCompletion]
    let viewModel: ChildRoutineViewModel

    @Environment(\.modelContext) private var modelContext

    private var sortedAssignments: [TaskAssignment] {
        guard let topic = topic else {
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
        ZStack {
            RoundedRectangle(cornerRadius: Radius.lg)
                .fill(Color.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .fill(Color.childTint(sortOrder: child.sortOrder).opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .stroke(Color.borderCard, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 2)

            VStack(spacing: 0) {
                // Header
                childHeader

                Divider()
                    .background(Color.borderTaskRow)
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.sm)

                // Task list
                if sortedAssignments.isEmpty {
                    Spacer()
                    Text("routine.noTasksYet")
                        .font(.childSubLabel)
                        .foregroundColor(.textSecondary)
                        .padding()
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(Array(sortedAssignments.enumerated()), id: \.element.id) { index, assignment in
                                TaskRowView(
                                    assignment: assignment,
                                    childIndex: child.sortOrder,
                                    taskIndex: index,
                                    completions: completions,
                                    viewModel: viewModel
                                )
                                if index < sortedAssignments.count - 1 {
                                    Divider()
                                        .background(Color.borderTaskRow)
                                }
                            }
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
            }

            // Celebration overlay — index-based identifier so celebrationView(0) is queryable.
            if isAllDone {
                CelebrationView(
                    childIndex: child.sortOrder,
                    childName: child.name
                )
                .accessibilityIdentifier(AX.ChildRoutine.celebrationView(child.sortOrder))
                .accessibilityLabel(String(format: String(localized: "accessibility.childColumn.allDone"), child.name))
            }
        }
        // Name-based identifier (DSGN-002) — applied directly so columnByName works.
        .accessibilityIdentifier(AX.ChildRoutine.columnByName(child.name))
        .accessibilityLabel(String(format: String(localized: "accessibility.childColumn.routine"), child.name, topic?.name ?? String(localized: "accessibility.childColumn.routineDefaultTopic")))
        .accessibilityElement(children: .contain)
    }

    private var childHeader: some View {
        VStack(spacing: Spacing.xs) {
            // Avatar — accessible as an image element so app.images["childAvatar_Name"] works.
            childAvatar

            // Name label — uses name-based identifier (DSGN-002).
            // Tests query: app.staticTexts["childName_<Name>"].
            Text(child.name)
                .font(.childTitle)
                .foregroundColor(.textChildName)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier(AX.ChildRoutine.childNameLabel(child.name))
                .accessibilityLabel(String(format: String(localized: "accessibility.childColumn.tasks"), child.name))
                .accessibilityAddTraits(.isHeader)

            // Progress indicator
            ProgressDotsView(
                total: sortedAssignments.count,
                completed: completedCount,
                accentColor: Color.childAccent(sortOrder: child.sortOrder)
            )
            .accessibilityIdentifier(AX.ChildRoutine.progressIndicator(child.name))
            .accessibilityLabel(String(format: String(localized: "accessibility.childColumn.progress"), completedCount, sortedAssignments.count))
        }
        .padding(.top, Spacing.lg)
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.sm)
    }

    private var childAvatar: some View {
        Group {
            if let avatarData = child.avatarImageData,
               let uiImage = UIImage(data: avatarData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.childAccent(sortOrder: child.sortOrder), lineWidth: 3)
                    )
                    .accessibilityIdentifier(AX.ChildRoutine.childAvatar(child.name))
                    .accessibilityLabel(String(format: String(localized: "accessibility.childColumn.avatar"), child.name))
            } else {
                // Default avatar: initial letter on colored circle
                ZStack {
                    Circle()
                        .fill(Color.childTint(sortOrder: child.sortOrder))
                    Text(String(child.name.prefix(1)))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color.childAccent(sortOrder: child.sortOrder))
                        .accessibilityHidden(true)
                }
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .stroke(Color.childAccent(sortOrder: child.sortOrder), lineWidth: 3)
                )
                .accessibilityIdentifier(AX.ChildRoutine.childAvatar(child.name))
                .accessibilityLabel(String(format: String(localized: "accessibility.childColumn.avatar"), child.name))
                .accessibilityAddTraits(.isImage)
            }
        }
    }
}

// MARK: - Progress Dots View

struct ProgressDotsView: View {
    let total: Int
    let completed: Int
    let accentColor: Color

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(0..<max(total, 0), id: \.self) { index in
                Circle()
                    .fill(index < completed ? accentColor : Color.borderPINDot)
                    .frame(width: 12, height: 12)
            }
        }
        .accessibilityElement(children: .ignore)
    }
}
