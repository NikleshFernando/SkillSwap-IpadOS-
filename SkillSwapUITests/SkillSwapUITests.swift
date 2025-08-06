//
//  SkillSwapUITests.swift
//  SkillSwapUITests
//
//  Created by Niklesh Fernando on 2025-04-19.
//
//
//  SkillSwapUITests.swift
//  SkillSwapUITests
//
//  Created by Niklesh Fernando on 2025-04-19.
//

import XCTest

final class SkillSwapUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // Home tab check
    func testNavigateToHomeTab() throws {
        let homeTab = app.staticTexts["Home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 5))
        homeTab.tap()

        let welcomeText = app.staticTexts["Welcome to"]
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 5))
    }
    func testOfferCardAppearsOnHomeScreen() throws {
            let welcomeText = app.staticTexts["Welcome to"]
            XCTAssertTrue(welcomeText.waitForExistence(timeout: 5), "Home screen welcome text missing.")

            let offerExampleText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'want to learn'")).firstMatch
            XCTAssertTrue(offerExampleText.waitForExistence(timeout: 5), "No offer card found.")

            let applyButton = app.buttons["Apply"]
            if applyButton.exists {
                applyButton.tap()

                let toast = app.staticTexts["✅ Successfully Applied!"]
                XCTAssertTrue(toast.waitForExistence(timeout: 3), "Success toast not shown after applying.")
            }
        }
}
