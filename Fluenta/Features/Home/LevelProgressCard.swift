import SwiftUI

struct LevelProgressCard: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        let p = appState.levelProgress

        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(p.label)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.accentColor.gradient)
                Text(p.level.subtitle)
                    .font(.subheadline).foregroundStyle(.secondary)
                Spacer()
                Text("%\(Int(p.overall * 100))")
                    .font(.headline.monospacedDigit())
            }

            // 5 aşamalı çubuk
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { i in
                    Capsule()
                        .fill(i <= p.stage ? Color.accentColor : Color.gray.opacity(0.25))
                        .frame(height: 6)
                }
            }

            VStack(spacing: 8) {
                RequirementRow(icon: "rectangle.stack", title: "Ezberlenen kelime", done: p.words.done, need: p.words.need)
                RequirementRow(icon: "checklist", title: "Geçilen test (%70+)", done: p.quizzes.done, need: p.quizzes.need)
                RequirementRow(icon: "waveform", title: "Konuşma pratiği", done: p.speaking.done, need: p.speaking.need)
                RequirementRow(icon: "square.and.pencil", title: "Yazma görevi", done: p.writing.done, need: p.writing.need)
            }

            if p.canLevelUp, let next = p.level.next {
                Button {
                    appState.levelUp()
                } label: {
                    Label("\(next.rawValue) seviyesine geç", systemImage: "arrow.up.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.green))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
    }
}

private struct RequirementRow: View {
    let icon: String
    let title: String
    let done: Int
    let need: Int

    var body: some View {
        let complete = done >= need
        HStack(spacing: 10) {
            Image(systemName: complete ? "checkmark.circle.fill" : icon)
                .font(.footnote)
                .foregroundStyle(complete ? Color.green : Color.secondary)
                .frame(width: 18)
            Text(title).font(.footnote)
            Spacer()
            ProgressView(value: Double(min(done, need)), total: Double(max(need, 1)))
                .frame(width: 70)
                .tint(complete ? .green : Color.accentColor)
            Text("\(min(done, need))/\(need)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
    }
}
