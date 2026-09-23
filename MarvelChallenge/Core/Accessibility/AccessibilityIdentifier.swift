enum AccessibilityIdentifier {
    enum Catalog {
        static let collection = "catalog.collection"
        static let layoutButton = "catalog.layoutButton"
        static let sectionControl = "catalog.sectionControl"

        static func character(id: Int) -> String {
            "catalog.character.\(id)"
        }
    }

    enum Details {
        static let backButton = "details.backButton"
        static let favoriteButton = "details.favoriteButton"
    }
}
