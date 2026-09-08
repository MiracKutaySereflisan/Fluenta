// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import SwiftUI

// MARK: - Okuma

struct ReadingDetailView: View {
    @EnvironmentObject var appState: AppState
    let passage: Passage
    @State private var showQuiz = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(passage.title).font(.title2.bold())
                Label("Bir kelimeye basılı tut → anlamı çıkar ve sözlüğüne eklenir",
                      systemImage: "hand.tap")
                    .font(.caption).foregroundStyle(.secondary)

                DictionaryText(text: passage.body, font: .body)

                Button {
                    showQuiz = true
                } label: {
                    Text("Soruları Çöz (\(appState.questions(for: passage).count))")
                        .font(.headline)
                        .frame(maxWidth: .infinity).padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentColor))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("Okuma")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showQuiz) {
            QuizView(title: passage.title,
                     questions: appState.questions(for: passage),
                     kind: "reading",
                     refId: passage.id)
        }
    }
}

// MARK: - Dinleme

struct ListeningDetailView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var player = SpeechPlayer()
    let passage: Passage

    @State private var showTranscript = false
    @State private var showQuiz = false
    @State private var rate: Double = 0.45

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: player.isSpeaking ? "waveform.circle.fill" : "headphones.circle.fill")
                    .font(.system(size: 90))
                    .foregroundStyle(Color.accentColor.gradient)
                    .symbolEffect(.pulse, isActive: player.isSpeaking)

                Text(passage.title).font(.title2.bold())

                HStack(spacing: 16) {
                    Button {
                        player.isSpeaking ? player.stop() : player.speak(passage.body, rate: Float(rate))
                    } label: {
                        Label(player.isSpeaking ? "Durdur" : "Dinle",
                              systemImage: player.isSpeaking ? "stop.fill" : "play.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity).padding()
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentColor))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Konuşma hızı: \(String(format: "%.2f", rate))")
                        .font(.caption).foregroundStyle(.secondary)
                    Slider(value: $rate, in: 0.30...0.60)
                }

                Toggle("Transkripti göster", isOn: $showTranscript)
                    .font(.subheadline)

                if showTranscript {
                    DictionaryText(text: passage.body, font: .callout)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                }

                Button {
                    player.stop()
                    showQuiz = true
                } label: {
                    Text("Soruları Çöz (\(appState.questions(for: passage).count))")
                        .font(.headline)
                        .frame(maxWidth: .infinity).padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial))
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .navigationTitle("Dinleme")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { player.stop() }
        .sheet(isPresented: $showQuiz) {
            QuizView(title: passage.title,
                     questions: appState.questions(for: passage),
                     kind: "listening",
                     refId: passage.id)
        }
    }
}

// MARK: - Ortak Quiz

struct QuizView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    let title: String
    let questions: [Question]
    let kind: String
    let refId: UUID?

    @State private var index = 0
    @State private var chosen: Int?
    @State private var correctCount = 0
    @State private var finished = false

    var body: some View {
        NavigationStack {
            Group {
                if finished || questions.isEmpty {
                    resultView
                } else {
                    quizBody(questions[index])
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }

    private func quizBody(_ q: Question) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            ProgressView(value: Double(index), total: Double(questions.count))
            Text("Soru \(index + 1) / \(questions.count)")
                .font(.caption).foregroundStyle(.secondary)

            Text(q.prompt).font(.title3.weight(.medium))

            ForEach(Array(q.options.enumerated()), id: \.offset) { i, option in
                Button {
                    guard chosen == nil else { return }
                    chosen = i
                    let correct = i == q.correctIndex
                    if correct { correctCount += 1 }
                    appState.recordAnswer(question: q, correct: correct)
                } label: {
                    HStack {
                        Text(option)
                        Spacer()
                        if chosen != nil {
                            if i == q.correctIndex {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            } else if i == chosen {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                }
                .buttonStyle(.plain)
            }

            if chosen != nil {
                Text(q.explanation)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.accentColor.opacity(0.12)))

                Button(index == questions.count - 1 ? "Bitir" : "Sonraki soru") {
                    if index == questions.count - 1 {
                        appState.recordAttempt(kind: kind, refId: refId,
                                               score: correctCount, maxScore: questions.count)
                        withAnimation { finished = true }
                    } else {
                        withAnimation { index += 1; chosen = nil }
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity).padding()
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentColor))
                .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding()
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "rosette").font(.system(size: 70))
                .foregroundStyle(Color.accentColor.gradient)
            Text(questions.isEmpty ? "Bu metinde soru yok" : "\(correctCount) / \(questions.count) doğru")
                .font(.title.bold())
            Spacer()
            Button("Kapat") { dismiss() }
                .font(.headline)
                .frame(maxWidth: .infinity).padding()
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentColor))
                .foregroundStyle(.white)
                .padding(.horizontal)
        }
        .padding(.bottom, 24)
    }
}

// MARK: - Yazma (yerel: süre + kelime sayacı; otomatik değerlendirme sonraki sürümde)

struct WritingDetailView: View {
    @EnvironmentObject var appState: AppState
    let prompt: WritingPrompt

    @State private var text = ""
    @State private var remaining: Int = 0
    @State private var running = false
    @State private var saved = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var wordCount: Int {
        text.split { $0 == " " || $0 == "\n" }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(prompt.prompt).font(.callout).padding(.horizontal)

            HStack {
                Label("\(wordCount) / \(prompt.minWords) kelime", systemImage: "text.word.spacing")
                    .font(.caption)
                    .foregroundStyle(wordCount >= prompt.minWords ? .green : .secondary)
                Spacer()
                Label(timeString, systemImage: "clock")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(remaining < 60 && running ? .red : .secondary)
            }
            .padding(.horizontal)

            TextEditor(text: $text)
                .font(.body)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                .padding(.horizontal)

            HStack {
                Button(running ? "Duraklat" : "Süreyi Başlat") {
                    if !running && remaining == 0 { remaining = prompt.timeLimitSeconds }
                    running.toggle()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Kaydet") {
                    let sub = WritingSubmission(id: UUID(), promptId: prompt.id, text: text,
                                                wordCount: wordCount, feedback: nil, createdAt: Date())
                    appState.userState.writingSubmissions.append(sub)
                    appState.updateDailyActivity(minutes: 5)
                    running = false
                    saved = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(text.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .navigationTitle(prompt.taskType)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            guard running, remaining > 0 else { return }
            remaining -= 1
            if remaining == 0 { running = false }
        }
        .alert("Kaydedildi", isPresented: $saved) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text("Yazın kaydedildi. AI değerlendirmesi Supabase bağlandığında etkinleşecek.")
        }
    }

    private var timeString: String {
        let t = remaining == 0 && !running ? prompt.timeLimitSeconds : remaining
        return String(format: "%02d:%02d", t / 60, t % 60)
    }
}

// MARK: - Teleprompter

struct TeleprompterView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var recognizer = SpeechRecognizer()
    let prompt: SpeakingPrompt

    @State private var matched = 0
    @State private var permissionDenied = false
    @State private var startedAt: Date?

    private var scriptWords: [String] {
        prompt.script.split(whereSeparator: { $0 == " " || $0 == "\n" }).map(String.init)
    }

    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                FlowLayout(spacing: 6, lineSpacing: 12) {
                    ForEach(Array(scriptWords.enumerated()), id: \.offset) { i, word in
                        Text(word)
                            .font(.title3)
                            .foregroundStyle(i < matched ? Color.green : Color.primary)
                            .fontWeight(i == matched ? .bold : .regular)
                    }
                }
                .padding()
            }

            ProgressView(value: Double(matched), total: Double(max(scriptWords.count, 1)))
                .tint(.green)
                .padding(.horizontal)

            Text("\(matched) / \(scriptWords.count) kelime")
                .font(.caption).foregroundStyle(.secondary)

            if let err = recognizer.errorMessage {
                Text(err).font(.caption).foregroundStyle(.red).padding(.horizontal)
            }

            Button {
                recognizer.isRunning ? finish() : start()
            } label: {
                Label(recognizer.isRunning ? "Bitir" : "Okumaya Başla",
                      systemImage: recognizer.isRunning ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity).padding()
                    .background(RoundedRectangle(cornerRadius: 14)
                        .fill(recognizer.isRunning ? Color.red : Color.accentColor))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .padding([.horizontal, .bottom])
        }
        .navigationTitle(prompt.title)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: recognizer.transcript) { _, t in
            matched = TeleprompterMatcher.matchedCount(script: scriptWords, transcript: t)
        }
        .onDisappear { recognizer.stop() }
        .alert("İzin gerekli", isPresented: $permissionDenied) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text("Ayarlar'dan mikrofon ve konuşma tanıma iznini aç.")
        }
    }

    private func start() {
        Task {
            guard await recognizer.requestPermission() else {
                permissionDenied = true
                return
            }
            matched = 0
            startedAt = Date()
            recognizer.start()
        }
    }

    private func finish() {
        recognizer.stop()
        let elapsed = max(1, Date().timeIntervalSince(startedAt ?? Date()))
        let wpm = Double(matched) / elapsed * 60
        let accuracy = Double(matched) / Double(max(scriptWords.count, 1))

        appState.userState.speakingSessions.append(
            SpeakingSession(id: UUID(), promptId: prompt.id,
                            transcript: recognizer.transcript,
                            accuracy: accuracy, wordsPerMinute: wpm,
                            feedback: nil, createdAt: Date())
        )
        appState.updateDailyActivity(minutes: elapsed / 60)
    }
}

// MARK: - Cue Card (IELTS Part 2)

struct CueCardView: View {
    let prompt: SpeakingPrompt
    @State private var phase: Phase = .idle
    @State private var remaining = 60

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    enum Phase { case idle, prep, speak, done }

    var body: some View {
        VStack(spacing: 20) {
            Text(prompt.script)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))

            Text(label).font(.headline)
            Text(String(format: "%02d:%02d", remaining / 60, remaining % 60))
                .font(.system(size: 54, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(phase == .speak ? Color.green : Color.accentColor)

            if let fups = prompt.followUps, phase == .done {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Takip soruları").font(.headline)
                    ForEach(fups, id: \.self) { Text("• \($0)").font(.callout) }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()

            Button(buttonTitle) { advance() }
                .font(.headline)
                .frame(maxWidth: .infinity).padding()
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentColor))
                .foregroundStyle(.white)
        }
        .padding()
        .navigationTitle("Cue Card")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in tick() }
    }

    private var label: String {
        switch phase {
        case .idle: return "1 dk hazırlık + 2 dk konuşma"
        case .prep: return "Hazırlık"
        case .speak: return "Konuş"
        case .done: return "Tamamlandı"
        }
    }

    private var buttonTitle: String {
        switch phase {
        case .idle: return "Başla"
        case .prep: return "Hazırım, konuşmaya geç"
        case .speak: return "Bitir"
        case .done: return "Tekrar dene"
        }
    }

    private func advance() {
        switch phase {
        case .idle: phase = .prep; remaining = 60
        case .prep: phase = .speak; remaining = 120
        case .speak: phase = .done; remaining = 0
        case .done: phase = .idle; remaining = 60
        }
    }

    private func tick() {
        guard phase == .prep || phase == .speak, remaining > 0 else { return }
        remaining -= 1
        if remaining == 0 { advance() }
    }
}
