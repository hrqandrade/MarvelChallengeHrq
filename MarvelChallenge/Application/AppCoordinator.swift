import UIKit

protocol Coordinator: AnyObject { func start() }

protocol ScreenBuilding {
    func makeCatalog(onSelect: @escaping (Character) -> Void) -> HeroesCatalogViewController
    func makeDetails(for character: Character, onClose: @escaping () -> Void) -> HeroesDetailsViewController
}

protocol ModalPresenting {
    func present(_ viewController: UIViewController, from presentingViewController: UIViewController?, animated: Bool)
    func dismissPresented(from presentingViewController: UIViewController?, animated: Bool)
}

struct UIKitModalPresenter: ModalPresenting {
    func present(_ viewController: UIViewController, from presentingViewController: UIViewController?, animated: Bool) {
        presentingViewController?.present(viewController, animated: animated)
    }

    func dismissPresented(from presentingViewController: UIViewController?, animated: Bool) {
        presentingViewController?.dismiss(animated: animated)
    }
}

struct AppScreenFactory: ScreenBuilding {
    let dependencies: AppDependencies
    func makeCatalog(onSelect: @escaping (Character) -> Void) -> HeroesCatalogViewController {
        let controller = HeroesCatalogViewController(viewModel: HeroesCatalogViewModel(
            service: dependencies.heroService,
            favorites: dependencies.favoritesStore
        ))
        controller.onSelectCharacter = onSelect
        return controller
    }

    func makeDetails(for character: Character, onClose: @escaping () -> Void) -> HeroesDetailsViewController {
        let controller = HeroesDetailsViewController(viewModel: HeroesDetailsViewModel(
            character: character,
            favorites: dependencies.favoritesStore
        ))
        controller.onClose = onClose
        return controller
    }
}

final class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let screenFactory: ScreenBuilding
    private let modalPresenter: ModalPresenting

    init(
        window: UIWindow,
        screenFactory: ScreenBuilding = AppScreenFactory(dependencies: .resolve()),
        modalPresenter: ModalPresenting = UIKitModalPresenter()
    ) {
        self.window = window
        self.screenFactory = screenFactory
        self.modalPresenter = modalPresenter
    }

    func start() {
        let catalog = screenFactory.makeCatalog { [weak self] character in self?.showDetails(for: character) }
        window.rootViewController = catalog
    }

    private func showDetails(for character: Character) {
        let details = screenFactory
            .makeDetails(for: character) { [weak self] in
                guard let self else { return }
                self.modalPresenter.dismissPresented(from: self.window.rootViewController, animated: true)
            }
        details.modalPresentationStyle = .fullScreen
        modalPresenter.present(details, from: window.rootViewController, animated: true)
    }
}

struct AppDependencies {
    let heroService: HeroServicing
    let favoritesStore: FavoritesStoring
    static let live = AppDependencies(heroService: HeroService(), favoritesStore: FavoritesStore())

    static func resolve(arguments: [String] = ProcessInfo.processInfo.arguments) -> AppDependencies {
        #if DEBUG
            if !arguments.contains("-useLiveData") {
                return AppDependencies(heroService: DebugHeroService(), favoritesStore: DebugFavoritesStore())
            }
        #endif
        return .live
    }
}
