import SonicFlowCore
import SwiftUI

struct ModeCard: View {
    let mode: FlowMode
    let isSelected: Bool
    var language: SonicFlowLanguage = .english
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: BrandTokens.Spacing.md) {
                Circle()
                    .fill(mode.accentColor)
                    .frame(maxWidth: 12, maxHeight: 12)

                VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                    Text(language.modeName(mode))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(BrandTokens.Neutral.fg)
                        .lineLimit(1)

                    Text("\(Int(mode.beatHz)) Hz · \(language.modeDescription(mode))")
                        .font(.caption)
                        .foregroundStyle(BrandTokens.Neutral.fg.opacity(0.68))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }

                Spacer(minLength: BrandTokens.Spacing.sm)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(isSelected ? mode.accentColor : BrandTokens.Neutral.muted.opacity(0.7))
            }
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .padding(.horizontal, BrandTokens.Spacing.md)
            .padding(.vertical, BrandTokens.Spacing.sm)
            .background(BrandTokens.Neutral.panel.opacity(isSelected ? 0.76 : 0.58), in: RoundedRectangle(cornerRadius: BrandTokens.Radius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: BrandTokens.Radius.lg, style: .continuous)
                    .stroke(
                        isSelected ? mode.accentColor : Color.white.opacity(0.14),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: BrandTokens.Radius.lg, style: .continuous))
            .shadow(
                color: isSelected ? mode.accentColor.opacity(0.22) : .clear,
                radius: 12,
                y: 4
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(DesignLabels.Accessibility.modeCard(for: mode))
    }
}
