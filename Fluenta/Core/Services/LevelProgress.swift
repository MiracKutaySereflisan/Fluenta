import Foundation

/// Bir CEFR seviyesi 5 aşamaya bölünür (örn. B1.1 → B1.5).
/// Aşama ilerlemesi UYDURMA PUAN değil, gerçek çalışma verisinden hesaplanır.
struct LevelRequirement {
    let masteredWords: Int
    let quizzesPassed: Int      // %70+ doğru
    let speakingSessions: Int   // %70+ doğruluk
    let writingSubmissions: Int

    static func of(_ level: CEFRLevel) -> LevelRequirement {
        switch level {
        case .a1: return .init(masteredWords: 20, quizzesPassed: 4,  speakingSessions: 3,  writingSubmissions: 1)
        case .a2: return .init(masteredWords: 30, quizzesPassed: 6,  speakingSessions: 4,  writingSubmissions: 2)
        case .b1: return .init(masteredWords: 40, quizzesPassed: 8,  speakingSessions: 5,  writingSubmissions: 3)
        case .b2: return .init(masteredWords: 50, quizzesPassed: 10, speakingSessions: 6,  writingSubmissions: 4)
        case .c1: return .init(masteredWords: 60, quizzesPassed: 12, speakingSessions: 7,  writingSubmissions: 5)
        case .c2: return .init(masteredWords: 70, quizzesPassed: 14, speakingSessions: 8,  writingSubmissions: 6)
        }
    }
}

struct LevelProgress {
    let level: CEFRLevel
    let stage: Int              // 1...5  → "B1.3"
    let overall: Double         // 0...1
    let words: (done: Int, need: Int)
    let quizzes: (done: Int, need: Int)
    let speaking: (done: Int, need: Int)
    let writing: (done: Int, need: Int)
    let canLevelUp: Bool

    var label: String { "\(level.rawValue).\(stage)" }
}

extension AppState {

    var levelProgress: LevelProgress {
        let level = userState.profile.level
        let req = LevelRequirement.of(level)

        let wordIdsAtLevel = Set(contentBundle.words.filter { $0.level == level }.map { $0.id })
        let mastered = userState.userWords.filter { $0.mastered && wordIdsAtLevel.contains($0.wordId) }.count

        let quizzes = userState.attempts.filter {
            $0.kind != "placement" && $0.maxScore > 0 &&
            Double($0.score) / Double($0.maxScore) >= 0.7
        }.count

        let speaking = userState.speakingSessions.filter { $0.accuracy >= 0.7 }.count
        let writing  = userState.writingSubmissions.count

        func ratio(_ done: Int, _ need: Int) -> Double {
            need == 0 ? 1 : min(1, Double(done) / Double(need))
        }

        let overall = (ratio(mastered, req.masteredWords)
                     + ratio(quizzes, req.quizzesPassed)
                     + ratio(speaking, req.speakingSessions)
                     + ratio(writing, req.writingSubmissions)) / 4

        let stage = min(5, Int(overall * 5) + 1)

        return LevelProgress(
            level: level,
            stage: stage,
            overall: overall,
            words: (mastered, req.masteredWords),
            quizzes: (quizzes, req.quizzesPassed),
            speaking: (speaking, req.speakingSessions),
            writing: (writing, req.writingSubmissions),
            canLevelUp: overall >= 1.0 && level.next != nil
        )
    }

    /// Bir üst CEFR seviyesine geç (yalnızca hak edilince).
    func levelUp() {
        guard levelProgress.canLevelUp, let next = userState.profile.level.next else { return }
        changeLevel(next)
        if !userState.earnedBadges.contains(where: { $0.code == "level_up" }) {
            userState.earnedBadges.append(UserBadge(code: "level_up", awardedAt: Date()))
        }
        masteryToast = "Tebrikler! Artık \(next.rawValue) seviyesindesin 🎉"
        saveUserState()
    }
}
