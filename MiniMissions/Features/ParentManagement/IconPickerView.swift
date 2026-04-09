// IconPickerView.swift
// SF Symbol icon picker for task icons.
// See DSGN-003 Sheet: Icon Picker for design specification.

import SwiftUI
import PhotosUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    let onDismiss: () -> Void

    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var photosPickerItem: PhotosPickerItem?

    let iconLibrary: [(category: String, icons: [(symbol: String, label: String)])] = [
        ("Hygiene", [
            ("shower.fill", "Shower"),
            ("hands.sparkles.fill", "Wash Hands"),
            ("mouth.fill", "Brush Teeth"),
            ("comb.fill", "Comb Hair"),
            ("toilet.fill", "Use Toilet")
        ]),
        ("Meals", [
            ("fork.knife", "Eat Breakfast"),
            ("cup.and.saucer.fill", "Drink"),
            ("takeoutbag.and.cup.and.straw.fill", "Pack Lunch")
        ]),
        ("Dressing", [
            ("tshirt.fill", "Get Dressed"),
            ("shoe.fill", "Put On Shoes"),
            ("backpack.fill", "Pack Backpack"),
            ("scarf.fill", "Put On Jacket")
        ]),
        ("Chores", [
            ("bed.double.fill", "Make Bed"),
            ("trash.fill", "Take Out Trash"),
            ("pawprint.fill", "Feed Pet"),
            ("sparkles", "Tidy Room")
        ]),
        ("Health", [
            ("pill.fill", "Take Medicine")
        ]),
        ("Learning", [
            ("book.fill", "Reading Time"),
            ("pencil", "Homework")
        ]),
        ("Activity", [
            ("figure.walk", "Go for Walk")
        ])
    ]

    private var filteredLibrary: [(category: String, icons: [(symbol: String, label: String)])] {
        if searchText.isEmpty { return iconLibrary }
        return iconLibrary.compactMap { section in
            let filtered = section.icons.filter {
                $0.label.localizedCaseInsensitiveContains(searchText)
            }
            return filtered.isEmpty ? nil : (section.category, filtered)
        }
    }

    let columns = [
        GridItem(.adaptive(minimum: 60, maximum: 80))
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search
                TextField(String(localized: "iconPicker.search.placeholder"), text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(Spacing.md)
                    .accessibilityIdentifier(AX.TaskEditor.iconSearchField)

                Picker(String(localized: "accessibility.iconPicker.source"), selection: $selectedTab) {
                    Text("iconPicker.sourceBuiltIn").tag(0)
                    Text("iconPicker.sourcePhotos").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.sm)

                if selectedTab == 0 {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: Spacing.lg) {
                            ForEach(filteredLibrary, id: \.category) { section in
                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text(section.category)
                                        .font(.parentSubhead)
                                        .foregroundColor(.textSecondary)
                                        .padding(.horizontal, Spacing.md)

                                    LazyVGrid(columns: columns, spacing: Spacing.sm) {
                                        ForEach(section.icons, id: \.symbol) { icon in
                                            IconCell(
                                                symbol: icon.symbol,
                                                label: icon.label,
                                                isSelected: selectedIcon == icon.symbol
                                            ) {
                                                selectedIcon = icon.symbol
                                                onDismiss()
                                            }
                                        }
                                    }
                                    .padding(.horizontal, Spacing.md)
                                }
                            }
                        }
                        .padding(.bottom, Spacing.xl)
                    }
                } else {
                    VStack(spacing: Spacing.lg) {
                        PhotosPicker(selection: $photosPickerItem, matching: .images) {
                            VStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 48))
                                    .foregroundColor(.brandPurple)
                                Text("iconPicker.chooseFromPhotos")
                                    .font(.parentHeadline)
                                    .foregroundColor(.brandPurple)
                            }
                            .padding(Spacing.xl)
                        }
                        .onChange(of: photosPickerItem) {
                            guard let item = photosPickerItem else { return }
                            Swift.Task {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    let uuid = UUID().uuidString
                                    saveCustomIcon(data: data, uuid: uuid)
                                    selectedIcon = "custom:\(uuid)"
                                    onDismiss()
                                }
                            }
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle(String(localized: "iconPicker.navigationTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "iconPicker.cancel")) {
                        onDismiss()
                    }
                    .foregroundColor(.brandPurple)
                }
            }
        }
        .presentationDetents([.large])
    }

    private func saveCustomIcon(data: Data, uuid: String) {
        guard let iconDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("icons") else { return }
        try? FileManager.default.createDirectory(at: iconDir, withIntermediateDirectories: true)
        let fileURL = iconDir.appendingPathComponent("\(uuid).jpg")
        let image = UIImage(data: data)
        let jpeg = image?.jpegData(compressionQuality: 0.8)
        try? jpeg?.write(to: fileURL)
    }
}

private struct IconCell: View {
    let symbol: String
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    private var background: Color {
        isSelected ? Color.brandPurpleLight : Color(UIColor.secondarySystemGroupedBackground)
    }
    private var border: Color { isSelected ? Color.brandPurple : Color.clear }
    private var iconColor: Color { isSelected ? Color.brandPurple : Color.textPrimary }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(background)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(border, lineWidth: 3)
                    )
                Image(systemName: symbol)
                    .font(.system(size: 32))
                    .foregroundColor(iconColor)
            }
            .frame(width: 60, height: 60)
        }
        .accessibilityIdentifier(AX.TaskEditor.iconPickerCell(symbol))
        .accessibilityLabel(label)
    }
}
