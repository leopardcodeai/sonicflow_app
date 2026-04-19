import FlowTonesCore
import SwiftUI

struct ModeCard: View {
    let mode: FlowMode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs + 2) {
                Text(mode.displayName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(BrandTokens.Neutral.fg)
                Text("\(Int(mode.beatHz)) Hz")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(BrandTokens.Neutral.muted)
                Text(mode.shortDescription)
                    .font(.caption)
                    .foregroundStyle(BrandTokens.Neutral.muted)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 94, alignment: .leading)
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
                color: isSelected ? mode.accentColor : .clear,
                radius: 24
            )
            .shadow(
                color: isSelected ? mode.accentColor.opacity(0.3) : .clear,
                radius: 64
            )
        }
        .buttonStyle(.plain)
    }
}
