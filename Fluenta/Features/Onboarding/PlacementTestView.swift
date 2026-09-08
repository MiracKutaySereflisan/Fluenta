import SwiftUI

struct PlacementTestView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @Binding var selectedLevel: CEFRLevel?

    /// ÖNEMLİ: sorular bir kez üretilir. Computed property olsaydı her render'da
    /// yeniden karışır ve sınav bozulurdu.
    @State private var questions: [PlacementQuestion] = []
    @State private var index = 0
    @State private var answers: [UUID: Int] = [:]
    @State private var showingResult = false
    @State private var result: CEFRLevel = .a1

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                if showingResult {
                    resultView
                } else if index < questions.count {
                    questionView(questions[index])
                } else {
                    ProgressView().tint(.white)
                }
            }
            .navigationTitle("Seviye Belirleme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
            .onAppear(perform: buildTest)
        }
    }

    /// Her seviyeden rastgele 2 soru → 12 soruluk, ezberlenemeyen sınav.
    private func buildTest() {
        guard questions.isEmpty else { return }
        var pool: [PlacementQuestion] = []
        for level in CEFRLevel.allCases {
            pool += appState.contentBundle.placementQuestions
                .filter { $0.level == level }
                .shuffled()
                .prefix(2)
        }
        questions = pool.sorted { $0.level < $1.level }   // kolaydan zora
    }

    private func questionView(_ qn: PlacementQuestion) -> some View {
        VStack(spacing: 20) {
            ProgressView(value: Double(index), total: Double(max(questions.count, 1)))
                .tint(Color.accentColor)
            Text("Soru \(index + 1) / \(questions.count)")
                .font(.caption).foregroundStyle(.secondary)

            Spacer()
            Text(qn.prompt)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()

            VStack(spacing: 12) {
                ForEach(Array(qn.options.enumerated()), id: \.offset) { i, option in
                    Button {
                        answer(qn, i)
                    } label: {
                        Text(option)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer()
        }
        .padding()
    }

    private var resultView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 72))
                .foregroundStyle(.green.gradient)
            Text("Seviyen belirlendi").font(.title.bold())
            Text(result.title)
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(Color.accentColor.gradient)
            Text(result.subtitle).font(.title3).foregroundStyle(.secondary)
            Text(result.descriptionText)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            Button {
                selectedLevel = result
                dismiss()
            } label: {
                Text("Bu seviyeyle devam et")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.accentColor))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
        }
        .padding(.bottom, 24)
    }

    private func answer(_ qn: PlacementQuestion, _ choice: Int) {
        answers[qn.id] = choice
        if index < questions.count - 1 {
            withAnimation { index += 1 }
        } else {
            calculate()
            withAnimation { showingResult = true }
        }
    }

    /// Seviye kuralı: kolaydan zora ilerlenir; bir seviyeyi geçmek için o seviyedeki
    /// soruların TAMAMI doğru olmalı. İlk takıldığı seviyenin bir altı sonuçtur.
    private func calculate() {
        var achieved: CEFRLevel = .a1
        var correctTotal = 0

        for level in CEFRLevel.allCases {
            let levelQs = questions.filter { $0.level == level }
            guard !levelQs.isEmpty else { continue }
            let correct = levelQs.filter { answers[$0.id] == $0.correctIndex }.count
            correctTotal += correct

            if correct == levelQs.count {
                achieved = level                 // bu seviyeyi tam geçti, devam
            } else {
                if correct > 0, level.index > achieved.index { achieved = level }
                break                            // ilk takıldığı yerde dur
            }
        }

        result = achieved
        appState.recordAttempt(kind: "placement", refId: nil,
                               score: correctTotal, maxScore: questions.count,
                               note: "Sonuç: \(achieved.rawValue)")
    }
}
