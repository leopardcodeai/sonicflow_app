import SwiftUI

struct LeopardBackgroundView: View {
    var body: some View {
        ZStack {
            Image("LeopardWallpaper")
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.38))

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.08),
                            Color.black.opacity(0.5)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
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
