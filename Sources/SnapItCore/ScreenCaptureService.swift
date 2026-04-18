import AppKit

public final class ScreenCaptureService {
    let settings: AppSettings
    weak var floatingPanel: NSPanel?

    public init(settings: AppSettings) {
        self.settings = settings
    }

    func captureWindowArgs() -> [String] {
        settings.includeWindowShadow ? ["-w"] : ["-w", "-o"]
    }

    func captureDesktopArgs() -> [String] {
        []
    }

    func captureAreaArgs() -> [String] {
        ["-s"]
    }

    public func captureWindow() {
        capture(args: captureWindowArgs())
    }

    public func captureDesktop() {
        capture(args: captureDesktopArgs())
    }

    public func captureArea() {
        capture(args: captureAreaArgs())
    }

    private func capture(args: [String]) {
        let panel = floatingPanel
        let wasVisible = panel?.isVisible ?? false

        if wasVisible {
            panel?.orderOut(nil)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            let path = screenshotPath()
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
            process.arguments = args + [path]
            process.terminationHandler = { _ in
                DispatchQueue.main.async {
                    if wasVisible {
                        panel?.orderFront(nil)
                    }
                    if FileManager.default.fileExists(atPath: path) {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(path, forType: .string)
                    }
                }
            }
            do {
                try process.run()
            } catch {
                if wasVisible {
                    panel?.orderFront(nil)
                }
            }
        }
    }

    func screenshotPath() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let timestamp = formatter.string(from: Date())
        return "\(settings.saveLocation)/SnapIt-\(timestamp).png"
    }
}
