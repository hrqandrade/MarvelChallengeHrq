import Foundation

enum HeroesCatalogSection {
    case characters
    case favorites
}

enum HeroesCatalogState: Equatable {
    case idle
    case initialLoading
    case refreshing
    case loadingNextPage
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
    private var hasMorePages = true
    private var currentRequest: RequestCancellable?
    private var currentRequestID: UUID?

    var onStateChange: ((HeroesCatalogState) -> Void)?

    init(service: HeroServicing, favorites: FavoritesStoring) {
        self.service = service
        self.favorites = favorites
    }

    deinit {
        currentRequest?.cancel()
    }

    var itemCount: Int {
        section == .characters ? characters.count : favoriteCharacters.count
    }

    func loadInitial() {
        precondition(Thread.isMainThread)
        guard characters.isEmpty, currentRequestID == nil else { return }
        page = 0
        hasMorePages = true
        load(page: page, mode: .initial)
    }

    func reload() {
        precondition(Thread.isMainThread)
        cancelCurrentRequest()
        page = 0
        hasMorePages = true
        load(page: page, mode: .refresh)
    }

    func loadNextPageIfNeeded(index: Int) {
        precondition(Thread.isMainThread)
        guard section == .characters,
              currentRequestID == nil,
              hasMorePages,
              !characters.isEmpty,
              index == characters.count - 1 else { return }
        load(page: page + 1, mode: .nextPage)
    }

    func selectSection(_ section: HeroesCatalogSection) {
        self.section = section
        if section == .favorites {
            reloadFavorites()
        }
        publishCurrentState()
    }

    func reloadFavorites() {
        favorites.load { [weak self] result in
            self?.performOnMain { [weak self] in
                guard let self else { return }
                switch result {
                case let .success(favorites):
                    self.favoriteCharacters = favorites
                    if self.section == .favorites {
                        self.publishCurrentState()
                    }
                case .failure(.fileNotFound):
                    self.favoriteCharacters = []
                    if self.section == .favorites {
                        self.publishCurrentState()
                    }
                case .failure:
                    self.onStateChange?(.failed(Localizable.Error.favoritesReading))
                }
            }
        }
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
        favorites.contains(id: character.id)
    }

    func toggleFavorite(_ character: Character) {
        let id = character.id
        let completion: (Result<Void, FavoritesStoreError>) -> Void = { [weak self] result in
            self?.handleFavoriteMutation(result)
        }
        if favorites.contains(id: id) {
            favorites.remove(id: id, completion: completion)
        } else {
            favorites.save(
                FavoriteCharacter(id: id, name: character.name, imageURL: character.imageURL),
                completion: completion
            )
        }
    }

    func removeFavorite(at index: Int) {
        guard let favorite = favorite(at: index) else { return }
        favorites.remove(id: favorite.id) { [weak self] result in
            self?.handleFavoriteMutation(result)
        }
    }

    private func load(page requestedPage: Int, mode: LoadMode) {
        guard currentRequestID == nil else { return }
        let requestID = UUID()
        currentRequestID = requestID
        onStateChange?(mode.state)
        let request = service.fetchHeroes(page: requestedPage) { [weak self] result in
            self?.performOnMain { [weak self] in
                self?.handle(result, page: requestedPage, mode: mode, requestID: requestID)
            }
        }
        if currentRequestID == requestID {
            currentRequest = request
        } else {
            request?.cancel()
        }
    }

    private func handle(
        _ result: Result<HeroesPage, HeroServiceError>,
        page requestedPage: Int,
        mode: LoadMode,
        requestID: UUID
    ) {
        guard currentRequestID == requestID else { return }
        currentRequest = nil
        currentRequestID = nil

        switch result {
        case let .success(response):
            page = requestedPage
            hasMorePages = response.hasNextPage
            switch mode {
            case .initial, .refresh:
                characters = response.characters
            case .nextPage:
                characters += response.characters
            }
            publishCurrentState()
        case let .failure(error):
            onStateChange?(.failed(message(for: error)))
        }
    }

    private func cancelCurrentRequest() {
        currentRequest?.cancel()
        currentRequest = nil
        currentRequestID = nil
    }

    private func performOnMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }

    private func handleFavoriteMutation(_ result: Result<Void, FavoritesStoreError>) {
        performOnMain { [weak self] in
            guard let self else { return }
            switch result {
            case .success:
                self.favoriteCharacters = self.favorites.all()
                self.publishCurrentState()
            case .failure:
                self.onStateChange?(.failed(Localizable.Error.favoritesWriting))
            }
        }
    }

    private func publishCurrentState() {
        onStateChange?(itemCount == 0 ? .empty : .loaded)
    }

    private func message(for error: HeroServiceError) -> String {
        switch error {
        case .missingCredentials: return Localizable.Error.missingCredentials
        case .invalidURL: return Localizable.Error.invalidURL
        case .transport: return Localizable.Error.transport
        case .invalidResponse: return Localizable.Error.invalidResponse
        case .decoding: return Localizable.Error.decoding
        }
    }
}

private extension HeroesCatalogViewModel {
    enum LoadMode {
        case initial
        case refresh
        case nextPage

        var state: HeroesCatalogState {
            switch self {
            case .initial: return .initialLoading
            case .refresh: return .refreshing
            case .nextPage: return .loadingNextPage
            }
        }
    }
}
