// Topic.swift
// SwiftData model for a topic category entity.
// See ADR-005 for data model decisions.

import Foundation
import SwiftData

@Model
final class Topic {
    @Attribute(.unique) var id: UUID
    var name: String
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \Task.topic)
    var tasks: [Task]

    @Relationship(deleteRule: .cascade, inverse: \TaskAssignment.topic)
    var topicAssignments: [TaskAssignment]

    init(id: UUID = UUID(), name: String, sortOrder: Int) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
        self.tasks = []
        self.topicAssignments = []
    }
}
