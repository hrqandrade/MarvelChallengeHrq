import Foundation

enum Localizable {
    enum Common {
        static let ok = text("common.ok")
        static let error = text("common.error")
    }

    enum Catalog {
        static let characters = text("catalog.characters")
        static let changeLayout = text("catalog.changeLayout")
        static let favorites = text("catalog.favorites")
    }

    enum Details {
        static let addFavorite = text("details.addFavorite")
        static let back = text("details.back")
        static let descriptionUnavailable = text("details.descriptionUnavailable")
        static let comics = text("details.comics")
        static let series = text("details.series")
        static let removeFavorite = text("details.removeFavorite")
    }

    enum Loading {
        static let title = text("loading.title")
        static let description = text("loading.description")
    }

    enum Error {
        static let missingCredentials = text("error.missingCredentials")
        static let invalidURL = text("error.invalidURL")
        static let transport = text("error.transport")
        static let invalidResponse = text("error.invalidResponse")
        static let decoding = text("error.decoding")
        static let favoritesReading = text("error.favoritesReading")
        static let favoritesWriting = text("error.favoritesWriting")
    }

    private static func text(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Localizable", bundle: .main, comment: "")
    }
}
