// StarBurstView.swift
// Star particle burst animation on task completion.
// Respects Reduce Motion — falls back to static star.
// See DSGN-002 §2.5, ADR-004 §5.

import SwiftUI

struct StarBurstView: View {
    let childIndex: Int
    let taskIndex: Int
    let accentColor: Color
    @Environment(\.appEnvironment) private var appEnvironment

    @State private var animating = false

    var body: some View {
        if appEnvironment.reduceMotion {
            // Reduce Motion: static star (cross-fade handled by parent)
            Image(systemName: "star.fill")
                .font(.system(size: 32))
                .foregroundColor(.brandYellow)
                .accessibilityIdentifier(AX.ChildRoutine.starAnimation(childIndex, taskIndex))
                .accessibilityHidden(true)
        } else {
            ZStack {
                // Central star
                Image(systemName: "star.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.brandYellow)
                    .shadow(color: Color.brandYellowDark.opacity(0.6), radius: 8)
                    .scaleEffect(animating ? 1.0 : 0.1)
                    .opacity(animating ? 1.0 : 0.0)

                // 4 burst particles at 45°/135°/225°/315°
                ForEach(0..<4) { i in
                    let angle = Double(i) * 90.0 + 45.0
                    let radians = angle * .pi / 180
                    let travel: CGFloat = 40

                    Image(systemName: "star.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.brandYellow)
                        .opacity(animating ? 0.0 : 1.0)
                        .offset(
                            x: animating ? cos(radians) * travel : 0,
                            y: animating ? sin(radians) * travel : 0
                        )
                }
            }
            .accessibilityIdentifier(AX.ChildRoutine.starBurstAnimation(childIndex, taskIndex))
            .accessibilityHidden(true)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    animating = true
                }
            }
        }
    }
}
