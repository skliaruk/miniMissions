// TaskAssignment.swift
// SwiftData model linking a TaskTemplate to a Child within a Topic.
// See REQ-008, ADR-006 for data model decisions.

import Foundation
import SwiftData

@Model
final class TaskAssignment {
    @Attribute(.unique) var id: UUID
    var sortOrder: Int
    var child: Child
    var topic: Topic
    var template: TaskTemplate

    @Relationship(deleteRule: .cascade, inverse: \TaskCompletion.assignment)
    var completions: [TaskCompletion]

    init(id: UUID = UUID(), child: Child, topic: Topic, template: TaskTemplate, sortOrder: Int) {
        self.id = id
        self.child = child
        self.topic = topic
        self.template = template
        self.sortOrder = sortOrder
        self.completions = []
    }
}
