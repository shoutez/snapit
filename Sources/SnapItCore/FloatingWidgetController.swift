import AppKit
import SwiftUI

public final class FloatingWidgetController: NSObject {
    let panel: NSPanel
    let settings: AppSettings
    let captureService: ScreenCaptureService
    private var popover: NSPopover?
    private var overlayPanel: NSPanel?

    public init(settings: AppSettings, captureService: ScreenCaptureService) {
        self.settings = settings
        self.captureService = captureService

        let size: CGFloat = 48
        panel = NSPanel(
            contentRect: NSRect(origin: settings.widgetPosition, size: NSSize(width: size, height: size)),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )

        super.init()

        panel.level = .floating
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.alphaValue = settings.widgetOpacity

        let button = WidgetButton(frame: NSRect(x: 0, y: 0, width: size, height: size))
        button.target = self
        button.action = #selector(widgetClicked(_:))
        panel.contentView = button

        captureService.floatingPanel = panel

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(panelDidMove(_:)),
            name: NSWindow.didMoveNotification,
            object: panel
        )
    }

    public func show() {
        panel.alphaValue = settings.widgetOpacity
        panel.orderFront(nil)
    }

    func hide() {
        panel.orderOut(nil)
    }

    @objc private func widgetClicked(_ sender: NSView) {
        if let popover, popover.isShown {
            dismissPopover()
            return
        }

        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 140, height: 80)
        popover.contentViewController = NSHostingController(
            rootView: CapturePopover(captureService: captureService, dismissAction: { [weak self] in
                self?.dismissPopover()
            })
        )
        popover.show(
            relativeTo: sender.bounds,
            of: sender,
            preferredEdge: .maxY
        )
        self.popover = popover

        showOverlay()
    }

    private func showOverlay() {
        // Create a transparent full-screen panel that catches clicks outside the popover
        let screenFrame = NSScreen.screens.reduce(NSRect.zero) { $0.union($1.frame) }
        let overlay = NSPanel(
            contentRect: screenFrame,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        overlay.level = .floating
        overlay.backgroundColor = .clear
        overlay.isOpaque = false
        overlay.hasShadow = false
        overlay.ignoresMouseEvents = false
        overlay.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]

        let clickView = OverlayClickView(frame: screenFrame)
        clickView.onMouseDown = { [weak self] in
            self?.dismissPopover()
        }
        overlay.contentView = clickView

        overlay.orderFront(nil)
        self.overlayPanel = overlay

        // Ensure the widget's panel and popover stay above the overlay
        panel.orderFront(nil)
    }

    private func dismissPopover() {
        popover?.close()
        popover = nil
        overlayPanel?.orderOut(nil)
        overlayPanel = nil
    }

    @objc private func panelDidMove(_ notification: Notification) {
        settings.widgetPosition = panel.frame.origin
    }
}

private class WidgetButton: NSView {
    var target: AnyObject?
    var action: Selector?

    private var isHovered = false

    override init(frame: NSRect) {
        super.init(frame: frame)
        updateTrackingAreas()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func updateTrackingAreas() {
        trackingAreas.forEach { removeTrackingArea($0) }
        addTrackingArea(NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self
        ))
    }

    override func draw(_ dirtyRect: NSRect) {
        let rect = bounds.insetBy(dx: 2, dy: 2)

        let background = isHovered
            ? NSColor(white: 0.15, alpha: 0.95)
            : NSColor(white: 0.2, alpha: 0.9)
        background.setFill()
        let path = NSBezierPath(roundedRect: rect, xRadius: rect.width / 2, yRadius: rect.height / 2)
        path.fill()

        let config = NSImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        if let image = NSImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: "Capture")?.withSymbolConfiguration(config) {
            let imageSize = image.size
            let origin = NSPoint(
                x: rect.midX - imageSize.width / 2,
                y: rect.midY - imageSize.height / 2
            )
            image.draw(at: origin, from: .zero, operation: .sourceOver, fraction: 1.0)
        }
    }

    override func mouseDown(with event: NSEvent) {
        if let target, let action {
            _ = target.perform(action, with: self)
        }
    }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
        needsDisplay = true
        NSCursor.pointingHand.push()
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
        needsDisplay = true
        NSCursor.pop()
    }
}

private class OverlayClickView: NSView {
    var onMouseDown: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        onMouseDown?()
    }

    override func rightMouseDown(with event: NSEvent) {
        onMouseDown?()
    }
}
