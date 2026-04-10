// TaskEditorView.swift
// Task assignment editor for a specific child + topic — assign from bank, remove, reorder.
// See DSGN-006, REQ-008 for design specification.

import SwiftUI
import SwiftData

struct TaskEditorView: View {
    let child: Child
    let topic: Topic

    // @Query on Child observes the child record (including its assignments relationship),
    // ensuring the list re-renders when assignments are added or removed.
    @Query private var observedChildren: [Child]

    @Query private var allChildrenForCopy: [Child]

    @Environment(\.modelContext) private var modelContext
    @State private var showBankSelector = false
    @State private var showCopySheet = false

    init(child: Child, topic: Topic) {
        self.child = child
        self.topic = topic
        let childID = child.id
        _observedChildren = Query(
            filter: #Predicate<Child> { $0.id == childID }
        )
    }

    /// Other children that have at least one assignment in this topic.
    private var otherChildrenWithTasks: [Child] {
        let topicID = topic.id
        let childID = child.id
        return allChildrenForCopy
            .filter { $0.id != childID }
            .filter { c in
                c.assignments.contains { $0.topic.id == topicID }
            }
    }

    private var sortedAssignments: [TaskAssignment] {
        let topicID = topic.id
        return ((observedChildren.first ?? child).assignments)
            .filter { $0.topic.id == topicID }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        List {
            if sortedAssignments.isEmpty {
                Text("taskEditor.empty")
                    .font(.parentBody)
                    .foregroundColor(.textSecondary)
                    .accessibilityIdentifier(AX.TaskAssignment.taskEditorEmptyLabel)
            } else {
                ForEach(Array(sortedAssignments.enumerated()), id: \.element.id) { index, assignment in
                    assignmentRow(assignment: assignment)
                }
                .onMove { indices, newOffset in
                    reorderAssignments(from: indices, to: newOffset)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(format: String(localized: "taskEditor.title"), child.name, topic.name))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showBankSelector = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                        Text("taskEditor.addFromBank")
                            .font(.parentHeadline)
                    }
                    .foregroundColor(.brandPurple)
                }
                .accessibilityIdentifier(AX.TaskAssignment.addFromBankButton)
                .accessibilityLabel(String(localized: "accessibility.taskEditor.addFromBank"))
                .accessibilityHint(String(localized: "accessibility.taskEditor.addFromBank.hint"))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            if !otherChildrenWithTasks.isEmpty {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showCopySheet = true
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 16))
                            .foregroundColor(.brandPurple)
                    }
                    .accessibilityIdentifier(AX.TaskAssignment.copyFromButton)
                    .accessibilityLabel(String(localized: "taskEditor.copyFrom"))
                }
            }
        }
        .sheet(isPresented: $showCopySheet) {
            CopyTasksSheet(targetChild: child, topic: topic) {
                showCopySheet = false
            }
        }
        .sheet(isPresented: $showBankSelector) {
            BankSelectorSheet(child: child, topic: topic) {
                showBankSelector = false
            }
        }
    }

    private func assignmentRow(assignment: TaskAssignment) -> some View {
        let namePascal = assignment.template.name.pascalCase
        let childNamePascal = child.name.pascalCase
        let topicNamePascal = topic.name.pascalCase

        return HStack(spacing: Spacing.sm) {
            // Reorder handle
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 18))
                .foregroundColor(.textSecondary)
                .frame(width: 44, height: 44)
                .accessibilityIdentifier(AX.TaskAssignment.assignmentReorderHandle(namePascal))
                .accessibilityLabel(String(format: String(localized: "accessibility.taskEditor.reorder"), assignment.template.name))

            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill(Color.childTint(sortOrder: child.sortOrder))
                Image(systemName: assignment.template.iconIdentifier.hasPrefix("custom:") ? "photo.fill" : assignment.template.iconIdentifier)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.childAccent(sortOrder: child.sortOrder))
            }
            .frame(width: 44, height: 44)

            // Task name
            Text(assignment.template.name)
                .font(.parentHeadline)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityIdentifier(
            AX.TaskAssignment.assignmentRow(child: childNamePascal, topic: topicNamePascal, template: namePascal)
        )
        .accessibilityLabel(assignment.template.name)
        .accessibilityHint(String(localized: "accessibility.taskEditor.swipeHint"))
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                removeAssignment(assignment)
            } label: {
                Label(String(localized: "taskEditor.remove"), systemImage: "minus.circle")
            }
            .tint(.brandOrange)
            .accessibilityIdentifier(AX.TaskAssignment.assignmentRemoveAction(namePascal))
            .accessibilityLabel(String(format: String(localized: "accessibility.taskEditor.remove"), assignment.template.name, child.name, topic.name))
        }
    }

    private func reorderAssignments(from indices: IndexSet, to newOffset: Int) {
        var reordered = sortedAssignments
        reordered.move(fromOffsets: indices, toOffset: newOffset)
        for (i, assignment) in reordered.enumerated() {
            assignment.sortOrder = i
        }
        try? modelContext.save()
    }

    private func removeAssignment(_ assignment: TaskAssignment) {
        modelContext.delete(assignment)
        try? modelContext.save()
    }
}

// MARK: - String PascalCase extension

extension String {
    var pascalCase: String {
        self.components(separatedBy: .whitespaces).map { word in
            guard !word.isEmpty else { return "" }
            return word.prefix(1).uppercased() + word.dropFirst()
        }.joined()
    }
}
