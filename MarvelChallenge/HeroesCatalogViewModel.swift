import Foundation

enum HeroesCatalogSection {
    case characters
    case favorites
}

enum HeroesCatalogState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case failed(String)
}

final class HeroesCatalogViewModel {
    private let service: HeroServicing
    private let favorites: FavoritesStoring
    private(set) var characters: [Character] = []
    private(set) var favoriteCharacters: [FavoriteCharacter] = []
    private(set) var section: HeroesCatalogSection = .characters
    private var page = 0
    private var isLoading = false

    var onStateChange: ((HeroesCatalogState) -> Void)?

    init(service: HeroServicing, favorites: FavoritesStoring) {
        self.service = service
        self.favorites = favorites
    }

    var itemCount: Int {
        section == .characters ? characters.count : favoriteCharacters.count
    }

    func loadInitial() {
        guard characters.isEmpty else { return }
        page = 0
        load(page: page)
    }

    func reload() {
        guard !isLoading else { return }
        characters = []
        page = 0
        load(page: page)
    }

    func loadNextPageIfNeeded(index: Int) {
        guard section == .characters, index == characters.count - 1 else { return }
        load(page: page + 1)
    }

    func selectSection(_ section: HeroesCatalogSection) {
        self.section = section
        if section == .favorites { reloadFavorites() }
        publishCurrentState()
    }

    func reloadFavorites() {
        favoriteCharacters = favorites.all()
    }

    func character(at index: Int) -> Character? {
        guard section == .characters, characters.indices.contains(index) else { return nil }
        return characters[index]
    }

    func favorite(at index: Int) -> FavoriteCharacter? {
        guard section == .favorites, favoriteCharacters.indices.contains(index) else { return nil }
        return favoriteCharacters[index]
    }

    func isFavorite(_ character: Character) -> Bool {
        character.id.map(favorites.contains(id:)) ?? false
    }

    func toggleFavorite(_ character: Character) {
        guard let id = character.id else { return }
        if favorites.contains(id: id) {
            try? favorites.remove(id: id)
        } else {
            try? favorites.save(FavoriteCharacter(id: id, name: character.name ?? "", imageURL: character.imageURL))
        }
        reloadFavorites()
        publishCurrentState()
    }

    func removeFavorite(at index: Int) {
        guard let favorite = favorite(at: index) else { return }
        try? favorites.remove(id: favorite.id)
        reloadFavorites()
        publishCurrentState()
    }

    private func load(page requestedPage: Int) {
        guard !isLoading else { return }
        isLoading = true
        onStateChange?(.loading)
        service.fetchHeroes(page: requestedPage) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let newCharacters):
                    self.page = requestedPage
                    self.characters += newCharacters
                    self.publishCurrentState()
                case .failure:
                    self.onStateChange?(.failed("Não foi possível carregar os personagens."))
                }
            }
        }
    }

    private func publishCurrentState() {
        onStateChange?(itemCount == 0 ? .empty : .loaded)
    }
}
