// ChildRoutineCompactView.swift
// iPhone (compact) layout for the child routine screen.
// Displays one child at a time with horizontal paging.
// See DSGN-008 for design specification.

import SwiftUI
import SwiftData

struct ChildRoutineCompactView: View {
    @Binding var showParentManagement: Bool
    @Binding var showPINEntry: Bool

    @Query(sort: \Child.sortOrder) private var children: [Child]
    @Query(sort: \Topic.sortOrder) private var topics: [Topic]
    @Query private var completions: [TaskCompletion]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appEnvironment) private var appEnvironment

    @State private var viewModel = ChildRoutineViewModel()
    @State private var selectedTopicID: UUID?
    @State private var selectedChildIndex: Int = 0
    @AppStorage("lastViewedChildIndex") private var lastViewedChildIndex: Int = 0

    private var selectedTopic: Topic? {
        if let id = selectedTopicID {
            return topics.first { $0.id == id }
        }
        return topics.first
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            NavigationStack {
                ZStack {
                    Color.backgroundPrimary
                        .ignoresSafeArea()

                    if children.isEmpty {
                        compactEmptyStateView
                    } else {
                        VStack(spacing: 0) {
                            compactTopicTabBar(width: width)

                            Rectangle()
                                .fill(Color.borderTaskRow)
                                .frame(height: 1)

                            childPager

                            if children.count > 1 {
                                pageIndicator
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
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
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AX.ChildRoutine.root)
        .onChange(of: topics) { _, newTopics in
            if let id = selectedTopicID, !newTopics.contains(where: { $0.id == id }) {
                selectedTopicID = newTopics.first?.id
            }
            if selectedTopicID == nil {
                selectedTopicID = newTopics.first?.id
            }
        }
        .onAppear {
            if selectedTopicID == nil {
                selectedTopicID = topics.first?.id
            }
            selectedChildIndex = lastViewedChildIndex < children.count ? lastViewedChildIndex : 0
        }
        .onChange(of: selectedChildIndex) { _, newIndex in
            lastViewedChildIndex = newIndex
        }
    }

    // MARK: - Empty State

    private var compactEmptyStateView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            Image(systemName: "person.3.fill")
                .font(.system(size: 64))
                .foregroundColor(.brandPurple)

            Text("routine.emptyState.title")
                .font(.childCelebration)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)

            Text("routine.emptyState.body")
                .font(.childTaskLabel)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)

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

            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AX.ChildManagement.emptyStateView)
    }

    // MARK: - Topic Tab Bar (Compact)

    private func compactTopicTabBar(width: CGFloat) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(topics) { topic in
                    compactTopicTabButton(for: topic, width: width)
                }
            }
            .padding(.horizontal, CompactDesignTokens.screenPadding(for: width))
            .padding(.vertical, Spacing.xs)
        }
        .frame(minHeight: 56)
        .background(
            Rectangle()
                .fill(Color.clear)
                .accessibilityElement()
                .accessibilityIdentifier(AX.TopicTab.tabBar)
                .accessibilityLabel(String(localized: "accessibility.topicTabBar"))
        )
    }

    private func compactTopicTabButton(for topic: Topic, width: CGFloat) -> some View {
        let isActive = selectedTopic?.id == topic.id
        return Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTopicID = topic.id
            }
        } label: {
            Text(topic.name)
                .font(CompactDesignTokens.topicTabFont(for: width))
                .foregroundColor(isActive ? .textOnAccent : .textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .frame(minWidth: 64, minHeight: CompactDesignTokens.topicPillMinHeight)
                .background(isActive ? Color.brandPurple : Color.brandPurpleLight)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        }
        .accessibilityIdentifier(AX.TopicTab.tab(topic.name))
        .accessibilityLabel(topic.name)
        .accessibilityValue(isActive ? "Selected" : "")
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
        .accessibilityHint(isActive ? "" : "Double tap to switch to \(topic.name)")
    }

    // MARK: - Child Pager

    private var childPager: some View {
        TabView(selection: $selectedChildIndex) {
            ForEach(Array(children.enumerated()), id: \.element.id) { index, child in
                ChildPageView(
                    child: child,
                    childIndex: child.sortOrder,
                    topic: selectedTopic,
                    completions: completions,
                    viewModel: viewModel
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .accessibilityScrollAction { edge in
            switch edge {
            case .trailing:
                if selectedChildIndex < children.count - 1 { selectedChildIndex += 1 }
            case .leading:
                if selectedChildIndex > 0 { selectedChildIndex -= 1 }
            default:
                break
            }
        }
    }

    // MARK: - Page Indicator Dots

    private var pageIndicator: some View {
        HStack(spacing: CompactDesignTokens.pageDotSpacing) {
            ForEach(0..<children.count, id: \.self) { index in
                Circle()
                    .fill(
                        index == selectedChildIndex
                            ? Color.childAccent(sortOrder: children[index].sortOrder)
                            : Color.borderPINDot
                    )
                    .frame(
                        width: index == selectedChildIndex
                            ? CompactDesignTokens.activePageDotSize
                            : CompactDesignTokens.inactivePageDotSize,
                        height: index == selectedChildIndex
                            ? CompactDesignTokens.activePageDotSize
                            : CompactDesignTokens.inactivePageDotSize
                    )
            }
        }
        .frame(height: CompactDesignTokens.pageIndicatorHeight)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            children.indices.contains(selectedChildIndex)
                ? "Child \(selectedChildIndex + 1) of \(children.count), \(children[selectedChildIndex].name)"
                : "Child \(selectedChildIndex + 1) of \(children.count)"
        )
    }
}
