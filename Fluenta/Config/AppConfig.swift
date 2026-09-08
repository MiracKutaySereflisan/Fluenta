import Foundation

/// Tüm ortam ayarları tek yerde.
/// ⚠️ Buraya SADECE public "anon" anahtarı yazılır. Service-role anahtarı ASLA client'a girmez.
/// Gemini API anahtarı da client'ta değil, Supabase Edge Function secret'ında durur.
enum AppConfig {

    // MARK: - Supabase
    /// Örn: "https://abcdefgh.supabase.co"
    static let supabaseURL = "https://YOUR-PROJECT-REF.supabase.co"
    /// Supabase Dashboard → Project Settings → API → "anon public"
    static let supabaseAnonKey = "YOUR-SUPABASE-ANON-KEY"

    /// Anahtarlar doldurulmadıysa uygulama "yerel mod"da çalışır:
    /// paketle gelen seed içeriği kullanılır, senkronizasyon devre dışı kalır.
    static var isBackendConfigured: Bool {
        !supabaseURL.contains("YOUR-PROJECT-REF") && !supabaseAnonKey.contains("YOUR-SUPABASE")
    }

    static var supabaseBaseURL: URL? { URL(string: supabaseURL) }

    // MARK: - StoreKit
    enum Products {
        static let monthly = "com.sereflisan.mirac.Fluenta.pro.monthly"
        static let yearly  = "com.sereflisan.mirac.Fluenta.pro.yearly"
        static let all: [String] = [monthly, yearly]
    }

    // MARK: - Edge Functions
    enum Functions {
        static let analyzeWriting  = "analyze-writing"
        static let analyzeSpeaking = "analyze-speaking"
    }

    // MARK: - Uygulama sabitleri
    static let appName = "Fluenta"
    static let freeDailyReviewLimit = 20      // Pro değilse günlük kart limiti
    static let freeAIAnalysisPerWeek = 2      // Pro değilse haftalık AI analiz hakkı
}
