import SwiftUI

/// Soft leopard-paper background layer for the menu-bar popover.
///
/// The visible leopard pattern belongs in the background. Session artwork stays
/// clean so controls do not compete with the brand texture.
struct LeopardBackgroundView: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Image("LeopardWallpaperRotated")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .blur(radius: 18)
                    .opacity(0.64)
                    .clipped()

                Image("LeopardWallpaperRotated")
                    .resizable()
                    .scaledToFit()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .scaleEffect(1.08)
                    .saturation(0.76)
                    .contrast(0.86)
                    .brightness(-0.12)
                    .clipped()
                    .overlay(BrandTokens.Neutral.ink.opacity(0.52))

                LinearGradient(
                    colors: [
                        BrandTokens.Neutral.bg.opacity(0.46),
                        BrandTokens.Neutral.ink.opacity(0.18),
                        BrandTokens.Neutral.ink.opacity(0.72)
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
                    startRadius: 18,
                    endRadius: 260
                )

                RadialGradient(
                    colors: [
                        BrandTokens.Mode.focus.opacity(0.1),
                        Color.clear
                    ],
                    center: .bottomTrailing,
                    startRadius: 12,
                    endRadius: 240
                )
                .blendMode(.screen)
            }
        }
        .background(BrandTokens.Neutral.ink)
    }
}

#if DEBUG
struct LeopardBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        LeopardBackgroundView()
            .frame(width: 320, height: 480)
            .background(BrandTokens.Neutral.ink)
    }
}
#endif
