// ChildTopicPickerView.swift
// Shows all topics for a specific child, with per-topic task counts.
// Tapping a topic opens the task editor scoped to child + topic.
// See DSGN-004 for design specification.

import SwiftUI
import SwiftData

struct ChildTopicPickerView: View {
    let child: Child

    @Query(sort: \Topic.sortOrder) private var topics: [Topic]

    var body: some View {
        List {
            Section(String(localized: "topics.section")) {
                ForEach(topics) { topic in
                    NavigationLink {
                        TaskEditorView(child: child, topic: topic)
                    } label: {
                        topicRowLabel(topic: topic)
                    }
                    .accessibilityIdentifier(AX.TopicManagement.childTopicRow(child: child.name, topic: topic.name))
                    .accessibilityLabel(String(format: String(localized: "accessibility.childTopicPicker.row"), topic.name, taskCount(for: topic)))
                    .accessibilityHint(String(format: String(localized: "accessibility.childTopicPicker.row.hint"), child.name, topic.name))
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(format: String(localized: "childTopicPicker.title"), child.name))
        .navigationBarTitleDisplayMode(.large)
    }

    private func topicRowLabel(topic: Topic) -> some View {
        HStack {
            Text(topic.name)
                .font(.parentHeadline)
                .foregroundColor(.textPrimary)

            Spacer()

            Text(String(format: String(localized: "childTopicPicker.taskCount"), taskCount(for: topic)))
                .font(.parentSubhead)
                .foregroundColor(.textSecondary)
        }
    }

    private func taskCount(for topic: Topic) -> Int {
        let childID = child.id
        return topic.topicAssignments.filter { $0.child.id == childID }.count
    }
}
