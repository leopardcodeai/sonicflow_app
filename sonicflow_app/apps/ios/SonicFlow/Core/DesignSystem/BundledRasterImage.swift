import SwiftUI
import UIKit

struct BundledRasterImage: View {
    let name: String

    var body: some View {
        if let image = BundledRasterImageCache.shared.image(named: name) {
            Image(uiImage: image)
                .resizable()
                .accessibilityHidden(true)
        } else {
            Color.clear
        }
    }
}

private final class BundledRasterImageCache {
    static let shared = BundledRasterImageCache()

    private var images: [String: UIImage] = [:]

    func image(named name: String) -> UIImage? {
        if let image = images[name] {
            return image
        }

        guard
            let url = Bundle.main.url(forResource: name, withExtension: "png"),
            let image = UIImage(contentsOfFile: url.path)
        else {
            return nil
        }

        images[name] = image
        return image
    }
}
