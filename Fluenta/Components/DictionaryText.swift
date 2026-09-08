import SwiftUI
import UIKit

/// Evrensel sözlük: metindeki her kelimeye basılı tutunca anlam balonu çıkar.
/// Sınav modunda (appState.examModeActive) balon HİÇ çıkmaz.
struct DictionaryText: View {
    let text: String
    var font: Font = .body

    @EnvironmentObject private var appState: AppState
    @State private var selected: Word?
    @State private var missing: String?

    private var tokens: [String] {
        text.split(whereSeparator: { $0 == " " || $0 == "\n" }).map(String.init)
    }

    var body: some View {
        FlowLayout(spacing: 5, lineSpacing: 8) {
            ForEach(Array(tokens.enumerated()), id: \.offset) { _, token in
                Text(token)
                    .font(font)
                    .onLongPressGesture(minimumDuration: 0.35) {
                        guard !appState.examModeActive else { return }
                        if let word = appState.lookup(token) {
                            appState.addToPersonalDictionary(word)
                            selected = word
                        } else {
                            missing = token.trimmingCharacters(in: .punctuationCharacters)
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
            }
        }
        .sheet(item: $selected) { word in
            WordDetailSheet(word: word)
                .presentationDetents([.height(300)])
                .presentationBackground(.regularMaterial)
        }
        .alert("Sözlükte yok", isPresented: .init(get: { missing != nil },
                                                  set: { if !$0 { missing = nil } })) {
            Button("Tamam", role: .cancel) { missing = nil }
        } message: {
            Text("“\(missing ?? "")” henüz sözlükte kayıtlı değil.")
        }
    }
}

struct WordDetailSheet: View {
    let word: Word
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(word.headword).font(.largeTitle.bold())
                Text(word.partOfSpeech).font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text(word.level.rawValue)
                    .font(.caption.bold())
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Capsule().fill(Color.accentColor.opacity(0.2)))
            }
            if let ph = word.phonetic {
                Text(ph).font(.callout).foregroundStyle(.secondary)
            }
            Text(word.meaningTr).font(.title3.weight(.semibold))
            Text(word.meaningEn).font(.body).foregroundStyle(.secondary)
            Divider()
            Text(word.example).font(.callout).italic()
            Label("Kişisel sözlüğüne eklendi", systemImage: "checkmark.circle.fill")
                .font(.caption).foregroundStyle(.green)
            Spacer()
        }
        .padding(24)
    }
}

/// Kelimeleri satır satır saran basit akış düzeni.
struct FlowLayout: Layout {
    var spacing: CGFloat = 5
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0
        for s in subviews {
            let size = s.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0; y += lineHeight + lineSpacing; lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: maxWidth == .infinity ? x : maxWidth, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, lineHeight: CGFloat = 0
        for s in subviews {
            let size = s.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX; y += lineHeight + lineSpacing; lineHeight = 0
            }
            s.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
