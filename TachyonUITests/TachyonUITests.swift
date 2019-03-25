import XCTest

/**
 To optimize test speed, this test does not terminate and restart the application between tests.
 Instead, it backgrounds and foregrounds the application, which should reset any state via
 logic living in `TachyonSampleApp.ViewController`.
 */
class TachyonUITests: XCTestCase {

    private static var application: XCUIApplication = XCUIApplication()

    override static func setUp() {
        super.setUp()
        application = XCUIApplication()

        // Here, we speed up animations instead of disabling them entirely. This helps us avoid missing any
        // animation-dependent issues.
        // See https://stackoverflow.com/questions/37282350/how-to-speed-up-ui-test-cases-in-xcode
        UIApplication.shared.keyWindow?.layer.speed = 100

        XCUIDevice.shared.orientation = .portrait
    }

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        TachyonUITests.application.activate()
    }

    override func tearDown() {
        super.setUp()

        XCUIDevice().press(.home)
    }

    func testBasicLayout() {
        let app = TachyonUITests.application

        // We default the collection view offset to 8 AM, so 9 AM should exist somewhere.
        XCTAssertTrue(app.staticTexts["9 AM"].exists)
    }

    func testCreateEvent() {
        let app = TachyonUITests.application

        // Tap in the middle of the screen to create a cell
        app.children(matching: .window)
            .element(boundBy: 0)
            .children(matching: .other)
            .element
            .children(matching: .other)
            .element(boundBy: 1)
            .children(matching: .collectionView)
            .element
            .tap()

        XCTAssertTrue(app.staticTexts["Available"].exists)
        XCTAssertTrue(app.collectionViews.cells.buttons["ic cancel 16dp"].exists)

        // Tap the close button
        app.collectionViews.cells.buttons["ic cancel 16dp"].tap()
        XCTAssertFalse(app.staticTexts["Available"].exists)
    }

    func testSelectDay() {
        let app = TachyonUITests.application
        let collectionViewsQuery = XCUIApplication().collectionViews

        // Tap on Wednesday
        collectionViewsQuery.cells.otherElements.containing(.staticText, identifier: "W").element.tap()
        XCTAssertTrue(app.staticTexts["Eat breakfast cookies"].waitForExistence(timeout: 1))

        // Tap on Monday
        collectionViewsQuery.cells.otherElements.containing(.staticText, identifier: "M").element.tap()
        XCTAssertTrue(app.staticTexts["Meeting"].waitForExistence(timeout: 1))

        // Create an event cell
        app.children(matching: .window)
            .element(boundBy: 0)
            .children(matching: .other)
            .element
            .children(matching: .other)
            .element(boundBy: 1)
            .children(matching: .collectionView)
            .element
            .tap()
        XCTAssertTrue(app.staticTexts["Available"].waitForExistence(timeout: 1))

        // Switch back to Wednesday
        collectionViewsQuery.cells.otherElements.containing(.staticText, identifier: "W").element.tap()
        XCTAssertTrue(app.staticTexts["Eat breakfast cookies"].waitForExistence(timeout: 1))
        XCTAssertFalse(app.staticTexts["Available"].waitForExistence(timeout: 1))
    }

}
