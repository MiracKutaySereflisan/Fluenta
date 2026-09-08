import Foundation

struct UserProfile: Codable, Hashable, Sendable {
    var id: UUID
    var displayName: String
    var level: CEFRLevel
    var examTarget: ExamType
    var streakCount: Int
    var longestStreak: Int
    var lastActiveDate: Date?
    var isPro: Bool

    static func guest() -> UserProfile {
        UserProfile(id: UUID(), displayName: "Misafir", level: .a2, examTarget: .general,
                    streakCount: 0, longestStreak: 0, lastActiveDate: nil, isPro: false)
    }
}

/// SM-2 tabanlı aralıklı tekrar kaydı. Yerelde tutulur, çevrimiçiyken senkronlanır.
struct UserWord: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var wordId: UUID
    var ease: Double
    var intervalDays: Int
    var repetitions: Int
    var lapses: Int
    var dueAt: Date
    var mastered: Bool
    var addedFrom: String
    var updatedAt: Date

    static func new(wordId: UUID, from source: String = "flashcard") -> UserWord {
        UserWord(id: UUID(), wordId: wordId, ease: 2.5, intervalDays: 0, repetitions: 0,
                 lapses: 0, dueAt: Date(), mastered: false, addedFrom: source, updatedAt: Date())
    }
}

/// "Önce yanlış yaptığın X artık doğru" takibi.
struct MistakeRecord: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var questionId: UUID
    var promptSnapshot: String
    var wrongCount: Int
    var correctStreak: Int
    var masteredAt: Date?
    var updatedAt: Date
}

struct DailyActivity: Codable, Identifiable, Hashable, Sendable {
    var id: String { dayKey }
    var dayKey: String
    var reviewedCards: Int
    var correctAnswers: Int
    var totalAnswers: Int
    var minutes: Double
    var aiAnalyses: Int

    static func empty(_ key: String) -> DailyActivity {
        DailyActivity(dayKey: key, reviewedCards: 0, correctAnswers: 0,
                      totalAnswers: 0, minutes: 0, aiAnalyses: 0)
    }
}

struct Attempt: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var kind: String
    var refId: UUID?
    var score: Int
    var maxScore: Int
    var createdAt: Date
    var note: String?
}

struct WritingFeedback: Codable, Hashable, Sendable {
    struct Issue: Codable, Hashable, Sendable, Identifiable {
        var id: String { excerpt + suggestion }
        var category: String
        var excerpt: String
        var problem: String
        var suggestion: String
    }
    var overallComment: String
    var taskResponse: Double
    var coherence: Double
    var lexicalResource: Double
    var grammaticalRange: Double
    var estimatedBand: Double
    var strengths: [String]
    var issues: [Issue]
    var rewrittenSample: String?
}

struct WritingSubmission: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var promptId: UUID
    var text: String
    var wordCount: Int
    var feedback: WritingFeedback?
    var createdAt: Date
}

struct SpeakingFeedback: Codable, Hashable, Sendable {
    var overallComment: String
    var fluency: Double
    var pronunciationNotes: [String]
    var vocabularySuggestions: [String]
    var estimatedBand: Double
}

struct SpeakingSession: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var promptId: UUID
    var transcript: String
    var accuracy: Double
    var wordsPerMinute: Double
    var feedback: SpeakingFeedback?
    var createdAt: Date
}

struct UserBadge: Codable, Identifiable, Hashable, Sendable {
    var id: String { code }
    var code: String
    var awardedAt: Date
}

/// Cihazda tutulan tüm kullanıcı durumu.
struct UserState: Codable, Sendable {
    var profile: UserProfile
    var userWords: [UserWord]
    var personalDictionary: [UUID]
    var mistakes: [MistakeRecord]
    var activities: [String: DailyActivity]
    var attempts: [Attempt]
    var writingSubmissions: [WritingSubmission]
    var speakingSessions: [SpeakingSession]
    var earnedBadges: [UserBadge]
    var onboardingCompleted: Bool
    var downloadedLevels: [CEFRLevel]

    static func fresh() -> UserState {
        UserState(profile: .guest(), userWords: [], personalDictionary: [], mistakes: [],
                  activities: [:], attempts: [], writingSubmissions: [], speakingSessions: [],
                  earnedBadges: [], onboardingCompleted: false, downloadedLevels: [])
    }
}
