// AppEnvironment.swift
// Value-type dependency injection container for test environment configuration.
// See ADR-004 for testability design.

import Foundation
import SwiftUI

// MARK: - AppEnvironment

struct AppEnvironment {
    var useInMemoryStore: Bool = false
    var skipPINSetup: Bool = false
    var presetPINHash: String? = nil
    var reduceMotion: Bool = false
    var fixedDate: Date? = nil
    var resetDateYesterday: Bool = false
    var clearKeychain: Bool = false

    static let live = AppEnvironment()

    static func fromLaunchArguments(_ args: [String]) -> AppEnvironment {
        var env = AppEnvironment()
        if args.contains("--uitesting") {
            env.useInMemoryStore = true
        }
        if args.contains("--skip-pin-setup") {
            env.skipPINSetup = true
        }
        if args.contains("--reduce-motion") {
            env.reduceMotion = true
        }
        if args.contains("--resetDateYesterday") {
            env.resetDateYesterday = true
        }
        if args.contains("--clear-keychain") {
            env.clearKeychain = true
        }
        if let pinIndex = args.firstIndex(of: "--preset-pin-hash"),
           args.indices.contains(pinIndex + 1) {
            env.presetPINHash = args[pinIndex + 1]
        }
        return env
    }
}

// MARK: - SwiftUI Environment Key

private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue = AppEnvironment.live
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
