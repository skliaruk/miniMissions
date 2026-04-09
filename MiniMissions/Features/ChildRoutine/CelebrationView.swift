// CelebrationView.swift
// Full-column celebration overlay when all tasks are done.
// Respects Reduce Motion.
// See DSGN-002 §2.6.

import SwiftUI

struct CelebrationView: View {
    let childIndex: Int
    let childName: String
    @Environment(\.appEnvironment) private var appEnvironment
    @State private var pulsing = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Background overlay
            RoundedRectangle(cornerRadius: Radius.lg)
                .fill(Color.backgroundCelebration.opacity(0.92))

            VStack(spacing: Spacing.md) {
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.brandYellow)
                    .accessibilityHidden(true)

                Text("celebration.allDone")
                    .font(.childCelebration)
                    .foregroundColor(.textChildName)
                    .multilineTextAlignment(.center)

                HStack(spacing: Spacing.sm) {
                    ForEach(0..<3) { i in
                        Image(systemName: "star.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.brandYellow)
                            .scaleEffect(pulsing && !appEnvironment.reduceMotion ? 1.2 : 1.0)
                            .animation(
                                appEnvironment.reduceMotion ? nil :
                                    .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.2),
                                value: pulsing
                            )
                    }
                }
                .accessibilityHidden(true)
            }
            .padding(Spacing.xl)

            // Confetti overlay (Reduce Motion OFF only)
            if !appEnvironment.reduceMotion && appeared {
                ConfettiView(childIndex: childIndex)
                    .allowsHitTesting(false)
            }
        }
        .opacity(appeared ? 1.0 : 0.0)
        .animation(appEnvironment.reduceMotion ? .easeInOut(duration: 0.15) : .easeInOut(duration: 0.3), value: appeared)
        .onAppear {
            appeared = true
            if !appEnvironment.reduceMotion {
                pulsing = true
                let notif = UINotificationFeedbackGenerator()
                notif.notificationOccurred(.success)
                UIAccessibility.post(
                    notification: .announcement,
                    argument: String(format: String(localized: "celebration.announcement"), childName)
                )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(format: String(localized: "accessibility.childColumn.allDone"), childName))
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    let childIndex: Int
    @State private var particles: [ConfettiParticle] = []

    let colors: [Color] = [.brandYellow, .brandPurple, Color(hex: "#FF6B35"), Color(hex: "#00A878")]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(particle.color)
                        .frame(width: 8, height: 4)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                startConfetti(in: geo.size)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func startConfetti(in size: CGSize) {
        particles = (0..<20).map { i in
            ConfettiParticle(
                id: i,
                color: colors[i % colors.count],
                position: CGPoint(x: CGFloat.random(in: 0...size.width), y: -20),
                rotation: Double.random(in: 0...360),
                opacity: 1.0
            )
        }

        withAnimation(.easeOut(duration: 2.0)) {
            for i in particles.indices {
                particles[i].position.y = CGFloat.random(in: size.height * 0.3...size.height)
                particles[i].position.x += CGFloat.random(in: -50...50)
                particles[i].rotation += Double.random(in: 180...540)
                particles[i].opacity = 0.0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: Int
    let color: Color
    var position: CGPoint
    var rotation: Double
    var opacity: Double
}

// MARK: - Color hex initialiser

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
