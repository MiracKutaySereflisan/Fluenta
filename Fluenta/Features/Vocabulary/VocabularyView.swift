import SwiftUI

struct VocabularyView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingFlashcards = false
    
    private var dueWords: [UserWord] {
        appState.userState.userWords.filter { $0.dueAt <= Date() }
    }
    
    private var masteredWords: [UserWord] {
        appState.userState.userWords.filter { $0.mastered }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HStack(spacing: 16) {
                        StatCard(title: "Toplam", value: "\(appState.userState.userWords.count)", color: .blue)
                        StatCard(title: "Ezber", value: "\(masteredWords.count)", color: .green)
                        StatCard(title: "Bugün", value: "\(dueWords.count)", color: .orange)
                    }
                    
                    if !dueWords.isEmpty {
                        Button {
                            showingFlashcards = true
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Çalışmaya Başla (\(dueWords.count) kart)")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue.gradient)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.green.gradient)
                            Text("Bugün için tamamladın! 🎉")
                                .font(.headline)
                        }
                        .padding()
                    }
                    
                    if !appState.userState.personalDictionary.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Kişisel Sözlük")
                                .font(.title2.bold())
                            
                            ForEach(personalDictionaryWords()) { word in
                                WordRowCard(word: word)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Kelimeler")
            .sheet(isPresented: $showingFlashcards) {
                FlashcardSessionView(words: dueWords)
            }
        }
    }
    
    private func personalDictionaryWords() -> [Word] {
        appState.userState.personalDictionary.compactMap { wordId in
            appState.contentBundle.words.first { $0.id == wordId }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title.bold())
                .foregroundStyle(color.gradient)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct WordRowCard: View {
    let word: Word
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(word.headword)
                    .font(.headline)
                Text("・")
                    .foregroundColor(.secondary)
                Text(word.partOfSpeech)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(word.level.rawValue)
                    .font(.caption.bold())
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.2))
                    )
            }
            
            Text(word.meaningTr)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let phonetic = word.phonetic {
                Text(phonetic)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(word.example)
                .font(.caption)
                .italic()
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - FlashcardSessionView

struct FlashcardSessionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    let words: [UserWord]
    @State private var currentIndex = 0
    @State private var showingAnswer = false
    @State private var sessionComplete = false
    @State private var correctCount = 0
    
    private var currentUserWord: UserWord? {
        guard currentIndex < words.count else { return nil }
        return words[currentIndex]
    }
    
    private var currentWord: Word? {
        guard let userWord = currentUserWord else { return nil }
        return appState.contentBundle.words.first { $0.id == userWord.wordId }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if sessionComplete {
                completionView
            } else if let word = currentWord {
                VStack(spacing: 24) {
                    HStack {
                        Button("Çık") {
                            dismiss()
                        }
                        Spacer()
                        Text("\(currentIndex + 1) / \(words.count)")
                            .font(.headline)
                    }
                    .padding()
                    
                    Spacer()
                    
                    FlashcardView(word: word, showingAnswer: $showingAnswer)
                        .onTapGesture {
                            withAnimation {
                                showingAnswer.toggle()
                            }
                        }
                    
                    Spacer()
                    
                    if showingAnswer {
                        HStack(spacing: 16) {
                            Button {
                                answerCard(correct: false)
                            } label: {
                                Label("Yanlış", systemImage: "xmark")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.red.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            
                            Button {
                                answerCard(correct: true)
                            } label: {
                                Label("Doğru", systemImage: "checkmark")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.green.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                    } else {
                        Text("Kartı çevirmek için dokun")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green.gradient)
            
            Text("Tebrikler!")
                .font(.largeTitle.bold())
            
            Text("\(words.count) karttan \(correctCount) doğru")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Button {
                dismiss()
            } label: {
                Text("Kapat")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.gradient)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal)
        }
    }
    
    private func answerCard(correct: Bool) {
        guard let userWord = currentUserWord else { return }
        
        if correct {
            correctCount += 1
        }
        
        var updated = userWord
        if correct {
            updated.repetitions += 1
            
            // Break down the ease calculation into simpler steps
            let quality = 4.0 // User's self-assessed quality (0-5)
            let targetQuality = 5.0
            let qualityDiff = targetQuality - quality
            let easeAdjustment = 0.1 - qualityDiff * (0.08 + qualityDiff * 0.02)
            let newEase = updated.ease + easeAdjustment
            updated.ease = max(1.3, newEase)
            
            updated.intervalDays = updated.repetitions == 1 ? 1 : Int(Double(updated.intervalDays) * updated.ease)
            
            if updated.repetitions >= 5 {
                updated.mastered = true
            }
        } else {
            updated.lapses += 1
            updated.repetitions = 0
            updated.intervalDays = 0
            updated.ease = max(1.3, updated.ease - 0.2)
        }
        
        updated.dueAt = Calendar.current.date(byAdding: .day, value: updated.intervalDays, to: Date()) ?? Date()
        updated.updatedAt = Date()
        
        if let index = appState.userState.userWords.firstIndex(where: { $0.id == userWord.id }) {
            appState.userState.userWords[index] = updated
        }
        
        appState.updateDailyActivity(reviewedCards: 1, correctAnswers: correct ? 1 : 0, totalAnswers: 1, minutes: 0.5)
        
        if currentIndex < words.count - 1 {
            withAnimation {
                currentIndex += 1
                showingAnswer = false
            }
        } else {
            withAnimation {
                sessionComplete = true
            }
        }
    }
}

struct FlashcardView: View {
    let word: Word
    @Binding var showingAnswer: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            if !showingAnswer {
                VStack(spacing: 16) {
                    Text(word.headword)
                        .font(.system(size: 48, weight: .bold))
                    
                    if let phonetic = word.phonetic {
                        Text(phonetic)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(word.partOfSpeech)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.2))
                        )
                }
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Türkçe")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(word.meaningTr)
                            .font(.title2.bold())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("İngilizce")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(word.meaningEn)
                            .font(.body)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Örnek")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(word.example)
                            .font(.body)
                            .italic()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, minHeight: 400)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
        .rotation3DEffect(
            .degrees(showingAnswer ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
    }
}
