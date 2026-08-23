import Foundation

final class HeroesDetailsViewModel {
    let character: Character
    private let favorites: FavoritesStoring

    init(character: Character, favorites: FavoritesStoring) {
        self.character = character
        self.favorites = favorites
    }

    var name: String { character.name ?? "" }
    var description: String {
        guard let description = character.resultDescription, !description.isEmpty else { return Localizable.Details.descriptionUnavailable }
        return description
    }
    var imageURL: URL? { character.imageURL }
    var comics: [ComicsItem] { character.comics?.items ?? [] }
    var series: [ComicsItem] { character.series?.items ?? [] }
    var isFavorite: Bool { character.id.map(favorites.contains(id:)) ?? false }

    func toggleFavorite() {
        guard let id = character.id else { return }
        if favorites.contains(id: id) {
            try? favorites.remove(id: id)
        } else {
            try? favorites.save(FavoriteCharacter(id: id, name: name, imageURL: imageURL))
        }
    }
}

extension Character {
    var imageURL: URL? {
        guard let path = thumbnail?.path, let fileExtension = thumbnail?.thumbnailExtension else { return nil }
        return URL(string: path + "." + fileExtension)
    }
}
