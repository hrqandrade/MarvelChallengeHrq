@testable import MarvelChallenge
import MarvelDesignSystem
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

    func testFavoriteButtonsIdentifyTheirCharacter() {
        let character = Character(
            id: 1,
            name: "Spider-Man",
            description: "",
            imageURL: nil,
            comics: [],
            series: []
        )
        let gridCell = HeroesCollectionViewCell()
        let listCell = HeroesCollectionListCell()

        gridCell.configure(character: character, isFavorite: false, onFavorite: {})
        listCell.configure(character: character, isFavorite: true, onFavorite: {})

        XCTAssertEqual(
            gridCell.descendantButtons.first?.accessibilityLabel,
            Localizable.Details.addFavorite(characterName: character.name)
        )
        XCTAssertEqual(
            listCell.descendantButtons.first?.accessibilityLabel,
            Localizable.Details.removeFavorite(characterName: character.name)
        )
    }

    func testCharacterCellsExposeSelectionAndFavoriteActions() {
        let character = Character(
            id: 1,
            name: "Spider-Man",
            description: "",
            imageURL: nil,
            comics: [],
            series: []
        )
        var selectionCount = 0
        let cell = HeroesCollectionViewCell()

        cell.configure(
            character: character,
            isFavorite: false,
            onFavorite: {},
            onSelect: { selectionCount += 1 }
        )

        XCTAssertTrue(cell.isAccessibilityElement)
        XCTAssertEqual(cell.accessibilityLabel, character.name)
        XCTAssertEqual(cell.accessibilityValue, Localizable.Catalog.notFavoriteStatus)
        XCTAssertTrue(cell.accessibilityTraits.contains(.button))
        XCTAssertTrue(cell.accessibilityActivate())
        XCTAssertEqual(selectionCount, 1)
        XCTAssertEqual(
            cell.accessibilityCustomActions?.first?.name,
            Localizable.Catalog.toggleFavorite
        )
    }

    func testDetailsIsModalAndFavoriteActionIdentifiesCharacter() {
        let view = HeroesDetailsView()

        view.render(.init(
            id: 1,
            name: "Spider-Man",
            description: "Description",
            imageURL: nil,
            isFavorite: true,
            hasComics: false,
            hasSeries: false
        ))

        XCTAssertTrue(view.accessibilityViewIsModal)
        XCTAssertTrue(view.descendantButtons.contains {
            $0.accessibilityLabel == Localizable.Details.removeFavorite(characterName: "Spider-Man")
        })
    }

    func testSemanticColorsMeetTheirMinimumContrast() {
        for style in [UIUserInterfaceStyle.light, .dark] {
            let traits = UITraitCollection(userInterfaceStyle: style)
            XCTAssertGreaterThanOrEqual(
                contrastRatio(
                    foreground: DesignSystem.Color.textPrimary,
                    background: DesignSystem.Color.backgroundPrimary,
                    traits: traits
                ),
                4.5
            )
            XCTAssertGreaterThanOrEqual(
                contrastRatio(
                    foreground: DesignSystem.Color.textSecondary,
                    background: DesignSystem.Color.backgroundPrimary,
                    traits: traits
                ),
                4.5
            )
        }

        XCTAssertGreaterThanOrEqual(
            contrastRatio(
                foreground: DesignSystem.Color.onAccent,
                background: DesignSystem.Color.accent,
                traits: UITraitCollection(userInterfaceStyle: .light)
            ),
            3
        )
    }

    func testSupportedOrientationsMatchTheLayoutPolicy() throws {
        let testBundle = Bundle(for: PresentationTests.self)
        let appBundleURL = testBundle.bundleURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let infoData = try Data(contentsOf: appBundleURL.appendingPathComponent("Info.plist"))
        let infoDictionary = try XCTUnwrap(
            PropertyListSerialization.propertyList(from: infoData, format: nil) as? [String: Any]
        )
        let phoneOrientations = try XCTUnwrap(
            infoDictionary["UISupportedInterfaceOrientations"] as? [String]
        )
        let padOrientations = try XCTUnwrap(
            infoDictionary["UISupportedInterfaceOrientations~ipad"] as? [String]
        )

        XCTAssertEqual(phoneOrientations, ["UIInterfaceOrientationPortrait"])
        XCTAssertEqual(Set(padOrientations), Set([
            "UIInterfaceOrientationPortrait",
            "UIInterfaceOrientationPortraitUpsideDown",
            "UIInterfaceOrientationLandscapeLeft",
            "UIInterfaceOrientationLandscapeRight",
        ]))
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

    private func contrastRatio(
        foreground: UIColor,
        background: UIColor,
        traits: UITraitCollection
    ) -> CGFloat {
        let foregroundLuminance = relativeLuminance(of: foreground.resolvedColor(with: traits))
        let backgroundLuminance = relativeLuminance(of: background.resolvedColor(with: traits))
        let lighter = max(foregroundLuminance, backgroundLuminance)
        let darker = min(foregroundLuminance, backgroundLuminance)
        return (lighter + 0.05) / (darker + 0.05)
    }

    private func relativeLuminance(of color: UIColor) -> CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        XCTAssertTrue(color.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
        let components = [red, green, blue].map { component in
            component <= 0.04045
                ? component / 12.92
                : pow((component + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * components[0] + 0.7152 * components[1] + 0.0722 * components[2]
    }
}

private extension UIView {
    var descendantButtons: [UIButton] {
        subviews.flatMap { view -> [UIButton] in
            let button = view as? UIButton
            return [button].compactMap { $0 } + view.descendantButtons
        }
    }
}
