import SwiftUI
import AppKit

struct CapturePopover: View {
    let captureService: ScreenCaptureService
    let dismissAction: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            Button(action: {
                dismissAction()
                captureService.captureWindow()
            }) {
                Label("Window", systemImage: "macwindow")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)

            Divider()

            Button(action: {
                dismissAction()
                captureService.captureDesktop()
            }) {
                Label("Desktop", systemImage: "desktopcomputer")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .padding(8)
    }
}
