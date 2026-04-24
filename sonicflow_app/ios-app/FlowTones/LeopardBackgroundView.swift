import SwiftUI

struct LeopardBackgroundView: View {
    var body: some View {
        ZStack {
            Image("LeopardWallpaper")
                .resizable()
                .scaledToFill()
                .saturation(1.16)
                .contrast(1.08)
                .overlay(Color.black.opacity(0.2))

            LinearGradient(
                colors: [
                    Color.black.opacity(0.05),
                    BrandTokens.Neutral.ink.opacity(0.52),
                    Color.black.opacity(0.82)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [
                    BrandTokens.Accent.gold.opacity(0.26),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 16,
                endRadius: 320
            )

            RadialGradient(
                colors: [
                    BrandTokens.Mode.focus.opacity(0.18),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 12,
                endRadius: 280
            )
            .blendMode(.screen)
        }
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
