// PINKeypadView.swift
// Reusable PIN keypad component (3x4 grid).
// See DSGN-003 §2 for design specification.

import SwiftUI

struct PINKeypadView: View {
    @Binding var digits: String
    var isDisabled: Bool = false
    let onDigitTap: (Int) -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                keyButton(1)
                keyButton(2)
                keyButton(3)
            }
            HStack(spacing: Spacing.sm) {
                keyButton(4)
                keyButton(5)
                keyButton(6)
            }
            HStack(spacing: Spacing.sm) {
                keyButton(7)
                keyButton(8)
                keyButton(9)
            }
            HStack(spacing: Spacing.sm) {
                Spacer()
                    .frame(width: 80, height: 80)
                keyButton(0)
                deleteButton
            }
        }
    }

    private func keyButton(_ digit: Int) -> some View {
        Button {
            onDigitTap(digit)
        } label: {
            Text("\(digit)")
                .font(.parentPINDigit)
                .foregroundColor(isDisabled ? Color.white.opacity(0.3) : .white)
                .frame(width: 80, height: 80)
                .background(
                    Circle()
                        .fill(isDisabled ? Color.white.opacity(0.04) : Color.white.opacity(0.12))
                )
        }
        .disabled(isDisabled)
        .accessibilityIdentifier(AX.PINGate.key(digit))
        .accessibilityLabel(isDisabled ? String(format: String(localized: "accessibility.pin.key.disabled"), digit) : String(format: String(localized: "accessibility.pin.key"), digit))
    }

    private var deleteButton: some View {
        Button {
            onDelete()
        } label: {
            Image(systemName: "delete.left.fill")
                .font(.system(size: 24))
                .foregroundColor(isDisabled ? Color.white.opacity(0.3) : .white)
                .frame(width: 80, height: 80)
                .background(
                    Circle()
                        .fill(isDisabled ? Color.white.opacity(0.04) : Color.white.opacity(0.12))
                )
        }
        .disabled(isDisabled)
        .accessibilityIdentifier(AX.PINGate.deleteButton)
        .accessibilityLabel(String(localized: "accessibility.pin.delete"))
    }
}

// MARK: - PIN Dot Display

struct PINDotDisplay: View {
    let filledCount: Int

    var body: some View {
        HStack(spacing: Spacing.md) {
            ForEach(0..<4) { i in
                Circle()
                    .fill(i < filledCount ? Color.white : Color.clear)
                    .overlay(
                        Circle()
                            .stroke(i < filledCount ? Color.white : Color.borderPINDot, lineWidth: 2)
                    )
                    .frame(width: 20, height: 20)
            }
        }
        .accessibilityIdentifier(AX.PINGate.dotDisplay)
        .accessibilityLabel(String(format: String(localized: "accessibility.pin.dotDisplay"), filledCount))
        .accessibilityElement(children: .ignore)
    }
}
