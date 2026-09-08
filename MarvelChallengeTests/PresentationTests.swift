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

        let errorView = view.collectionView.backgroundView as? MarvelErrorStateView
        let elements = errorView?.accessibilityElements as? [UIView]
        XCTAssertNotNil(errorView)
        XCTAssertFalse(errorView?.isAccessibilityElement ?? true)
        XCTAssertEqual(elements?.first?.accessibilityLabel, Localizable.Error.transport)
        XCTAssertEqual((elements?.last as? UIButton)?.currentTitle, Localizable.Catalog.retry)
    }

    func testFeedbackBannerExposesItsCurrentMessage() {
        let banner = MarvelFeedbackBanner()

        banner.show(message: Localizable.Catalog.favoriteAdded, isError: false)

        XCTAssertFalse(banner.isHidden)
        XCTAssertTrue(banner.isAccessibilityElement)
        XCTAssertEqual(banner.accessibilityLabel, Localizable.Catalog.favoriteAdded)
    }

    func testLoadingViewIsExposedAsAStatusUpdate() {
        let loadingView = MarvelLoadingView()

        XCTAssertTrue(loadingView.isAccessibilityElement)
        XCTAssertEqual(loadingView.accessibilityLabel, Localizable.Loading.title)
        XCTAssertTrue(loadingView.accessibilityTraits.contains(.updatesFrequently))
    }

    func testAccessibilityContentSizeUsesListLayout() {
        let viewModel = HeroesCatalogViewModel(
            service: DebugHeroService(),
            favorites: DebugFavoritesStore()
        )
        let controller = HeroesCatalogViewController(viewModel: viewModel)
        let parent = UIViewController()
        parent.addChild(controller)
        parent.setOverrideTraitCollection(
            UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge),
            forChild: controller
        )

        controller.loadViewIfNeeded()

        XCTAssertFalse(controller.isGridLayout)
        XCTAssertTrue(controller.heroesCollectionView.collectionViewLayout is ListFlowLayout)
    }

    func testFavoriteAccessibilityLabelsIncludeCharacterName() {
        XCTAssertTrue(Localizable.Details.addFavorite(characterName: "Storm").contains("Storm"))
        XCTAssertTrue(Localizable.Details.removeFavorite(characterName: "Storm").contains("Storm"))
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
