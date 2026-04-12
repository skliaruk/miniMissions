// SeedDataServiceTests.swift
// Unit tests for SeedDataService seeding logic.
// Updated to match REQ-007: SeedDataService no longer seeds children or tasks,
// only the default "Aamu" topic.

import XCTest
import SwiftData
@testable import MiniMissions

@MainActor
final class SeedDataServiceTests: XCTestCase {

    private var modelContext: ModelContext!
    private var container: ModelContainer!

    override func setUpWithError() throws {
        let schema = Schema([Child.self, Task.self, TaskCompletion.self, Topic.self, TaskTemplate.self, TaskAssignment.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        modelContext = container.mainContext
    }

    override func tearDownWithError() throws {
        modelContext = nil
        container = nil
    }

    func testSeedIfNeededCreatesNoChildren() throws {
        // REQ-007: SeedDataService no longer seeds children.
        SeedDataService.seedIfNeeded(context: modelContext)

        let descriptor = FetchDescriptor<Child>()
        let children = try modelContext.fetch(descriptor)

        XCTAssertEqual(children.count, 0, "SeedDataService must not create any children (REQ-007)")
    }

    func testSeedIfNeededCreatesNoTasks() throws {
        // REQ-007: SeedDataService no longer seeds tasks.
        SeedDataService.seedIfNeeded(context: modelContext)

        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)

        XCTAssertEqual(tasks.count, 0, "SeedDataService must not create any tasks (REQ-007)")
    }

    func testSeedIfNeededCreatesDefaultTopic() throws {
        SeedDataService.seedIfNeeded(context: modelContext)

        let descriptor = FetchDescriptor<Topic>()
        let topics = try modelContext.fetch(descriptor)

        XCTAssertEqual(topics.count, 1, "SeedDataService must create exactly 1 default topic")
        XCTAssertEqual(topics.first?.name, SeedDataService.defaultTopicName, "Default topic must be named correctly")
    }

    func testSeedIfNeededIsIdempotent() throws {
        SeedDataService.seedIfNeeded(context: modelContext)
        SeedDataService.seedIfNeeded(context: modelContext)

        let topicDescriptor = FetchDescriptor<Topic>()
        let topics = try modelContext.fetch(topicDescriptor)

        XCTAssertEqual(topics.count, 1, "Seeding twice must not create duplicate topics")
    }

    func testSeedIfNeededDoesNotSeedWhenTopicsExist() throws {
        // If a topic already exists, seeding must not add another.
        let existingTopic = Topic(name: "Ilta", sortOrder: 0)
        modelContext.insert(existingTopic)
        try modelContext.save()

        SeedDataService.seedIfNeeded(context: modelContext)

        let descriptor = FetchDescriptor<Topic>()
        let topics = try modelContext.fetch(descriptor)

        XCTAssertEqual(topics.count, 1, "SeedDataService must not seed when topics already exist")
        XCTAssertEqual(topics.first?.name, "Ilta", "Existing topic must be preserved")
    }

    func testSeedIfNeededDefaultTopicHasSortOrderZero() throws {
        SeedDataService.seedIfNeeded(context: modelContext)

        let descriptor = FetchDescriptor<Topic>()
        let topics = try modelContext.fetch(descriptor)

        XCTAssertEqual(topics.first?.sortOrder, 0, "Default topic must have sortOrder 0")
    }
}
