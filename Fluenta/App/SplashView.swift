import SwiftUI

/// Açılış ekranı: yumuşak giriş, nefes alan halka, sonra otomatik geçiş.
struct SplashView: View {
    @State private var appear = false
    @State private var pulse = false
    @State private var shine = false

    var body: some View {
        ZStack {
            // Derin lacivert → siyah arka plan
            LinearGradient(colors: [Color(red: 0.06, green: 0.10, blue: 0.22),
                                    .black],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            // Arkada yumuşak ışık halkası
            Circle()
                .fill(Color.accentColor.opacity(0.28))
                .frame(width: 300, height: 300)
                .blur(radius: 90)
                .scaleEffect(pulse ? 1.15 : 0.9)
                .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: pulse)

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        .frame(width: 132, height: 132)
                        .scaleEffect(pulse ? 1.08 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: pulse)

                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 68, weight: .light))
                        .foregroundStyle(
                            LinearGradient(colors: [.white, Color.accentColor],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .rotationEffect(.degrees(appear ? 0 : -18))
                        .scaleEffect(appear ? 1 : 0.7)
                }

                VStack(spacing: 6) {
                    Text("Fluenta")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .overlay(
                            // ismin üzerinden geçen parıltı
                            LinearGradient(colors: [.clear, .white.opacity(0.75), .clear],
                                           startPoint: .leading, endPoint: .trailing)
                                .rotationEffect(.degrees(18))
                                .offset(x: shine ? 160 : -160)
                                .mask(
                                    Text("Fluenta")
                                        .font(.system(size: 42, weight: .bold, design: .rounded))
                                )
                        )

                    Text("A1'den C2'ye İngilizce")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.white.opacity(0.55))
                        .tracking(1.2)
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 14)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.65)) { appear = true }
            pulse = true
            withAnimation(.easeInOut(duration: 1.4).delay(0.5).repeatForever(autoreverses: false)) {
                shine = true
            }
        }
    }
}
