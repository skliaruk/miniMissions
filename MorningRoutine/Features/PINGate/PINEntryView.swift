// PINEntryView.swift
// PIN entry gate screen — shown when parent taps gear icon.
// See DSGN-003 Screen 2 for design specification.

import SwiftUI

struct PINEntryView: View {
    let onSuccess: () -> Void
    let onCancel: () -> Void
    var mode: PINViewModel.Mode = .entry

    @State private var viewModel = PINViewModel()
    @Environment(\.appEnvironment) private var appEnvironment

    var body: some View {
        ZStack {
            Color.backgroundPINScreen
                .ignoresSafeArea()

            VStack {
                // Cancel button (top-left)
                HStack {
                    Button {
                        onCancel()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(.textSecondary)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityIdentifier(AX.PINGate.cancelButton)
                    .accessibilityLabel(String(localized: "accessibility.pin.cancel"))
                    Spacer()
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)

                Spacer()

                // Central card
                VStack(spacing: Spacing.xl) {
                    // Header
                    VStack(spacing: Spacing.sm) {
                        Text(viewModel.title)
                            .font(.parentTitle)
                            .foregroundColor(.white)

                        Text(viewModel.subtitle)
                            .font(.parentBody)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    // PIN dots
                    PINDotDisplay(filledCount: viewModel.digits.count)

                    // Error or lockout message
                    if viewModel.isLockedOut {
                        Text(viewModel.lockoutText)
                            .font(.parentCountdown)
                            .foregroundColor(.brandOrange)
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier(AX.PINGate.lockoutLabel)
                            .accessibilityLabel(String(format: String(localized: "accessibility.pin.lockout"), viewModel.lockoutSecondsRemaining))
                    } else if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .font(.parentSubhead)
                            .foregroundColor(.textError)
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier(AX.PINGate.errorLabel)
                            .accessibilityLabel(viewModel.errorMessage)
                    } else {
                        // Spacer to keep layout stable
                        Text(" ")
                            .font(.parentSubhead)
                    }

                    // Keypad
                    PINKeypadView(
                        digits: $viewModel.digits,
                        isDisabled: viewModel.isLockedOut,
                        onDigitTap: { digit in
                            viewModel.addDigit(digit)
                        },
                        onDelete: {
                            viewModel.deleteLastDigit()
                        }
                    )
                }
                .padding(Spacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .fill(Color.white.opacity(0.06))
                )
                .frame(maxWidth: 400)

                Spacer()
            }

            // PIN Changed Toast (for change-PIN flow)
            if viewModel.showPINChangedToast {
                VStack {
                    Text("pin.changed.toast")
                        .font(.parentHeadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            Capsule().fill(Color.brandGreen)
                        )
                    Spacer()
                }
                .padding(.top, Spacing.xl)
                .accessibilityIdentifier(AX.TaskEditor.pinChangedToast)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .accessibilityIdentifier(AX.PINGate.root)
        .onAppear {
            viewModel.mode = mode
            viewModel.onSuccess = onSuccess
        }
        .onChange(of: viewModel.showPINChangedToast) { _, newValue in
            if !newValue && mode != .entry {
                onSuccess()
            }
        }
    }
}
