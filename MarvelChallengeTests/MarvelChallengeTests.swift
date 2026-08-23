import XCTest
import UIKit
@testable import MarvelChallenge

final class MarvelChallengeTests: XCTestCase {
    func testCatalogPublishesEmptyStateWhenServiceReturnsNoCharacters() {
        let service = HeroServiceStub(result: .success(HeroesPage(characters: [], offset: 0, total: 0)))
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

    func testReloadCancelsPreviousRequestAndIgnoresItsResponse() throws {
        let service = HeroServiceSpy()
        let viewModel = HeroesCatalogViewModel(
            service: service,
            favorites: FavoritesStore(fileURL: temporaryFileURL())
        )
        var states: [HeroesCatalogState] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.loadInitial()
        let initialToken = try XCTUnwrap(service.requests.first?.token)
        viewModel.reload()

        XCTAssertTrue(initialToken.isCancelled)
        XCTAssertEqual(service.requests.map(\.page), [0, 0])
        XCTAssertEqual(states, [.initialLoading, .refreshing])

        service.completeRequest(at: 0, with: .success(HeroesPage(
            characters: [try makeCharacter(id: 1, name: "Old")],
            offset: 0,
            total: 1
        )))
        XCTAssertTrue(viewModel.characters.isEmpty)

        service.completeRequest(at: 1, with: .success(HeroesPage(
            characters: [try makeCharacter(id: 2, name: "Current")],
            offset: 0,
            total: 1
        )))
        XCTAssertEqual(viewModel.characters.first?.id, 2)
        XCTAssertEqual(states.last, .loaded)
    }

    func testCatalogDoesNotRequestAnotherPageAfterReachingTotal() throws {
        let service = HeroServiceSpy()
        let viewModel = HeroesCatalogViewModel(
            service: service,
            favorites: FavoritesStore(fileURL: temporaryFileURL())
        )

        viewModel.loadInitial()
        service.completeRequest(at: 0, with: .success(HeroesPage(
            characters: [try makeCharacter()],
            offset: 0,
            total: 1
        )))
        viewModel.loadNextPageIfNeeded(index: 0)

        XCTAssertEqual(service.requests.count, 1)
    }

    func testCatalogAppendsNextPageAndPublishesPaginationState() throws {
        let service = HeroServiceSpy()
        let viewModel = HeroesCatalogViewModel(
            service: service,
            favorites: FavoritesStore(fileURL: temporaryFileURL())
        )
        var states: [HeroesCatalogState] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.loadInitial()
        service.completeRequest(at: 0, with: .success(HeroesPage(
            characters: [try makeCharacter(id: 1, name: "First")],
            offset: 0,
            total: 2
        )))
        viewModel.loadNextPageIfNeeded(index: 0)

        XCTAssertEqual(service.requests.map(\.page), [0, 1])
        XCTAssertEqual(states.last, .loadingNextPage)

        service.completeRequest(at: 1, with: .success(HeroesPage(
            characters: [try makeCharacter(id: 2, name: "Second")],
            offset: 1,
            total: 2
        )))
        XCTAssertEqual(viewModel.characters.compactMap(\.id), [1, 2])
        XCTAssertEqual(states.last, .loaded)
    }

    func testCatalogDoesNotDuplicatePaginationRequestWhileOneIsRunning() throws {
        let service = HeroServiceSpy()
        let viewModel = HeroesCatalogViewModel(
            service: service,
            favorites: FavoritesStore(fileURL: temporaryFileURL())
        )

        viewModel.loadInitial()
        service.completeRequest(at: 0, with: .success(HeroesPage(
            characters: [try makeCharacter()],
            offset: 0,
            total: 2
        )))
        viewModel.loadNextPageIfNeeded(index: 0)
        viewModel.loadNextPageIfNeeded(index: 0)

        XCTAssertEqual(service.requests.map(\.page), [0, 1])
    }

    func testCatalogPublishesFailureAndAllowsRetry() {
        let service = HeroServiceSpy()
        let viewModel = HeroesCatalogViewModel(
            service: service,
            favorites: FavoritesStore(fileURL: temporaryFileURL())
        )
        var states: [HeroesCatalogState] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.loadInitial()
        service.completeRequest(at: 0, with: .failure(.transport))
        viewModel.reload()

        XCTAssertEqual(states, [.initialLoading, .failed(HeroServiceError.transport.message), .refreshing])
        XCTAssertEqual(service.requests.map(\.page), [0, 0])
    }

    func testCatalogPublishesBackgroundCompletionOnMainThread() throws {
        let expectation = expectation(description: "main thread state")
        let service = BackgroundHeroServiceStub(page: HeroesPage(
            characters: [try makeCharacter()],
            offset: 0,
            total: 1
        ))
        let viewModel = HeroesCatalogViewModel(
            service: service,
            favorites: FavoritesStore(fileURL: temporaryFileURL())
        )
        viewModel.onStateChange = { state in
            guard state == .loaded else { return }
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }

        viewModel.loadInitial()

        wait(for: [expectation], timeout: 1)
    }

    func testViewModelCancelsRequestWhenReleased() throws {
        let service = HeroServiceSpy()
        var viewModel: HeroesCatalogViewModel? = HeroesCatalogViewModel(
            service: service,
            favorites: FavoritesStore(fileURL: temporaryFileURL())
        )

        viewModel?.loadInitial()
        let token = try XCTUnwrap(service.requests.first?.token)
        viewModel = nil

        XCTAssertTrue(token.isCancelled)
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
                    heroService: HeroServiceStub(result: .success(HeroesPage(characters: [], offset: 0, total: 0))),
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

    private func makeCharacter(id: Int = 1, name: String = "Spider-Man") throws -> Character {
        let json = #"{"id":\#(id),"name":"\#(name)","description":""}"#
        let data = try XCTUnwrap(json.data(using: .utf8))
        return try JSONDecoder().decode(Character.self, from: data)
    }
}

private final class HeroServiceStub: HeroServicing {
    let result: Result<HeroesPage, HeroServiceError>

    init(result: Result<HeroesPage, HeroServiceError>) {
        self.result = result
    }

    func fetchHeroes(page: Int, completion: @escaping (Result<HeroesPage, HeroServiceError>) -> Void) -> RequestCancellable? {
        completion(result)
        return nil
    }
}

private final class HeroServiceSpy: HeroServicing {
    struct Request {
        let page: Int
        let token: RequestTokenSpy
        let completion: (Result<HeroesPage, HeroServiceError>) -> Void
    }

    private(set) var requests: [Request] = []

    func fetchHeroes(page: Int, completion: @escaping (Result<HeroesPage, HeroServiceError>) -> Void) -> RequestCancellable? {
        let token = RequestTokenSpy()
        requests.append(Request(page: page, token: token, completion: completion))
        return token
    }

    func completeRequest(at index: Int, with result: Result<HeroesPage, HeroServiceError>) {
        requests[index].completion(result)
    }
}

private final class RequestTokenSpy: RequestCancellable {
    private(set) var isCancelled = false

    func cancel() {
        isCancelled = true
    }
}

private final class BackgroundHeroServiceStub: HeroServicing {
    let page: HeroesPage

    init(page: HeroesPage) {
        self.page = page
    }

    func fetchHeroes(page: Int, completion: @escaping (Result<HeroesPage, HeroServiceError>) -> Void) -> RequestCancellable? {
        DispatchQueue.global().async { [self] in
            completion(.success(self.page))
        }
        return nil
    }
}
