import Foundation

struct FavoriteCharacter: Codable, Equatable {
    let id: Int
    let name: String
    let imageURL: URL?
}

protocol FavoritesStoring: AnyObject {
    func all() -> [FavoriteCharacter]
    func contains(id: Int) -> Bool
    func save(_ character: FavoriteCharacter) throws
    func remove(id: Int) throws
}

enum FavoritesStoreError: Error {
    case encoding
    case writing
}

final class FavoritesStore: FavoritesStoring {
    private let fileURL: URL
    private let queue = DispatchQueue(label: "com.marvelchallenge.favorites")

    init(fileManager: FileManager = .default) {
        let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appendingPathComponent("favorites.json")
    }

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func all() -> [FavoriteCharacter] {
        queue.sync { read().sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending } }
    }

    func contains(id: Int) -> Bool {
        queue.sync { read().contains { $0.id == id } }
    }

    func save(_ character: FavoriteCharacter) throws {
        try queue.sync {
            var favorites = read().filter { $0.id != character.id }
            favorites.append(character)
            try write(favorites)
        }
    }

    func remove(id: Int) throws {
        try queue.sync { try write(read().filter { $0.id != id }) }
    }

    private func read() -> [FavoriteCharacter] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder().decode([FavoriteCharacter].self, from: data)) ?? []
    }

    private func write(_ favorites: [FavoriteCharacter]) throws {
        guard let data = try? JSONEncoder().encode(favorites) else { throw FavoritesStoreError.encoding }
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw FavoritesStoreError.writing
        }
    }
}
