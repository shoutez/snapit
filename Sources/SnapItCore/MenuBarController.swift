import AppKit

public final class MenuBarController: NSObject {
    private let statusItem: NSStatusItem
    private let settings: AppSettings
    private let captureService: ScreenCaptureService
    private weak var widgetController: FloatingWidgetController?
    private var settingsWindowController: SettingsWindowController?

    public init(settings: AppSettings, captureService: ScreenCaptureService, widgetController: FloatingWidgetController) {
        self.settings = settings
        self.captureService = captureService
        self.widgetController = widgetController
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        super.init()

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: "SnapIt")
        }

        buildMenu()
    }

    private func buildMenu() {
        let menu = NSMenu()

        let windowItem = NSMenuItem(title: "Capture Window", action: #selector(captureWindow), keyEquivalent: "")
        windowItem.target = self
        windowItem.image = NSImage(systemSymbolName: "macwindow", accessibilityDescription: nil)
        menu.addItem(windowItem)

        let areaItem = NSMenuItem(title: "Capture Area", action: #selector(captureArea), keyEquivalent: "")
        areaItem.target = self
        areaItem.image = NSImage(systemSymbolName: "crop", accessibilityDescription: nil)
        menu.addItem(areaItem)

        let desktopItem = NSMenuItem(title: "Capture Desktop", action: #selector(captureDesktop), keyEquivalent: "")
        desktopItem.target = self
        desktopItem.image = NSImage(systemSymbolName: "desktopcomputer", accessibilityDescription: nil)
        menu.addItem(desktopItem)

        menu.addItem(.separator())

        let toggleItem = NSMenuItem(title: "Show Widget", action: #selector(toggleWidget), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit SnapIt", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        menu.delegate = self
        statusItem.menu = menu
    }

    @objc private func captureWindow() {
        captureService.captureWindow()
    }

    @objc private func captureArea() {
        captureService.captureArea()
    }

    @objc private func captureDesktop() {
        captureService.captureDesktop()
    }

    @objc private func toggleWidget() {
        settings.showFloatingWidget.toggle()
        if settings.showFloatingWidget {
            widgetController?.show()
        } else {
            widgetController?.hide()
        }
    }

    @objc private func openSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController(settings: settings, widgetController: widgetController)
        }
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

extension MenuBarController: NSMenuDelegate {
    public func menuWillOpen(_ menu: NSMenu) {
        if let toggleItem = menu.item(withTitle: "Show Widget") ?? menu.item(withTitle: "Hide Widget") {
            toggleItem.title = settings.showFloatingWidget ? "Hide Widget" : "Show Widget"
        }
    }
}
