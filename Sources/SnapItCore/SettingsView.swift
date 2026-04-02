import SwiftUI
import AppKit

struct SettingsView: View {
    @Bindable var settings: AppSettings
    weak var widgetController: FloatingWidgetController?

    var body: some View {
        Form {
            Section("Widget") {
                Toggle("Show floating widget", isOn: $settings.showFloatingWidget)
                    .onChange(of: settings.showFloatingWidget) { _, newValue in
                        if newValue {
                            widgetController?.show()
                        } else {
                            widgetController?.hide()
                        }
                    }

                HStack {
                    Text("Opacity")
                    Slider(value: $settings.widgetOpacity, in: 0.3...1.0, step: 0.05)
                        .onChange(of: settings.widgetOpacity) { _, newValue in
                            widgetController?.panel.alphaValue = newValue
                        }
                    Text("\(Int(settings.widgetOpacity * 100))%")
                        .frame(width: 40, alignment: .trailing)
                        .monospacedDigit()
                }
            }

            Section("Capture") {
                Toggle("Include window shadow", isOn: $settings.includeWindowShadow)

                HStack {
                    Text("Save to")
                    Text(settings.saveLocation)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Choose...") {
                        chooseFolder()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 380, height: 220)
    }

    private func chooseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.directoryURL = URL(fileURLWithPath: settings.saveLocation)

        if panel.runModal() == .OK, let url = panel.url {
            settings.saveLocation = url.path
        }
    }
}

final class SettingsWindowController: NSWindowController {
    convenience init(settings: AppSettings, widgetController: FloatingWidgetController?) {
        let hostingController = NSHostingController(
            rootView: SettingsView(settings: settings, widgetController: widgetController)
        )

        let window = NSWindow(contentViewController: hostingController)
        window.title = "SnapIt Settings"
        window.styleMask = [.titled, .closable]
        window.center()

        self.init(window: window)
    }
}
