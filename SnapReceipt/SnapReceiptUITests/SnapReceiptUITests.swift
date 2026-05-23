//
//  SnapReceiptUITests.swift
//  SnapReceiptUITests
//
//  Created by Codex on 23.5.2026.
//

import XCTest

final class SnapReceiptUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testReviewDemoScenarioShowsPrepopulatedReviewFlow() throws {
        let app = launchApp(demoScenario: "review")

        XCTAssertTrue(app.navigationBars["Review Receipt"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Save Preview"].exists)
        XCTAssertTrue(app.staticTexts["Cafe Esplanad"].exists)
        XCTAssertTrue(app.staticTexts["Recognized Text"].exists)
        XCTAssertTrue(app.buttons["Save Receipt"].exists)
    }

    @MainActor
    func testReceiptsDemoScenarioShowsSeededReceiptHistory() throws {
        let app = launchApp(demoScenario: "receipts")

        XCTAssertTrue(app.navigationBars["Receipts"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Saved Receipts"].exists)
        XCTAssertTrue(app.staticTexts["Cafe Esplanad"].exists)
        XCTAssertTrue(app.staticTexts["Library Status"].exists)
    }

    @MainActor
    func testSettingsDemoScenarioShowsLocalPreferences() throws {
        let app = launchApp(demoScenario: "settings")

        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Receipt Defaults"].exists)
        XCTAssertTrue(app.staticTexts["Saved Image Quality"].exists)
        XCTAssertTrue(app.staticTexts["Local Storage"].exists)
        XCTAssertTrue(app.staticTexts["About SnapReceipt"].exists)
    }

    @MainActor
    private func launchApp(demoScenario: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["SNAPRECEIPT_DEMO_SCENARIO"] = demoScenario
        app.launch()
        return app
    }
}
