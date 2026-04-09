// AddEditChildSheet.swift
// Sheet for creating or editing a child (name + optional photo).
// See DSGN-005 Sheet: Add / Edit Child for design specification.

import SwiftUI
import SwiftData
import PhotosUI

struct AddEditChildSheet: View {
    let childToEdit: Child?
    let nextSortOrder: Int
    let onDismiss: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var childName: String = ""
    @State private var selectedPhotoData: Data? = nil
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil

    private var isEditing: Bool { childToEdit != nil }
    private var canSave: Bool { !childName.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                // Photo section
                Section(String(localized: "childForm.photo.section")) {
                    HStack {
                        // Photo preview
                        ZStack {
                            Circle()
                                .fill(Color.backgroundTaskIncomplete)
                            if let data = selectedPhotoData,
                               let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .frame(width: 80, height: 80)

                        Spacer()

                        VStack(spacing: Spacing.sm) {
                            Button(String(localized: "childForm.choosePhoto")) {
                                showPhotoPicker = true
                            }
                            .font(.parentHeadline)
                            .foregroundColor(.brandPurple)
                            .accessibilityIdentifier(AX.ChildManagement.childPhotoPickerButton)
                            .accessibilityLabel(String(localized: "childForm.choosePhoto"))
                            .accessibilityHint(String(localized: "childForm.choosePhoto"))

                            if selectedPhotoData != nil {
                                Button(String(localized: "childForm.removePhoto")) {
                                    selectedPhotoData = nil
                                }
                                .font(.parentSubhead)
                                .foregroundColor(.brandRed)
                                .accessibilityIdentifier(AX.ChildManagement.childPhotoRemoveButton)
                                .accessibilityLabel(String(localized: "childForm.removePhoto"))
                            }
                        }
                    }
                }

                // Name section
                Section(String(localized: "childForm.name.section")) {
                    HStack {
                        TextField(String(localized: "childForm.name.placeholder"), text: $childName)
                            .font(.parentBody)
                            .onChange(of: childName) { _, newValue in
                                if newValue.count > 30 {
                                    childName = String(newValue.prefix(30))
                                }
                            }
                            .accessibilityIdentifier(AX.ChildManagement.childNameField)
                            .accessibilityLabel(String(localized: "accessibility.childForm.name"))
                            .accessibilityHint(String(localized: "accessibility.taskSheet.name.hint"))

                        Text("\(childName.count)/30")
                            .font(.parentCaption)
                            .foregroundColor(childName.count >= 30 ? .brandRed : .textSecondary)
                    }
                }
            }
            .navigationTitle(isEditing ? String(localized: "childForm.editTitle") : String(localized: "childForm.newTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "childForm.cancel")) {
                        onDismiss()
                    }
                    .foregroundColor(.brandPurple)
                    .accessibilityIdentifier(AX.ChildManagement.childFormCancelButton)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "childForm.save")) {
                        saveChild()
                    }
                    .font(.parentHeadline)
                    .foregroundColor(canSave ? .brandPurple : .textSecondary)
                    .disabled(!canSave)
                    .accessibilityIdentifier(AX.ChildManagement.childFormSaveButton)
                    .accessibilityLabel(String(localized: "accessibility.childForm.save"))
                }
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedPhotoItem,
                matching: .images
            )
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem = newItem else { return }
                Swift.Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            selectedPhotoData = data
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear {
            if let child = childToEdit {
                childName = child.name
                selectedPhotoData = child.avatarImageData
            }
        }
    }

    private func saveChild() {
        let name = childName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        if let child = childToEdit {
            child.name = name
            child.avatarImageData = selectedPhotoData
        } else {
            let newChild = Child(name: name, sortOrder: nextSortOrder)
            newChild.avatarImageData = selectedPhotoData
            modelContext.insert(newChild)
        }
        try? modelContext.save()
        onDismiss()
    }
}
