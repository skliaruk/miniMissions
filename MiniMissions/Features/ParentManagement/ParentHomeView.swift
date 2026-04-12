// ParentHomeView.swift
// Parent home screen — Topics section + Children list + Reset All + Change PIN.
// See DSGN-003, DSGN-004, DSGN-005, REQ-006, REQ-007 for design specification.

import SwiftUI
import SwiftData

struct ParentHomeView: View {
    let onDismiss: () -> Void

    @Query(sort: \Child.sortOrder) private var children: [Child]
    @Query(sort: \Topic.sortOrder) private var topics: [Topic]
    @Query private var templates: [TaskTemplate]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ParentManagementViewModel()
    @State private var showChangePIN = false

    // Paywall state (REQ-010)
    @State private var showPaywall = false
    @State private var pendingAddTopic = false
    @State private var store = StoreService.shared

    // Topic CRUD state
    @State private var showAddTopicAlert = false
    @State private var newTopicName = ""
    @State private var showRenameTopicAlert = false
    @State private var renameTopicName = ""
    @State private var topicToRename: Topic? = nil
    @State private var topicToDelete: Topic? = nil
    @State private var showDeleteTopicConfirmation = false
    @State private var topicToReset: Topic? = nil
    @State private var showResetTopicConfirmation = false
    @State private var showResetAllConfirmation = false

    // Task Bank state
    @State private var showAddTemplateSheet = false
    @State private var templateToEdit: TaskTemplate? = nil
    @State private var templateToDelete: TaskTemplate? = nil
    @State private var showDeleteTemplateConfirmation = false

    // Child CRUD state
    @State private var showAddChildSheet = false
    @State private var childToEdit: Child? = nil
    @State private var childToDelete: Child? = nil
    @State private var showDeleteChildConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                topicsSection
                taskBankSection
                childrenSection
                settingsSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle(String(localized: "parent.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "parent.done")) {
                        onDismiss()
                    }
                    .font(.parentHeadline)
                    .foregroundColor(.brandPurple)
                    .accessibilityIdentifier(AX.ParentManagement.doneButton)
                    .accessibilityLabel(String(localized: "accessibility.done.hint"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "parent.resetAll")) {
                        showResetAllConfirmation = true
                    }
                    .font(.parentHeadline)
                    .foregroundColor(.brandRed)
                    .accessibilityIdentifier(AX.TopicManagement.resetAllButton)
                    .accessibilityLabel(String(localized: "parent.resetAll"))
                    .accessibilityHint(String(localized: "topics.resetAll.confirm.message"))
                }
            }
            // Add Topic alert
            .alert(String(localized: "topics.newTopic.alert"), isPresented: $showAddTopicAlert) {
                TextField(String(localized: "topics.newTopic.placeholder"), text: $newTopicName)
                    .accessibilityIdentifier(AX.TopicManagement.addTopicNameField)
                    .onChange(of: newTopicName) { _, newValue in
                        if newValue.count > 30 {
                            newTopicName = String(newValue.prefix(30))
                        }
                    }
                Button(String(localized: "topics.addTopic")) {
                    addTopic()
                }
                .accessibilityIdentifier(AX.TopicManagement.addTopicConfirmButton)
                .disabled(newTopicName.trimmingCharacters(in: .whitespaces).isEmpty)

                Button(String(localized: "childForm.cancel"), role: .cancel) {
                    newTopicName = ""
                }
                .accessibilityIdentifier(AX.TopicManagement.addTopicCancelButton)
            }
            // Rename Topic alert
            .alert(String(localized: "topics.rename.alert"), isPresented: $showRenameTopicAlert) {
                TextField(String(localized: "topics.newTopic.placeholder"), text: $renameTopicName)
                    .accessibilityIdentifier(AX.TopicManagement.renameTopicNameField)
                    .onChange(of: renameTopicName) { _, newValue in
                        if newValue.count > 30 {
                            renameTopicName = String(newValue.prefix(30))
                        }
                    }
                Button(String(localized: "childForm.save")) {
                    renameTopic()
                }
                .accessibilityIdentifier(AX.TopicManagement.renameTopicConfirmButton)
                .disabled(renameTopicName.trimmingCharacters(in: .whitespaces).isEmpty)

                Button(String(localized: "childForm.cancel"), role: .cancel) {
                    renameTopicName = ""
                    topicToRename = nil
                }
                .accessibilityIdentifier(AX.TopicManagement.renameTopicCancelButton)
            }
            // Delete Topic confirmation
            .confirmationDialog(
                topicToDelete.map { String(format: String(localized: "topics.delete.confirm.title"), $0.name) } ?? "",
                isPresented: $showDeleteTopicConfirmation,
                titleVisibility: .visible
            ) {
                Button(String(localized: "topics.delete.confirm.button"), role: .destructive) {
                    deleteTopic()
                }
                .accessibilityIdentifier(AX.TopicManagement.deleteTopicConfirmButton)

                Button(String(localized: "childForm.cancel"), role: .cancel) {
                    topicToDelete = nil
                }
                .accessibilityIdentifier(AX.TopicManagement.deleteTopicCancelButton)
            } message: {
                Text("topics.delete.confirm.message")
            }
            // Per-topic reset confirmation
            .confirmationDialog(
                topicToReset.map { String(format: String(localized: "topics.reset.confirm.title"), $0.name) } ?? "",
                isPresented: $showResetTopicConfirmation,
                titleVisibility: .visible
            ) {
                if let topic = topicToReset {
                    Button(String(localized: "topics.reset.confirm.button"), role: .destructive) {
                        resetTopic(topic)
                    }
                    .accessibilityIdentifier(AX.TopicManagement.resetTopicConfirmButton(topic.name))

                    Button(String(localized: "childForm.cancel"), role: .cancel) {
                        topicToReset = nil
                    }
                    .accessibilityIdentifier(AX.TopicManagement.resetTopicCancelButton(topic.name))
                }
            } message: {
                if let topic = topicToReset {
                    Text(String(format: String(localized: "topics.reset.confirm.message"), topic.name))
                }
            }
            // Reset All confirmation
            .confirmationDialog(
                String(localized: "topics.resetAll.confirm.title"),
                isPresented: $showResetAllConfirmation,
                titleVisibility: .visible
            ) {
                Button(String(localized: "topics.resetAll.confirm.button"), role: .destructive) {
                    resetAll()
                }
                .accessibilityIdentifier(AX.TopicManagement.resetAllConfirmButton)

                Button(String(localized: "childForm.cancel"), role: .cancel) {}
                    .accessibilityIdentifier(AX.TopicManagement.resetAllCancelButton)
            } message: {
                Text("topics.resetAll.confirm.message")
            }
            // Delete Child confirmation
            .confirmationDialog(
                childToDelete.map { String(format: String(localized: "children.delete.confirm.title"), $0.name) } ?? "",
                isPresented: $showDeleteChildConfirmation,
                titleVisibility: .visible
            ) {
                Button(String(localized: "children.delete.confirm.button"), role: .destructive) {
                    deleteChild()
                }
                .accessibilityIdentifier(AX.ChildManagement.deleteChildConfirmButton)

                Button(String(localized: "childForm.cancel"), role: .cancel) {
                    childToDelete = nil
                }
                .accessibilityIdentifier(AX.ChildManagement.deleteChildCancelButton)
            } message: {
                if let child = childToDelete {
                    Text(String(format: String(localized: "children.delete.confirm.message"), child.name))
                }
            }
            // Delete Template confirmation
            .confirmationDialog(
                deleteTemplateTitle,
                isPresented: $showDeleteTemplateConfirmation,
                titleVisibility: .visible
            ) {
                Button(String(localized: "taskBank.delete.confirm.button"), role: .destructive) {
                    deleteTemplate()
                }
                .accessibilityIdentifier(AX.TaskBank.deleteTemplateConfirmButton)

                Button(String(localized: "childForm.cancel"), role: .cancel) {
                    templateToDelete = nil
                }
                .accessibilityIdentifier(AX.TaskBank.deleteTemplateCancelButton)
            } message: {
                Text(deleteTemplateMessage)
            }
            .sheet(isPresented: $showAddTemplateSheet) {
                AddEditTemplateSheet(onDismiss: {
                    showAddTemplateSheet = false
                })
            }
            .sheet(item: $templateToEdit) { template in
                AddEditTemplateSheet(templateToEdit: template, onDismiss: {
                    templateToEdit = nil
                })
            }
            .sheet(isPresented: $showChangePIN) {
                ChangePINView(onComplete: {
                    showChangePIN = false
                }, onCancel: {
                    showChangePIN = false
                })
            }
            .sheet(isPresented: $showAddChildSheet) {
                AddEditChildSheet(
                    childToEdit: nil,
                    nextSortOrder: (children.map(\.sortOrder).max() ?? -1) + 1,
                    onDismiss: {
                        showAddChildSheet = false
                    }
                )
            }
            .sheet(item: $childToEdit) { child in
                AddEditChildSheet(
                    childToEdit: child,
                    nextSortOrder: child.sortOrder,
                    onDismiss: {
                        childToEdit = nil
                    }
                )
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(
                    onDismiss: {
                        showPaywall = false
                        pendingAddTopic = false
                    },
                    onPurchased: {
                        showPaywall = false
                        if pendingAddTopic {
                            pendingAddTopic = false
                            newTopicName = ""
                            showAddTopicAlert = true
                        }
                    }
                )
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AX.ParentManagement.root)
    }

    // MARK: - Children Section

    private var childrenSection: some View {
        Section {
            ForEach(children) { child in
                NavigationLink {
                    ChildTopicPickerView(child: child)
                } label: {
                    childRowLabel(child: child)
                }
                .accessibilityIdentifier(AX.ChildManagement.childRow(child.name))
                .accessibilityLabel(String(format: String(localized: "accessibility.children.row"), child.name, child.assignments.count))
                .accessibilityHint(children.count > 1
                    ? String(localized: "accessibility.children.row.hint.deletable")
                    : String(localized: "accessibility.children.row.hint.only"))
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if children.count > 1 {
                        Button(role: .destructive) {
                            childToDelete = child
                            showDeleteChildConfirmation = true
                        } label: {
                            Label(String(localized: "action.delete"), systemImage: "trash")
                        }
                        .accessibilityIdentifier(AX.ChildManagement.childDeleteAction(child.name))
                        .accessibilityLabel(String(format: String(localized: "accessibility.children.delete"), child.name))
                    }
                }
            }
            .onMove { indices, newOffset in
                reorderChildren(from: indices, to: newOffset)
            }

            // Info labels
            if children.count == 1 {
                Text("children.lastChildInfo")
                    .font(.parentCaption)
                    .foregroundColor(.textSecondary)
                    .accessibilityIdentifier(AX.ChildManagement.lastChildInfoLabel)
            }
            if children.count >= 6 {
                Text("children.maxChildrenInfo")
                    .font(.parentCaption)
                    .foregroundColor(.textSecondary)
                    .accessibilityIdentifier(AX.ChildManagement.maxChildrenInfoLabel)
            }
        } header: {
            HStack {
                Text("children.section")
                Spacer()
                Button {
                    showAddChildSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                        Text("children.addChild")
                            .font(.parentSubhead)
                    }
                    .foregroundColor(.brandPurple)
                }
                .disabled(children.count >= 6)
                .accessibilityIdentifier(AX.ChildManagement.addChildButton)
                .accessibilityLabel(children.count >= 6 ? String(localized: "accessibility.children.addChild.maxReached") : String(localized: "accessibility.children.addChild"))
                .accessibilityHint(children.count >= 6 ? String(localized: "accessibility.children.addChild.maxHint") : String(localized: "accessibility.children.addChild.hint"))
            }
        }
    }

    // MARK: - Task Bank Section

    private var taskBankSection: some View {
        Section {
            if templates.isEmpty {
                Text("taskBank.empty")
                    .font(.parentBody)
                    .foregroundColor(.textSecondary)
                    .accessibilityIdentifier(AX.TaskBank.taskBankEmptyLabel)
            } else {
                ForEach(templates) { template in
                    templateRow(template: template)
                }
            }
        } header: {
            HStack {
                Text("taskBank.section")
                Spacer()
                Button {
                    showAddTemplateSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                        Text("taskBank.addTemplate")
                            .font(.parentSubhead)
                    }
                    .foregroundColor(.brandPurple)
                }
                .accessibilityIdentifier(AX.TaskBank.addTemplateButton)
                .accessibilityLabel(String(localized: "accessibility.taskBank.newTemplate"))
                .accessibilityHint(String(localized: "accessibility.taskBank.newTemplate.hint"))
            }
        }
    }

    private func templateRow(template: TaskTemplate) -> some View {
        let namePascal = template.name.pascalCase

        return HStack(spacing: Spacing.sm) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(Color.brandPurpleLight)
                Image(systemName: template.iconIdentifier.hasPrefix("custom:") ? "photo.fill" : template.iconIdentifier)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.brandPurple)
            }
            .frame(width: 36, height: 36)

            // Name
            Text(template.name)
                .font(.parentHeadline)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Edit button
            Button {
                templateToEdit = template
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 18))
                    .foregroundColor(.brandPurple)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AX.TaskBank.templateEditButton(namePascal))
            .accessibilityLabel(String(format: String(localized: "accessibility.taskBank.edit"), template.name))
            .accessibilityHint(String(localized: "accessibility.taskBank.edit.hint"))
        }
        .accessibilityIdentifier(AX.TaskBank.templateRow(namePascal))
        .accessibilityLabel(template.name)
        .accessibilityHint(String(localized: "accessibility.taskBank.row.hint"))
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                templateToDelete = template
                showDeleteTemplateConfirmation = true
            } label: {
                Label(String(localized: "action.delete"), systemImage: "trash")
            }
            .accessibilityIdentifier(AX.TaskBank.templateDeleteAction(namePascal))
            .accessibilityLabel(String(format: String(localized: "accessibility.taskBank.delete"), template.name))
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        Section(String(localized: "settings.section")) {
            Button {
                showChangePIN = true
            } label: {
                Label(String(localized: "settings.changePIN"), systemImage: "lock.fill")
                    .foregroundColor(.textPrimary)
            }
            .accessibilityIdentifier(AX.ParentManagement.changePINRow)
            .accessibilityLabel(String(localized: "settings.changePIN"))
            .accessibilityHint(String(localized: "settings.changePIN"))

            if !store.isPremium {
                Button {
                    Swift.Task { await store.restore() }
                } label: {
                    Label(String(localized: "settings.restorePurchase"), systemImage: "arrow.clockwise")
                        .foregroundColor(.textPrimary)
                }
                .accessibilityIdentifier("settings.restorePurchaseButton")
            }
        }
    }

    // MARK: - Topics Section

    private var topicsSection: some View {
        Section {
            ForEach(topics) { topic in
                topicRow(topic: topic)
            }
            .onMove { indices, newOffset in
                reorderTopics(from: indices, to: newOffset)
            }
        } header: {
            HStack {
                Text("topics.section")
                Spacer()
                Button {
                    if store.isPremium || topics.count < 1 {
                        // Free users can have 1 topic; gate fires when they already have 1+
                        newTopicName = ""
                        showAddTopicAlert = true
                    } else {
                        // topics.count >= 1 and not premium -> show paywall
                        pendingAddTopic = true
                        showPaywall = true
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                        Text("topics.addTopic")
                            .font(.parentSubhead)
                    }
                    .foregroundColor(.brandPurple)
                }
                .accessibilityIdentifier(AX.TopicManagement.addTopicButton)
                .accessibilityLabel(String(localized: "accessibility.topics.add"))
                .accessibilityHint(String(localized: "accessibility.topics.add.hint"))
            }
        }
    }

    private func topicRow(topic: Topic) -> some View {
        HStack(spacing: Spacing.sm) {
            // Reorder handle
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 18))
                .foregroundColor(.textSecondary)
                .frame(width: 44, height: 44)
                .accessibilityIdentifier(AX.TopicManagement.topicReorderHandle(topic.name))
                .accessibilityLabel(String(format: String(localized: "accessibility.topics.reorder"), topic.name))

            // Topic name
            Text(topic.name)
                .font(.parentHeadline)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Reset button
            Button {
                topicToReset = topic
                showResetTopicConfirmation = true
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18))
                    .foregroundColor(.brandOrange)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AX.TopicManagement.topicResetButton(topic.name))
            .accessibilityLabel(String(format: String(localized: "accessibility.topics.reset"), topic.name))

            // Edit/rename button
            Button {
                topicToRename = topic
                renameTopicName = topic.name
                showRenameTopicAlert = true
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 18))
                    .foregroundColor(.brandPurple)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AX.TopicManagement.topicEditButton(topic.name))
            .accessibilityLabel(String(format: String(localized: "accessibility.topics.rename"), topic.name))
        }
        .accessibilityIdentifier(AX.TopicManagement.topicRow(topic.name))
        .accessibilityLabel(topic.name)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if topics.count > 1 {
                Button(role: .destructive) {
                    topicToDelete = topic
                    showDeleteTopicConfirmation = true
                } label: {
                    Label(String(localized: "action.delete"), systemImage: "trash")
                }
                .accessibilityIdentifier(AX.TopicManagement.topicDeleteAction(topic.name))
                .accessibilityLabel(String(format: String(localized: "accessibility.topics.delete"), topic.name))
            }
        }
    }

    // MARK: - Child Row

    private func childRowLabel(child: Child) -> some View {
        HStack(spacing: Spacing.sm) {
            // Reorder handle
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 18))
                .foregroundColor(.textSecondary)
                .frame(width: 44, height: 44)
                .accessibilityIdentifier(AX.ChildManagement.childReorderHandle(child.name))
                .accessibilityLabel(String(format: String(localized: "accessibility.children.reorder"), child.name))

            // Avatar thumbnail
            ZStack {
                if let avatarData = child.avatarImageData,
                   let uiImage = UIImage(data: avatarData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.childTint(sortOrder: child.sortOrder))
                    Text(String(child.name.prefix(1)))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.childAccent(sortOrder: child.sortOrder))
                }
            }
            .frame(width: 40, height: 40)
            .overlay(
                Circle()
                    .stroke(Color.childAccent(sortOrder: child.sortOrder), lineWidth: 2)
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(child.name)
                    .font(.parentHeadline)
                    .foregroundColor(.textPrimary)
                Text(String(format: String(localized: "children.taskCount"), child.assignments.count, topics.count))
                    .font(.parentSubhead)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            // Edit button
            Button {
                childToEdit = child
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 18))
                    .foregroundColor(.brandPurple)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AX.ChildManagement.childEditButton(child.name))
            .accessibilityLabel(String(format: String(localized: "accessibility.children.edit"), child.name))
            .accessibilityHint(String(localized: "accessibility.children.edit.hint"))
        }
    }

    private var deleteTemplateTitle: String {
        guard let template = templateToDelete else {
            return ""
        }
        return String(format: String(localized: "taskBank.delete.confirm.title"), template.name)
    }

    private var deleteTemplateMessage: String {
        guard let template = templateToDelete else {
            return ""
        }
        if template.assignments.isEmpty {
            return String(localized: "taskBank.delete.confirm.unassigned")
        }
        let childCount = Set(template.assignments.map(\.child.id)).count
        let topicCount = Set(template.assignments.map(\.topic.id)).count
        return String(format: String(localized: "taskBank.delete.confirm.assigned"), childCount, topicCount)
    }

    // MARK: - Actions

    private func deleteTemplate() {
        guard let template = templateToDelete else { return }
        modelContext.delete(template)
        try? modelContext.save()
        templateToDelete = nil
    }

    private func addTopic() {
        let name = newTopicName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let maxSortOrder = topics.map(\.sortOrder).max() ?? -1
        let topic = Topic(name: name, sortOrder: maxSortOrder + 1)
        modelContext.insert(topic)
        try? modelContext.save()
        newTopicName = ""
    }

    private func renameTopic() {
        guard let topic = topicToRename else { return }
        let name = renameTopicName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        topic.name = name
        try? modelContext.save()
        topicToRename = nil
        renameTopicName = ""
    }

    private func deleteTopic() {
        guard let topic = topicToDelete, topics.count > 1 else { return }
        modelContext.delete(topic)
        try? modelContext.save()
        topicToDelete = nil
    }

    private func resetTopic(_ topic: Topic) {
        try? ResetService.resetTopic(topic, context: modelContext)
        topicToReset = nil
    }

    private func resetAll() {
        try? ResetService.resetAll(context: modelContext)
    }

    private func reorderTopics(from indices: IndexSet, to newOffset: Int) {
        var reordered = topics.sorted { $0.sortOrder < $1.sortOrder }
        reordered.move(fromOffsets: indices, toOffset: newOffset)
        for (i, topic) in reordered.enumerated() {
            topic.sortOrder = i
        }
        try? modelContext.save()
    }

    private func deleteChild() {
        guard let child = childToDelete, children.count > 1 else { return }
        modelContext.delete(child)
        try? modelContext.save()
        childToDelete = nil
        // Reassign sort orders to keep them contiguous
        let remaining = children.filter { $0.id != child.id }.sorted { $0.sortOrder < $1.sortOrder }
        for (i, c) in remaining.enumerated() {
            c.sortOrder = i
        }
        try? modelContext.save()
    }

    private func reorderChildren(from indices: IndexSet, to newOffset: Int) {
        var reordered = children.sorted { $0.sortOrder < $1.sortOrder }
        reordered.move(fromOffsets: indices, toOffset: newOffset)
        for (i, child) in reordered.enumerated() {
            child.sortOrder = i
        }
        try? modelContext.save()
    }
}
