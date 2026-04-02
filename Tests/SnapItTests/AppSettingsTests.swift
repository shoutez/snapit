import XCTest
@testable import SnapItCore

final class AppSettingsTests: XCTestCase {
    private var suiteName: String!
    private var suite: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "com.snapit.test.\(UUID().uuidString)"
        suite = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        suite = nil
        suiteName = nil
        super.tearDown()
    }

    func testDefaultValues() {
        let settings = AppSettings(defaults: suite)

        XCTAssertTrue(settings.showFloatingWidget)
        XCTAssertTrue(settings.saveLocation.hasSuffix("/Desktop"))
        XCTAssertTrue(settings.includeWindowShadow)
        XCTAssertEqual(settings.widgetOpacity, 0.85)
        XCTAssertEqual(settings.widgetPositionX, 100.0)
        XCTAssertEqual(settings.widgetPositionY, 100.0)
    }

    func testPersistence() {
        let settings1 = AppSettings(defaults: suite)
        settings1.saveLocation = "/tmp/test-screenshots"

        let settings2 = AppSettings(defaults: suite)
        XCTAssertEqual(settings2.saveLocation, "/tmp/test-screenshots")
    }

    func testWidgetPositionGet() {
        let settings = AppSettings(defaults: suite)
        settings.widgetPositionX = 200.0
        settings.widgetPositionY = 300.0

        XCTAssertEqual(settings.widgetPosition, CGPoint(x: 200.0, y: 300.0))
    }

    func testWidgetPositionSet() {
        let settings = AppSettings(defaults: suite)
        settings.widgetPosition = CGPoint(x: 50.0, y: 75.0)

        XCTAssertEqual(settings.widgetPositionX, 50.0)
        XCTAssertEqual(settings.widgetPositionY, 75.0)
    }

    func testDidSetWritesToDefaults() {
        let settings = AppSettings(defaults: suite)
        settings.widgetOpacity = 0.5

        XCTAssertEqual(suite.double(forKey: "widgetOpacity"), 0.5)
    }

    func testPreExistingValues() {
        suite.set(false, forKey: "showFloatingWidget")
        suite.set("/tmp/custom", forKey: "saveLocation")
        suite.set(false, forKey: "includeWindowShadow")
        suite.set(0.6, forKey: "widgetOpacity")
        suite.set(250.0, forKey: "widgetPositionX")
        suite.set(350.0, forKey: "widgetPositionY")

        let settings = AppSettings(defaults: suite)

        XCTAssertFalse(settings.showFloatingWidget)
        XCTAssertEqual(settings.saveLocation, "/tmp/custom")
        XCTAssertFalse(settings.includeWindowShadow)
        XCTAssertEqual(settings.widgetOpacity, 0.6)
        XCTAssertEqual(settings.widgetPositionX, 250.0)
        XCTAssertEqual(settings.widgetPositionY, 350.0)
    }
}
