import UIKit

protocol Coordinator: AnyObject { func start() }

protocol ScreenBuilding {
    func makeCatalog(onSelect: @escaping (Character) -> Void) -> HeroesCatalogViewController
    func makeDetails(for character: Character, onClose: @escaping () -> Void) -> HeroesDetailsViewController
}

struct AppScreenFactory: ScreenBuilding {
    let dependencies: AppDependencies
    func makeCatalog(onSelect: @escaping (Character) -> Void) -> HeroesCatalogViewController {
        let controller = HeroesCatalogViewController(viewModel: HeroesCatalogViewModel(service: dependencies.heroService, favorites: dependencies.favoritesStore))
        controller.onSelectCharacter = onSelect
        return controller
    }

    func makeDetails(for character: Character, onClose: @escaping () -> Void) -> HeroesDetailsViewController {
        let controller = HeroesDetailsViewController(viewModel: HeroesDetailsViewModel(character: character, favorites: dependencies.favoritesStore))
        controller.onClose = onClose
        return controller
    }
}

final class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let screenFactory: ScreenBuilding
    init(window: UIWindow, screenFactory: ScreenBuilding = AppScreenFactory(dependencies: .live)) {
        self.window = window
        self.screenFactory = screenFactory
    }

    func start() {
        let catalog = screenFactory.makeCatalog { [weak self] character in self?.showDetails(for: character) }
        window.rootViewController = catalog
    }

    private func showDetails(for character: Character) {
        let details = screenFactory.makeDetails(for: character) { [weak self] in self?.window.rootViewController?.dismiss(animated: true) }
        details.modalPresentationStyle = .fullScreen
        window.rootViewController?.present(details, animated: true)
    }
}

struct AppDependencies {
    let heroService: HeroServicing
    let favoritesStore: FavoritesStoring
    static let live = AppDependencies(heroService: HeroService(), favoritesStore: FavoritesStore())
}
