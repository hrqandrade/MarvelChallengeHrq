import Foundation

enum HeroesDetailsFavoriteResult {
    case success(Bool)
    case failure(String)
}

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

    func toggleFavorite(completion: @escaping (HeroesDetailsFavoriteResult) -> Void) {
        guard let id = character.id else { return }
        let mutationCompletion: (Result<Void, FavoritesStoreError>) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success: completion(.success(self.isFavorite))
                case .failure: completion(.failure(Localizable.Error.favoritesWriting))
                }
            }
        }
        if favorites.contains(id: id) {
            favorites.remove(id: id, completion: mutationCompletion)
        } else {
            favorites.save(FavoriteCharacter(id: id, name: name, imageURL: imageURL), completion: mutationCompletion)
        }
    }
}

extension Character {
    var imageURL: URL? {
        guard let path = thumbnail?.path, let fileExtension = thumbnail?.thumbnailExtension else { return nil }
        return URL(string: path + "." + fileExtension)
    }
}
