// Child.swift
// SwiftData model for a child entity.
// See ADR-003 for data model decisions.

import Foundation
import SwiftData

@Model
final class Child {
    @Attribute(.unique) var id: UUID
    var name: String
    var sortOrder: Int
    var avatarImageData: Data?

    @Relationship(deleteRule: .cascade, inverse: \Task.child)
    var tasks: [Task]

    @Relationship(deleteRule: .cascade, inverse: \TaskAssignment.child)
    var assignments: [TaskAssignment]

    init(id: UUID = UUID(), name: String, sortOrder: Int) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
        self.avatarImageData = nil
        self.tasks = []
        self.assignments = []
    }
}
