//
//  SnapReceiptUITestsLaunchTests.swift
//  SnapReceiptUITests
//
//  Created by Codex on 23.5.2026.
//

import XCTest

final class SnapReceiptUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchEnvironment["SNAPRECEIPT_DEMO_SCENARIO"] = "capture"
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Capture Demo Launch"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
