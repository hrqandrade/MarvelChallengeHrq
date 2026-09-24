import XCTest

final class MarvelChallengeUITests: XCTestCase {
    private enum Identifier {
        static let layoutButton = "catalog.layoutButton"
        static let sectionControl = "catalog.sectionControl"
        static let backButton = "details.backButton"
        static let favoriteButton = "details.favoriteButton"

        static func character(id: Int) -> String {
            "catalog.character.\(id)"
        }
    }

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testDemoCatalogChangesLayoutAndOpensDetails() {
        launch(language: "pt-BR", locale: "pt_BR")

        let spiderMan = character(id: 1)
        XCTAssertTrue(spiderMan.waitForExistence(timeout: 5))

        let initialFrame = spiderMan.frame
        app.buttons[Identifier.layoutButton].tap()
        XCTAssertTrue(waitUntil { spiderMan.frame != initialFrame })

        spiderMan.tap()
        XCTAssertTrue(app.buttons[Identifier.backButton].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Spider-Man"].exists)
    }

    func testFavoriteAddedFromDetailsAppearsInFavorites() {
        launch(language: "pt-BR", locale: "pt_BR")

        let captainMarvel = character(id: 3)
        XCTAssertTrue(captainMarvel.waitForExistence(timeout: 5))
        captainMarvel.tap()

        let favoriteButton = app.buttons[Identifier.favoriteButton]
        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 2))
        favoriteButton.tap()
        app.buttons[Identifier.backButton].tap()

        app.segmentedControls[Identifier.sectionControl].buttons["Favoritos"].tap()
        XCTAssertTrue(character(id: 3).waitForExistence(timeout: 2))
    }

    func testPortugueseLocalizationIsPresentedWithoutRawKeys() {
        launch(language: "pt-BR", locale: "pt_BR")

        assertCatalogTexts(characters: "Personagens", favorites: "Favoritos")
    }

    func testEnglishLocalizationIsPresentedWithoutRawKeys() {
        launch(language: "en", locale: "en_US")

        assertCatalogTexts(characters: "Characters", favorites: "Favorites")
    }

    private func launch(language: String, locale: String) {
        app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", locale]
        app.launch()
    }

    private func assertCatalogTexts(characters: String, favorites: String) {
        let sectionControl = app.segmentedControls[Identifier.sectionControl]
        XCTAssertTrue(sectionControl.waitForExistence(timeout: 5))
        XCTAssertTrue(sectionControl.buttons[characters].exists)
        XCTAssertTrue(sectionControl.buttons[favorites].exists)

        let rawLocalizationKeys = app.descendants(matching: .any).matching(
            NSPredicate(format: "label BEGINSWITH 'catalog.' OR label BEGINSWITH 'details.'")
        )
        XCTAssertFalse(rawLocalizationKeys.firstMatch.exists)
    }

    private func character(id: Int) -> XCUIElement {
        app.descendants(matching: .any)[Identifier.character(id: id)]
    }

    private func waitUntil(
        timeout: TimeInterval = 2,
        condition: @escaping () -> Bool
    ) -> Bool {
        let predicate = NSPredicate { _, _ in condition() }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }
}
