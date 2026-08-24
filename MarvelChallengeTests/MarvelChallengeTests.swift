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

        XCTAssertEqual(states, [.initialLoading, .failed(Localizable.Error.transport), .refreshing])
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
        let saveExpectation = expectation(description: "save")
        let removeExpectation = expectation(description: "remove")

        store.save(favorite) { result in
            if case .failure(let error) = result { XCTFail("Unexpected error: \(error)") }
            saveExpectation.fulfill()
        }
        wait(for: [saveExpectation], timeout: 1)
        XCTAssertTrue(store.contains(id: 1))
        XCTAssertEqual(store.all(), [favorite])

        store.remove(id: 1) { result in
            if case .failure(let error) = result { XCTFail("Unexpected error: \(error)") }
            removeExpectation.fulfill()
        }
        wait(for: [removeExpectation], timeout: 1)
        XCTAssertFalse(store.contains(id: 1))
    }

    func testFavoritesStoreDifferentiatesMissingAndCorruptedFiles() throws {
        let fileURL = temporaryFileURL()
        let missingStore = FavoritesStore(fileURL: fileURL)
        let missingExpectation = expectation(description: "missing file")

        missingStore.load { result in
            XCTAssertEqual(result.failure, .fileNotFound)
            missingExpectation.fulfill()
        }
        wait(for: [missingExpectation], timeout: 1)

        try Data("invalid".utf8).write(to: fileURL)
        let corruptedStore = FavoritesStore(fileURL: fileURL)
        let corruptedExpectation = expectation(description: "corrupted file")
        corruptedStore.load { result in
            XCTAssertEqual(result.failure, .corruptedFile)
            corruptedExpectation.fulfill()
        }
        wait(for: [corruptedExpectation], timeout: 1)
    }

    func testFavoritesStoreReportsWritingFailureWithoutChangingCache() {
        let store = FavoritesStore(fileURL: URL(fileURLWithPath: "/dev/null/favorites.json"))
        let expectation = expectation(description: "writing failure")

        store.save(FavoriteCharacter(id: 1, name: "Spider-Man", imageURL: nil)) { result in
            XCTAssertEqual(result.failure, .writing)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(store.contains(id: 1))
    }

    func testFavoritesStoreSerializesConcurrentMutationsAndWritesValidFile() {
        let fileURL = temporaryFileURL()
        let store = FavoritesStore(fileURL: fileURL)
        let expectations = (0..<20).map { index in
            expectation(description: "save \(index)")
        }

        for index in 0..<20 {
            DispatchQueue.global().async {
                store.save(FavoriteCharacter(id: index, name: "Hero \(index)", imageURL: nil)) { result in
                    if case .failure(let error) = result { XCTFail("Unexpected error: \(error)") }
                    expectations[index].fulfill()
                }
            }
        }

        wait(for: expectations, timeout: 3)
        XCTAssertEqual(store.all().count, 20)
        XCTAssertNoThrow(try JSONDecoder().decode([FavoriteCharacter].self, from: Data(contentsOf: fileURL)))
    }

    func testFavoritesCacheQueriesDoNotWaitForIOQueue() {
        let ioQueue = DispatchQueue(label: "favorites.blocked.io")
        ioQueue.suspend()
        let store = FavoritesStore(fileURL: temporaryFileURL(), ioQueue: ioQueue)
        let expectation = expectation(description: "cache query")

        store.save(FavoriteCharacter(id: 1, name: "Spider-Man", imageURL: nil)) { _ in }
        DispatchQueue.global().async {
            XCTAssertFalse(store.contains(id: 1))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        ioQueue.resume()
    }

    func testCatalogPublishesFavoriteWritingFailure() throws {
        let viewModel = HeroesCatalogViewModel(
            service: HeroServiceStub(result: .success(HeroesPage(characters: [], offset: 0, total: 0))),
            favorites: FailingFavoritesStoreStub()
        )
        let expectation = expectation(description: "favorite writing failure")
        viewModel.onStateChange = { state in
            guard state == .failed(Localizable.Error.favoritesWriting) else { return }
            expectation.fulfill()
        }

        viewModel.toggleFavorite(try makeCharacter())

        wait(for: [expectation], timeout: 1)
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

        autoreleasepool {
            let window = UIWindow()
            var coordinator: AppCoordinator? = AppCoordinator(
                window: window,
                screenFactory: AppScreenFactory(dependencies: AppDependencies(
                    heroService: HeroServiceStub(result: .success(HeroesPage(characters: [], offset: 0, total: 0))),
                    favoritesStore: FavoritesStore(fileURL: temporaryFileURL())
                ))
            )

            coordinator?.start()
            let catalog = window.rootViewController as? HeroesCatalogViewController
            catalog?.loadViewIfNeeded()
            weakCoordinator = coordinator
            weakCatalog = catalog
            window.isHidden = true
            window.rootViewController = nil
            coordinator = nil
        }

        XCTAssertNil(weakCoordinator)
        XCTAssertNil(weakCatalog)
    }

    func testCoordinatorBuildsDetailsWhenCatalogSelectsCharacter() throws {
        let window = UIWindow()
        let factory = ScreenFactorySpy()
        let coordinator = AppCoordinator(window: window, screenFactory: factory)
        let character = try makeCharacter()

        coordinator.start()
        factory.onSelect?(character)

        XCTAssertTrue(window.rootViewController === factory.catalog)
        XCTAssertEqual(factory.detailsCharacter, character)
    }

    func testDetailsControllerAndViewModelAreReleasedAfterDismissal() throws {
        weak var weakController: HeroesDetailsViewController?
        weak var weakViewModel: HeroesDetailsViewModel?

        try autoreleasepool {
            var viewModel: HeroesDetailsViewModel? = HeroesDetailsViewModel(
                character: try makeCharacter(),
                favorites: FavoritesStore(fileURL: temporaryFileURL())
            )
            var controller: HeroesDetailsViewController? = HeroesDetailsViewController(viewModel: try XCTUnwrap(viewModel))
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
        Character(id: id, name: name, description: "", imageURL: nil, comics: [], series: [])
    }
}

private extension Result {
    var failure: Failure? {
        if case .failure(let error) = self { return error }
        return nil
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

private final class FailingFavoritesStoreStub: FavoritesStoring {
    func all() -> [FavoriteCharacter] { [] }
    func contains(id: Int) -> Bool { false }

    func load(completion: @escaping (Result<[FavoriteCharacter], FavoritesStoreError>) -> Void) {
        completion(.success([]))
    }

    func save(_ character: FavoriteCharacter, completion: @escaping (Result<Void, FavoritesStoreError>) -> Void) {
        completion(.failure(.writing))
    }

    func remove(id: Int, completion: @escaping (Result<Void, FavoritesStoreError>) -> Void) {
        completion(.failure(.writing))
    }
}

private final class ScreenFactorySpy: ScreenBuilding {
    let catalog = HeroesCatalogViewController(viewModel: HeroesCatalogViewModel(
        service: HeroServiceStub(result: .success(HeroesPage(characters: [], offset: 0, total: 0))),
        favorites: FavoritesStore(fileURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))
    ))
    private(set) var onSelect: ((Character) -> Void)?
    private(set) var detailsCharacter: Character?

    func makeCatalog(onSelect: @escaping (Character) -> Void) -> HeroesCatalogViewController {
        self.onSelect = onSelect
        return catalog
    }

    func makeDetails(for character: Character, onClose: @escaping () -> Void) -> HeroesDetailsViewController {
        detailsCharacter = character
        return HeroesDetailsViewController(viewModel: HeroesDetailsViewModel(
            character: character,
            favorites: FavoritesStore(fileURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))
        ))
    }
}
