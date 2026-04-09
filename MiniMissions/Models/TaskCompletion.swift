// TaskCompletion.swift
// SwiftData model representing a task completion record.
// One record = task is done for the current session.
// Deleted by DailyResetService to reset the day.
// See ADR-003 for data model decisions.

import Foundation
import SwiftData

@Model
final class TaskCompletion {
    @Attribute(.unique) var id: UUID
    var task: Task?
    var assignment: TaskAssignment?
    var completedAt: Date
    var isDone: Bool

    init(id: UUID = UUID(), task: Task, isDone: Bool = true) {
        self.id = id
        self.task = task
        self.assignment = nil
        self.completedAt = Date()
        self.isDone = isDone
    }

    init(id: UUID = UUID(), assignment: TaskAssignment, isDone: Bool = true) {
        self.id = id
        self.task = nil
        self.assignment = assignment
        self.completedAt = Date()
        self.isDone = isDone
    }
}
