import SwiftUI

struct ConfettiView: View {
    @State private var confetti: [ConfettiParticle] = []
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confetti) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                startConfetti(in: geometry.size)
            }
        }.ignoresSafeArea()
    }
    
    private func startConfetti(in size: CGSize) {
        // Generate particles
        for _ in 0..<100 {
            let randomX = CGFloat.random(in: 0...size.width)
            let randomY = CGFloat.random(in: -size.height...0)
            let particle = ConfettiParticle(
                position: CGPoint(x: randomX, y: randomY),
                color: [.red, .blue, .green, .yellow, .pink, .purple].randomElement()!,
                size: CGFloat.random(in: 5...10),
                speed: CGFloat.random(in: 2...5),
                opacity: 1.0
            )
            confetti.append(particle)
        }
        
        // Animation loop
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            updateConfetti(in: size)
        }
    }
    
    private func updateConfetti(in size: CGSize) {
        for i in 0..<confetti.count {
            confetti[i].position.y += confetti[i].speed
            confetti[i].position.x += CGFloat.random(in: -1...1)
            
            if confetti[i].position.y > size.height {
                confetti[i].opacity -= 0.02
            }
        }
        confetti.removeAll { $0.opacity <= 0 }
        
        if confetti.isEmpty {
            timer?.invalidate()
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    let speed: CGFloat
    var opacity: Double
}
