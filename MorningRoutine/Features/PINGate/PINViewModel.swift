// PINViewModel.swift
// PIN gate view model — manages attempt tracking and lockout timer.
// See ADR-002, DSGN-003 for design.

import SwiftUI
import Observation

@Observable
final class PINViewModel {
    enum Mode {
        case entry       // Normal PIN entry gate
        case setup       // First-launch PIN creation — step 1
        case setupConfirm// First-launch PIN creation — step 2 (confirm)
        case changeVerify// Change PIN — verify current PIN
        case changeNew   // Change PIN — enter new PIN
        case changeConfirm// Change PIN — confirm new PIN
    }

    var mode: Mode = .entry
    var digits: String = ""
    var pendingPIN: String = ""   // Used for setup/change confirm step
    var errorMessage: String = ""
    var isLockedOut: Bool = false
    var lockoutSecondsRemaining: Int = 30
    var attemptCount: Int = 0
    var showPINChangedToast: Bool = false

    private var lockoutTimer: Timer?
    private let maxAttempts = 3
    private let lockoutDuration = 30

    func addDigit(_ digit: Int) {
        guard !isLockedOut else { return }
        guard digits.count < 4 else { return }
        digits += String(digit)

        if digits.count == 4 {
            handleFourDigitsEntered()
        }
    }

    func deleteLastDigit() {
        guard !isLockedOut && !digits.isEmpty else { return }
        digits.removeLast()
    }

    private func handleFourDigitsEntered() {
        switch mode {
        case .entry:
            verifyPIN()
        case .setup:
            pendingPIN = digits
            digits = ""
            mode = .setupConfirm
            errorMessage = ""
        case .setupConfirm:
            confirmSetupPIN()
        case .changeVerify:
            verifyCurrentPINForChange()
        case .changeNew:
            pendingPIN = digits
            digits = ""
            mode = .changeConfirm
            errorMessage = ""
        case .changeConfirm:
            confirmNewPIN()
        }
    }

    private func verifyPIN() {
        let hash = PINService.hash(digits)
        let stored = KeychainStore.shared.loadPINHash()
        digits = ""

        if hash == stored {
            errorMessage = ""
            attemptCount = 0
            onSuccess?()
        } else {
            attemptCount += 1
            if attemptCount >= maxAttempts {
                startLockout()
            } else {
                errorMessage = String(format: String(localized: "pin.error.incorrect"), attemptCount)
            }
        }
    }

    private func confirmSetupPIN() {
        if digits == pendingPIN {
            let hash = PINService.hash(digits)
            try? KeychainStore.shared.savePINHash(hash)
            digits = ""
            errorMessage = ""
            onSetupComplete?()
        } else {
            errorMessage = String(localized: "pin.error.mismatch")
            digits = ""
            pendingPIN = ""
            mode = .setup
        }
    }

    private func verifyCurrentPINForChange() {
        let hash = PINService.hash(digits)
        let stored = KeychainStore.shared.loadPINHash()
        digits = ""

        if hash == stored {
            errorMessage = ""
            attemptCount = 0
            mode = .changeNew
        } else {
            attemptCount += 1
            if attemptCount >= maxAttempts {
                startLockout()
            } else {
                errorMessage = String(format: String(localized: "pin.error.incorrect"), attemptCount)
            }
        }
    }

    private func confirmNewPIN() {
        if digits == pendingPIN {
            let hash = PINService.hash(digits)
            try? KeychainStore.shared.savePINHash(hash)
            digits = ""
            errorMessage = ""
            showPINChangedToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.showPINChangedToast = false
                self?.onChangePINComplete?()
            }
        } else {
            errorMessage = String(localized: "pin.error.mismatch")
            digits = ""
            pendingPIN = ""
            mode = .changeNew
        }
    }

    private func startLockout() {
        isLockedOut = true
        lockoutSecondsRemaining = lockoutDuration
        errorMessage = ""

        UIAccessibility.post(
            notification: .announcement,
            argument: String(format: String(localized: "pin.lockout.announcement"), lockoutDuration)
        )

        lockoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            self.lockoutSecondsRemaining -= 1
            if self.lockoutSecondsRemaining <= 0 {
                timer.invalidate()
                self.lockoutTimer = nil
                self.isLockedOut = false
                self.attemptCount = 0
                self.digits = ""
            }
        }
    }

    // Callbacks
    var onSuccess: (() -> Void)?
    var onSetupComplete: (() -> Void)?
    var onChangePINComplete: (() -> Void)?

    var title: String {
        switch mode {
        case .entry: return String(localized: "pin.entry.title")
        case .setup: return String(localized: "pin.setup.title")
        case .setupConfirm: return String(localized: "pin.setupConfirm.title")
        case .changeVerify: return String(localized: "pin.changeVerify.title")
        case .changeNew: return String(localized: "pin.changeNew.title")
        case .changeConfirm: return String(localized: "pin.changeConfirm.title")
        }
    }

    var subtitle: String {
        switch mode {
        case .entry: return String(localized: "pin.entry.subtitle")
        case .setup: return String(localized: "pin.setup.subtitle")
        case .setupConfirm: return String(localized: "pin.setupConfirm.subtitle")
        case .changeVerify: return String(localized: "pin.changeVerify.subtitle")
        case .changeNew: return String(localized: "pin.changeNew.subtitle")
        case .changeConfirm: return String(localized: "pin.changeConfirm.subtitle")
        }
    }

    var lockoutText: String {
        let minutes = lockoutSecondsRemaining / 60
        let seconds = lockoutSecondsRemaining % 60
        let timeString = "\(minutes):\(String(format: "%02d", seconds))"
        return String(format: String(localized: "pin.lockout"), timeString)
    }
}
