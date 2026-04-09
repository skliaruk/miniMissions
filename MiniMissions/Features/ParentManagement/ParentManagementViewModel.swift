// ParentManagementViewModel.swift
// ViewModel for parent home — manages reset confirmation state and PIN change flow.
// See ADR-002 for architecture decisions.

import SwiftUI
import SwiftData
import Observation

@Observable
final class ParentManagementViewModel {
    var showResetConfirmation = false
    var showChangePIN = false

    func resetAllTasks(context: ModelContext) {
        try? ResetService.resetAll(context: context)
    }
}
