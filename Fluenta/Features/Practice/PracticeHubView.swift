import SwiftUI

/// Pratik ana ekranı: ÖNCE seviye seçilir, sonra o seviyenin içeriği gelir.
/// İçerik büyüdükçe tek liste anlaşılmaz hale gelmesin diye böyle kurgulandı.
struct PracticeView: View {
    @EnvironmentObject var appState: AppState

    private let cols = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Seviyeni seç, sana uygun pratikler gelsin.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: cols, spacing: 14) {
                        ForEach(CEFRLevel.allCases) { level in
                            NavigationLink {
                                LevelPracticeView(level: level)
                            } label: {
                                LevelTile(level: level,
                                          count: appState.practiceCount(for: level),
                                          isCurrent: level == appState.userState.profile.level)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Pratik")
        }
    }
}

private struct LevelTile: View {
    let level: CEFRLevel
    let count: Int
    let isCurrent: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(level.rawValue)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.accentColor.gradient)
                Spacer()
                if isCurrent {
                    Text("Senin seviyen")
                        .font(.caption2.bold())
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(Capsule().fill(Color.accentColor.opacity(0.25)))
                }
            }
            Text(level.subtitle).font(.subheadline.weight(.semibold))
            Text(level.descriptionText)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Text("\(count) pratik")
                .font(.caption2)
                .foregroundStyle(count == 0 ? .orange : .secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isCurrent ? Color.accentColor : .clear, lineWidth: 2)
        )
    }
}

// MARK: - Seçilen seviyenin pratikleri

struct LevelPracticeView: View {
    @EnvironmentObject var appState: AppState
    let level: CEFRLevel

    @State private var skill: Skill? = nil   // nil = tümü

    private let practiceSkills: [Skill] = [.reading, .listening, .speaking, .writing]

    var body: some View {
        List {
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "Tümü", active: skill == nil) { skill = nil }
                        ForEach(practiceSkills) { s in
                            FilterChip(title: s.title, active: skill == s) { skill = s }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
            }

            if show(.reading) {
                let items = appState.passages(skill: .reading).filter { $0.level == level }
                if !items.isEmpty {
                    Section("Okuma") {
                        ForEach(items) { p in
                            NavigationLink { ReadingDetailView(passage: p) } label: {
                                PassageRow(passage: p, icon: "book")
                            }
                        }
                    }
                }
            }

            if show(.listening) {
                let items = appState.passages(skill: .listening).filter { $0.level == level }
                if !items.isEmpty {
                    Section("Dinleme") {
                        ForEach(items) { p in
                            NavigationLink { ListeningDetailView(passage: p) } label: {
                                PassageRow(passage: p, icon: "headphones")
                            }
                        }
                    }
                }
            }

            if show(.speaking) {
                let items = appState.contentBundle.speakingPrompts.filter { $0.level == level }
                if !items.isEmpty {
                    Section("Konuşma") {
                        ForEach(items) { s in
                            NavigationLink {
                                if s.kind == .teleprompter { TeleprompterView(prompt: s) }
                                else { CueCardView(prompt: s) }
                            } label: {
                                HStack {
                                    Image(systemName: s.kind == .teleprompter ? "waveform" : "rectangle.on.rectangle")
                                        .foregroundStyle(Color.accentColor).frame(width: 26)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(s.title)
                                        Text(s.kind == .teleprompter ? "Teleprompter" : "IELTS Part 2 · Cue Card")
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if show(.writing) {
                let items = appState.contentBundle.writingPrompts.filter { $0.level == level }
                if !items.isEmpty {
                    Section("Yazma") {
                        ForEach(items) { wp in
                            NavigationLink { WritingDetailView(prompt: wp) } label: {
                                HStack {
                                    Image(systemName: "square.and.pencil")
                                        .foregroundStyle(Color.accentColor).frame(width: 26)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(wp.taskType)
                                        Text("\(wp.minWords)+ kelime · \(wp.timeLimitSeconds / 60) dk")
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if appState.practiceCount(for: level, skill: skill) == 0 {
                Section {
                    ContentUnavailableView(
                        "Henüz içerik yok",
                        systemImage: "tray",
                        description: Text("\(level.rawValue) seviyesinde bu alan için pratik eklenmedi.")
                    )
                }
            }
        }
        .navigationTitle("\(level.rawValue) · \(level.subtitle)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func show(_ s: Skill) -> Bool { skill == nil || skill == s }
}

private struct FilterChip: View {
    let title: String
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.footnote.weight(.medium))
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(Capsule().fill(active ? Color.accentColor : Color.gray.opacity(0.25)))
                .foregroundStyle(active ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Ortak satır

struct PassageRow: View {
    let passage: Passage
    let icon: String
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundStyle(Color.accentColor).frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text(passage.title)
                Text("\(passage.wordCount) kelime")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

extension AppState {
    /// Bir seviyedeki (ve istenirse tek bir beceriye ait) pratik sayısı.
    func practiceCount(for level: CEFRLevel, skill: Skill? = nil) -> Int {
        var n = 0
        if skill == nil || skill == .reading {
            n += contentBundle.passages.filter { $0.level == level && $0.skill == .reading }.count
        }
        if skill == nil || skill == .listening {
            n += contentBundle.passages.filter { $0.level == level && $0.skill == .listening }.count
        }
        if skill == nil || skill == .speaking {
            n += contentBundle.speakingPrompts.filter { $0.level == level }.count
        }
        if skill == nil || skill == .writing {
            n += contentBundle.writingPrompts.filter { $0.level == level }.count
        }
        return n
    }
}
