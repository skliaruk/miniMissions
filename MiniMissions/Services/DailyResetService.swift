// DailyResetService.swift
// Legacy wrapper — delegates to ResetService.resetAll.
// Kept for backward compatibility with existing call sites.
// See ADR-005 for reset service redesign.

import Foundation
import SwiftData

struct DailyResetService {
    static func resetAllTasks(context: ModelContext) throws {
        try ResetService.resetAll(context: context)
    }
}
