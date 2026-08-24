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

    var name: String { character.name }
    var description: String {
        character.description.isEmpty ? Localizable.Details.descriptionUnavailable : character.description
    }
    var imageURL: URL? { character.imageURL }
    var comics: [CharacterReference] { character.comics }
    var series: [CharacterReference] { character.series }
    var isFavorite: Bool { favorites.contains(id: character.id) }

    func toggleFavorite(completion: @escaping (HeroesDetailsFavoriteResult) -> Void) {
        let id = character.id
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
