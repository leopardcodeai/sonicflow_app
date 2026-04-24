import FlowTonesCore
import SwiftUI

struct ModeCard: View {
    let mode: FlowMode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs + 2) {
                HStack {
                    Circle()
                        .fill(mode.accentColor)
                        .frame(width: 8, height: 8)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(mode.accentColor)
                    }
                }

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
            .frame(maxWidth: .infinity, minHeight: isSelected ? 104 : 84, alignment: .leading)
            .padding(BrandTokens.Spacing.md)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: BrandTokens.Radius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: BrandTokens.Radius.lg, style: .continuous)
                    .stroke(
                        isSelected ? mode.accentColor : Color.white.opacity(0.14),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: BrandTokens.Radius.lg, style: .continuous))
            .shadow(
                color: isSelected ? mode.accentColor.opacity(0.48) : .clear,
                radius: 30
            )
            .shadow(
                color: isSelected ? mode.accentColor.opacity(0.24) : .clear,
                radius: 72
            )
        }
        .buttonStyle(.plain)
    }
}
