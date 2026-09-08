// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import Foundation
import SwiftUI

extension Date {
    var dayKey: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: self)
    }
}

@MainActor
final class AppState: ObservableObject {

    @Published var userState: UserState = .fresh()
    @Published var contentBundle: ContentBundle = .empty
    @Published var isLoading: Bool = true

    /// Sınav simülasyonu açıkken evrensel sözlük TAMAMEN kapalı olur.
    @Published var examModeActive: Bool = false

    /// "Önce yanlış yaptığın X artık doğru" bildirimi
    @Published var masteryToast: String?

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("fluenta_userstate.json")
    }()

    init() { load() }

    // MARK: - Yükleme / kaydetme

    func load() {
        contentBundle = SeedData.generate()

        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(UserState.self, from: data) {
            userState = decoded
        }
        refreshStreak()
        isLoading = false
    }

    func saveUserState() {
        guard let data = try? JSONEncoder().encode(userState) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func resetAll() {
        try? FileManager.default.removeItem(at: fileURL)
        userState = .fresh()
        saveUserState()
    }

    // MARK: - Onboarding

    func completeOnboarding(level: CEFRLevel, examTarget: ExamType, displayName: String) {
        userState.profile.level = level
        userState.profile.examTarget = examTarget
        userState.profile.displayName = displayName
        userState.onboardingCompleted = true
        seedWords(for: level)
        registerStudyDay()
        saveUserState()
    }

    func changeLevel(_ level: CEFRLevel) {
        userState.profile.level = level
        seedWords(for: level)
        saveUserState()
    }

    /// Seviyenin kelimelerini tekrar kuyruğuna ekler (varsa tekrar eklemez).
    func seedWords(for level: CEFRLevel) {
        let existing = Set(userState.userWords.map { $0.wordId })
        let fresh = contentBundle.words
            .filter { $0.level == level && !existing.contains($0.id) }
            .map { UserWord.new(wordId: $0.id) }
        userState.userWords.append(contentsOf: fresh)
    }

    // MARK: - Evrensel sözlük

    func lookup(_ token: String) -> Word? {
        let cleaned = token
            .lowercased()
            .trimmingCharacters(in: CharacterSet.punctuationCharacters.union(.whitespaces))
        guard !cleaned.isEmpty else { return nil }
        if let exact = contentBundle.words.first(where: { $0.headword.lowercased() == cleaned }) {
            return exact
        }
        // basit kök eşleme: plurals / -ed / -ing
        return contentBundle.words.first { w in
            let h = w.headword.lowercased()
            return cleaned.hasPrefix(h) && cleaned.count - h.count <= 3
        }
    }

    /// Sınav modu dışında: kelime otomatik kişisel sözlüğe eklenir.
    func addToPersonalDictionary(_ word: Word) {
        guard !examModeActive else { return }
        if !userState.personalDictionary.contains(word.id) {
            userState.personalDictionary.append(word.id)
        }
        if !userState.userWords.contains(where: { $0.wordId == word.id }) {
            userState.userWords.append(UserWord.new(wordId: word.id, from: "dictionary"))
        }
        saveUserState()
    }

    func word(id: UUID) -> Word? {
        contentBundle.words.first { $0.id == id }
    }

    // MARK: - Günlük aktivite & seri

    func updateDailyActivity(reviewedCards: Int = 0,
                             correctAnswers: Int = 0,
                             totalAnswers: Int = 0,
                             minutes: Double = 0,
                             aiAnalyses: Int = 0) {
        let key = Date().dayKey
        var a = userState.activities[key] ?? .empty(key)
        a.reviewedCards += reviewedCards
        a.correctAnswers += correctAnswers
        a.totalAnswers += totalAnswers
        a.minutes += minutes
        a.aiAnalyses += aiAnalyses
        userState.activities[key] = a

        registerStudyDay()
        checkBadges()
        saveUserState()
    }

    private func registerStudyDay() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        guard let last = userState.profile.lastActiveDate else {
            userState.profile.streakCount = 1
            userState.profile.longestStreak = max(1, userState.profile.longestStreak)
            userState.profile.lastActiveDate = today
            return
        }

        let lastDay = cal.startOfDay(for: last)
        let diff = cal.dateComponents([.day], from: lastDay, to: today).day ?? 0

        if diff == 0 { return }
        if diff == 1 {
            userState.profile.streakCount += 1
        } else {
            userState.profile.streakCount = 1
        }
        userState.profile.longestStreak = max(userState.profile.longestStreak,
                                              userState.profile.streakCount)
        userState.profile.lastActiveDate = today
    }

    /// Uygulama açılışında: 1 günden fazla ara verildiyse seri düşer.
    private func refreshStreak() {
        guard let last = userState.profile.lastActiveDate else { return }
        let cal = Calendar.current
        let diff = cal.dateComponents([.day],
                                      from: cal.startOfDay(for: last),
                                      to: cal.startOfDay(for: Date())).day ?? 0
        if diff > 1 { userState.profile.streakCount = 0 }
    }

    // MARK: - Hata → ustalık takibi

    func recordAnswer(question: Question, correct: Bool) {
        let idx = userState.mistakes.firstIndex { $0.questionId == question.id }

        if correct {
            if var m = idx.map({ userState.mistakes[$0] }), m.masteredAt == nil {
                m.correctStreak += 1
                m.updatedAt = Date()
                if m.correctStreak >= 2 {
                    m.masteredAt = Date()
                    masteryToast = "Daha önce yanlış yaptığın soruyu artık doğru yapıyorsun ✅"
                }
                userState.mistakes[idx!] = m
            }
        } else {
            if let i = idx {
                var m = userState.mistakes[i]
                m.wrongCount += 1
                m.correctStreak = 0
                m.masteredAt = nil
                m.updatedAt = Date()
                userState.mistakes[i] = m
            } else {
                userState.mistakes.append(
                    MistakeRecord(id: UUID(), questionId: question.id,
                                  promptSnapshot: question.prompt,
                                  wrongCount: 1, correctStreak: 0,
                                  masteredAt: nil, updatedAt: Date())
                )
            }
        }
        updateDailyActivity(correctAnswers: correct ? 1 : 0, totalAnswers: 1, minutes: 0.3)
    }

    func recordAttempt(kind: String, refId: UUID?, score: Int, maxScore: Int, note: String? = nil) {
        userState.attempts.append(
            Attempt(id: UUID(), kind: kind, refId: refId, score: score,
                    maxScore: maxScore, createdAt: Date(), note: note)
        )
        saveUserState()
    }

    // MARK: - Rozetler (gerçek veriye bağlı)

    func checkBadges() {
        award("first_day", if: !userState.activities.isEmpty)
        award("streak_7", if: userState.profile.streakCount >= 7)
        award("master_25", if: userState.userWords.filter { $0.mastered }.count >= 25)
        award("master_100", if: userState.userWords.filter { $0.mastered }.count >= 100)
        award("comeback", if: userState.mistakes.contains { $0.masteredAt != nil })
    }

    private func award(_ code: String, if condition: Bool) {
        guard condition, !userState.earnedBadges.contains(where: { $0.code == code }) else { return }
        userState.earnedBadges.append(UserBadge(code: code, awardedAt: Date()))
    }

    // MARK: - Yardımcılar

    var dueWords: [UserWord] {
        userState.userWords.filter { $0.dueAt <= Date() && !$0.mastered }
    }

    func passages(skill: Skill) -> [Passage] {
        contentBundle.passages
            .filter { $0.skill == skill }
            .sorted { $0.level < $1.level }
    }

    func questions(for passage: Passage) -> [Question] {
        contentBundle.questions.filter { $0.passageId == passage.id }
    }
}
