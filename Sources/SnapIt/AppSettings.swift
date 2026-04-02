import Foundation
import AppKit

@Observable
final class AppSettings {
    private let defaults = UserDefaults.standard

    var showFloatingWidget: Bool {
        didSet { defaults.set(showFloatingWidget, forKey: "showFloatingWidget") }
    }

    var saveLocation: String {
        didSet { defaults.set(saveLocation, forKey: "saveLocation") }
    }

    var includeWindowShadow: Bool {
        didSet { defaults.set(includeWindowShadow, forKey: "includeWindowShadow") }
    }

    var widgetOpacity: Double {
        didSet { defaults.set(widgetOpacity, forKey: "widgetOpacity") }
    }

    var widgetPositionX: Double {
        didSet { defaults.set(widgetPositionX, forKey: "widgetPositionX") }
    }

    var widgetPositionY: Double {
        didSet { defaults.set(widgetPositionY, forKey: "widgetPositionY") }
    }

    var widgetPosition: CGPoint {
        get { CGPoint(x: widgetPositionX, y: widgetPositionY) }
        set {
            widgetPositionX = newValue.x
            widgetPositionY = newValue.y
        }
    }

    init() {
        let defaults = UserDefaults.standard

        if defaults.object(forKey: "showFloatingWidget") == nil {
            defaults.set(true, forKey: "showFloatingWidget")
        }
        if defaults.object(forKey: "saveLocation") == nil {
            defaults.set(
                NSHomeDirectory() + "/Desktop", forKey: "saveLocation")
        }
        if defaults.object(forKey: "includeWindowShadow") == nil {
            defaults.set(true, forKey: "includeWindowShadow")
        }
        if defaults.object(forKey: "widgetOpacity") == nil {
            defaults.set(0.85, forKey: "widgetOpacity")
        }
        if defaults.object(forKey: "widgetPositionX") == nil {
            defaults.set(100.0, forKey: "widgetPositionX")
        }
        if defaults.object(forKey: "widgetPositionY") == nil {
            defaults.set(100.0, forKey: "widgetPositionY")
        }

        self.showFloatingWidget = defaults.bool(forKey: "showFloatingWidget")
        self.saveLocation = defaults.string(forKey: "saveLocation") ?? NSHomeDirectory() + "/Desktop"
        self.includeWindowShadow = defaults.bool(forKey: "includeWindowShadow")
        self.widgetOpacity = defaults.double(forKey: "widgetOpacity")
        self.widgetPositionX = defaults.double(forKey: "widgetPositionX")
        self.widgetPositionY = defaults.double(forKey: "widgetPositionY")
    }
}
