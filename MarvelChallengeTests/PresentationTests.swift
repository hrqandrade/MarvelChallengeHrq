@testable import MarvelChallenge
import XCTest

final class PresentationTests: XCTestCase {
    func testCatalogEmptyStatesExposeLocalizedMessages() {
        let view = HeroesCatalogView()

        view.renderEmpty(section: .characters)
        XCTAssertEqual(
            view.collectionView.backgroundView?.accessibilityLabel,
            "\(Localizable.Catalog.emptyCharactersTitle). \(Localizable.Catalog.emptyCharactersDescription)"
        )

        view.renderEmpty(section: .favorites)
        XCTAssertEqual(
            view.collectionView.backgroundView?.accessibilityLabel,
            "\(Localizable.Catalog.emptyFavoritesTitle). \(Localizable.Catalog.emptyFavoritesDescription)"
        )
    }

    func testDemoDescriptionsUseLocalizedCopy() {
        XCTAssertEqual(DebugSampleData.characters.first?.description, Localizable.Demo.spiderManDescription)
    }
}
