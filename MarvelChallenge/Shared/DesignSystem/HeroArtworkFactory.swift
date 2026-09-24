import MarvelDesignSystem
import UIKit

enum HeroArtworkFactory {
    private enum Metrics {
        static let canvasSize = CGSize(width: 600, height: 600)
        static let monogramScale: CGFloat = 0.28
        static let backgroundMarkScale: CGFloat = 0.72
    }

    private static let cache = NSCache<NSString, UIImage>()

    static func image(id: Int, name: String) -> UIImage {
        let key = "\(id)-\(name)" as NSString
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }

        let image = UIGraphicsImageRenderer(size: Metrics.canvasSize).image { context in
            let bounds = CGRect(origin: .zero, size: Metrics.canvasSize)
            DesignSystem.Color.accent.setFill()
            context.fill(bounds)

            let markSize = Metrics.canvasSize.width * Metrics.backgroundMarkScale
            let markBounds = CGRect(
                x: Metrics.canvasSize.width - markSize * 0.72,
                y: -markSize * 0.18,
                width: markSize,
                height: markSize
            )
            DesignSystem.Color.textPrimary.withAlphaComponent(0.16).setFill()
            context.cgContext.fillEllipse(in: markBounds)

            let initials = initials(for: name)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(
                    ofSize: Metrics.canvasSize.width * Metrics.monogramScale,
                    weight: .black
                ),
                .foregroundColor: DesignSystem.Color.onAccent,
                .paragraphStyle: paragraphStyle,
            ]
            let textHeight = (initials as NSString).size(withAttributes: attributes).height
            let textBounds = CGRect(
                x: .zero,
                y: (Metrics.canvasSize.height - textHeight) / 2,
                width: Metrics.canvasSize.width,
                height: textHeight
            )
            (initials as NSString).draw(in: textBounds, withAttributes: attributes)
        }

        cache.setObject(image, forKey: key)
        return image
    }

    private static func initials(for name: String) -> String {
        let words = name.split(whereSeparator: { !$0.isLetter && !$0.isNumber })
        return words.prefix(2).compactMap(\.first).map(String.init).joined().uppercased()
    }
}
