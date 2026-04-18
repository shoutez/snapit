import XCTest
@testable import SnapItCore

final class ScreenCaptureServiceTests: XCTestCase {
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

    func testCaptureWindowArgsWithShadow() {
        let settings = AppSettings(defaults: suite)
        settings.includeWindowShadow = true
        let service = ScreenCaptureService(settings: settings)

        XCTAssertEqual(service.captureWindowArgs(), ["-w"])
    }

    func testCaptureWindowArgsWithoutShadow() {
        let settings = AppSettings(defaults: suite)
        settings.includeWindowShadow = false
        let service = ScreenCaptureService(settings: settings)

        XCTAssertEqual(service.captureWindowArgs(), ["-w", "-o"])
    }

    func testCaptureDesktopArgs() {
        let settings = AppSettings(defaults: suite)
        let service = ScreenCaptureService(settings: settings)

        XCTAssertEqual(service.captureDesktopArgs(), [])
    }

    func testCaptureAreaArgs() {
        let settings = AppSettings(defaults: suite)
        let service = ScreenCaptureService(settings: settings)

        XCTAssertEqual(service.captureAreaArgs(), ["-s"])
    }

    func testScreenshotPathFormat() {
        let settings = AppSettings(defaults: suite)
        settings.saveLocation = "/tmp/test-screenshots"
        let service = ScreenCaptureService(settings: settings)

        let path = service.screenshotPath()

        XCTAssertTrue(path.hasPrefix("/tmp/test-screenshots/SnapIt-"))
        XCTAssertTrue(path.hasSuffix(".png"))
    }

    func testScreenshotPathUsesSettingsLocation() {
        let settings = AppSettings(defaults: suite)
        let service = ScreenCaptureService(settings: settings)

        settings.saveLocation = "/tmp/location-a"
        let pathA = service.screenshotPath()
        XCTAssertTrue(pathA.hasPrefix("/tmp/location-a/"))

        settings.saveLocation = "/tmp/location-b"
        let pathB = service.screenshotPath()
        XCTAssertTrue(pathB.hasPrefix("/tmp/location-b/"))
    }
}
