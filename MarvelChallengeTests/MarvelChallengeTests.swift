import XCTest
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

    private func temporaryFileURL() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".json")
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
