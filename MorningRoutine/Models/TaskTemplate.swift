// TaskTemplate.swift
// SwiftData model for a task template in the Task Bank.
// See REQ-008, ADR-006 for data model decisions.

import Foundation
import SwiftData

@Model
final class TaskTemplate {
    @Attribute(.unique) var id: UUID
    var name: String
    var iconIdentifier: String

    @Relationship(deleteRule: .cascade, inverse: \TaskAssignment.template)
    var assignments: [TaskAssignment]

    init(id: UUID = UUID(), name: String, iconIdentifier: String) {
        self.id = id
        self.name = name
        self.iconIdentifier = iconIdentifier
        self.assignments = []
    }
}
