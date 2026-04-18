import SwiftUI

struct ModeCard: View {
    let mode: FlowMode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(mode.displayName)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("\(Int(mode.beatHz)) Hz")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(mode.shortDescription)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
            .padding(10)
            .background(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? mode.accentColor : Color.white.opacity(0.12), lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
