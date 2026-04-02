// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "SnapIt",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .target(
            name: "SnapItCore",
            path: "Sources/SnapItCore"
        ),
        .executableTarget(
            name: "SnapIt",
            dependencies: ["SnapItCore"],
            path: "Sources/SnapIt",
            exclude: ["Info.plist", "AppIcon.icns"]
        ),
        .testTarget(
            name: "SnapItTests",
            dependencies: ["SnapItCore"],
            path: "Tests/SnapItTests"
        )
    ]
)
