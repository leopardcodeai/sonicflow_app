import SwiftUI

struct LeopardBackgroundView: View {
    var body: some View {
        Color.clear
            .overlay {
                ZStack {
                    BundledRasterImage(name: "LeopardWallpaper")
                        .scaledToFill()
                        .clipped()
                        .saturation(0.9)
                        .contrast(0.94)
                        .brightness(-0.06)
                        .overlay(BrandTokens.Neutral.ink.opacity(0.34))

                    LinearGradient(
                        colors: [
                            BrandTokens.Neutral.bg.opacity(0.22),
                            BrandTokens.Neutral.ink.opacity(0.12),
                            BrandTokens.Neutral.ink.opacity(0.66)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    RadialGradient(
                        colors: [
                            BrandTokens.Accent.gold.opacity(0.18),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 16,
                        endRadius: 320
                    )

                    RadialGradient(
                        colors: [
                            BrandTokens.Mode.focus.opacity(0.1),
                            Color.clear
                        ],
                        center: .bottomTrailing,
                        startRadius: 12,
                        endRadius: 280
                    )
                    .blendMode(.screen)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .allowsHitTesting(false)
            }
            .background(BrandTokens.Neutral.ink)
            .allowsHitTesting(false)
    }
}

#if DEBUG
struct LeopardBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        LeopardBackgroundView()
            .previewLayout(.sizeThatFits)
            .background(BrandTokens.Neutral.ink)
    }
}
#endif
