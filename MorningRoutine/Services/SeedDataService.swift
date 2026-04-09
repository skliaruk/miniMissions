// SeedDataService.swift
// Seeds default "Aamu" topic on first launch. Children are no longer seeded (REQ-007).
// See ADR-003, ADR-005, ADR-006 for seeding design.

import Foundation
import SwiftData

struct SeedDataService {
    static var defaultTopicName: String {
        String(localized: "seed.defaultTopicName")
    }

    static func seedIfNeeded(context: ModelContext) {
        // Seed default topic if none exist
        let topicDescriptor = FetchDescriptor<Topic>()
        let existingTopics = (try? context.fetch(topicDescriptor)) ?? []
        guard existingTopics.isEmpty else { return }

        let defaultTopic = Topic(name: defaultTopicName, sortOrder: 0)
        context.insert(defaultTopic)
        try? context.save()
    }
}
