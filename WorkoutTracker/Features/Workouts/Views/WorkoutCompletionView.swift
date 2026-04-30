import SwiftUI

struct WorkoutCompletionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var showParticles = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Particles Background
            if showParticles {
                ParticleSystemView()
            }
            
            VStack(spacing: 30) {
                Text("WORKOUT\nCOMPLETED")
                    .font(.system(size: 50, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text(languageManager.t("Great Session!"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                Button(action: {
                    dismiss()
                }) {
                    Text(languageManager.t("Continue"))
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 200)
                        .background(Color.yellow)
                        .cornerRadius(25)
                        .shadow(radius: 10)
                }
                .padding(.top, 50)
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0)) {
                scale = 1.0
                opacity = 1.0
            }
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                showParticles = true
            }
        }
    }
}

struct ParticleSystemView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<15) { i in
                Circle()
                    .fill(Color(
                        red: .random(in: 0.5...1),
                        green: .random(in: 0.5...1),
                        blue: .random(in: 0...1)
                    ))
                    .frame(width: 20, height: 20)
                    .scaleEffect(animate ? 1.0 : 0.2)
                    .offset(x: CGFloat.random(in: -150...150), y: CGFloat.random(in: -300...300))
                    .opacity(animate ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: Double.random(in: 1...2))
                            .repeatForever(autoreverses: false)
                            .delay(Double.random(in: 0...0.5)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}
