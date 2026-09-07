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

    func testCatalogErrorStateKeepsFailureInTheScreen() {
        let view = HeroesCatalogView()

        view.renderError(message: Localizable.Error.transport)

        XCTAssertTrue(view.collectionView.backgroundView is MarvelErrorStateView)
        XCTAssertEqual(view.collectionView.backgroundView?.accessibilityLabel, Localizable.Error.transport)
    }

    func testFeedbackBannerExposesItsCurrentMessage() {
        let banner = MarvelFeedbackBanner()

        banner.show(message: Localizable.Catalog.favoriteAdded, isError: false)

        XCTAssertFalse(banner.isHidden)
        XCTAssertEqual(banner.accessibilityLabel, Localizable.Catalog.favoriteAdded)
    }

    func testDemoDescriptionsUseLocalizedCopy() {
        XCTAssertEqual(DebugSampleData.characters.first?.description, Localizable.Demo.spiderManDescription)
    }

    func testDemoCharactersDoNotDependOnRemoteImages() {
        XCTAssertTrue(DebugSampleData.characters.allSatisfy { $0.imageURL == nil })
        XCTAssertTrue(DebugSampleData.favorites.allSatisfy { $0.imageURL == nil })
    }

    func testLocalArtworkIsStableAndCachedForACharacter() {
        let firstImage = HeroArtworkFactory.image(id: 1, name: "Spider-Man")
        let secondImage = HeroArtworkFactory.image(id: 1, name: "Spider-Man")

        XCTAssertTrue(firstImage === secondImage)
        XCTAssertEqual(firstImage.size, CGSize(width: 600, height: 600))
    }
}
