//
//  pipelineUITests.swift
//  pipelineUITests
//

import XCTest

final class pipelineUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testDemoFlowOpensDashboard() throws {
        let app = XCUIApplication()
        app.launch()

        let demoButton = app.buttons["Explore with demo data"]

        // The simulator can keep app data between test runs. Clear it through
        // the real Settings flow when the app opens on the dashboard.
        if !demoButton.waitForExistence(timeout: 5) {
            let settingsTab = app.tabBars.buttons["Settings"]
            XCTAssertTrue(
                settingsTab.waitForExistence(timeout: 5),
                "Expected either the connect screen or the dashboard on launch."
            )
            settingsTab.tap()

            let deleteAllButton = app.buttons["settings.deleteAllButton"]
            XCTAssertTrue(deleteAllButton.waitForExistence(timeout: 5))
            deleteAllButton.tap()

            let confirmButton = app.buttons["Delete Everything"]
            XCTAssertTrue(confirmButton.waitForExistence(timeout: 5))
            confirmButton.tap()

            XCTAssertTrue(
                demoButton.waitForExistence(timeout: 10),
                "Delete all local data should return to the connect screen."
            )
        }

        demoButton.tap()

        XCTAssertTrue(
            app.staticTexts["Builds need attention"].waitForExistence(timeout: 10),
            "Demo data should open the dashboard with a failure summary."
        )
        XCTAssertTrue(app.tabBars.buttons["Repositories"].exists)
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)
    }
}
