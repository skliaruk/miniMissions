// BankSelectorSheet.swift
// Sheet for selecting task templates from the Task Bank to assign to a child+topic.
// See DSGN-006, REQ-008 for design specification.

import SwiftUI
import SwiftData

struct BankSelectorSheet: View {
    let child: Child
    let topic: Topic
    let onDismiss: () -> Void

    @Query private var allTemplates: [TaskTemplate]
    @Environment(\.modelContext) private var modelContext

    @State private var searchText = ""
    @State private var selectedTemplateIDs: Set<UUID> = []
    @State private var showCreateTemplate = false

    /// IDs of templates already assigned to this child+topic
    private var assignedTemplateIDs: Set<UUID> {
        let childID = child.id
        let topicID = topic.id
        let assigned = child.assignments
            .filter { $0.topic.id == topicID }
            .map { $0.template.id }
        return Set(assigned)
    }

    private var filteredTemplates: [TaskTemplate] {
        if searchText.isEmpty {
            return allTemplates
        }
        let lowered = searchText.lowercased()
        return allTemplates.filter { $0.name.lowercased().contains(lowered) }
    }

    private var selectedCount: Int {
        selectedTemplateIDs.count
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.textSecondary)
                    TextField(String(localized: "bankSelector.search.placeholder"), text: $searchText)
                        .font(.parentBody)
                        .accessibilityIdentifier(AX.TaskAssignment.bankSelectorSearchField)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(Radius.sm)
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)

                if filteredTemplates.isEmpty && allTemplates.isEmpty {
                    // Empty bank state
                    Spacer()
                    VStack(spacing: Spacing.md) {
                        Text("bankSelector.empty")
                            .font(.parentBody)
                            .foregroundColor(.textSecondary)
                        Button(String(localized: "bankSelector.createNew")) {
                            showCreateTemplate = true
                        }
                        .font(.parentHeadline)
                        .foregroundColor(.brandPurple)
                        .accessibilityIdentifier(AX.TaskAssignment.bankSelectorCreateNewButton)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredTemplates) { template in
                            templateRow(template)
                        }

                        // Create new template footer
                        Section {
                            Button {
                                showCreateTemplate = true
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("bankSelector.createNew")
                                        .font(.parentHeadline)
                                        .foregroundColor(.brandPurple)
                                    Spacer()
                                }
                            }
                            .accessibilityIdentifier(AX.TaskAssignment.bankSelectorCreateNewButton)
                            .accessibilityLabel(String(localized: "bankSelector.createNew"))
                            .accessibilityHint(String(localized: "accessibility.bankSelector.createNew.hint"))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(String(localized: "bankSelector.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "bankSelector.cancel")) {
                        onDismiss()
                    }
                    .foregroundColor(.brandPurple)
                    .accessibilityIdentifier(AX.TaskAssignment.bankSelectorCancelButton)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(selectedCount > 0 ? String(format: String(localized: "bankSelector.addButton"), selectedCount) : String(localized: "bankSelector.addButtonZero")) {
                        assignSelectedTemplates()
                    }
                    .font(.parentHeadline)
                    .foregroundColor(selectedCount > 0 ? .brandPurple : .textSecondary)
                    .disabled(selectedCount == 0)
                    .opacity(selectedCount > 0 ? 1.0 : 0.4)
                    .accessibilityIdentifier(AX.TaskAssignment.bankSelectorAddButton)
                    .accessibilityLabel(String(format: String(localized: "accessibility.bankSelector.add"), selectedCount))
                    .accessibilityHint(String(localized: "accessibility.bankSelector.add.hint"))
                }
            }
            .sheet(isPresented: $showCreateTemplate) {
                AddEditTemplateSheet(onDismiss: {
                    showCreateTemplate = false
                }, onSave: { newTemplate in
                    // Pre-select the newly created template
                    selectedTemplateIDs.insert(newTemplate.id)
                })
            }
        }
        .presentationDetents([.large])
    }

    private func templateRow(_ template: TaskTemplate) -> some View {
        let isAssigned = assignedTemplateIDs.contains(template.id)
        let isSelected = selectedTemplateIDs.contains(template.id)
        let namePascal = template.name.pascalCase

        return Button {
            guard !isAssigned else { return }
            if isSelected {
                selectedTemplateIDs.remove(template.id)
            } else {
                selectedTemplateIDs.insert(template.id)
            }
        } label: {
            HStack(spacing: Spacing.sm) {
                // Checkbox
                if isAssigned {
                    Image(systemName: "checkmark.square.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.brandGreen)
                        .frame(width: 44, height: 44)
                } else if isSelected {
                    Image(systemName: "checkmark.square.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.brandPurple)
                        .frame(width: 44, height: 44)
                } else {
                    Image(systemName: "square")
                        .font(.system(size: 24))
                        .foregroundColor(.textSecondary)
                        .frame(width: 44, height: 44)
                }

                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.md)
                        .fill(Color.brandPurpleLight)
                    Image(systemName: template.iconIdentifier.hasPrefix("custom:") ? "photo.fill" : template.iconIdentifier)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.brandPurple)
                }
                .frame(width: 44, height: 44)

                // Name
                Text(template.name)
                    .font(.parentHeadline)
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Assigned badge
                if isAssigned {
                    Text("bankSelector.assigned")
                        .font(.parentCaption)
                        .foregroundColor(.brandGreen)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 4)
                        .background(Color.backgroundTaskComplete)
                        .clipShape(Capsule())
                }
            }
        }
        .disabled(isAssigned)
        .accessibilityIdentifier(AX.TaskAssignment.bankSelectorRow(namePascal))
        .accessibilityLabel(
            isAssigned ? "\(template.name), already assigned" :
            isSelected ? "\(template.name), selected for assignment" :
            "\(template.name), not assigned"
        )
    }

    private func assignSelectedTemplates() {
        let topicID = topic.id
        let existingAssignments = child.assignments.filter { $0.topic.id == topicID }
        var maxSort = existingAssignments.map(\.sortOrder).max() ?? -1

        for templateID in selectedTemplateIDs {
            guard let template = allTemplates.first(where: { $0.id == templateID }) else { continue }
            // Double-check not already assigned
            guard !assignedTemplateIDs.contains(templateID) else { continue }
            maxSort += 1
            let assignment = TaskAssignment(child: child, topic: topic, template: template, sortOrder: maxSort)
            modelContext.insert(assignment)
        }
        try? modelContext.save()
        onDismiss()
    }
}
