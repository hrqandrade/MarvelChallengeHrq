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
    private let queue = DispatchQueue(label: "com.marvelchallenge.favorites", qos: .utility)
    private var favorites: [FavoriteCharacter] = []

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        fileURL = directory.appendingPathComponent("favorites.json")
    }

    init(fileURL: URL, fileManager: FileManager = .default) {
        self.fileURL = fileURL
        self.fileManager = fileManager
    }

    func all() -> [FavoriteCharacter] {
        queue.sync { sorted(favorites) }
    }

    func contains(id: Int) -> Bool {
        queue.sync { favorites.contains { $0.id == id } }
    }

    func load(completion: @escaping (Result<[FavoriteCharacter], FavoritesStoreError>) -> Void) {
        queue.async { [self] in
            guard fileManager.fileExists(atPath: fileURL.path) else {
                favorites = []
                deliver(.failure(.fileNotFound), to: completion)
                return
            }
            do {
                let data = try Data(contentsOf: fileURL)
                let decoded = try JSONDecoder().decode([FavoriteCharacter].self, from: data)
                favorites = decoded
                deliver(.success(sorted(decoded)), to: completion)
            } catch {
                favorites = []
                deliver(.failure(.corruptedFile), to: completion)
            }
        }
    }

    func save(_ character: FavoriteCharacter, completion: @escaping (Result<Void, FavoritesStoreError>) -> Void) {
        queue.async { [self] in
            var updated = favorites.filter { $0.id != character.id }
            updated.append(character)
            deliver(persist(updated), to: completion)
        }
    }

    func remove(id: Int, completion: @escaping (Result<Void, FavoritesStoreError>) -> Void) {
        queue.async { [self] in
            deliver(persist(favorites.filter { $0.id != id }), to: completion)
        }
    }

    private func persist(_ updated: [FavoriteCharacter]) -> Result<Void, FavoritesStoreError> {
        let data: Data
        do {
            data = try JSONEncoder().encode(updated)
        } catch {
            return .failure(.encoding)
        }
        do {
            try fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: fileURL, options: .atomic)
            favorites = updated
            return .success(())
        } catch {
            return .failure(.writing)
        }
    }

    private func sorted(_ values: [FavoriteCharacter]) -> [FavoriteCharacter] {
        values.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func deliver<Success>(
        _ result: Result<Success, FavoritesStoreError>,
        to completion: @escaping (Result<Success, FavoritesStoreError>) -> Void
    ) {
        DispatchQueue.main.async { completion(result) }
    }
}
