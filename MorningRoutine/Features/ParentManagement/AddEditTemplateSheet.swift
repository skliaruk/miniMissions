// AddEditTemplateSheet.swift
// Sheet for creating or editing a TaskTemplate in the Task Bank.
// See DSGN-006, REQ-008 for design specification.

import SwiftUI
import SwiftData

struct AddEditTemplateSheet: View {
    let templateToEdit: TaskTemplate?
    let onDismiss: () -> Void
    let onSave: ((TaskTemplate) -> Void)?

    @Environment(\.modelContext) private var modelContext
    @State private var templateName: String = ""
    @State private var selectedIcon: String = ""
    @State private var showIconPicker = false

    private var isEditing: Bool { templateToEdit != nil }
    private var canSave: Bool {
        !templateName.trimmingCharacters(in: .whitespaces).isEmpty && !selectedIcon.isEmpty
    }

    init(templateToEdit: TaskTemplate? = nil, onDismiss: @escaping () -> Void, onSave: ((TaskTemplate) -> Void)? = nil) {
        self.templateToEdit = templateToEdit
        self.onDismiss = onDismiss
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                // Icon section
                Section(String(localized: "templateForm.icon.section")) {
                    HStack {
                        // Icon preview
                        ZStack {
                            RoundedRectangle(cornerRadius: Radius.md)
                                .fill(Color.brandPurpleLight)
                            if selectedIcon.isEmpty {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.textSecondary)
                            } else {
                                Image(systemName: selectedIcon.hasPrefix("custom:") ? "photo.fill" : selectedIcon)
                                    .font(.system(size: 40))
                                    .foregroundColor(.brandPurple)
                            }
                        }
                        .frame(width: 80, height: 80)

                        Spacer()

                        Button(String(localized: "templateForm.chooseIcon")) {
                            showIconPicker = true
                        }
                        .font(.parentHeadline)
                        .foregroundColor(.brandPurple)
                        .accessibilityIdentifier(AX.TaskBank.templateChooseIconButton)
                        .accessibilityLabel(String(localized: "accessibility.templateSheet.chooseIcon"))
                        .accessibilityHint(String(localized: "accessibility.taskSheet.chooseIcon.hint"))
                    }
                }

                // Template name section
                Section(String(localized: "templateForm.name.section")) {
                    HStack {
                        TextField(String(localized: "templateForm.name.placeholder"), text: $templateName)
                            .font(.parentBody)
                            .onChange(of: templateName) { _, newValue in
                                if newValue.count > 30 {
                                    templateName = String(newValue.prefix(30))
                                }
                            }
                            .accessibilityIdentifier(AX.TaskBank.templateNameField)
                            .accessibilityLabel(String(localized: "accessibility.templateSheet.name"))
                            .accessibilityHint(String(localized: "accessibility.taskSheet.name.hint"))

                        Text("\(templateName.count)/30")
                            .font(.parentCaption)
                            .foregroundColor(templateName.count >= 30 ? .brandRed : .textSecondary)
                    }
                }
            }
            .navigationTitle(isEditing ? String(localized: "templateForm.editTitle") : String(localized: "templateForm.newTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "templateForm.cancel")) {
                        onDismiss()
                    }
                    .foregroundColor(.brandPurple)
                    .accessibilityIdentifier(AX.TaskBank.templateFormCancelButton)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "templateForm.save")) {
                        saveTemplate()
                    }
                    .font(.parentHeadline)
                    .foregroundColor(canSave ? .brandPurple : .textSecondary)
                    .disabled(!canSave)
                    .accessibilityIdentifier(AX.TaskBank.templateFormSaveButton)
                    .accessibilityLabel(String(localized: "accessibility.templateSheet.save"))
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon) {
                    showIconPicker = false
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear {
            if let template = templateToEdit {
                templateName = template.name
                selectedIcon = template.iconIdentifier
            }
        }
    }

    private func saveTemplate() {
        let name = templateName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, !selectedIcon.isEmpty else { return }

        if let template = templateToEdit {
            template.name = name
            template.iconIdentifier = selectedIcon
        } else {
            let newTemplate = TaskTemplate(name: name, iconIdentifier: selectedIcon)
            modelContext.insert(newTemplate)
            try? modelContext.save()
            onSave?(newTemplate)
            onDismiss()
            return
        }
        try? modelContext.save()
        onDismiss()
    }
}
