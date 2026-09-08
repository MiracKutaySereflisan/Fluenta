// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem { Label("Ana Sayfa", systemImage: "house.fill") }.tag(0)
            VocabularyView()
                .tabItem { Label("Kelimeler", systemImage: "rectangle.stack.fill") }.tag(1)
            PracticeView()
                .tabItem { Label("Pratik", systemImage: "pencil.and.outline") }.tag(2)
            ProgressTrackingView()
                .tabItem { Label("İlerleme", systemImage: "chart.line.uptrend.xyaxis") }.tag(3)
            ProfileView()
                .tabItem { Label("Profil", systemImage: "person.fill") }.tag(4)
        }
        .tint(Color.accentColor)
        .overlay(alignment: .top) {
            if let toast = appState.masteryToast {
                Text(toast)
                    .font(.footnote.weight(.medium))
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(Capsule().fill(.ultraThinMaterial))
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task {
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        withAnimation { appState.masteryToast = nil }
                    }
            }
        }
        .animation(.spring, value: appState.masteryToast)
    }
}

// MARK: - Ana Sayfa

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @Binding var selectedTab: Int

    private var todayActivity: DailyActivity {
        appState.userState.activities[Date().dayKey] ?? .empty(Date().dayKey)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Merhaba, \(appState.userState.profile.displayName)")
                                .font(.title2.bold())
                            Text("Seviye \(appState.userState.profile.level.title) · \(appState.userState.profile.examTarget.title)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    LevelProgressCard()
                    StreakCard(streakCount: appState.userState.profile.streakCount)
                    TodayActivityCard(activity: todayActivity)

                    Button {
                        selectedTab = 1
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Bugünün kartları (\(appState.dueWords.count))")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.accentColor))
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)

                    QuickActionsGrid(selectedTab: $selectedTab)
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StreakCard: View {
    let streakCount: Int
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.system(size: 36))
                .foregroundStyle(.orange.gradient)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(streakCount) gün").font(.title2.bold())
                Text("Çalışma serisi").font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
    }
}

struct TodayActivityCard: View {
    let activity: DailyActivity
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bugün").font(.headline)
            HStack {
                StatItem(icon: "rectangle.stack", value: "\(activity.reviewedCards)", label: "Kart")
                Spacer()
                StatItem(icon: "checkmark.circle", value: "\(activity.correctAnswers)/\(activity.totalAnswers)", label: "Doğru")
                Spacer()
                StatItem(icon: "clock", value: String(format: "%.0f dk", activity.minutes), label: "Süre")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.title3).foregroundStyle(Color.accentColor)
            Text(value).font(.headline)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}

struct QuickActionsGrid: View {
    @Binding var selectedTab: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hızlı Erişim").font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                QuickActionCard(icon: "rectangle.stack", title: "Kelime Kartları", color: .blue) { selectedTab = 1 }
                QuickActionCard(icon: "book", title: "Okuma", color: .green) { selectedTab = 2 }
                QuickActionCard(icon: "headphones", title: "Dinleme", color: .purple) { selectedTab = 2 }
                QuickActionCard(icon: "waveform", title: "Konuşma", color: .orange) { selectedTab = 2 }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon).font(.system(size: 28)).foregroundStyle(color.gradient)
                Text(title).font(.subheadline.bold()).foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - İlerleme

struct ProgressTrackingView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    weekCard
                    totalsCard
                    masteryCard
                    badgesCard
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("İlerleme")
        }
    }

    private var weekCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bu Hafta").font(.headline)
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weekActivities(), id: \.dayKey) { a in
                    VStack(spacing: 4) {
                        Text("\(a.reviewedCards)").font(.caption2).foregroundStyle(.secondary)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(a.reviewedCards > 0 ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(height: max(6, CGFloat(min(a.reviewedCards * 6, 80))))
                        Text(dayLetter(a.dayKey)).font(.caption2).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 110, alignment: .bottom)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
    }

    private var totalsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Toplam").font(.headline)
            HStack {
                StatItem(icon: "flame.fill", value: "\(appState.userState.profile.longestStreak)", label: "En Uzun Seri")
                Spacer()
                StatItem(icon: "brain.head.profile",
                         value: "\(appState.userState.userWords.filter { $0.mastered }.count)",
                         label: "Ezber Kelime")
                Spacer()
                StatItem(icon: "list.bullet.rectangle",
                         value: "\(appState.userState.attempts.count)",
                         label: "Test")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
    }

    /// Hata → ustalık: somut ilerleme bildirimi
    private var masteryCard: some View {
        let recovered = appState.userState.mistakes.filter { $0.masteredAt != nil }
        return Group {
            if !recovered.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hatadan Ustalığa").font(.headline)
                    ForEach(recovered.prefix(4)) { m in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            Text("Önce yanlış yaptığın “\(m.promptSnapshot)” sorusunu artık doğru yapıyorsun.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
            }
        }
    }

    private var badgesCard: some View {
        Group {
            if !appState.userState.earnedBadges.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Rozetler").font(.headline)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        ForEach(appState.userState.earnedBadges) { earned in
                            if let b = appState.contentBundle.badges.first(where: { $0.code == earned.code }) {
                                VStack(spacing: 6) {
                                    Image(systemName: b.systemImage)
                                        .font(.title)
                                        .foregroundStyle(.yellow.gradient)
                                    Text(b.title).font(.caption2).multilineTextAlignment(.center)
                                }
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
            }
        }
    }

    private func weekActivities() -> [DailyActivity] {
        let cal = Calendar.current
        return (0..<7).reversed().compactMap { i -> DailyActivity? in
            guard let d = cal.date(byAdding: .day, value: -i, to: Date()) else { return nil }
            let key = d.dayKey
            return appState.userState.activities[key] ?? .empty(key)
        }
    }

    private func dayLetter(_ key: String) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        guard let d = f.date(from: key) else { return "" }
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "EEE"
        return String(f.string(from: d).prefix(2))
    }
}

// MARK: - Profil

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingPlacement = false
    @State private var placementResult: CEFRLevel?
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section("Hesap") {
                    LabeledContent("İsim", value: appState.userState.profile.displayName)
                    Picker("Seviye", selection: Binding(
                        get: { appState.userState.profile.level },
                        set: { appState.changeLevel($0) }
                    )) {
                        ForEach(CEFRLevel.allCases) { Text("\($0.title) · \($0.subtitle)").tag($0) }
                    }
                    Picker("Hedef", selection: Binding(
                        get: { appState.userState.profile.examTarget },
                        set: { appState.userState.profile.examTarget = $0; appState.saveUserState() }
                    )) {
                        ForEach(ExamType.allCases) { Text($0.title).tag($0) }
                    }
                }

                Section("Seviye Tespiti") {
                    Button("Seviye belirleme sınavını tekrar çöz") {
                        showingPlacement = true
                    }
                    Text("Her çözüşte havuzdan farklı sorular gelir.")
                        .font(.caption).foregroundStyle(.secondary)
                }

                Section("İstatistik") {
                    LabeledContent("Tekrar kuyruğu", value: "\(appState.userState.userWords.count)")
                    LabeledContent("Kişisel sözlük", value: "\(appState.userState.personalDictionary.count)")
                    LabeledContent("En uzun seri", value: "\(appState.userState.profile.longestStreak) gün")
                }

                Section {
                    Button("Tüm verileri sıfırla", role: .destructive) { showResetAlert = true }
                } footer: {
                    Text("Fluenta \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0") · İçerik cihazda saklanır.")
                }
            }
            .navigationTitle("Profil")
            .sheet(isPresented: $showingPlacement) {
                PlacementTestView(selectedLevel: $placementResult)
            }
            .onChange(of: placementResult) { _, new in
                if let new { appState.changeLevel(new) }
            }
            .alert("Emin misin?", isPresented: $showResetAlert) {
                Button("Sıfırla", role: .destructive) { appState.resetAll() }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text("Tüm ilerleme, kelimeler ve rozetler silinir.")
            }
        }
    }
}
