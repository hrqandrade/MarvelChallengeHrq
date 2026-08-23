import UIKit

protocol Coordinator: AnyObject {
    func start()
}

final class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let storyboard: UIStoryboard
    private let dependencies: AppDependencies

    init(window: UIWindow, storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil), dependencies: AppDependencies = .live) {
        self.window = window
        self.storyboard = storyboard
        self.dependencies = dependencies
    }

    func start() {
        guard let catalog = window.rootViewController as? HeroesCatalogViewController else { return }
        catalog.viewModel = HeroesCatalogViewModel(
            service: dependencies.heroService,
            favorites: dependencies.favoritesStore
        )
        catalog.onSelectCharacter = { [weak self] character in
            self?.showDetails(for: character)
        }
    }

    private func showDetails(for character: Character) {
        guard let details = storyboard.instantiateViewController(withIdentifier: "HeroesDetailsViewController") as? HeroesDetailsViewController else { return }
        details.viewModel = HeroesDetailsViewModel(
            character: character,
            favorites: dependencies.favoritesStore
        )
        window.rootViewController?.present(details, animated: true)
    }
}

struct AppDependencies {
    let heroService: HeroServicing
    let favoritesStore: FavoritesStoring

    static let live = AppDependencies(
        heroService: HeroService(),
        favoritesStore: FavoritesStore()
    )
}
