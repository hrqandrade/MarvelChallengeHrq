import CryptoKit
import Foundation

protocol HeroServicing {
    @discardableResult
    func fetchHeroes(page: Int, completion: @escaping (Result<HeroesPage, HeroServiceError>) -> Void) -> RequestCancellable?
}

protocol RequestCancellable: AnyObject {
    func cancel()
}

extension URLSessionDataTask: RequestCancellable {}

struct HeroesPage {
    let characters: [Character]
    let offset: Int
    let total: Int?

    var hasNextPage: Bool {
        guard !characters.isEmpty else { return false }
        guard let total else { return true }
        return offset + characters.count < total
    }
}

enum HeroServiceError: Error, Equatable {
    case missingCredentials
    case invalidURL
    case transport
    case invalidResponse
    case decoding
}

final class HeroService: HeroServicing {
    private let session: URLSession
    private let baseURL: URL
    private let publicKey: String
    private let privateKey: String

    init(
        session: URLSession = .shared,
        baseURL: URL = URL(string: "https://gateway.marvel.com:443")!,
        publicKey: String = ProcessInfo.processInfo.environment["MARVEL_PUBLIC_KEY"] ?? "",
        privateKey: String = ProcessInfo.processInfo.environment["MARVEL_PRIVATE_KEY"] ?? ""
    ) {
        self.session = session
        self.baseURL = baseURL
        self.publicKey = publicKey
        self.privateKey = privateKey
    }

    @discardableResult
    func fetchHeroes(page: Int, completion: @escaping (Result<HeroesPage, HeroServiceError>) -> Void) -> RequestCancellable? {
        guard !publicKey.isEmpty, !privateKey.isEmpty else {
            completion(.failure(.missingCredentials))
            return nil
        }
        guard let url = makeURL(page: page) else {
            completion(.failure(.invalidURL))
            return nil
        }

        let task = session.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(.transport))
                return
            }
            guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode), let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            do {
                let response = try JSONDecoder().decode(CharacterDataDTO.self, from: data)
                guard let result = response.data else {
                    completion(.failure(.invalidResponse))
                    return
                }
                completion(.success(HeroesPage(
                    characters: result.results?.compactMap { $0.domainModel() } ?? [],
                    offset: result.offset ?? page * 20,
                    total: result.total
                )))
            } catch {
                completion(.failure(.decoding))
            }
        }
        task.resume()
        return task
    }

    private func makeURL(page: Int) -> URL? {
        let limit = 20
        let timestamp = String(Date().timeIntervalSince1970)
        let hash = md5(timestamp + privateKey + publicKey)
        var components = URLComponents(
            url: baseURL.appendingPathComponent("v1/public/characters"),
            resolvingAgainstBaseURL: true
        )
        components?.queryItems = [
            URLQueryItem(name: "offset", value: String(page * limit)),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "orderBy", value: "name"),
            URLQueryItem(name: "ts", value: timestamp),
            URLQueryItem(name: "hash", value: hash),
            URLQueryItem(name: "apikey", value: publicKey)
        ]
        return components?.url
    }

    private func md5(_ value: String) -> String {
        Insecure.MD5.hash(data: Data(value.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
