// PINSetupView.swift
// First-launch PIN creation screen.
// See DSGN-003 Screen 1 for design specification.

import SwiftUI

struct PINSetupView: View {
    let onComplete: () -> Void

    @State private var viewModel = PINViewModel()
    @Environment(\.appEnvironment) private var appEnvironment

    var body: some View {
        ZStack {
            Color.backgroundPINScreen
                .ignoresSafeArea()

            VStack {
                Spacer()

                // Central card
                VStack(spacing: Spacing.xl) {
                    // Header
                    VStack(spacing: Spacing.sm) {
                        Text(verbatim: "Morning Routine")
                            .font(.parentLargeTitle)
                            .foregroundColor(.white)

                        Text(viewModel.title)
                            .font(.parentTitle)
                            .foregroundColor(.white)

                        Text(viewModel.subtitle)
                            .font(.parentBody)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }

                    // PIN dots
                    PINDotDisplay(filledCount: viewModel.digits.count)

                    // Error message
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .font(.parentSubhead)
                            .foregroundColor(.textError)
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier(AX.PINGate.errorLabel)
                    }

                    // Keypad
                    PINKeypadView(
                        digits: $viewModel.digits,
                        isDisabled: false,
                        onDigitTap: { digit in
                            viewModel.addDigit(digit)
                        },
                        onDelete: {
                            viewModel.deleteLastDigit()
                        }
                    )

                    // Confirm button (optional — PIN auto-advances on 4 digits)
                    if viewModel.digits.count == 4 {
                        Button(String(localized: "pinSetup.continue")) {
                            // Auto-advances in viewModel when 4 digits entered
                        }
                        .font(.parentHeadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.sm)
                        .background(Capsule().fill(Color.brandPurple))
                        .accessibilityIdentifier(AX.PINGate.setupConfirmButton)
                    }
                }
                .padding(Spacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .fill(Color.white.opacity(0.06))
                )
                .frame(maxWidth: 400)

                Spacer()
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AX.PINGate.setupRoot)
        .onAppear {
            viewModel.mode = .setup
            viewModel.onSetupComplete = onComplete
        }
    }
}
