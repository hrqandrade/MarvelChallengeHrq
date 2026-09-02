import Foundation
@testable import MarvelChallenge
import XCTest

final class FavoritesStoreTests: XCTestCase {
    func testSavesAndRemovesCharacter() {
        let persistence = InMemoryFavoritesPersistence()
        let store = FavoritesStore(persistence: persistence)
        let favorite = FavoriteCharacter(id: 1, name: "Spider-Man", imageURL: nil)

        assertSuccess { store.save(favorite, completion: $0) }
        XCTAssertTrue(store.contains(id: favorite.id))
        XCTAssertEqual(store.all(), [favorite])

        assertSuccess { store.remove(id: favorite.id, completion: $0) }
        XCTAssertFalse(store.contains(id: favorite.id))
    }

    func testDifferentiatesMissingAndCorruptedData() {
        let persistence = InMemoryFavoritesPersistence()
        let store = FavoritesStore(persistence: persistence)

        assertLoad(store, expectedError: .fileNotFound)

        persistence.data = Data("invalid".utf8)
        assertLoad(store, expectedError: .corruptedFile)
    }

    func testWritingFailureDoesNotChangeCache() {
        let persistence = InMemoryFavoritesPersistence()
        persistence.writeError = PersistenceError.expected
        let store = FavoritesStore(persistence: persistence)
        let expectation = expectation(description: "writing failure")

        store.save(FavoriteCharacter(id: 1, name: "Spider-Man", imageURL: nil)) { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected writing failure")
            }
            XCTAssertEqual(error, .writing)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: Timeout.operation)
        XCTAssertFalse(store.contains(id: 1))
    }

    func testSerializesConcurrentMutationsAndWritesValidData() throws {
        let persistence = InMemoryFavoritesPersistence()
        let store = FavoritesStore(persistence: persistence)
        let expectations = (0 ..< 20).map { expectation(description: "save \($0)") }

        for index in 0 ..< expectations.count {
            DispatchQueue.global().async {
                store.save(FavoriteCharacter(id: index, name: "Hero \(index)", imageURL: nil)) { result in
                    if case let .failure(error) = result {
                        XCTFail("Unexpected error: \(error)")
                    }
                    expectations[index].fulfill()
                }
            }
        }

        wait(for: expectations, timeout: Timeout.stress)
        XCTAssertEqual(store.all().count, expectations.count)
        XCTAssertEqual(
            try JSONDecoder().decode([FavoriteCharacter].self, from: XCTUnwrap(persistence.data)).count,
            expectations.count
        )
    }

    func testLoadsSortedValuesAndUpdatesExistingCharacter() throws {
        let initialValues = [
            FavoriteCharacter(id: 2, name: "Thor", imageURL: nil),
            FavoriteCharacter(id: 1, name: "Captain America", imageURL: nil),
        ]
        let persistence = try InMemoryFavoritesPersistence(data: JSONEncoder().encode(initialValues))
        let store = FavoritesStore(persistence: persistence)
        let loadExpectation = expectation(description: "load sorted favorites")

        store.load { result in
            XCTAssertEqual(try? result.get().map(\.name), ["Captain America", "Thor"])
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: Timeout.operation)

        assertSuccess {
            store.save(FavoriteCharacter(id: 2, name: "Mighty Thor", imageURL: nil), completion: $0)
        }
        XCTAssertEqual(store.all().map(\.name), ["Captain America", "Mighty Thor"])
    }

    func testCacheQueriesDoNotWaitForIOQueue() {
        let ioQueue = DispatchQueue(label: "favorites.blocked.io")
        ioQueue.suspend()
        let store = FavoritesStore(persistence: InMemoryFavoritesPersistence(), ioQueue: ioQueue)
        let expectation = expectation(description: "cache query")

        store.save(FavoriteCharacter(id: 1, name: "Spider-Man", imageURL: nil)) { _ in }
        DispatchQueue.global().async {
            XCTAssertFalse(store.contains(id: 1))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: Timeout.operation)
        ioQueue.resume()
    }

    func testFilePersistenceRoundTrip() throws {
        let fileURL = temporaryFileURL()
        let persistence = FileFavoritesPersistence(fileURL: fileURL)
        let data = Data("favorites".utf8)

        XCTAssertNil(try persistence.read())
        try persistence.write(data)

        XCTAssertEqual(try persistence.read(), data)
    }

    func testFilePersistenceReportsInvalidDestination() {
        let persistence = FileFavoritesPersistence(fileURL: URL(fileURLWithPath: "/dev/null/favorites.json"))

        XCTAssertThrowsError(try persistence.write(Data()))
    }

    private func assertSuccess(
        file: StaticString = #filePath,
        line: UInt = #line,
        operation: (@escaping (Result<Void, FavoritesStoreError>) -> Void) -> Void
    ) {
        let expectation = expectation(description: "successful operation")
        operation { result in
            if case let .failure(error) = result {
                XCTFail("Unexpected error: \(error)", file: file, line: line)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: Timeout.operation)
    }

    private func assertLoad(_ store: FavoritesStore, expectedError: FavoritesStoreError) {
        let expectation = expectation(description: "load failure")
        store.load { result in
            guard case let .failure(error) = result else {
                return XCTFail("Expected load failure")
            }
            XCTAssertEqual(error, expectedError)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: Timeout.operation)
    }

    private func temporaryFileURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("favorites.json")
    }
}

private final class InMemoryFavoritesPersistence: FavoritesPersistence {
    var data: Data?
    var writeError: Error?

    init(data: Data? = nil) {
        self.data = data
    }

    func read() throws -> Data? {
        data
    }

    func write(_ data: Data) throws {
        if let writeError {
            throw writeError
        }
        self.data = data
    }
}

private enum PersistenceError: Error {
    case expected
}

private enum Timeout {
    static let operation: TimeInterval = 1
    static let stress: TimeInterval = 2
}
