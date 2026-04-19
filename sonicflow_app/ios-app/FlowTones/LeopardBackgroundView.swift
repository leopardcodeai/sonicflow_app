import SwiftUI

/// Procedural leopard-print background layer.
///
/// Generated from `BrandTokens.Leopard.*`. Deterministic spot placement — same
/// layout every render, no motion. Always intended to sit BEHIND a blurred panel
/// per brand rules (see `brand/BRAND.md`).
struct LeopardBackgroundView: View {
    var body: some View {
        Canvas { context, size in
            let spots = LeopardBackgroundView.spots(in: size)
            for spot in spots {
                let rect = CGRect(
                    x: spot.center.x - spot.radius,
                    y: spot.center.y - spot.radius,
                    width: spot.radius * 2,
                    height: spot.radius * 2
                )
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(BrandTokens.Leopard.spot)
                )
            }
        }
        .background(BrandTokens.Leopard.base)
        .opacity(BrandTokens.Leopard.opacity)
        .blur(radius: BrandTokens.Leopard.blurRadius)
    }

    // MARK: - Deterministic spot layout

    private struct Spot {
        let center: CGPoint
        let radius: CGFloat
    }

    /// Deterministic pseudo-random sequence seeded on spot index. Avoids
    /// `Double.random` so the pattern is stable across launches.
    private static func spots(in size: CGSize) -> [Spot] {
        guard size.width > 0, size.height > 0 else { return [] }
        let count = BrandTokens.Leopard.spotCount
        let minR = BrandTokens.Leopard.spotMinPx
        let maxR = BrandTokens.Leopard.spotMaxPx
        var result: [Spot] = []
        result.reserveCapacity(count)
        for index in 0..<count {
            let a = seededUnit(index: index, salt: 1)
            let b = seededUnit(index: index, salt: 2)
            let c = seededUnit(index: index, salt: 3)
            let center = CGPoint(
                x: a * size.width,
                y: b * size.height
            )
            let radius = minR + CGFloat(c) * (maxR - minR)
            result.append(Spot(center: center, radius: radius))
        }
        return result
    }

    /// Deterministic [0, 1) value from an integer seed.
    /// Uses a small integer hash (splitmix-style) so results are stable and
    /// well-distributed without Foundation's `Random` types.
    private static func seededUnit(index: Int, salt: Int) -> Double {
        var x = UInt64(bitPattern: Int64(index &* 2_654_435_761 &+ salt &* 40_503))
        x ^= x >> 30
        x = x &* 0xBF58_476D_1CE4_E5B9
        x ^= x >> 27
        x = x &* 0x94D0_49BB_1331_11EB
        x ^= x >> 31
        // Keep 53 bits of mantissa precision.
        let scaled = Double(x & 0x1F_FFFF_FFFF_FFFF) / Double(1 << 53)
        return scaled
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
