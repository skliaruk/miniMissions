// ChildRoutineView.swift
// Root child-facing view. Shows topic tab bar + adaptive child columns layout.
// See REQ-001, REQ-006, REQ-007, DSGN-002, DSGN-004, DSGN-005 for requirements.

import SwiftUI
import SwiftData

struct ChildRoutineView: View {
    @Binding var showParentManagement: Bool
    @Binding var showPINEntry: Bool

    @Query(sort: \Child.sortOrder) private var children: [Child]
    @Query(sort: \Topic.sortOrder) private var topics: [Topic]
    @Query private var completions: [TaskCompletion]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appEnvironment) private var appEnvironment

    @State private var viewModel = ChildRoutineViewModel()
    @State private var selectedTopicID: UUID?

    private var selectedTopic: Topic? {
        if let id = selectedTopicID {
            return topics.first { $0.id == id }
        }
        return topics.first
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                Color.backgroundPrimary
                    .ignoresSafeArea()

                if children.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: Spacing.md) {
                        // Topic tab bar
                        topicTabBar

                        // Adaptive child columns layout
                        childColumnsLayout
                    }
                    .padding(.top, Spacing.md)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AX.ChildRoutine.root)
        .ignoresSafeArea(.keyboard)
        .onChange(of: topics) { _, newTopics in
            // If selected topic was deleted, select first available
            if let id = selectedTopicID, !newTopics.contains(where: { $0.id == id }) {
                selectedTopicID = newTopics.first?.id
            }
            // If no topic selected yet, select first
            if selectedTopicID == nil {
                selectedTopicID = newTopics.first?.id
            }
        }
        .onAppear {
            if selectedTopicID == nil {
                selectedTopicID = topics.first?.id
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack {
            // Gear button in top-right corner
            HStack {
                Spacer()
                Button {
                    showPINEntry = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.textSecondary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityIdentifier(AX.ChildRoutine.parentSettingsButton)
                .accessibilityLabel(String(localized: "accessibility.parentSettings"))
                .accessibilityHint(String(localized: "accessibility.parentSettings.hint"))
                .padding(.trailing, Spacing.md)
                .padding(.top, Spacing.md)
            }

            Spacer()

            VStack(spacing: Spacing.lg) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.brandPurple)

                Text("routine.emptyState.title")
                    .font(.childCelebration)
                    .foregroundColor(.textPrimary)

                Text("routine.emptyState.body")
                    .font(.childTaskLabel)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)

                Button {
                    showPINEntry = true
                } label: {
                    Text("routine.emptyState.openSettings")
                        .font(.childTaskLabel)
                        .foregroundColor(.textOnAccent)
                        .frame(minWidth: 200, minHeight: 60)
                        .background(Color.brandPurple)
                        .clipShape(Capsule())
                }
                .accessibilityIdentifier(AX.ChildManagement.emptyStateSettingsButton)
                .accessibilityLabel(String(localized: "accessibility.openSettings"))
                .accessibilityHint(String(localized: "accessibility.openSettings.hint"))
            }
            .padding(Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .fill(Color.backgroundCard)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 2)
            )
            .frame(maxWidth: 480)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AX.ChildManagement.emptyStateView)
    }

    // MARK: - Child Columns Layout

    private var childColumnsLayout: some View {
        Group {
            if children.count <= 3 {
                // Single row: HStack for 1-3 children
                HStack(spacing: Spacing.lg) {
                    ForEach(children) { child in
                        ChildColumnView(
                            child: child,
                            topic: selectedTopic,
                            completions: completions,
                            viewModel: viewModel
                        )
                        .accessibilityIdentifier(AX.ChildRoutine.column(child.sortOrder))
                        .accessibilityElement(children: .contain)
                    }
                }
                .padding(.horizontal, Spacing.xxl)
                .padding(.bottom, Spacing.xxl)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Two-row grid for 4-6 children
                let row1 = Array(children.prefix(3))
                let row2 = Array(children.dropFirst(3))

                VStack(spacing: Spacing.md) {
                    HStack(spacing: Spacing.md) {
                        ForEach(row1) { child in
                            ChildColumnView(
                                child: child,
                                topic: selectedTopic,
                                completions: completions,
                                viewModel: viewModel
                            )
                            .accessibilityIdentifier(AX.ChildRoutine.column(child.sortOrder))
                            .accessibilityElement(children: .contain)
                        }
                    }

                    HStack(spacing: Spacing.md) {
                        ForEach(row2) { child in
                            ChildColumnView(
                                child: child,
                                topic: selectedTopic,
                                completions: completions,
                                viewModel: viewModel
                            )
                            .accessibilityIdentifier(AX.ChildRoutine.column(child.sortOrder))
                            .accessibilityElement(children: .contain)
                        }
                    }
                }
                .padding(.horizontal, Spacing.xxl)
                .padding(.bottom, Spacing.lg)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Topic Tab Bar

    private var topicTabBar: some View {
        HStack(spacing: Spacing.sm) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(topics) { topic in
                        topicTabButton(for: topic)
                    }
                }
                .padding(.horizontal, Spacing.md)
            }

            Spacer()

            // Parent entry gear button (inside tab bar per DSGN-004)
            Button {
                showPINEntry = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.textSecondary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityIdentifier(AX.ChildRoutine.parentSettingsButton)
            .accessibilityLabel(String(localized: "accessibility.parentSettings"))
            .accessibilityHint(String(localized: "accessibility.parentSettings.hint"))
            .padding(.trailing, Spacing.md)
        }
        .frame(minHeight: 72)
        .background(
            RoundedRectangle(cornerRadius: Radius.lg)
                .fill(Color.backgroundCard)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 2)
        )
        .padding(.horizontal, Spacing.xxl)
        .background(
            Rectangle()
                .fill(Color.white.opacity(0.001))
                .accessibilityElement()
                .accessibilityIdentifier(AX.TopicTab.tabBar)
                .accessibilityLabel(String(localized: "accessibility.topicTabBar"))
        )
    }

    private func topicTabButton(for topic: Topic) -> some View {
        let isActive = selectedTopic?.id == topic.id
        return Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTopicID = topic.id
            }
        } label: {
            Text(topic.name)
                .font(.childTaskLabel)
                .foregroundColor(isActive ? .textOnAccent : .textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
                .frame(minWidth: 80, minHeight: 60)
                .background(isActive ? Color.brandPurple : Color.brandPurpleLight)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        }
        .accessibilityIdentifier(AX.TopicTab.tab(topic.name))
        .accessibilityLabel(topic.name)
        .accessibilityValue(isActive ? "Selected" : "")
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
        .accessibilityHint(isActive ? "" : "Double tap to switch to \(topic.name)")
    }
}
