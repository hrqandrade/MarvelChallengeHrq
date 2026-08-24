import Foundation

struct Character: Equatable {
    let id: Int
    let name: String
    let description: String
    let imageURL: URL?
    let comics: [CharacterReference]
    let series: [CharacterReference]
}

struct CharacterReference: Equatable {
    let name: String
}
