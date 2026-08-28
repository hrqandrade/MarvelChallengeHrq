#if DEBUG
    import Foundation

    final class DebugHeroService: HeroServicing {
        private let characters: [Character]

        init(characters: [Character] = DebugSampleData.characters) {
            self.characters = characters
        }

        @discardableResult
        func fetchHeroes(
            page: Int,
            completion: @escaping (Result<HeroesPage, HeroServiceError>) -> Void
        ) -> RequestCancellable? {
            let result = page == 0 ? characters : []
            completion(.success(HeroesPage(
                characters: result,
                offset: page * characters.count,
                total: characters.count
            )))
            return nil
        }
    }

    final class DebugFavoritesStore: FavoritesStoring {
        private let lock = NSLock()
        private var favoritesByID: [Int: FavoriteCharacter]

        init(favorites: [FavoriteCharacter] = DebugSampleData.favorites) {
            favoritesByID = Dictionary(uniqueKeysWithValues: favorites.map { ($0.id, $0) })
        }

        func all() -> [FavoriteCharacter] {
            withLock {
                favoritesByID.values.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            }
        }

        func contains(id: Int) -> Bool {
            withLock { favoritesByID[id] != nil }
        }

        func load(completion: @escaping (Result<[FavoriteCharacter], FavoritesStoreError>) -> Void) {
            completion(.success(all()))
        }

        func save(_ character: FavoriteCharacter, completion: @escaping (Result<Void, FavoritesStoreError>) -> Void) {
            withLock { favoritesByID[character.id] = character }
            completion(.success(()))
        }

        func remove(id: Int, completion: @escaping (Result<Void, FavoritesStoreError>) -> Void) {
            withLock { favoritesByID[id] = nil }
            completion(.success(()))
        }

        private func withLock<Value>(_ action: () -> Value) -> Value {
            lock.lock()
            defer { lock.unlock() }
            return action()
        }
    }

    enum DebugSampleData {
        static let characters = [
            Character(
                id: 1,
                name: "Spider-Man",
                description: "Friendly neighborhood hero balancing everyday life with extraordinary responsibility.",
                imageURL: URL(string: "https://i.annihil.us/u/prod/marvel/i/mg/3/50/526548a343e4b.jpg"),
                comics: references("Amazing Fantasy", "The Amazing Spider-Man", "Secret Wars"),
                series: references("Spider-Verse", "Ultimate Spider-Man")
            ),
            Character(
                id: 2,
                name: "Black Panther",
                description: "King of Wakanda, protector of his people and bearer of the Black Panther legacy.",
                imageURL: URL(string: "https://i.annihil.us/u/prod/marvel/i/mg/9/03/537ba26276348.jpg"),
                comics: references("Black Panther", "Avengers"),
                series: references("World of Wakanda", "Agents of Wakanda")
            ),
            Character(
                id: 3,
                name: "Captain Marvel",
                description: "A powerful cosmic hero who protects Earth and the universe from intergalactic threats.",
                imageURL: URL(string: "https://i.annihil.us/u/prod/marvel/i/mg/6/30/5190c90d5f2a3.jpg"),
                comics: references("Captain Marvel", "The Ultimates"),
                series: references("Secret Invasion", "Civil War II")
            ),
            Character(
                id: 4,
                name: "Iron Man",
                description: "Inventor Tony Stark uses his technology and courage to defend a better future.",
                imageURL: URL(string: "https://i.annihil.us/u/prod/marvel/i/mg/9/c0/527bb7b37ff55.jpg"),
                comics: references("Tales of Suspense", "Invincible Iron Man"),
                series: references("Armor Wars", "Avengers")
            ),
            Character(
                id: 5,
                name: "Storm",
                description: "Mutant leader with the ability to command weather and inspire heroes around the world.",
                imageURL: URL(string: "https://i.annihil.us/u/prod/marvel/i/mg/6/40/526963dad214d.jpg"),
                comics: references("Uncanny X-Men", "X-Men Red"),
                series: references("X-Men", "Extraordinary X-Men")
            ),
            Character(
                id: 6,
                name: "Doctor Strange",
                description: "Master of the mystic arts and guardian against supernatural threats.",
                imageURL: URL(string: "https://i.annihil.us/u/prod/marvel/i/mg/5/f0/5261a8648b4f0.jpg"),
                comics: references("Strange Tales", "Doctor Strange"),
                series: references("Defenders", "New Avengers")
            ),
        ]

        static let favorites = characters.prefix(2).map {
            FavoriteCharacter(id: $0.id, name: $0.name, imageURL: $0.imageURL)
        }

        private static func references(_ names: String...) -> [CharacterReference] {
            names.map(CharacterReference.init(name:))
        }
    }
#endif
