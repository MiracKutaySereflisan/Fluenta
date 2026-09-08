// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var displayName = ""
    @State private var selectedLevel: CEFRLevel?
    @State private var selectedExamTarget: ExamType = .general
    @State private var showingPlacementTest = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                namePage.tag(1)
                levelSelectionPage.tag(2)
                examTargetPage.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 100))
                .foregroundStyle(Color.accentColor.gradient)
            Text("Fluenta'ya Hoş Geldin")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text("CEFR A1'den C2'ye genel İngilizce + IELTS/TOEFL hazırlık")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            primaryButton("Başla") { withAnimation { currentPage = 1 } }
        }
        .padding(.bottom, 60)
    }

    private var namePage: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("Adın nedir?").font(.largeTitle.bold())
            TextField("Adın", text: $displayName)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .padding(.horizontal)
            Spacer()
            primaryButton("Devam", enabled: !displayName.isEmpty) {
                withAnimation { currentPage = 2 }
            }
        }
        .padding(.bottom, 60)
    }

    private var levelSelectionPage: some View {
        VStack(spacing: 20) {
            Text("İngilizce seviyen nedir?")
                .font(.title.bold())
                .padding(.top, 40)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(CEFRLevel.allCases) { level in
                        LevelCard(level: level, isSelected: selectedLevel == level) {
                            selectedLevel = level
                        }
                    }
                }
                .padding(.horizontal)
            }

            Button("Emin değilim — Seviye Belirleme Sınavı Çöz") {
                showingPlacementTest = true
            }
            .font(.subheadline)

            primaryButton("Devam", enabled: selectedLevel != nil) {
                withAnimation { currentPage = 3 }
            }
        }
        .padding(.bottom, 60)
        .sheet(isPresented: $showingPlacementTest) {
            PlacementTestView(selectedLevel: $selectedLevel)
        }
    }

    private var examTargetPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Hedefin nedir?").font(.title.bold())

            VStack(spacing: 12) {
                ForEach(ExamType.allCases) { examType in
                    Button {
                        selectedExamTarget = examType
                    } label: {
                        HStack {
                            Text(examType.title).font(.headline)
                            Spacer()
                            if selectedExamTarget == examType {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedExamTarget == examType ? Color.accentColor : .clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)

            Spacer()
            primaryButton("Tamamla") { completeOnboarding() }
        }
        .padding(.bottom, 60)
    }

    // Tek tip buton — tip uyuşmazlığı yaratmayan güvenli sürüm.
    private func primaryButton(_ title: String,
                               enabled: Bool = true,
                               action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(enabled ? Color.accentColor : Color.gray.opacity(0.4))
                )
                .foregroundStyle(.white)
        }
        .disabled(!enabled)
        .padding(.horizontal)
    }

    private func completeOnboarding() {
        guard let level = selectedLevel else { return }
        appState.completeOnboarding(
            level: level,
            examTarget: selectedExamTarget,
            displayName: displayName.trimmingCharacters(in: .whitespaces).isEmpty ? "Kullanıcı" : displayName
        )
    }
}

struct LevelCard: View {
    let level: CEFRLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(level.title).font(.title2.bold())
                    Text("·").foregroundStyle(.secondary)
                    Text(level.subtitle).font(.subheadline).foregroundStyle(.secondary)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                    }
                }
                Text(level.descriptionText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
