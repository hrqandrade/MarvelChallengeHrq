import CommonCrypto
import Foundation

protocol HeroServicing {
    func fetchHeroes(page: Int, completion: @escaping (Result<[Character], HeroServiceError>) -> Void)
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

    func fetchHeroes(page: Int, completion: @escaping (Result<[Character], HeroServiceError>) -> Void) {
        guard !publicKey.isEmpty, !privateKey.isEmpty else {
            completion(.failure(.missingCredentials))
            return
        }
        guard let url = makeURL(page: page) else {
            completion(.failure(.invalidURL))
            return
        }

        session.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(.transport))
                return
            }
            guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode), let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            do {
                let result = try JSONDecoder().decode(CharacterData.self, from: data)
                completion(.success(result.data?.results ?? []))
            } catch {
                completion(.failure(.decoding))
            }
        }.resume()
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
        let data = Data(value.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes { bytes in
            _ = CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
