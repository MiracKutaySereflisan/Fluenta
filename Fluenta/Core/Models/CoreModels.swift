// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import Foundation

// MARK: - Seviye

enum CEFRLevel: String, Codable, CaseIterable, Identifiable, Hashable, Comparable, Sendable {
    case a1 = "A1", a2 = "A2", b1 = "B1", b2 = "B2", c1 = "C1", c2 = "C2"

    var id: String { rawValue }
    var index: Int { CEFRLevel.allCases.firstIndex(of: self) ?? 0 }
    static func < (lhs: CEFRLevel, rhs: CEFRLevel) -> Bool { lhs.index < rhs.index }

    var title: String { rawValue }

    var subtitle: String {
        switch self {
        case .a1: return "Başlangıç"
        case .a2: return "Temel"
        case .b1: return "Orta"
        case .b2: return "Orta Üstü"
        case .c1: return "İleri"
        case .c2: return "Ustalık"
        }
    }

    var descriptionText: String {
        switch self {
        case .a1: return "Günlük basit ifadeleri anlar, kendini tanıtabilir."
        case .a2: return "Sık kullanılan kalıpları anlar, basit alışverişleri yürütür."
        case .b1: return "Tanıdık konularda anlaşılır iletişim kurar."
        case .b2: return "Soyut konularda tartışabilir, akıcılık belirgin artar."
        case .c1: return "Uzun metinleri anlar, dili esnek ve etkili kullanır."
        case .c2: return "Duyduğu/okuduğu her şeyi kolayca anlar, nüansları kullanır."
        }
    }

    /// Teleprompter cümle uzunluğu hedefi (kelime) — ergonomik ilerleme.
    var targetSentenceLength: Int {
        switch self {
        case .a1: return 6
        case .a2: return 9
        case .b1: return 13
        case .b2: return 17
        case .c1: return 22
        case .c2: return 28
        }
    }

    /// Varsayılan okuma hızı (kelime/dakika)
    var defaultWPM: Double {
        switch self {
        case .a1: return 70
        case .a2: return 85
        case .b1: return 100
        case .b2: return 115
        case .c1: return 130
        case .c2: return 145
        }
    }

    var next: CEFRLevel? {
        let all = CEFRLevel.allCases
        let i = index + 1
        return i < all.count ? all[i] : nil
    }
}

// MARK: - Sınav & Beceri

enum ExamType: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case general, ielts, toefl
    var id: String { rawValue }
    var title: String {
        switch self {
        case .general: return "Genel İngilizce"
        case .ielts: return "IELTS"
        case .toefl: return "TOEFL"
        }
    }
}

enum Skill: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case vocabulary, grammar, reading, listening, writing, speaking
    var id: String { rawValue }
    var title: String {
        switch self {
        case .vocabulary: return "Kelime"
        case .grammar: return "Gramer"
        case .reading: return "Okuma"
        case .listening: return "Dinleme"
        case .writing: return "Yazma"
        case .speaking: return "Konuşma"
        }
    }
    var systemImage: String {
        switch self {
        case .vocabulary: return "rectangle.stack"
        case .grammar: return "text.book.closed"
        case .reading: return "book"
        case .listening: return "headphones"
        case .writing: return "square.and.pencil"
        case .speaking: return "waveform"
        }
    }
}

// MARK: - İçerik modelleri (Supabase tablolarıyla birebir)

struct Word: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var level: CEFRLevel
    var headword: String
    var partOfSpeech: String
    var phonetic: String?
    var meaningEn: String
    var meaningTr: String
    var example: String
    var tags: [String]?
}

struct Passage: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var level: CEFRLevel
    var skill: Skill              // reading | listening
    var examType: ExamType
    var title: String
    var body: String              // okuma gövdesi ya da dinleme transkripti
    var wordCount: Int
    var timeLimitSeconds: Int?
}

enum QuestionKind: String, Codable, Hashable, Sendable {
    case mcq, trueFalse, gapFill
}

struct Question: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var passageId: UUID?
    var level: CEFRLevel
    var skill: Skill
    var examType: ExamType
    var kind: QuestionKind
    var prompt: String
    var options: [String]
    var correctIndex: Int
    var explanation: String
    var difficulty: Int
}

struct PlacementQuestion: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var level: CEFRLevel
    var skill: Skill
    var prompt: String
    var options: [String]
    var correctIndex: Int
    var difficulty: Int
}

struct WritingPrompt: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var level: CEFRLevel
    var examType: ExamType
    var taskType: String
    var prompt: String
    var minWords: Int
    var timeLimitSeconds: Int
}

enum SpeakingKind: String, Codable, Hashable, Sendable {
    case teleprompter, cueCard
}

struct SpeakingPrompt: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var level: CEFRLevel
    var examType: ExamType
    var kind: SpeakingKind
    var title: String
    var script: String
    var followUps: [String]?
}

struct Badge: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var code: String
    var title: String
    var detail: String
    var systemImage: String
}

struct ContentBundle: Codable, Sendable {
    var words: [Word]
    var passages: [Passage]
    var questions: [Question]
    var placementQuestions: [PlacementQuestion]
    var writingPrompts: [WritingPrompt]
    var speakingPrompts: [SpeakingPrompt]
    var badges: [Badge]

    static let empty = ContentBundle(words: [], passages: [], questions: [],
                                     placementQuestions: [], writingPrompts: [],
                                     speakingPrompts: [], badges: [])
}
