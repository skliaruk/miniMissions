// AddEditTaskSheet.swift
// Sheet for creating or editing a single task within a child + topic scope.
// See DSGN-003 Sheet: Add/Edit Task for design specification.

import SwiftUI
import SwiftData

struct AddEditTaskSheet: View {
    let child: Child
    let topic: Topic
    let taskToEdit: Task?
    let onDismiss: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var taskName: String = ""
    @State private var selectedIcon: String = ""
    @State private var showIconPicker = false

    private var isEditing: Bool { taskToEdit != nil }
    private var canSave: Bool { !taskName.trimmingCharacters(in: .whitespaces).isEmpty && !selectedIcon.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                // Icon section
                Section(String(localized: "taskSheet.icon.section")) {
                    HStack {
                        // Icon preview
                        ZStack {
                            RoundedRectangle(cornerRadius: Radius.md)
                                .fill(Color.childTint(sortOrder: child.sortOrder))
                            if selectedIcon.isEmpty {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.textSecondary)
                            } else {
                                Image(systemName: selectedIcon.hasPrefix("custom:") ? "photo.fill" : selectedIcon)
                                    .font(.system(size: 40))
                                    .foregroundColor(Color.childAccent(sortOrder: child.sortOrder))
                            }
                        }
                        .frame(width: 80, height: 80)

                        Spacer()

                        Button(String(localized: "taskSheet.chooseIcon")) {
                            showIconPicker = true
                        }
                        .font(.parentHeadline)
                        .foregroundColor(.brandPurple)
                        .accessibilityIdentifier(AX.TaskEditor.chooseIconButton)
                        .accessibilityLabel(String(localized: "accessibility.taskSheet.chooseIcon"))
                        .accessibilityHint(String(localized: "accessibility.taskSheet.chooseIcon.hint"))
                    }
                }

                // Task name section
                Section(String(localized: "taskSheet.name.section")) {
                    HStack {
                        TextField(String(localized: "taskSheet.name.placeholder"), text: $taskName)
                            .font(.parentBody)
                            .onChange(of: taskName) { _, newValue in
                                if newValue.count > 30 {
                                    taskName = String(newValue.prefix(30))
                                }
                            }
                            .accessibilityIdentifier(AX.TaskEditor.taskNameField)
                            .accessibilityLabel(String(localized: "accessibility.taskSheet.name"))
                            .accessibilityHint(String(localized: "accessibility.taskSheet.name.hint"))

                        Text("\(taskName.count)/30")
                            .font(.parentCaption)
                            .foregroundColor(taskName.count >= 30 ? .brandRed : .textSecondary)
                    }
                }
            }
            .navigationTitle(isEditing ? String(localized: "taskSheet.editTitle") : String(localized: "taskSheet.addTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "childForm.cancel")) {
                        onDismiss()
                    }
                    .foregroundColor(.brandPurple)
                    .accessibilityIdentifier(AX.TaskEditor.cancelButton)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "childForm.save")) {
                        saveTask()
                    }
                    .font(.parentHeadline)
                    .foregroundColor(canSave ? .brandPurple : .textSecondary)
                    .disabled(!canSave)
                    .accessibilityIdentifier(AX.TaskEditor.formSaveButton)
                    .accessibilityLabel(String(localized: "accessibility.taskSheet.save"))
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon) {
                    showIconPicker = false
                }
            }
        }
        .onAppear {
            if let task = taskToEdit {
                taskName = task.name
                selectedIcon = task.iconIdentifier
            }
        }
    }

    private func saveTask() {
        let name = taskName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, !selectedIcon.isEmpty else { return }

        if let task = taskToEdit {
            task.name = name
            task.iconIdentifier = selectedIcon
        } else {
            let topicID = topic.id
            let existingTasks = child.tasks.filter { $0.topic.id == topicID }
            let maxSortOrder = existingTasks.map(\.sortOrder).max() ?? -1
            let newTask = Task(
                name: name,
                iconIdentifier: selectedIcon,
                sortOrder: maxSortOrder + 1,
                child: child,
                topic: topic
            )
            modelContext.insert(newTask)
        }
        try? modelContext.save()
        onDismiss()
    }
}
