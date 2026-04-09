// CopyTasksSheet.swift
// Sheet for copying task assignments from another child in the same topic.
// See REQ-008 for feature specification.

import SwiftUI
import SwiftData

struct CopyTasksSheet: View {
    let targetChild: Child
    let topic: Topic
    let onDismiss: () -> Void

    @Query private var allChildren: [Child]
    @Environment(\.modelContext) private var modelContext

    @State private var selectedChild: Child?

    /// Other children that have at least one assignment in this topic
    private var otherChildrenWithTasks: [Child] {
        let topicID = topic.id
        let targetID = targetChild.id
        return allChildren
            .filter { $0.id != targetID }
            .filter { child in
                child.assignments.contains { $0.topic.id == topicID }
            }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        NavigationStack {
            Group {
                if otherChildrenWithTasks.isEmpty {
                    VStack {
                        Spacer()
                        Text("copySource.empty")
                            .font(.parentBody)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.lg)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(otherChildrenWithTasks) { child in
                            let isSelected = selectedChild?.id == child.id
                            Button {
                                selectedChild = child
                            } label: {
                                HStack(spacing: Spacing.sm) {
                                    // Selection indicator
                                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 24))
                                        .foregroundColor(isSelected ? .brandPurple : .textSecondary)
                                        .frame(width: 44, height: 44)

                                    // Avatar
                                    if let imageData = child.avatarImageData,
                                       let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 44, height: 44)
                                            .clipShape(Circle())
                                    } else {
                                        ZStack {
                                            Circle()
                                                .fill(Color.childTint(sortOrder: child.sortOrder))
                                                .frame(width: 44, height: 44)
                                            Text(String(child.name.prefix(1)))
                                                .font(.parentHeadline)
                                                .foregroundColor(Color.childAccent(sortOrder: child.sortOrder))
                                        }
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(child.name)
                                            .font(.parentHeadline)
                                            .foregroundColor(.textPrimary)

                                        let taskCount = child.assignments.filter { $0.topic.id == topic.id }.count
                                        Text(String(format: String(localized: "childTopicPicker.taskCount"), taskCount))
                                            .font(.parentCaption)
                                            .foregroundColor(.textSecondary)
                                    }

                                    Spacer()
                                }
                            }
                            .accessibilityIdentifier(AX.TaskAssignment.copySourceChildRow(child.name))
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(String(localized: "copySource.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "bankSelector.cancel")) {
                        onDismiss()
                    }
                    .foregroundColor(.brandPurple)
                    .accessibilityIdentifier(AX.TaskAssignment.copySourceCancelButton)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "copySource.confirm")) {
                        if let source = selectedChild {
                            copyTasks(from: source)
                        }
                        onDismiss()
                    }
                    .font(.parentHeadline)
                    .foregroundColor(selectedChild != nil ? .brandPurple : .textSecondary)
                    .disabled(selectedChild == nil)
                    .opacity(selectedChild != nil ? 1.0 : 0.4)
                    .accessibilityIdentifier(AX.TaskAssignment.copySourceConfirmButton)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func copyTasks(from sourceChild: Child) {
        let topicID = topic.id
        let targetID = targetChild.id

        // Get template IDs already assigned to the target child in this topic
        let existingTemplateIDs = Set(
            (allChildren.first { $0.id == targetID } ?? targetChild).assignments
                .filter { $0.topic.id == topicID }
                .map { $0.template.id }
        )

        // Get source child's assignments in this topic
        let sourceAssignments = sourceChild.assignments
            .filter { $0.topic.id == topicID }
            .sorted { $0.sortOrder < $1.sortOrder }

        // Find the current max sortOrder for the target child in this topic
        let currentTarget = allChildren.first { $0.id == targetID } ?? targetChild
        var maxSort = currentTarget.assignments
            .filter { $0.topic.id == topicID }
            .map(\.sortOrder)
            .max() ?? -1

        for sourceAssignment in sourceAssignments {
            // Skip templates already assigned to the target child
            guard !existingTemplateIDs.contains(sourceAssignment.template.id) else { continue }
            maxSort += 1
            let newAssignment = TaskAssignment(
                child: targetChild,
                topic: topic,
                template: sourceAssignment.template,
                sortOrder: maxSort
            )
            modelContext.insert(newAssignment)
        }
        try? modelContext.save()
    }
}
