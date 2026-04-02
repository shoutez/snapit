import AppKit

@main
struct SnapItApp {
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)

        let settings = AppSettings()
        let captureService = ScreenCaptureService(settings: settings)
        let widgetController = FloatingWidgetController(settings: settings, captureService: captureService)
        let menuBarController = MenuBarController(
            settings: settings,
            captureService: captureService,
            widgetController: widgetController
        )

        if settings.showFloatingWidget {
            widgetController.show()
        }

        // Keep references alive for the lifetime of the app
        withExtendedLifetime((widgetController, menuBarController)) {
            app.run()
        }
    }
}
