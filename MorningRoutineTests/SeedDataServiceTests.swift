// SeedDataServiceTests.swift
// Unit tests for SeedDataService seeding logic.

import XCTest
import SwiftData
@testable import MorningRoutine

@MainActor
final class SeedDataServiceTests: XCTestCase {

    private var modelContext: ModelContext!
    private var container: ModelContainer!

    override func setUpWithError() throws {
        let schema = Schema([Child.self, Task.self, TaskCompletion.self, Topic.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        modelContext = container.mainContext
    }

    override func tearDownWithError() throws {
        modelContext = nil
        container = nil
    }

    func testSeedIfNeededCreatesThreeChildren() throws {
        SeedDataService.seedIfNeeded(context: modelContext)

        let descriptor = FetchDescriptor<Child>(sortBy: [SortDescriptor(\.sortOrder)])
        let children = try modelContext.fetch(descriptor)

        XCTAssertEqual(children.count, 3, "SeedDataService must create exactly 3 children")
    }

    func testSeedIfNeededCreatesCorrectChildNames() throws {
        SeedDataService.seedIfNeeded(context: modelContext)

        let descriptor = FetchDescriptor<Child>(sortBy: [SortDescriptor(\.sortOrder)])
        let children = try modelContext.fetch(descriptor)

        let names = children.map { $0.name }
        XCTAssertEqual(names[0], "Сара", "First child must be named 'Сара'")
        XCTAssertEqual(names[1], "Самуил", "Second child must be named 'Самуил'")
        XCTAssertEqual(names[2], "Бен", "Third child must be named 'Бен'")
    }

    func testSeedIfNeededCreatesCorrectSortOrders() throws {
        SeedDataService.seedIfNeeded(context: modelContext)

        let descriptor = FetchDescriptor<Child>(sortBy: [SortDescriptor(\.sortOrder)])
        let children = try modelContext.fetch(descriptor)

        XCTAssertEqual(children[0].sortOrder, 0)
        XCTAssertEqual(children[1].sortOrder, 1)
        XCTAssertEqual(children[2].sortOrder, 2)
    }

    func testSeedIfNeededIsIdempotent() throws {
        SeedDataService.seedIfNeeded(context: modelContext)
        SeedDataService.seedIfNeeded(context: modelContext)

        let descriptor = FetchDescriptor<Child>()
        let children = try modelContext.fetch(descriptor)

        XCTAssertEqual(children.count, 3, "Seeding twice must not create duplicate children")
    }

    func testSeedIfNeededCreatesDefaultTasks() throws {
        SeedDataService.seedIfNeeded(context: modelContext)

        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)

        XCTAssertGreaterThan(tasks.count, 0, "SeedDataService must create default tasks for children")
    }

    func testSeedIfNeededEachChildHasTasks() throws {
        SeedDataService.seedIfNeeded(context: modelContext)

        let descriptor = FetchDescriptor<Child>()
        let children = try modelContext.fetch(descriptor)

        for child in children {
            XCTAssertGreaterThan(
                child.tasks.count, 0,
                "Each seeded child must have at least one task. '\(child.name)' has \(child.tasks.count)"
            )
        }
    }

    func testSeedIfNeededCreatesDefaultTopic() throws {
        SeedDataService.seedIfNeeded(context: modelContext)

        let descriptor = FetchDescriptor<Topic>()
        let topics = try modelContext.fetch(descriptor)

        XCTAssertEqual(topics.count, 1, "SeedDataService must create exactly 1 default topic")
        XCTAssertEqual(topics.first?.name, "Aamu", "Default topic must be named 'Aamu'")
    }

    func testSeedIfNeededAssignsAllTasksToDefaultTopic() throws {
        SeedDataService.seedIfNeeded(context: modelContext)

        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        let topicDescriptor = FetchDescriptor<Topic>()
        let topics = try modelContext.fetch(topicDescriptor)

        guard let defaultTopic = topics.first else {
            XCTFail("Default topic must exist")
            return
        }

        for task in tasks {
            XCTAssertEqual(task.topic.id, defaultTopic.id, "All seeded tasks must be assigned to the default 'Aamu' topic")
        }
    }
}
