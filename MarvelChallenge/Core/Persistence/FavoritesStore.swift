import Foundation

struct FavoriteCharacter: Codable, Equatable {
    let id: Int
    let name: String
    let imageURL: URL?
}

protocol FavoritesStoring: AnyObject {
    func all() -> [FavoriteCharacter]
    func contains(id: Int) -> Bool
    func load(completion: @escaping (Result<[FavoriteCharacter], FavoritesStoreError>) -> Void)
    func save(_ character: FavoriteCharacter, completion: @escaping (Result<Void, FavoritesStoreError>) -> Void)
    func remove(id: Int, completion: @escaping (Result<Void, FavoritesStoreError>) -> Void)
}

enum FavoritesStoreError: Error, Equatable {
    case fileNotFound
    case corruptedFile
    case encoding
    case writing
}

final class FavoritesStore: FavoritesStoring {
    private let fileURL: URL
    private let fileManager: FileManager
    private let ioQueue: DispatchQueue
    private let cacheLock = NSLock()
    private var favoritesByID: [Int: FavoriteCharacter] = [:]

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        ioQueue = DispatchQueue(label: "com.marvelchallenge.favorites.io", qos: .utility)
        let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        fileURL = directory.appendingPathComponent("favorites.json")
    }

    init(
        fileURL: URL,
        fileManager: FileManager = .default,
        ioQueue: DispatchQueue = DispatchQueue(label: "com.marvelchallenge.favorites.io", qos: .utility)
    ) {
        self.fileURL = fileURL
        self.fileManager = fileManager
        self.ioQueue = ioQueue
    }

    func all() -> [FavoriteCharacter] {
        cacheLock.withLock {
            sorted(Array(favoritesByID.values))
        }
    }

    func contains(id: Int) -> Bool {
        cacheLock.withLock {
            favoritesByID[id] != nil
        }
    }

    func load(completion: @escaping (Result<[FavoriteCharacter], FavoritesStoreError>) -> Void) {
        ioQueue.async { [self] in
            guard fileManager.fileExists(atPath: fileURL.path) else {
                replaceCache(with: [])
                deliver(.failure(.fileNotFound), to: completion)
                return
            }
            do {
                let data = try Data(contentsOf: fileURL)
                let decoded = try JSONDecoder().decode([FavoriteCharacter].self, from: data)
                replaceCache(with: decoded)
                deliver(.success(sorted(decoded)), to: completion)
            } catch {
                replaceCache(with: [])
                deliver(.failure(.corruptedFile), to: completion)
            }
        }
    }

    func save(_ character: FavoriteCharacter, completion: @escaping (Result<Void, FavoritesStoreError>) -> Void) {
        ioQueue.async { [self] in
            var updated = cachedFavorites()
            updated[character.id] = character
            deliver(persist(updated), to: completion)
        }
    }

    func remove(id: Int, completion: @escaping (Result<Void, FavoritesStoreError>) -> Void) {
        ioQueue.async { [self] in
            var updated = cachedFavorites()
            updated[id] = nil
            deliver(persist(updated), to: completion)
        }
    }

    private func persist(_ updated: [Int: FavoriteCharacter]) -> Result<Void, FavoritesStoreError> {
        let data: Data
        do {
            data = try JSONEncoder().encode(sorted(Array(updated.values)))
        } catch {
            return .failure(.encoding)
        }
        do {
            try fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: fileURL, options: .atomic)
            cacheLock.withLock {
                favoritesByID = updated
            }
            return .success(())
        } catch {
            return .failure(.writing)
        }
    }

    private func sorted(_ values: [FavoriteCharacter]) -> [FavoriteCharacter] {
        values.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func cachedFavorites() -> [Int: FavoriteCharacter] {
        cacheLock.withLock { favoritesByID }
    }

    private func replaceCache(with favorites: [FavoriteCharacter]) {
        cacheLock.withLock {
            favoritesByID = Dictionary(favorites.map { ($0.id, $0) }, uniquingKeysWith: { _, latest in latest })
        }
    }

    private func deliver<Success>(
        _ result: Result<Success, FavoritesStoreError>,
        to completion: @escaping (Result<Success, FavoritesStoreError>) -> Void
    ) {
        DispatchQueue.main.async { completion(result) }
    }
}

private extension NSLock {
    func withLock<T>(_ action: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try action()
    }
}
