//
//  ConfettiView.swift
//  fit
//
//  Created by Cedric Kienzler on 10.01.25.
//

import SwiftUI

struct ConfettiView: View {
    @State private var confettiParticles: [ConfettiParticle] = []
    private let particleCount: Int = 20

    var body: some View {
        ZStack {
            ForEach(confettiParticles) { particle in
                Capsule()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size * 0.4)
                    .rotationEffect(.degrees(particle.rotation))  // Random rotation
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    let center = geo.frame(in: .named("confettiArea")).center
                    startAnimation(from: center)
                }
            })
    }

    private func startAnimation(from center: CGPoint) {
        // Generate confetti particles
        confettiParticles = (0..<particleCount).map { _ in
            ConfettiParticle(
                id: UUID(),
                position: center,
                size: CGFloat.random(in: 4...8),
                opacity: 1.0,
                color: Color.random(),
                offset: CGPoint(
                    x: CGFloat.random(in: -20...70),
                    y: CGFloat.random(in: -60...30)
                ),
                rotation: Double.random(in: 0...360)
            )
        }

        // Animate confetti particles outward
        withAnimation(.easeOut(duration: 1.0)) {
            for i in confettiParticles.indices {
                confettiParticles[i].position = CGPoint(
                    x: confettiParticles[i].offset.x,
                    y: confettiParticles[i].offset.y
                )
                confettiParticles[i].opacity = 0.0
                confettiParticles[i].rotation += 90
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: UUID
    var position: CGPoint
    let size: CGFloat
    var opacity: Double
    let color: Color
    let offset: CGPoint
    var rotation: Double
}

extension Color {
    static func random() -> Color {
        return Color(
            red: Double.random(in: 0.5...1.0),
            green: Double.random(in: 0.5...1.0),
            blue: Double.random(in: 0.5...1.0)
        )
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

struct ConfettiPreviewView: View {
    @State private var exerciseComplete: Bool = false

    var body: some View {
        ZStack {
            VStack {
                Button(action: {
                    withAnimation {
                        exerciseComplete.toggle()
                    }
                }) {
                    Image(
                        systemName: exerciseComplete
                            ? "checkmark.seal.fill"
                            : "figure.strengthtraining.traditional"
                    )
                    .foregroundColor(Color.accentColor)
                    .font(.title3)
                    .frame(width: 32, height: 32)
                }
            }
        }
        .overlay(
            exerciseComplete ? ConfettiView().allowsHitTesting(false) : nil
        )
        .coordinateSpace(name: "confettiArea")  // Define a named coordinate space
    }
}

#Preview {
    ConfettiPreviewView()
}
