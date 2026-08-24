import Foundation

struct CharacterDataDTO: Decodable {
    let data: CharacterResultDTO?
}

struct CharacterResultDTO: Decodable {
    let offset: Int?
    let total: Int?
    let results: [CharacterDTO]?
}

struct CharacterDTO: Decodable {
    let id: Int?
    let name: String?
    let description: String?
    let thumbnail: ThumbnailDTO?
    let comics: ResourceListDTO?
    let series: ResourceListDTO?
}

struct ResourceListDTO: Decodable {
    let items: [ResourceItemDTO]?
}

struct ResourceItemDTO: Decodable {
    let name: String?
}

struct ThumbnailDTO: Decodable {
    let path: String?
    let fileExtension: String?

    enum CodingKeys: String, CodingKey {
        case path
        case fileExtension = "extension"
    }
}

extension CharacterDTO {
    func domainModel() -> Character? {
        guard let id, let name else { return nil }
        let imageURL = thumbnail.flatMap { value -> URL? in
            guard let path = value.path, let fileExtension = value.fileExtension else { return nil }
            return URL(string: path + "." + fileExtension)
        }
        return Character(
            id: id,
            name: name,
            description: description ?? "",
            imageURL: imageURL,
            comics: comics?.items?.compactMap { $0.name.map(CharacterReference.init(name:)) } ?? [],
            series: series?.items?.compactMap { $0.name.map(CharacterReference.init(name:)) } ?? []
        )
    }
}
