import Foundation

enum Localizable {
    enum Catalog {
        static let characters = text("catalog.characters")
        static let changeLayout = text("catalog.changeLayout")
        static let favorites = text("catalog.favorites")
        static let emptyCharactersTitle = text("catalog.emptyCharacters.title")
        static let emptyCharactersDescription = text("catalog.emptyCharacters.description")
        static let emptyFavoritesTitle = text("catalog.emptyFavorites.title")
        static let emptyFavoritesDescription = text("catalog.emptyFavorites.description")
        static let favoriteAdded = text("catalog.favoriteAdded")
        static let favoriteRemoved = text("catalog.favoriteRemoved")
        static let favoriteStatus = text("catalog.favoriteStatus")
        static let notFavoriteStatus = text("catalog.notFavoriteStatus")
        static let retry = text("catalog.retry")
        static let toggleFavorite = text("catalog.toggleFavorite")
    }

    enum Details {
        static let addFavorite = text("details.addFavorite")
        static let back = text("details.back")
        static let descriptionUnavailable = text("details.descriptionUnavailable")
        static let comics = text("details.comics")
        static let series = text("details.series")
        static let removeFavorite = text("details.removeFavorite")

        static func addFavorite(characterName: String) -> String {
            String(format: text("details.addFavorite.character"), characterName)
        }

        static func removeFavorite(characterName: String) -> String {
            String(format: text("details.removeFavorite.character"), characterName)
        }
    }

    enum Loading {
        static let title = text("loading.title")
    }

    enum Demo {
        static let spiderManDescription = text("demo.spiderMan.description")
        static let blackPantherDescription = text("demo.blackPanther.description")
        static let captainMarvelDescription = text("demo.captainMarvel.description")
        static let ironManDescription = text("demo.ironMan.description")
        static let stormDescription = text("demo.storm.description")
        static let doctorStrangeDescription = text("demo.doctorStrange.description")
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
