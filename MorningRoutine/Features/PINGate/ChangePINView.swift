// ChangePINView.swift
// Change PIN flow — verify current PIN, enter new PIN, confirm new PIN.
// See DSGN-003 Screen: Change PIN Flow for design specification.

import SwiftUI

struct ChangePINView: View {
    let onComplete: () -> Void
    let onCancel: () -> Void

    @State private var viewModel = PINViewModel()

    var body: some View {
        ZStack {
            Color.backgroundPINScreen
                .ignoresSafeArea()

            VStack {
                // Cancel button
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

                VStack(spacing: Spacing.xl) {
                    VStack(spacing: Spacing.sm) {
                        Text(viewModel.title)
                            .font(.parentTitle)
                            .foregroundColor(.white)
                        Text(viewModel.subtitle)
                            .font(.parentBody)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    PINDotDisplay(filledCount: viewModel.digits.count)

                    // Error or lockout
                    if viewModel.isLockedOut {
                        Text(viewModel.lockoutText)
                            .font(.parentCountdown)
                            .foregroundColor(.brandOrange)
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier(AX.PINGate.lockoutLabel)
                    } else if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .font(.parentSubhead)
                            .foregroundColor(.textError)
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier(AX.PINGate.errorLabel)
                    } else {
                        Text(" ").font(.parentSubhead)
                    }

                    PINKeypadView(
                        digits: $viewModel.digits,
                        isDisabled: viewModel.isLockedOut,
                        onDigitTap: { viewModel.addDigit($0) },
                        onDelete: { viewModel.deleteLastDigit() }
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

            // PIN Changed Toast
            if viewModel.showPINChangedToast {
                VStack {
                    Text("pin.changed.toast")
                        .font(.parentHeadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.sm)
                        .background(Capsule().fill(Color.brandGreen))
                    Spacer()
                }
                .padding(.top, Spacing.xl)
                .accessibilityIdentifier(AX.TaskEditor.pinChangedToast)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .accessibilityIdentifier(AX.PINGate.root)
        .onAppear {
            viewModel.mode = .changeVerify
            viewModel.onChangePINComplete = onComplete
        }
    }
}
