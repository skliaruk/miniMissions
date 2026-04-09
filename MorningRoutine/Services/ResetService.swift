// ResetService.swift
// Per-topic and global reset of task completions.
// Supports both legacy Task completions and new TaskAssignment completions (REQ-008).
// Replaces DailyResetService per ADR-005.

import Foundation
import SwiftData

struct ResetService {
    /// Reset completions for all tasks within a specific topic (all children).
    static func resetTopic(_ topic: Topic, context: ModelContext) throws {
        // Reset legacy Task completions
        for task in topic.tasks {
            for completion in task.completions {
                context.delete(completion)
            }
        }
        // Reset TaskAssignment completions
        for assignment in topic.topicAssignments {
            for completion in assignment.completions {
                context.delete(completion)
            }
        }
        try context.save()
    }

    /// Reset completions for ALL tasks across ALL topics (all children).
    static func resetAll(context: ModelContext) throws {
        let descriptor = FetchDescriptor<TaskCompletion>()
        let allCompletions = try context.fetch(descriptor)
        for completion in allCompletions {
            context.delete(completion)
        }
        try context.save()
    }
}
