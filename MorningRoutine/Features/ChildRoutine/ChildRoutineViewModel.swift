// ChildRoutineViewModel.swift
// ViewModel for child routine view — manages task completion logic.
// See ADR-002, ADR-003, REQ-008 for architecture and data model decisions.

import SwiftUI
import SwiftData
import Observation

@Observable
final class ChildRoutineViewModel {
    var celebratingChildIndex: Int? = nil
    var showingStarBurst: [String: Bool] = [:]

    // MARK: - Legacy Task-based methods (kept for backward compat)

    func completeTask(_ task: Task, completions: [TaskCompletion], context: ModelContext) {
        guard !isDone(task: task, completions: completions) else { return }
        let completion = TaskCompletion(task: task, isDone: true)
        context.insert(completion)
        try? context.save()
    }

    func isDone(task: Task, completions: [TaskCompletion]) -> Bool {
        completions.contains { $0.task?.id == task.id && $0.isDone }
    }

    func allDone(tasks: [Task], completions: [TaskCompletion]) -> Bool {
        guard !tasks.isEmpty else { return false }
        return tasks.allSatisfy { isDone(task: $0, completions: completions) }
    }

    func completedCount(tasks: [Task], completions: [TaskCompletion]) -> Int {
        tasks.filter { isDone(task: $0, completions: completions) }.count
    }

    // MARK: - TaskAssignment-based methods (REQ-008)

    func completeAssignment(_ assignment: TaskAssignment, completions: [TaskCompletion], context: ModelContext) {
        guard !isAssignmentDone(assignment: assignment, completions: completions) else { return }
        let completion = TaskCompletion(assignment: assignment, isDone: true)
        context.insert(completion)
        try? context.save()
    }

    func isAssignmentDone(assignment: TaskAssignment, completions: [TaskCompletion]) -> Bool {
        completions.contains { $0.assignment?.id == assignment.id && $0.isDone }
    }

    func allAssignmentsDone(assignments: [TaskAssignment], completions: [TaskCompletion]) -> Bool {
        guard !assignments.isEmpty else { return false }
        return assignments.allSatisfy { isAssignmentDone(assignment: $0, completions: completions) }
    }

    func completedAssignmentCount(assignments: [TaskAssignment], completions: [TaskCompletion]) -> Int {
        assignments.filter { isAssignmentDone(assignment: $0, completions: completions) }.count
    }
}
