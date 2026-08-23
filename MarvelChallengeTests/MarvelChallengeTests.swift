import XCTest
import UIKit
@testable import MarvelChallenge

final class MarvelChallengeTests: XCTestCase {
    func testCatalogPublishesEmptyStateWhenServiceReturnsNoCharacters() {
        let service = HeroServiceStub(result: .success([]))
        let store = FavoritesStore(fileURL: temporaryFileURL())
        let viewModel = HeroesCatalogViewModel(service: service, favorites: store)
        let expectation = expectation(description: "empty state")

        viewModel.onStateChange = { state in
            if state == .empty { expectation.fulfill() }
        }
        viewModel.loadInitial()

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(viewModel.itemCount, 0)
    }

    func testFavoritesStoreSavesAndRemovesCharacter() throws {
        let store = FavoritesStore(fileURL: temporaryFileURL())
        let favorite = FavoriteCharacter(id: 1, name: "Spider-Man", imageURL: nil)

        try store.save(favorite)
        XCTAssertTrue(store.contains(id: 1))
        XCTAssertEqual(store.all(), [favorite])

        try store.remove(id: 1)
        XCTAssertFalse(store.contains(id: 1))
    }

    func testGridLayoutCalculatesTwoColumnsWithoutRecursion() {
        let layout = GridFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 640), collectionViewLayout: layout)

        layout.prepare()

        XCTAssertEqual(layout.itemSize, CGSize(width: 159.5, height: 190))
        XCTAssertTrue(collectionView.collectionViewLayout === layout)
    }

    func testListLayoutUsesAvailableCollectionWidth() {
        let layout = ListFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 640), collectionViewLayout: layout)

        layout.prepare()

        XCTAssertEqual(layout.itemSize, CGSize(width: 320, height: 95))
        XCTAssertTrue(collectionView.collectionViewLayout === layout)
    }

    func testCoordinatorAndCatalogAreReleasedAfterFlowTeardown() throws {
        weak var weakCoordinator: AppCoordinator?
        weak var weakCatalog: HeroesCatalogViewController?

        try autoreleasepool {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let catalog = try XCTUnwrap(storyboard.instantiateInitialViewController() as? HeroesCatalogViewController)
            let window = UIWindow()
            window.rootViewController = catalog
            var coordinator: AppCoordinator? = AppCoordinator(
                window: window,
                storyboard: storyboard,
                dependencies: AppDependencies(
                    heroService: HeroServiceStub(result: .success([])),
                    favoritesStore: FavoritesStore(fileURL: temporaryFileURL())
                )
            )

            coordinator?.start()
            catalog.loadViewIfNeeded()
            weakCoordinator = coordinator
            weakCatalog = catalog
            window.rootViewController = nil
            coordinator = nil
        }

        XCTAssertNil(weakCoordinator)
        XCTAssertNil(weakCatalog)
    }

    func testDetailsControllerAndViewModelAreReleasedAfterDismissal() throws {
        weak var weakController: HeroesDetailsViewController?
        weak var weakViewModel: HeroesDetailsViewModel?

        try autoreleasepool {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            var controller: HeroesDetailsViewController? = try XCTUnwrap(
                storyboard.instantiateViewController(withIdentifier: "HeroesDetailsViewController") as? HeroesDetailsViewController
            )
            var viewModel: HeroesDetailsViewModel? = HeroesDetailsViewModel(
                character: try makeCharacter(),
                favorites: FavoritesStore(fileURL: temporaryFileURL())
            )
            controller?.viewModel = try XCTUnwrap(viewModel)
            controller?.loadViewIfNeeded()

            weakController = controller
            weakViewModel = viewModel
            controller = nil
            viewModel = nil
        }

        XCTAssertNil(weakController)
        XCTAssertNil(weakViewModel)
    }

    private func temporaryFileURL() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".json")
    }

    private func makeCharacter() throws -> Character {
        let data = try XCTUnwrap(#"{"id":1,"name":"Spider-Man","description":""}"#.data(using: .utf8))
        return try JSONDecoder().decode(Character.self, from: data)
    }
}

private final class HeroServiceStub: HeroServicing {
    let result: Result<[Character], HeroServiceError>

    init(result: Result<[Character], HeroServiceError>) {
        self.result = result
    }

    func fetchHeroes(page: Int, completion: @escaping (Result<[Character], HeroServiceError>) -> Void) {
        completion(result)
    }
}
