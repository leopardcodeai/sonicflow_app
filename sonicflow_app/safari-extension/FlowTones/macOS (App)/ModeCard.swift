import SwiftUI

struct ModeCard: View {
    let mode: FlowMode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                Text(mode.displayName)
                    .font(.headline)
                    .foregroundStyle(BrandTokens.Neutral.fg)
                Text("\(Int(mode.beatHz)) Hz")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(BrandTokens.Neutral.muted)
                Text(mode.shortDescription)
                    .font(.caption2)
                    .foregroundStyle(BrandTokens.Neutral.muted)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
            .padding(BrandTokens.Spacing.md)
            .background(BrandTokens.Neutral.panel)
            .overlay(
                RoundedRectangle(cornerRadius: BrandTokens.Radius.md)
                    .stroke(
                        isSelected ? mode.accentColor : BrandTokens.Neutral.border,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: BrandTokens.Radius.md))
            .shadow(
                color: isSelected ? mode.accentColor : Color.clear,
                radius: isSelected ? 24 : 0
            )
            .shadow(
                color: isSelected ? mode.accentColor.opacity(0.3) : Color.clear,
                radius: isSelected ? 64 : 0
            )
        }
        .buttonStyle(.plain)
    }
}
