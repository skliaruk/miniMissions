// Task.swift
// SwiftData model for a task belonging to a child and a topic.
// See ADR-003, ADR-005 for data model decisions.

import Foundation
import SwiftData

@Model
final class Task {
    @Attribute(.unique) var id: UUID
    var name: String
    var iconIdentifier: String
    var sortOrder: Int
    var child: Child
    var topic: Topic

    var completions: [TaskCompletion]

    init(id: UUID = UUID(), name: String, iconIdentifier: String, sortOrder: Int, child: Child, topic: Topic) {
        self.id = id
        self.name = name
        self.iconIdentifier = iconIdentifier
        self.sortOrder = sortOrder
        self.child = child
        self.topic = topic
        self.completions = []
    }
}
