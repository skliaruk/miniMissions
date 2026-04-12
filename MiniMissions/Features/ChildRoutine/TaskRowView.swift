// TaskRowView.swift
// Single task row — icon + label + done state. Now uses TaskAssignment.
// See DSGN-002 §2.4, DSGN-006 for design specification.

import SwiftUI
import SwiftData

struct TaskRowView: View {
    let assignment: TaskAssignment
    let childIndex: Int
    let taskIndex: Int
    let completions: [TaskCompletion]
    let viewModel: ChildRoutineViewModel

    @Environment(\.modelContext) private var modelContext

    private var isDone: Bool {
        viewModel.isAssignmentDone(assignment: assignment, completions: completions)
    }

    // Generate PascalCase name for identifier (spaces removed, interior casing preserved)
    private var taskNamePascal: String {
        assignment.template.name.components(separatedBy: .whitespaces).map { word in
            guard !word.isEmpty else { return "" }
            return word.prefix(1).uppercased() + word.dropFirst()
        }.joined()
    }

    private var childName: String {
        assignment.child.name
    }

    private var taskName: String {
        assignment.template.name
    }

    private var iconIdentifier: String {
        assignment.template.iconIdentifier
    }

    @State private var showStarBurst = false

    var body: some View {
        ZStack {
            // The primary tappable button — carries the index-based identifier.
            Button {
                guard !isDone else { return }
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    viewModel.completeAssignment(assignment, completions: completions, context: modelContext)
                }
                showStarBurst = true
            } label: {
                rowContent
                    .frame(maxWidth: .infinity, minHeight: 72)
                    .background(isDone ? Color.backgroundTaskComplete : Color.backgroundTaskIncomplete)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AX.ChildRoutine.taskButton(childIndex, taskIndex))
            .accessibilityLabel(taskName)
            .accessibilityValue(isDone ? "done" : "not done")
            .accessibilityHint(isDone ? "" : "Tap to mark as done")
            .overlay(
                Color.clear
                    .accessibilityIdentifier(AX.ChildRoutine.taskByName(child: childName, task: taskNamePascal))
            )

            // Star burst shown after task completion.
            if isDone && showStarBurst {
                StarBurstView(
                    childIndex: childIndex,
                    taskIndex: taskIndex,
                    accentColor: Color.childAccent(sortOrder: childIndex)
                )
                .transition(.opacity)
                .allowsHitTesting(false)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showStarBurst = false
                    }
                }
            }
        }
        // Row-level identifier (ADR-004 taskRow) on the ZStack container.
        // Used by AccessibilityUITests to verify row touch targets.
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AX.ChildRoutine.taskRow(childIndex, taskIndex))
    }

    private var rowContent: some View {
        HStack(spacing: Spacing.sm) {
            // Icon container
            taskIcon

            // Task label
            Text(taskName)
                .font(.childTaskLabel)
                .foregroundColor(isDone ? .textTaskLabelDone : .textTaskLabel)
                .strikethrough(isDone, color: .textTaskLabelDone)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Checkmark when done
            if isDone {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.brandGreen)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
    }

    private var taskIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.childTint(sortOrder: childIndex))
                .frame(width: 60, height: 60)

            if iconIdentifier.hasPrefix("custom:") {
                // Custom photo icon
                let uuidString = String(iconIdentifier.dropFirst(7))
                if let url = customIconURL(uuidString),
                   let data = try? Data(contentsOf: url),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                } else {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color.childAccent(sortOrder: childIndex))
                        .symbolRenderingMode(.hierarchical)
                        .imageScale(.large)
                        .frame(width: 44, height: 44)
                }
            } else {
                // SF Symbol
                Image(systemName: iconIdentifier)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color.childAccent(sortOrder: childIndex))
                    .symbolRenderingMode(.hierarchical)
                    .imageScale(.large)
                    .frame(width: 44, height: 44)
            }
        }
        .opacity(isDone ? 0.6 : 1.0)
        .accessibilityHidden(true)
    }

    private func customIconURL(_ uuid: String) -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("icons")
            .appendingPathComponent("\(uuid).jpg")
    }
}
